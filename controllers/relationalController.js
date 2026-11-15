// ============================================================================
// RELATIONAL CONTROLLER (CRUD, Relational Views, & Cache-Aside Integration)
// ============================================================================

const relationalDb = require('../database/relational_db');
const redisCache = require('../database/redis_cache');
const nosqlDb = require('../database/nosql_db');

module.exports = {
    // ------------------------------------------------------------------------
    // CUSTOMERS
    // ------------------------------------------------------------------------
    getCustomers: async (req, res) => {
        const customers = relationalDb.findAll('customers');
        res.json({ success: true, count: customers.length, data: customers });
    },

    getCustomerById: async (req, res) => {
        const customer = relationalDb.findById('customers', req.params.id);
        if (!customer) return res.status(404).json({ success: false, error: 'Customer not found' });
        res.json({ success: true, data: customer });
    },

    createCustomer: async (req, res) => {
        const { firstName, lastName, companyName, email, phone, addressLine, city, state, postalCode, creditLimit } = req.body;
        if (!firstName || !lastName || !email || !phone) {
            return res.status(400).json({ success: false, error: 'Missing mandatory customer fields' });
        }
        const custCode = `CUST-${String(relationalDb.tables.customers.length + 1).padStart(3, '0')}`;
        const newCust = relationalDb.insert('customers', {
            customer_code: custCode,
            first_name: firstName,
            last_name: lastName,
            company_name: companyName || '',
            email,
            phone,
            address_line: addressLine || 'N/A',
            city: city || 'N/A',
            state: state || 'N/A',
            postal_code: postalCode || 'N/A',
            country: 'India',
            credit_limit: creditLimit ? parseFloat(creditLimit) : 50000.00
        });

        // Audit log in NoSQL
        nosqlDb.logCustomerActivity(req.user?.id || 1, req.user?.username || 'admin', 'CREATE_CUSTOMER', custCode);
        res.status(201).json({ success: true, message: 'Customer registered successfully', data: newCust });
    },

    // ------------------------------------------------------------------------
    // PRODUCTS (With Cache-Aside Demonstration)
    // ------------------------------------------------------------------------
    getProducts: async (req, res) => {
        const cacheKey = 'cache:products:all';
        const start = Date.now();

        // 1. Try Cache Read
        const cached = await redisCache.get(cacheKey);
        if (cached) {
            return res.json({
                success: true,
                source: 'REDIS_CACHE (Cache Hit)',
                latencyMs: +(Date.now() - start).toFixed(2),
                count: cached.length,
                data: cached
            });
        }

        // 2. Cache Miss -> Query Database
        const products = relationalDb.findAll('products').map(p => {
            const supplier = relationalDb.findById('suppliers', p.supplier_id) || {};
            return { ...p, supplier_name: supplier.supplier_name || 'N/A' };
        });

        // 3. Write to Cache with 180s TTL
        await redisCache.set(cacheKey, products, 180);

        res.json({
            success: true,
            source: 'RELATIONAL_DATABASE (Cache Miss -> Populated)',
            latencyMs: +(Date.now() - start + 25).toFixed(2), // Simulate DB I/O latency
            count: products.length,
            data: products
        });
    },

    createProduct: async (req, res) => {
        const { supplierId, sku, productName, category, unitPrice, weightKg, dimensionsCm, minStockLevel, isFragile, requiresTemperatureControl } = req.body;
        if (!sku || !productName || !unitPrice) {
            return res.status(400).json({ success: false, error: 'SKU, name, and unit price are required' });
        }

        const newProd = relationalDb.insert('products', {
            supplier_id: Number(supplierId) || 1,
            sku,
            product_name: productName,
            category: category || 'General',
            unit_price: parseFloat(unitPrice),
            weight_kg: parseFloat(weightKg) || 1.0,
            dimensions_cm: dimensionsCm || '10x10x10',
            min_stock_level: parseInt(minStockLevel, 10) || 10,
            is_fragile: !!isFragile,
            requires_temperature_control: !!requiresTemperatureControl
        });

        // Invalidate Product Cache (Cache Invalidation on Mutation)
        await redisCache.invalidate('cache:products:all');

        res.status(201).json({ success: true, message: 'Product added and Redis cache invalidated', data: newProd });
    },

    // ------------------------------------------------------------------------
    // WAREHOUSES & INVENTORY
    // ------------------------------------------------------------------------
    getWarehouses: async (req, res) => {
        const cacheKey = 'cache:warehouses:all';
        const cached = await redisCache.get(cacheKey);
        if (cached) {
            return res.json({ success: true, source: 'REDIS_CACHE', data: cached });
        }

        const warehouses = relationalDb.findAll('warehouses');
        await redisCache.set(cacheKey, warehouses, 300);
        res.json({ success: true, source: 'DATABASE', data: warehouses });
    },

    getInventory: async (req, res) => {
        const inventory = relationalDb.findAll('inventory').map(inv => {
            const wh = relationalDb.findById('warehouses', inv.warehouse_id) || {};
            const prod = relationalDb.findById('products', inv.product_id) || {};
            return {
                ...inv,
                warehouse_name: wh.warehouse_name,
                warehouse_code: wh.warehouse_code,
                product_name: prod.product_name,
                sku: prod.sku,
                category: prod.category
            };
        });
        res.json({ success: true, count: inventory.length, data: inventory });
    },

    restockInventory: async (req, res) => {
        const { warehouseId, productId, restockQuantity, aisleLocation } = req.body;
        const record = relationalDb.tables.inventory.find(i => i.warehouse_id === Number(warehouseId) && i.product_id === Number(productId));

        if (!record) {
            const newRecord = relationalDb.insert('inventory', {
                warehouse_id: Number(warehouseId),
                product_id: Number(productId),
                quantity_on_hand: Number(restockQuantity),
                quantity_reserved: 0,
                quantity_available: Number(restockQuantity),
                aisle_bin_location: aisleLocation || 'Dock-A',
                last_restocked_at: new Date().toISOString()
            });
            await redisCache.invalidate('cache:inventory:*');
            return res.status(201).json({ success: true, message: 'Inventory initialized', data: newRecord });
        }

        record.quantity_on_hand += Number(restockQuantity);
        record.quantity_available = record.quantity_on_hand - record.quantity_reserved;
        record.last_restocked_at = new Date().toISOString();
        record.updated_at = record.last_restocked_at;

        // Invalidate Inventory Cache
        await redisCache.invalidate('cache:inventory:*');

        res.json({ success: true, message: 'Inventory restocked successfully', data: record });
    },

    // ------------------------------------------------------------------------
    // ORDERS & SHIPMENTS
    // ------------------------------------------------------------------------
    getOrders: async (req, res) => {
        const orders = relationalDb.findAll('orders').map(ord => {
            const customer = relationalDb.findById('customers', ord.customer_id) || {};
            const items = relationalDb.findAll('order_items', i => i.order_id === ord.id);
            const shipment = relationalDb.tables.shipments.find(s => s.order_id === ord.id) || null;
            return {
                ...ord,
                customer_name: `${customer.first_name} ${customer.last_name}`,
                customer_phone: customer.phone,
                item_count: items.length,
                items,
                shipment_tracking: shipment?.tracking_number || null,
                shipment_status: shipment?.shipment_status || 'Unassigned'
            };
        });
        res.json({ success: true, count: orders.length, data: orders });
    },

    getShipments: async (req, res) => {
        const shipments = relationalDb.getView('v_active_shipments');
        res.json({ success: true, count: shipments.length, data: shipments });
    },

    updateShipmentStatus: async (req, res) => {
        const { trackingNumber } = req.params;
        const { newStatus, currentLocation, remarks, latitude, longitude } = req.body;

        const shipment = relationalDb.tables.shipments.find(s => s.tracking_number === trackingNumber);
        if (!shipment) return res.status(404).json({ success: false, error: 'Shipment not found' });

        shipment.shipment_status = newStatus;
        if (currentLocation) shipment.current_location = currentLocation;
        if (newStatus === 'Delivered') shipment.actual_delivery = new Date().toISOString();
        shipment.updated_at = new Date().toISOString();

        // 1. Invalidate Shipment Cache in Redis
        await redisCache.invalidate(`cache:shipment:${trackingNumber}`);

        // 2. Append event to NoSQL Tracking Timeline
        nosqlDb.addTrackingEvent(trackingNumber, {
            status: newStatus,
            locationName: currentLocation || shipment.current_location,
            city: currentLocation ? currentLocation.split(',').pop().trim() : 'En Route',
            coordinates: [latitude || 77.2, longitude || 28.6],
            handler: req.user?.username || 'Agent Dispatcher',
            remarks: remarks || `Status updated to ${newStatus}`
        });

        res.json({ success: true, message: `Shipment ${trackingNumber} updated to ${newStatus}`, data: shipment });
    },

    // ------------------------------------------------------------------------
    // VEHICLES, AGENTS, ROUTES, SUPPLIERS, PAYMENTS
    // ------------------------------------------------------------------------
    getVehicles: async (req, res) => {
        res.json({ success: true, data: relationalDb.findAll('vehicles') });
    },

    getDeliveryAgents: async (req, res) => {
        const agents = relationalDb.findAll('delivery_agents').map(a => {
            const wh = relationalDb.findById('warehouses', a.assigned_warehouse_id) || {};
            const v = relationalDb.findById('vehicles', a.current_vehicle_id) || {};
            return {
                ...a,
                warehouse_name: wh.warehouse_name || 'Unassigned',
                vehicle_number: v.vehicle_number || 'None'
            };
        });
        res.json({ success: true, data: agents });
    },

    getRoutes: async (req, res) => {
        const cacheKey = 'cache:routes:all';
        const cached = await redisCache.get(cacheKey);
        if (cached) return res.json({ success: true, source: 'REDIS_CACHE', data: cached });

        const routes = relationalDb.findAll('routes').map(r => {
            const origin = relationalDb.findById('warehouses', r.origin_warehouse_id) || {};
            return { ...r, origin_warehouse_name: origin.warehouse_name || 'N/A' };
        });

        await redisCache.set(cacheKey, routes, 300);
        res.json({ success: true, source: 'DATABASE', data: routes });
    },

    getSuppliers: async (req, res) => {
        res.json({ success: true, data: relationalDb.findAll('suppliers') });
    },

    getPayments: async (req, res) => {
        const payments = relationalDb.findAll('payments').map(p => {
            const cust = relationalDb.findById('customers', p.customer_id) || {};
            return { ...p, customer_name: `${cust.first_name} ${cust.last_name}` };
        });
        res.json({ success: true, data: payments });
    },

    // ------------------------------------------------------------------------
    // RELATIONAL VIEWS & SQL CONSOLE
    // ------------------------------------------------------------------------
    getViewData: async (req, res) => {
        try {
            const { viewName } = req.params;
            const data = relationalDb.getView(viewName);
            res.json({ success: true, view: viewName, count: data.length, data });
        } catch (e) {
            res.status(404).json({ success: false, error: e.message });
        }
    },

    executeCustomSQL: async (req, res) => {
        const { sql } = req.body;
        if (!sql) return res.status(400).json({ success: false, error: 'SQL query string required' });
        const result = relationalDb.executeSQL(sql);
        res.json(result);
    }
};
