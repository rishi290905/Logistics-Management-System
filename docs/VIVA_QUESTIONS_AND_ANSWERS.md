# Comprehensive Viva Voce Questions & Answers (College Examination Defense)

This document provides academic, conceptual, and implementation-level model answers for external examiners and college viva boards.

---

## Group 1: Relational Database & Normalization Concepts

### Q1: What is a Relational Database Management System (RDBMS), and why did you choose it for this project?
**Answer:**
An RDBMS manages structured data organized in tables consisting of rows (tuples) and columns (attributes) governed by relational algebra and predicate logic. In our Logistics Management System, RDBMS (PostgreSQL/MySQL) is chosen for critical transactional entities—Customers, Orders, OrderItems, Inventory, Warehouses, Shipments, and Payments—where strict mathematical consistency, primary/foreign key relationships, and ACID guarantees are non-negotiable.

### Q2: Explain the Normalization levels applied to your schema.
**Answer:**
* **1NF (First Normal Form):** Every cell holds a single atomic value. No multi-valued repeating groups (e.g. order item arrays are moved to `order_items`). Each row has a primary key (`id`).
* **2NF (Second Normal Form):** Satisfies 1NF, and all non-key attributes are fully functionally dependent on the entire primary key. In the composite relationship between `warehouse` and `product` in `inventory`, stock quantities depend strictly on the pair, eliminating partial functional dependencies.
* **3NF (Third Normal Form):** Satisfies 2NF and contains no transitive dependencies ($A \rightarrow B, B \rightarrow C$). Supplier details (name, email, city) are stored in `suppliers`, not repeated within `products`. Warehouse city and coordinates are in `warehouses`, not repeated within `shipments`.
* **BCNF (Boyce-Codd Normal Form):** For every functional dependency $X \rightarrow Y$, $X$ is a candidate key (e.g., `sku` determines product attributes; `tracking_number` determines shipment details).

### Q3: What is the purpose of database indexes, and what indexing strategy did you implement?
**Answer:**
An index is an auxiliary data structure (typically a B-Tree or Hash) that speeds up data retrieval operations without scanning every row in a table ($O(\log N)$ instead of $O(N)$ full table scan).
We implemented:
1. **Primary and Unique Indexes:** On `id`, `sku`, `tracking_number`, `order_number`, `email`.
2. **Foreign Key Indexes:** On `orders(customer_id)`, `products(supplier_id)`, and `shipments(delivery_agent_id)` to speed up `JOIN` performance.
3. **Composite Index:** `inventory(warehouse_id, product_id)` to speed up inventory concurrency locks during order placement.
4. **Temporal Filter Index:** `orders(created_at DESC)` to optimize real-time dashboard pagination.

### Q4: What is the difference between a Relational View and a Stored Procedure?
**Answer:**
* A **View** (e.g., `v_active_shipments`) is a saved `SELECT` query treated as a virtual table. It abstracts complex multi-table `JOIN`s, provides security by hiding sensitive internal IDs, and does not store duplicated data on disk.
* A **Stored Procedure** is a precompiled collection of procedural SQL statements containing control-flow logic (`IF/ELSE`, loops, exception handlers, and explicit `BEGIN TRANSACTION / COMMIT / ROLLBACK`). It executes directly inside the database engine, reducing network round-trips.

---

## Group 2: NoSQL Database Concepts (MongoDB)

### Q5: Why is MongoDB preferable to SQL for shipment tracking and IoT telemetry?
**Answer:**
Shipment tracking involves **high write velocity** and **polymorphic semi-structured events**.
1. **Schema Polymorphism:** A vaccine shipment logs temperature and humidity; heavy machinery logs tilt and vibration; standard parcels log only GPS coordinates. In SQL, this requires either many empty `NULL` columns or frequent schema alterations (`ALTER TABLE`). In MongoDB, each document or embedded event dynamically includes only relevant fields.
2. **Single Disk Read:** In MongoDB, the entire checkpoint timeline is embedded inside the `events: [...]` array within the shipment document. Fetching the timeline requires a single indexed lookup without multi-table relational joins.
3. **Write Throughput:** MongoDB's WiredTiger storage engine supports high-throughput, append-only document updates without heavy relational constraint locking.

### Q6: What is the difference between Embedding and Referencing in MongoDB?
**Answer:**
* **Embedding (Denormalization):** Subdocuments are stored directly inside the parent document (e.g., `events` inside `shipment_tracking_events`). Ideal for 1-to-Few relationships where data is queried together and rarely updated independently.
* **Referencing (Normalization):** Documents in different collections reference each other using `_id` (similar to foreign keys). Ideal for 1-to-Many or Many-to-Many relationships where child documents grow unboundedly or must be queried from multiple contexts (e.g., linking `user_id` in audit logs to `users`).

---

## Group 3: Graph Database Concepts (Neo4j)

### Q7: What is Index-Free Adjacency in Graph Databases?
**Answer:**
In a traditional relational database, determining if Table A is connected to Table B requires querying a global B-Tree index on a foreign key table ($O(\log N)$).
In Neo4j, **Index-Free Adjacency** means each node physically stores direct memory pointers to its adjacent relationships and neighboring nodes on disk. Traversing an edge requires dereferencing a pointer ($O(1)$ per edge), allowing complex multi-hop pathfinding whose speed depends only on the traversed subgraph size, not the total database size.

