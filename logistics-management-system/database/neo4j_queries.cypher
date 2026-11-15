// ============================================================================
// LOGISTICS MANAGEMENT SYSTEM - NEO4J GRAPH DATABASE SCHEMA & CYPHER QUERIES
// ============================================================================
// Focus: Nodes, Relationships, Properties, Pathfinding, Supply Chain Topologies,
// and Graph Algorithms (Dijkstra Shortest Path, Degree Centrality).
// ============================================================================

// 1. CREATE UNIQUE CONSTRAINTS (Ensures integrity and fast index lookups)
CREATE CONSTRAINT c_warehouse_code IF NOT EXISTS FOR (w:Warehouse) REQUIRE w.code IS UNIQUE;
CREATE CONSTRAINT c_supplier_code IF NOT EXISTS FOR (s:Supplier) REQUIRE s.code IS UNIQUE;
CREATE CONSTRAINT c_customer_code IF NOT EXISTS FOR (c:Customer) REQUIRE c.code IS UNIQUE;
CREATE CONSTRAINT c_hub_code IF NOT EXISTS FOR (h:DeliveryHub) REQUIRE h.code IS UNIQUE;
CREATE CONSTRAINT c_vehicle_number IF NOT EXISTS FOR (v:Vehicle) REQUIRE v.vehicle_number IS UNIQUE;
CREATE CONSTRAINT c_agent_code IF NOT EXISTS FOR (a:DeliveryAgent) REQUIRE a.code IS UNIQUE;

// 2. CREATE NODES

// Warehouses
CREATE (wDel:Warehouse {code: 'WH-DEL-01', name: 'North Zone Mega Hub', city: 'New Delhi', capacity_sqft: 150000, lat: 28.5355, lng: 77.0863})
CREATE (wMum:Warehouse {code: 'WH-MUM-02', name: 'West Coast Logistics Terminal', city: 'Navi Mumbai', capacity_sqft: 200000, lat: 19.0760, lng: 72.9982})
CREATE (wBlr:Warehouse {code: 'WH-BLR-03', name: 'South Tech Hub', city: 'Bengaluru', capacity_sqft: 120000, lat: 12.8452, lng: 77.6602})
CREATE (wKol:Warehouse {code: 'WH-KOL-04', name: 'East Bengal Center', city: 'Kolkata', capacity_sqft: 90000, lat: 22.6845, lng: 88.2912})

// Suppliers
CREATE (supElec:Supplier {code: 'SUP-001', name: 'Bharat Electronics Co.', city: 'New Delhi', rating: 4.85})
CREATE (supAuto:Supplier {code: 'SUP-002', name: 'Tata Auto Spares Ltd', city: 'Pune', rating: 4.90})
CREATE (supFmcg:Supplier {code: 'SUP-003', name: 'Hindustan FMCG Corp', city: 'Kolkata', rating: 4.60})
CREATE (supPhrm:Supplier {code: 'SUP-004', name: 'Apex Cold Chain Pharma', city: 'Bengaluru', rating: 4.95})

// Intermediate Transit & Delivery Hubs
CREATE (hubNoida:DeliveryHub {code: 'HUB-NOI', name: 'Noida Sector 62 Sorting Hub', city: 'Noida'})
CREATE (hubGurgaon:DeliveryHub {code: 'HUB-GUR', name: 'Cyber City Hub', city: 'Gurugram'})
CREATE (hubJaipur:DeliveryHub {code: 'HUB-JAI', name: 'Pink City Transit Junction', city: 'Jaipur'})
CREATE (hubPune:DeliveryHub {code: 'HUB-PUN', name: 'Chakan Industrial Distribution Hub', city: 'Pune'})
CREATE (hubNagpur:DeliveryHub {code: 'HUB-NAG', name: 'Central India Zero-Mile Mega Hub', city: 'Nagpur'})
CREATE (hubHyd:DeliveryHub {code: 'HUB-HYD', name: 'Deccan Gateway Hub', city: 'Hyderabad'})
CREATE (hubChennai:DeliveryHub {code: 'HUB-CHE', name: 'Coromandel Coastal Hub', city: 'Chennai'})

