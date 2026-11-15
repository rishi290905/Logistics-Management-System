-- ============================================================================
-- LOGISTICS MANAGEMENT SYSTEM - SAMPLE SEED DATA
-- ============================================================================

-- 1. Insert Users (Password is 'Admin@123' hashed with bcrypt/PBKDF2)
-- Format: PBKDF2:salt:hash (or standard hash for mock auth)
INSERT INTO users (id, username, email, password_hash, role, status) VALUES
(1, 'admin', 'admin@logistics.com', 'pbkdf2$10000$saltsuper123$4a3b2c1d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b', 'admin', 'active'),
(2, 'manager_delhi', 'rajesh.kumar@logistics.com', 'pbkdf2$10000$saltsuper123$4a3b2c1d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b', 'logistics_manager', 'active'),
(3, 'dispatcher_mumbai', 'amit.sharma@logistics.com', 'pbkdf2$10000$saltsuper123$4a3b2c1d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b', 'dispatcher', 'active'),
(4, 'agent_vikram', 'vikram.singh@logistics.com', 'pbkdf2$10000$saltsuper123$4a3b2c1d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b', 'delivery_agent', 'active'),
(5, 'cust_rohit', 'rohit.verma@gmail.com', 'pbkdf2$10000$saltsuper123$4a3b2c1d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b', 'customer', 'active');

-- 2. Insert Suppliers
INSERT INTO suppliers (id, supplier_code, supplier_name, contact_person, email, phone, address, city, country, rating, status) VALUES
(1, 'SUP-001', 'Bharat Electronics Supply Co.', 'Suresh Oberoi', 'contact@bharatelec.in', '+91 98110 23456', 'Plot 45, Okhla Phase III', 'New Delhi', 'India', 4.85, 'active'),
(2, 'SUP-002', 'Tata Auto & Heavy Spares Ltd', 'Pooja Nair', 'procurement@tataspares.com', '+91 98220 87654', 'MIDC Industrial Area Bhosari', 'Pune', 'India', 4.90, 'active'),
(3, 'SUP-003', 'Hindustan Fast Moving Consumer Goods', 'Kavita Das', 'orders@hindustanfmcg.com', '+91 98330 55443', 'Ballygunge Circular Rd', 'Kolkata', 'India', 4.60, 'active'),
(4, 'SUP-004', 'Apex Cold Chain Pharma Labs', 'Dr. Arvind Rao', 'supply@apexcoldchain.com', '+91 98440 99881', 'Peenya Industrial Estate', 'Bengaluru', 'India', 4.95, 'active');

-- 3. Insert Warehouses
INSERT INTO warehouses (id, warehouse_code, warehouse_name, address, city, state, postal_code, latitude, longitude, total_capacity_sqft, available_capacity_sqft, manager_name, contact_phone, status) VALUES
(1, 'WH-DEL-01', 'North Zone Mega Fulfillment Hub', 'Khasra 28/11, Samalkha Near NH-48', 'New Delhi', 'Delhi', '110037', 28.5355, 77.0863, 150000, 48000, 'Rajesh Kumar', '+91 98111 11001', 'operational'),
(2, 'WH-MUM-02', 'West Coast Logistics Terminal', 'Sector 19, Vashi MIDC Logistics Park', 'Navi Mumbai', 'Maharashtra', '400705', 19.0760, 72.9982, 200000, 82000, 'Amit Sharma', '+91 98222 22002', 'operational'),
(3, 'WH-BLR-03', 'South Tech & Express Hub', 'Hosur Road, Electronic City Phase 2', 'Bengaluru', 'Karnataka', '560100', 12.8452, 77.6602, 120000, 39000, 'Deepak Shenoy', '+91 98444 44004', 'operational'),
(4, 'WH-KOL-04', 'East Bengal Distribution Center', 'NH-12, Dankuni Logistics Hub', 'Kolkata', 'West Bengal', '712311', 22.6845, 88.2912, 90000, 31000, 'Anupam Ghosh', '+91 98333 33003', 'operational');

-- 4. Insert Products
INSERT INTO products (id, supplier_id, sku, product_name, category, unit_price, weight_kg, dimensions_cm, min_stock_level, is_fragile, requires_temperature_control) VALUES
(1, 1, 'SKU-ELEC-001', 'Industrial IoT Gateway Router', 'Electronics', 14500.00, 1.80, '25x15x8', 15, TRUE, FALSE),
(2, 1, 'SKU-ELEC-002', 'High-Efficiency Solar Inverter 5kVA', 'Electronics', 38000.00, 22.50, '60x40x25', 5, TRUE, FALSE),
(3, 2, 'SKU-AUTO-001', 'Heavy Duty Brake Disc Assembly', 'Automotive', 4850.00, 8.20, '35x35x10', 25, FALSE, FALSE),
(4, 2, 'SKU-AUTO-002', 'Hydraulic Steering Pump Assembly', 'Automotive', 7200.00, 5.40, '30x20x18', 10, FALSE, FALSE),
(5, 3, 'SKU-FMCG-001', 'Eco Care Detergent Bulk Carton (20kg)', 'FMCG', 2400.00, 20.00, '40x30x30', 50, FALSE, FALSE),
(6, 4, 'SKU-PHRM-001', 'Temperature-Sensitive Vaccine Vial Pack', 'Pharmaceuticals', 62000.00, 3.20, '20x15x12', 8, TRUE, TRUE);