### Q8: How did you implement Dijkstra's Shortest Path algorithm for route optimization?
**Answer:**
Dijkstra's algorithm finds the path with minimum total weight between an origin node (e.g., Delhi Warehouse `WH-DEL-01`) and destination hub (e.g., Chennai Hub `HUB-CHE`).
Using a priority queue, the algorithm iteratively visits unvisited nodes with the smallest tentative distance, relaxing adjacent edge weights:
$$\text{dist}(v) = \min(\text{dist}(v), \text{dist}(u) + \text{weight}(u, v))$$
Our system allows optimizing across three distinct criteria: **Distance (km)**, **Transit Duration (mins)**, or **Highway Toll Cost (INR)**.

### Q9: What is Degree Centrality, and how does it help logistics planners?
**Answer:**
Degree Centrality measures the total number of direct edges (routes) connected to a node ($C_D(v) = \text{deg}(v)$). In logistics network analysis, identifying hubs with high degree centrality (such as the Central India Hub in Nagpur) reveals the most critical cross-docking bottlenecks. If that hub experiences a strike or flood, planners know it will disrupt the largest number of connected transit corridors.

---

## Group 4: Caching Concepts (Redis)

### Q10: Explain the Cache-Aside (Lazy Loading) pattern.
**Answer:**
1. The application first checks Redis for the requested key (`cache:products:all`).
2. If found (**Cache Hit**), data is returned immediately to the client in **< 2ms**.
3. If not found (**Cache Miss**), the application queries the relational database, stores the retrieved result in Redis with an expiration TTL, and returns the response.
4. When database records are modified (`INSERT/UPDATE`), the corresponding cache key is proactively invalidated to ensure future reads fetch fresh data.

### Q11: What is Cache Eviction, and what happens when Redis runs out of memory?
**Answer:**
When Redis memory reaches its configured `maxmemory` limit, an eviction policy decides which keys to remove. Our system configures **`volatile-lru`** (Least Recently Used among keys with a TTL set). This ensures actively read keys stay in RAM while stale, unreferenced keys are evicted automatically.

---

## Group 5: Transaction Management & ACID Properties

### Q12: Walk through the 6-step Order Placement transaction and explain how ACID is guaranteed.
**Answer:**
1. **Begin Transaction:** Sets isolation level to Serializable/Repeatable Read and acquires row-level locks on inventory via `SELECT ... FOR UPDATE`.
2. **Stock Verification:** Confirms `quantity_available >= requested_qty`. If insufficient, triggers `ROLLBACK`.
3. **Insert Order Header:** Generates `order_number` and totals.
4. **Insert Order Items:** Links SKUs, quantities, and prices.
5. **Update Inventory:** Increments `quantity_reserved` and decrements `quantity_available`.
6. **Generate Shipment:** Creates tracking number and dispatch bay status.
7. **Authorize Payment:** Records gateway auth code and reference.
8. **Commit Transaction:** Writes transaction records to Write-Ahead Log (WAL), releases row locks, and invalidates Redis product/inventory caches.
If any step fails, **Atomicity** guarantees the entire set of mutations is rolled back cleanly.

### Q13: What are Dirty Reads, Non-Repeatable Reads, and Phantom Reads?
**Answer:**
* **Dirty Read:** Transaction A reads uncommitted modifications made by Transaction B. If B aborts, A has operated on invalid data. Prevented in **Read Committed** and higher.
* **Non-Repeatable Read:** Transaction A reads a row. Transaction B updates or deletes that row and commits. Transaction A re-reads the row and sees different values. Prevented in **Repeatable Read** and higher.
* **Phantom Read:** Transaction A executes a range query (e.g. `WHERE price < 500`). Transaction B inserts a new row matching that predicate and commits. Transaction A re-executes the query and sees a new "phantom" row. Prevented in **Serializable** isolation.

---

## Group 6: Security & RBAC

### Q14: Why must passwords never be stored using MD5 or SHA-256 directly?
**Answer:**
Fast hashing algorithms like plain MD5 or SHA-256 are vulnerable to modern GPU hardware (billions of hashes computed per second) and precomputed lookup tables (**Rainbow Tables**).
Instead, password storage requires:
1. **Cryptographic Salt:** A unique random string prepended to the password, ensuring two identical passwords produce completely distinct hashes.
2. **Key Stretching:** Algorithms like **PBKDF2**, **bcrypt**, or **Argon2** that run thousands of iterations (e.g., 10,000 rounds of HMAC-SHA512), making offline brute-force attacks computationally infeasible.

### Q15: How does your system prevent SQL Injection?
**Answer:**
SQL Injection happens when user input is concatenated into query strings, allowing attackers to manipulate SQL command structure. We prevent this by strictly using **parameterized queries** with placeholders (`$1, $2` or `?`). The database query parser compiles the query structure first and treats the parameters strictly as literal scalar data, rendering SQL syntax manipulation impossible.

---

## Group 7: Cloud Architecture & Deployment

### Q16: How is your cloud architecture optimized for student projects?
**Answer:**
Enterprise cloud setups often incur steep monthly charges. Our architecture utilizes **AWS Free Tier** (RDS PostgreSQL `db.t4g.micro`, 750 free compute hours/month, 5GB S3 storage) paired with **MongoDB Atlas M0 Free Cluster** and **Neo4j AuraDB Free Tier**. This achieves a realistic, production-grade multi-database deployment at **$0.00/month**.
