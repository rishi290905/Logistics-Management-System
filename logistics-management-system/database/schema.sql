-- ============================================================================
-- LOGISTICS MANAGEMENT SYSTEM - RELATIONAL DATABASE SCHEMA (PostgreSQL / MySQL)
-- ============================================================================
-- Academic Focus: Normalization (1NF, 2NF, 3NF, BCNF), Primary & Foreign Keys,
-- Integrity Constraints (CHECK, UNIQUE, NOT NULL), Indexing, Views, & Stored Procedures.
-- ============================================================================

-- Drop tables in reverse foreign-key dependency order if re-initializing
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS delivery_agents CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS routes CASCADE;
DROP TABLE IF EXISTS warehouses CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- 1. USERS & RBAC TABLE
-- ============================================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'customer' 
        CHECK (role IN ('admin', 'logistics_manager', 'dispatcher', 'delivery_agent', 'customer')),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. CUSTOMERS TABLE (1:1 with User or Standalone Account)
-- ============================================================================
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    customer_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    company_name VARCHAR(100),
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(60) NOT NULL DEFAULT 'India',
    credit_limit DECIMAL(12, 2) DEFAULT 50000.00 CHECK (credit_limit >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. SUPPLIERS TABLE
-- ============================================================================
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20) NOT NULL UNIQUE,
    supplier_name VARCHAR(120) NOT NULL,
    contact_person VARCHAR(80) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(60) NOT NULL,
    country VARCHAR(60) NOT NULL DEFAULT 'India',
    rating DECIMAL(3, 2) DEFAULT 4.50 CHECK (rating BETWEEN 0.00 AND 5.00),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. WAREHOUSES TABLE
-- ============================================================================
CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    warehouse_code VARCHAR(20) NOT NULL UNIQUE,
    warehouse_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    total_capacity_sqft INT NOT NULL CHECK (total_capacity_sqft > 0),
    available_capacity_sqft INT NOT NULL CHECK (available_capacity_sqft >= 0),
    manager_name VARCHAR(80) NOT NULL,
    contact_phone VARCHAR(25) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'operational' CHECK (status IN ('operational', 'maintenance', 'closed')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_capacity CHECK (available_capacity_sqft <= total_capacity_sqft)
);

-- ============================================================================
-- 5. PRODUCTS TABLE
-- ============================================================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(id) ON DELETE RESTRICT,
    sku VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(60) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    weight_kg DECIMAL(8, 2) NOT NULL CHECK (weight_kg > 0),
    dimensions_cm VARCHAR(50), -- e.g. "30x20x15"
    min_stock_level INT NOT NULL DEFAULT 10 CHECK (min_stock_level >= 0),
    is_fragile BOOLEAN DEFAULT FALSE,
    requires_temperature_control BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. INVENTORY TABLE (Many-to-Many Bridge between Warehouse and Product)
-- ============================================================================
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INT NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_available INT GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    aisle_bin_location VARCHAR(30),
    last_restocked_at TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_warehouse_product UNIQUE (warehouse_id, product_id),
    CONSTRAINT chk_reserved CHECK (quantity_reserved <= quantity_on_hand)
);