-- 5. Insert Inventory
INSERT INTO inventory (id, warehouse_id, product_id, quantity_on_hand, quantity_reserved, aisle_bin_location, last_restocked_at) VALUES
(1, 1, 1, 140, 20, 'Aisle A-01-B2', '2026-11-01 10:30:00'),
(2, 1, 2, 35, 5, 'Aisle A-03-C1', '2026-11-02 11:15:00'),
(3, 1, 3, 220, 15, 'Aisle B-01-A4', '2026-11-03 09:00:00'),
(4, 2, 3, 180, 10, 'Aisle W-02-B1', '2026-11-04 14:20:00'),
(5, 2, 4, 95, 12, 'Aisle W-04-C3', '2026-11-05 16:45:00'),
(6, 2, 5, 450, 40, 'Aisle W-05-D2', '2026-11-06 08:30:00'),
(7, 3, 1, 80, 8, 'Aisle S-01-A1', '2026-11-07 13:10:00'),
(8, 3, 6, 40, 6, 'Cold-Store CS-01', '2026-11-08 17:00:00'),
(9, 4, 5, 300, 25, 'Aisle E-02-A2', '2026-11-09 10:00:00');

-- 6. Insert Customers
INSERT INTO customers (id, user_id, customer_code, first_name, last_name, company_name, email, phone, address_line, city, state, postal_code, country, credit_limit) VALUES
(1, 5, 'CUST-001', 'Rohit', 'Verma', 'Verma InfraTech Pvt Ltd', 'rohit.verma@gmail.com', '+91 98990 11223', 'Flat 402, Skyline Towers, Sector 62', 'Noida', 'Uttar Pradesh', '201309', 'India', 150000.00),
(2, NULL, 'CUST-002', 'Ananya', 'Deshmukh', 'Sahyadri Automotive Spares', 'ananya.deshmukh@sahyadri.com', '+91 98880 33445', 'Unit 12, Senapati Bapat Road', 'Pune', 'Maharashtra', '411016', 'India', 250000.00),
(3, NULL, 'CUST-003', 'Karthik', 'Swaminathan', 'Nilgiri Retail Networks', 'karthik@nilgiriretail.in', '+91 98770 55667', '44 1st Main, Indiranagar', 'Bengaluru', 'Karnataka', '560038', 'India', 300000.00),
(4, NULL, 'CUST-004', 'Debashish', 'Banerjee', 'Howrah Engineering Works', 'dbanerjee@howraheng.org', '+91 98660 77889', '88 Grand Trunk Road', 'Howrah', 'West Bengal', '711101', 'India', 100000.00);

-- 7. Insert Vehicles
INSERT INTO vehicles (id, vehicle_number, model, vehicle_type, payload_capacity_kg, fuel_type, status, current_city, odometer_km) VALUES
(1, 'DL-01-AB-1234', 'Tata 407 LPT', 'Medium Truck', 3800.00, 'Diesel', 'in_transit', 'New Delhi', 45200),
(2, 'MH-04-CD-5678', 'Ashok Leyland Dost+', 'Small Van', 1500.00, 'CNG', 'available', 'Navi Mumbai', 28100),
(3, 'KA-05-EF-9012', 'BharatBenz 2823R', 'Heavy Trailer', 18000.00, 'Diesel', 'in_transit', 'Bengaluru', 89400),
(4, 'WB-02-GH-3456', 'Mahindra Bolero Maxi Truck', 'Small Van', 1200.00, 'Diesel', 'available', 'Kolkata', 34200),
(5, 'DL-03-IJ-7890', 'Tata Ace EV', 'Electric Two-Wheeler', 600.00, 'Electric', 'available', 'New Delhi', 8900);

-- 8. Insert Delivery Agents
INSERT INTO delivery_agents (id, user_id, agent_code, full_name, phone, license_number, assigned_warehouse_id, current_vehicle_id, status, rating) VALUES
(1, 4, 'AGT-001', 'Vikram Singh', '+91 98119 99881', 'DL-1420180012345', 1, 1, 'on_delivery', 4.92),
(2, NULL, 'AGT-002', 'Ganesh Jadhav', '+91 98229 99882', 'MH-0320190023456', 2, 2, 'available', 4.85),
(3, NULL, 'AGT-003', 'Manoj Kumar Gowda', '+91 98449 99883', 'KA-0120170034567', 3, 3, 'on_delivery', 4.78),
(4, NULL, 'AGT-004', 'Sourav Mukherjee', '+91 98339 99884', 'WB-0220200045678', 4, 4, 'available', 4.88);