// Customers
CREATE (c1:Customer {code: 'CUST-001', name: 'Rohit Verma', city: 'Noida', address: 'Skyline Towers, Sec 62'})
CREATE (c2:Customer {code: 'CUST-002', name: 'Ananya Deshmukh', city: 'Pune', address: 'Senapati Bapat Road'})
CREATE (c3:Customer {code: 'CUST-003', name: 'Karthik Swaminathan', city: 'Bengaluru', address: 'Indiranagar'})
CREATE (c4:Customer {code: 'CUST-004', name: 'Debashish Banerjee', city: 'Howrah', address: 'Grand Trunk Road'})

// Vehicles & Delivery Agents
CREATE (v1:Vehicle {vehicle_number: 'DL-01-AB-1234', type: 'Medium Truck', capacity_kg: 3800})
CREATE (v2:Vehicle {vehicle_number: 'MH-04-CD-5678', type: 'Small Van', capacity_kg: 1500})
CREATE (v3:Vehicle {vehicle_number: 'KA-05-EF-9012', type: 'Heavy Trailer', capacity_kg: 18000})

CREATE (a1:DeliveryAgent {code: 'AGT-001', name: 'Vikram Singh', phone: '+91 98119 99881'})
CREATE (a2:DeliveryAgent {code: 'AGT-002', name: 'Ganesh Jadhav', phone: '+91 98229 99882'})
CREATE (a3:DeliveryAgent {code: 'AGT-003', name: 'Manoj Kumar Gowda', phone: '+91 98449 99883');

// 3. CREATE RELATIONSHIPS (EDGES WITH WEIGHTS)

// Supplier -> Warehouse [:SUPPLIES_TO]
CREATE (supElec)-[:SUPPLIES_TO {lead_time_days: 1, shipping_mode: 'Road Express', cost_per_ton: 1200}]->(wDel)
CREATE (supAuto)-[:SUPPLIES_TO {lead_time_days: 1, shipping_mode: 'Rail Freight', cost_per_ton: 950}]->(wMum)
CREATE (supPhrm)-[:SUPPLIES_TO {lead_time_days: 1, shipping_mode: 'Refrigerated Road', cost_per_ton: 3500}]->(wBlr)
CREATE (supFmcg)-[:SUPPLIES_TO {lead_time_days: 2, shipping_mode: 'Barge & Road', cost_per_ton: 800}]->(wKol)
CREATE (supAuto)-[:SUPPLIES_TO {lead_time_days: 3, shipping_mode: 'Interstate Road', cost_per_ton: 2100}]->(wDel);

// Warehouse <-> Hub Connections [:ROUTE_TO]
CREATE (wDel)-[:ROUTE_TO {distance_km: 42, avg_time_mins: 65, toll_cost: 80, quality: 'A+'}]->(hubNoida)
CREATE (wDel)-[:ROUTE_TO {distance_km: 18, avg_time_mins: 35, toll_cost: 45, quality: 'A'}]->(hubGurgaon)
CREATE (wDel)-[:ROUTE_TO {distance_km: 268, avg_time_mins: 310, toll_cost: 420, quality: 'A+'}]->(hubJaipur)
CREATE (wDel)-[:ROUTE_TO {distance_km: 1080, avg_time_mins: 1180, toll_cost: 1450, quality: 'A'}]->(hubNagpur)

CREATE (wMum)-[:ROUTE_TO {distance_km: 148, avg_time_mins: 180, toll_cost: 320, quality: 'A+'}]->(hubPune)
CREATE (wMum)-[:ROUTE_TO {distance_km: 840, avg_time_mins: 960, toll_cost: 1100, quality: 'A'}]->(hubNagpur)

CREATE (wBlr)-[:ROUTE_TO {distance_km: 560, avg_time_mins: 640, toll_cost: 780, quality: 'A'}]->(hubHyd)
CREATE (wBlr)-[:ROUTE_TO {distance_km: 345, avg_time_mins: 410, toll_cost: 480, quality: 'A+'}]->(hubChennai)

// Hub-to-Hub Inter-Corridor Network [:ROUTE_TO]
CREATE (hubNagpur)-[:ROUTE_TO {distance_km: 500, avg_time_mins: 580, toll_cost: 620, quality: 'A'}]->(hubHyd)
CREATE (hubHyd)-[:ROUTE_TO {distance_km: 620, avg_time_mins: 710, toll_cost: 850, quality: 'A+'}]->(hubChennai)
CREATE (hubJaipur)-[:ROUTE_TO {distance_km: 1150, avg_time_mins: 1300, toll_cost: 1600, quality: 'B+'}]->(wMum)

// Hub -> Customer Last-Mile [:DELIVERS_TO]
CREATE (hubNoida)-[:DELIVERS_TO {last_mile_km: 6.5, est_time_mins: 20}]->(c1)
CREATE (hubPune)-[:DELIVERS_TO {last_mile_km: 14.0, est_time_mins: 40}]->(c2)
CREATE (hubChennai)-[:DELIVERS_TO {last_mile_km: 22.0, est_time_mins: 55}]->(c3)

// Agent, Vehicle, Warehouse Assignments
CREATE (a1)-[:ASSIGNED_TO]->(wDel)
CREATE (a1)-[:OPERATES]->(v1)
CREATE (a2)-[:ASSIGNED_TO]->(wMum)
CREATE (a2)-[:OPERATES]->(v2)
CREATE (a3)-[:ASSIGNED_TO]->(wBlr)
CREATE (a3)-[:OPERATES]->(v3);

// ============================================================================
// 4. SAMPLE CYPHER QUERIES FOR DEMONSTRATION & VIVA
// ============================================================================

// Query 1: Find all suppliers delivering to North Zone Warehouse (Delhi)
// MATCH (s:Supplier)-[r:SUPPLIES_TO]->(w:Warehouse {code: 'WH-DEL-01'})
// RETURN s.name, s.rating, r.lead_time_days, r.shipping_mode, r.cost_per_ton;

// Query 2: Find all delivery routes originating from a warehouse
// MATCH (w:Warehouse {code: 'WH-DEL-01'})-[r:ROUTE_TO]->(h:DeliveryHub)
// RETURN w.name AS Origin, h.name AS Destination, r.distance_km AS Distance, r.avg_time_mins AS Duration;

// Query 3: Shortest Path between North Zone Mega Hub (Delhi) and Deccan Gateway Hub (Hyderabad)
// MATCH p = shortestPath((origin:Warehouse {code: 'WH-DEL-01'})-[:ROUTE_TO*]-(dest:DeliveryHub {code: 'HUB-HYD'}))
// RETURN p, length(p) AS hops, [n IN nodes(p) | n.name] AS route_cities;

// Query 4: Multi-criteria Route Analysis (Total Distance and Toll Calculation)
// MATCH path = (w:Warehouse {code: 'WH-DEL-01'})-[:ROUTE_TO*1..4]->(h:DeliveryHub {code: 'HUB-CHE'})
// RETURN [node IN nodes(path) | node.name] AS checkpoints,
//        REDUCE(dist = 0, rel IN relationships(path) | dist + rel.distance_km) AS total_distance_km,
//        REDUCE(toll = 0, rel IN relationships(path) | toll + rel.toll_cost) AS total_toll_inr
// ORDER BY total_distance_km ASC
// LIMIT 3;

// Query 5: Full End-to-End Supply Chain Traceability (Supplier -> Warehouse -> Hub -> Customer)
// MATCH (s:Supplier)-[:SUPPLIES_TO]->(w:Warehouse)-[:ROUTE_TO]->(h:DeliveryHub)-[:DELIVERS_TO]->(c:Customer)
// RETURN s.name AS Supplier, w.name AS Warehouse, h.name AS DispatchHub, c.name AS Customer;

// Query 6: Hub Centrality (Identifying the Most Connected Hub in the Logistics Grid)
// MATCH (h:DeliveryHub)-[r:ROUTE_TO]-()
// RETURN h.name AS HubName, COUNT(r) AS ConnectedCorridors
// ORDER BY ConnectedCorridors DESC;