-- ============================================================================
-- 7. VEHICLES TABLE
-- ============================================================================
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    model VARCHAR(60) NOT NULL,
    vehicle_type VARCHAR(40) NOT NULL CHECK (vehicle_type IN ('Small Van', 'Medium Truck', 'Heavy Trailer', 'Refrigerated Truck', 'Electric Two-Wheeler')),
    payload_capacity_kg DECIMAL(10, 2) NOT NULL CHECK (payload_capacity_kg > 0),
    fuel_type VARCHAR(30) NOT NULL DEFAULT 'Diesel' CHECK (fuel_type IN ('Diesel', 'Petrol', 'Electric', 'CNG')),
    status VARCHAR(30) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'in_transit', 'maintenance', 'retired')),
    current_city VARCHAR(60) NOT NULL,
    odometer_km INT DEFAULT 0 CHECK (odometer_km >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 8. DELIVERY AGENTS TABLE
-- ============================================================================
CREATE TABLE delivery_agents (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    agent_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(80) NOT NULL,
    phone VARCHAR(25) NOT NULL UNIQUE,
    license_number VARCHAR(40) NOT NULL UNIQUE,
    assigned_warehouse_id INT REFERENCES warehouses(id) ON DELETE SET NULL,
    current_vehicle_id INT REFERENCES vehicles(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'assigned', 'on_delivery', 'off_duty')),
    rating DECIMAL(3, 2) DEFAULT 4.80 CHECK (rating BETWEEN 0.00 AND 5.00),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 9. ROUTES TABLE
-- ============================================================================
CREATE TABLE routes (
    id SERIAL PRIMARY KEY,
    route_code VARCHAR(30) NOT NULL UNIQUE,
    origin_warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    destination_city VARCHAR(60) NOT NULL,
    distance_km DECIMAL(8, 2) NOT NULL CHECK (distance_km > 0),
    estimated_duration_mins INT NOT NULL CHECK (estimated_duration_mins > 0),
    toll_cost DECIMAL(8, 2) DEFAULT 0.00 CHECK (toll_cost >= 0),
    route_type VARCHAR(30) DEFAULT 'Highway' CHECK (route_type IN ('Highway', 'Expressway', 'Urban Corridor', 'Rural Bypass')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 10. ORDERS TABLE
-- ============================================================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    tax_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    final_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (final_amount >= 0),
    order_status VARCHAR(30) NOT NULL DEFAULT 'Pending' 
        CHECK (order_status IN ('Pending', 'Processing', 'Confirmed', 'Dispatched', 'Delivered', 'Cancelled')),
    shipping_address VARCHAR(255) NOT NULL,
    shipping_city VARCHAR(60) NOT NULL,
    shipping_postal_code VARCHAR(20) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 11. ORDER ITEMS TABLE (Bridge: Order <-> Product)
-- ============================================================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(12, 2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

-- ============================================================================
-- 12. SHIPMENTS TABLE
-- ============================================================================
CREATE TABLE shipments (
    id SERIAL PRIMARY KEY,
    tracking_number VARCHAR(40) NOT NULL UNIQUE,
    order_id INT NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
    origin_warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    delivery_agent_id INT REFERENCES delivery_agents(id) ON DELETE SET NULL,
    vehicle_id INT REFERENCES vehicles(id) ON DELETE SET NULL,
    route_id INT REFERENCES routes(id) ON DELETE SET NULL,
    shipment_status VARCHAR(30) NOT NULL DEFAULT 'Manifest Created'
        CHECK (shipment_status IN ('Manifest Created', 'Picked Up', 'In Transit', 'Out for Delivery', 'Delivered', 'Failed Attempt', 'Returned')),
    current_location VARCHAR(100) NOT NULL DEFAULT 'Origin Warehouse Hub',
    dispatched_at TIMESTAMP,
    estimated_delivery TIMESTAMP NOT NULL,
    actual_delivery TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 13. PAYMENTS TABLE
-- ============================================================================
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    payment_reference VARCHAR(40) NOT NULL UNIQUE,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    customer_id INT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('Credit Card', 'UPI', 'Net Banking', 'Cash On Delivery', 'Corporate Billing')),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Success' CHECK (payment_status IN ('Pending', 'Success', 'Failed', 'Refunded')),
    transaction_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gateway_auth_code VARCHAR(80),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 14. PERFORMANCE INDEXING STRATEGY
-- ============================================================================
-- B-Tree indexes for frequent JOINs, foreign keys, and query WHERE filters
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_inventory_lookup ON inventory(warehouse_id, product_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_shipments_tracking ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(shipment_status);
CREATE INDEX idx_shipments_agent ON shipments(delivery_agent_id);
CREATE INDEX idx_routes_origin_dest ON routes(origin_warehouse_id, destination_city);
CREATE INDEX idx_payments_order ON payments(order_id);

-- ============================================================================
-- 15. RELATIONAL VIEWS (For reporting and aggregated query abstraction)
-- ============================================================================

-- View 1: Active Shipments Tracking Summary
CREATE OR REPLACE VIEW v_active_shipments AS
SELECT 
    s.id AS shipment_id,
    s.tracking_number,
    o.order_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.phone AS customer_phone,
    w.warehouse_name AS origin_warehouse,
    s.shipment_status,
    s.current_location,
    da.full_name AS assigned_agent,
    da.phone AS agent_phone,
    v.vehicle_number,
    v.vehicle_type,
    s.estimated_delivery
FROM shipments s
JOIN orders o ON s.order_id = o.id
JOIN customers c ON o.customer_id = c.id
JOIN warehouses w ON s.origin_warehouse_id = w.id
LEFT JOIN delivery_agents da ON s.delivery_agent_id = da.id
LEFT JOIN vehicles v ON s.vehicle_id = v.id;

-- View 2: Warehouse Stock Alert View (Identifies Low Stock)
CREATE OR REPLACE VIEW v_warehouse_stock_alerts AS
SELECT 
    w.id AS warehouse_id,
    w.warehouse_code,
    w.warehouse_name,
    p.id AS product_id,
    p.sku,
    p.product_name,
    p.category,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.quantity_available,
    p.min_stock_level,
    CASE 
        WHEN i.quantity_available <= 0 THEN 'OUT_OF_STOCK'
        WHEN i.quantity_available <= p.min_stock_level THEN 'CRITICAL_LOW'
        ELSE 'ADEQUATE'
    END AS stock_health_status
FROM inventory i
JOIN warehouses w ON i.warehouse_id = w.id
JOIN products p ON i.product_id = p.id;

-- View 3: Customer Revenue and Order Summary
CREATE OR REPLACE VIEW v_customer_order_analytics AS
SELECT 
    c.id AS customer_id,
    c.customer_code,
    c.first_name || ' ' || c.last_name AS full_name,
    c.city,
    COUNT(o.id) AS total_orders_placed,
    COALESCE(SUM(o.final_amount), 0.00) AS total_lifetime_spent,
    MAX(o.order_date) AS latest_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.customer_code, c.first_name, c.last_name, c.city;