-- 9. Insert Routes
INSERT INTO routes (id, route_code, origin_warehouse_id, destination_city, distance_km, estimated_duration_mins, toll_cost, route_type, is_active) VALUES
(1, 'RT-DEL-NOI-01', 1, 'Noida', 42.50, 65, 80.00, 'Highway', TRUE),
(2, 'RT-DEL-GUR-02', 1, 'Gurugram', 18.00, 35, 45.00, 'Expressway', TRUE),
(3, 'RT-DEL-JAI-03', 1, 'Jaipur', 268.00, 310, 420.00, 'Expressway', TRUE),
(4, 'RT-MUM-PUN-01', 2, 'Pune', 148.00, 180, 320.00, 'Expressway', TRUE),
(5, 'RT-MUM-THN-02', 2, 'Thane', 28.00, 45, 60.00, 'Urban Corridor', TRUE),
(6, 'RT-BLR-MYS-01', 3, 'Mysuru', 145.00, 175, 180.00, 'Expressway', TRUE),
(7, 'RT-BLR-CHE-02', 3, 'Chennai', 345.00, 410, 480.00, 'Highway', TRUE),
(8, 'RT-KOL-DGP-01', 4, 'Durgapur', 170.00, 210, 220.00, 'Highway', TRUE);

-- 10. Insert Orders
INSERT INTO orders (id, order_number, customer_id, order_date, total_amount, tax_amount, discount_amount, final_amount, order_status, shipping_address, shipping_city, shipping_postal_code, notes) VALUES
(1, 'ORD-2026-1001', 1, '2026-11-10 09:30:00', 43500.00, 7830.00, 1330.00, 50000.00, 'Dispatched', 'Flat 402, Skyline Towers, Sector 62', 'Noida', '201309', 'Urgent office installation delivery'),
(2, 'ORD-2026-1002', 2, '2026-11-11 11:20:00', 48500.00, 8730.00, 2230.00, 55000.00, 'Confirmed', 'Unit 12, Senapati Bapat Road', 'Pune', '411016', 'Scheduled weekend delivery'),
(3, 'ORD-2026-1003', 3, '2026-11-12 14:15:00', 124000.00, 14880.00, 5000.00, 133880.00, 'Dispatched', '44 1st Main, Indiranagar', 'Bengaluru', '560038', 'Temperature monitor required'),
(4, 'ORD-2026-1004', 4, '2026-11-13 16:00:00', 24000.00, 4320.00, 1000.00, 27320.00, 'Delivered', '88 Grand Trunk Road', 'Howrah', '711101', 'Signature required on arrival');

-- 11. Insert Order Items
INSERT INTO order_items (id, order_id, product_id, warehouse_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 1, 3, 14500.00, 43500.00),
(2, 2, 3, 2, 10, 4850.00, 48500.00),
(3, 3, 6, 3, 2, 62000.00, 124000.00),
(4, 4, 5, 4, 10, 2400.00, 24000.00);

-- 12. Insert Shipments
INSERT INTO shipments (id, tracking_number, order_id, origin_warehouse_id, delivery_agent_id, vehicle_id, route_id, shipment_status, current_location, dispatched_at, estimated_delivery, actual_delivery) VALUES
(1, 'TRK-IN-9812001', 1, 1, 1, 1, 1, 'Out for Delivery', 'Sector 62 Hub, Noida', '2026-11-10 11:00:00', '2026-11-10 17:00:00', NULL),
(2, 'TRK-IN-9812002', 2, 2, 2, 2, 4, 'Manifest Created', 'Origin Warehouse Hub, Navi Mumbai', NULL, '2026-11-16 18:00:00', NULL),
(3, 'TRK-IN-9812003', 3, 3, 3, 3, 6, 'In Transit', 'NH-44 Toll Plaza Checkpoint, Mandya', '2026-11-12 16:00:00', '2026-11-16 12:00:00', NULL),
(4, 'TRK-IN-9812004', 4, 4, 4, 4, 8, 'Delivered', 'Customer Premises, Howrah', '2026-11-13 17:00:00', '2026-11-14 14:00:00', '2026-11-14 13:45:00');

-- 13. Insert Payments
INSERT INTO payments (id, payment_reference, order_id, customer_id, payment_method, amount, payment_status, transaction_timestamp, gateway_auth_code) VALUES
(1, 'PAY-TXN-778901', 1, 1, 'UPI', 50000.00, 'Success', '2026-11-10 09:32:15', 'UPI-AUTH-909281'),
(2, 'PAY-TXN-778902', 2, 2, 'Corporate Billing', 55000.00, 'Success', '2026-11-11 11:21:40', 'CORP-PO-55421'),
(3, 'PAY-TXN-778903', 3, 3, 'Net Banking', 133880.00, 'Success', '2026-11-12 14:18:02', 'HDFC-NETB-44109'),
(4, 'PAY-TXN-778904', 4, 4, 'Credit Card', 27320.00, 'Success', '2026-11-13 16:05:12', 'VISA-AUTH-665123');
