// ============================================================================
// TRANSACTION CONTROLLER (ACID Order Placement Workflow & Rollback Simulation)
// ============================================================================
// Focus:
// 1. Atomicity: All 6 operations succeed or ALL are rolled back completely.
// 2. Consistency: Inventory cannot fall below 0, credit/payment invariants upheld.
// 3. Isolation: Row-level lock (SERIALIZABLE) prevents race conditions.
// 4. Durability: Changes committed to disk log; uncommitted changes discarded.
// ============================================================================

const relationalDb = require('../database/relational_db');
const redisCache = require('../database/redis_cache');
const nosqlDb = require('../database/nosql_db');

module.exports = {
    /**
     * Executes multi-step ACID Order Placement Transaction
     */
    executeOrderPlacement: async (req, res) => {
        const {
            customerId,
            warehouseId,
            productId,
            quantity,
            shippingAddress,
            shippingCity,
            shippingPostalCode,
            paymentMethod,
            simulateFailure
        } = req.body;

        if (!customerId || !warehouseId || !productId || !quantity) {
            return res.status(400).json({
                success: false,
                error: 'Mandatory transaction parameters missing: customerId, warehouseId, productId, and quantity are required.'
            });
        }

        const result = await relationalDb.executeOrderTransaction({
            customerId: Number(customerId),
            warehouseId: Number(warehouseId),
            productId: Number(productId),
            quantity: Number(quantity),
            shippingAddress,
            shippingCity,
            shippingPostalCode,
            paymentMethod: paymentMethod || 'UPI',
            simulateFailure: simulateFailure || null
        });

        // If committed successfully:
        if (result.success) {
            // 1. Invalidate caches
            await redisCache.invalidate('cache:products:*');
            await redisCache.invalidate('cache:inventory:*');

            // 2. Record initial NoSQL tracking timeline
            if (result.data.shipment) {
                nosqlDb.addTrackingEvent(result.data.shipment.tracking_number, {
                    status: 'Manifest Created',
                    locationName: 'Warehouse Dispatch Bay',
                    city: shippingCity || 'Dispatch Hub',
                    coordinates: [77.2, 28.6],
                    handler: 'Automated ACID Transaction Engine',
                    remarks: `Order #${result.data.order.order_number} confirmed. Payment ${result.data.payment.payment_reference} cleared.`
                });
            }

            // 3. Audit log in MongoDB
            nosqlDb.logCustomerActivity(
                req.user?.id || 1,
                req.user?.username || 'admin',
                'ORDER_ACID_COMMIT',
                result.data.order.order_number,
                req.ip || '127.0.0.1',
                { finalAmount: result.data.order.final_amount, steps: result.trace.length }
            );

            return res.status(201).json(result);
        } else {
            // Transaction was rolled back
            nosqlDb.logCustomerActivity(
                req.user?.id || 1,
                req.user?.username || 'admin',
                'ORDER_ACID_ROLLBACK',
                'FAILED_ATTEMPT',
                req.ip || '127.0.0.1',
                { reason: result.error, simulateFailure }
            );

            return res.status(409).json(result);
        }
    },

    /**
     * Returns academic explanation of ACID properties and isolation levels
     */
    getAcidExplanation: (req, res) => {
        res.json({
            success: true,
            concept: 'ACID Transaction Management in Database Systems',
            properties: {
                Atomicity: 'All or Nothing. Either all 6 operations (Order, Items, Inventory Lock, Stock Reduction, Shipment, Payment) succeed or the entire transaction is rolled back leaving the database untouched.',
                Consistency: 'Preserves database integrity invariants. Check constraints like `quantity_available >= 0` and foreign key relationships are strictly maintained.',
                Isolation: 'Ensures concurrent transactions execute without interference. Using Serializable or Repeatable Read isolation levels prevents dirty reads, non-repeatable reads, and phantom reads.',
                Durability: 'Once COMMIT is acknowledged, changes are permanently written to persistent storage (Write-Ahead Logging / WAL) surviving power outages or crashes.'
            },
            isolationLevels: [
                { level: 'Read Uncommitted', dirtyRead: true, nonRepeatableRead: true, phantomRead: true },
                { level: 'Read Committed', dirtyRead: false, nonRepeatableRead: true, phantomRead: true },
                { level: 'Repeatable Read', dirtyRead: false, nonRepeatableRead: false, phantomRead: true },
                { level: 'Serializable', dirtyRead: false, nonRepeatableRead: false, phantomRead: false }
            ]
        });
    }
};
