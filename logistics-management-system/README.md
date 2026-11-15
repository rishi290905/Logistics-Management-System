# Logistics Management System (LogistiCore)
### Database-Centric Information Management System (DBMS Final Project)

---

## 1. Project Overview & Concept

The **Logistics Management System (LogistiCore)** is an enterprise-grade Information Management System engineered to demonstrate **ten essential database concepts** within a unified supply chain platform:
1. **Relational Database** (PostgreSQL / MySQL)
2. **NoSQL Database** (MongoDB)
3. **Graph Database** (Neo4j)
4. **Caching Layer** (Redis)
5. **ACID Transaction Management**
6. **Database Security & RBAC**
7. **Database Normalization (1NF - 3NF / BCNF)**
8. **Performance Indexing Strategy**
9. **Relational Views & Stored Procedures**
10. **Cloud Database & Storage Architecture (AWS)**

---

## 2. Technology Stack & Database Paradigm Mapping

| Technology | Database Paradigm | What It Does in System | Why It Is Used | Database Concept Demonstrated |
| :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL / MySQL** | Relational Database (RDBMS) | Manages 11 transactional entities: Customers, Products, Warehouses, Inventory, Orders, OrderItems, Shipments, Delivery Agents, Vehicles, Routes, Payments. | Ensures mathematical consistency, foreign key cascades, and check constraints. | **ACID Transactions, Schema Normalization, Relational Algebra, B-Tree Indexes**. |
| **MongoDB** | Document NoSQL | Manages time-series shipment tracking checkpoints, driver notes, polymorphic IoT sensor telemetry, and audit logs. | Eliminates rigid schema migrations; embedded subdocuments enable single disk reads. | **Polymorphic Schemas, Horizontal Sharding, BSON Aggregation Pipelines**. |
| **Neo4j** | Graph Database | Models warehouses, regional hubs, suppliers, and customer nodes connected via weighted transit corridors. | Calculates shortest paths across corridors without exponential SQL recursive JOIN costs. | **Graph Theory, Dijkstra Shortest Path, Degree Centrality, Index-Free Adjacency**. |
| **Redis** | In-Memory Cache | Caches product catalogs, active inventory levels, shipment statuses, and pre-calculated routes. | Reduces read query latency from ~45ms to ~1.2ms; eliminates DB connection pool starvation. | **Cache-Aside Pattern, TTL Expiration, Write-Busting Invalidation, RAM vs Disk Benchmark**. |
| **Node.js (v20+)** | Application Server | Serves REST API endpoints, transaction coordination, and static frontend dashboard. | Asynchronous non-blocking event-driven I/O. | **REST API Architecture, Connection Pooling, Concurrency Isolation**. |
| **Amazon Web Services (AWS)** | Cloud Infrastructure | Production architecture: RDS PostgreSQL, S3 Proof of Delivery buckets, DocumentDB/Atlas, and ECS compute. | Provides automated Multi-AZ failover, Point-in-Time Recovery (PITR), and scalable cloud storage. | **Cloud Database Services, High Availability, Disaster Recovery, S3 Lifecycle Rules**. |

---

## 3. Project Directory Structure

```
logistics-management-system/
├── package.json                    # Project configuration and npm scripts
├── .env.example                    # Environment variable template
├── .env                            # Active configuration (JWT, ports, credentials)
├── server.js                       # Modular REST API server & static asset host
│
├── database/
│   ├── schema.sql                  # PostgreSQL/MySQL DDL with 13 tables, keys, constraints & views
│   ├── seed.sql                    # Production test seed data for all entities
│   ├── mongo_schemas.json          # MongoDB BSON schemas, indexes & sample documents
│   ├── neo4j_queries.cypher        # Neo4j node/edge creation script & Cypher algorithms
│   ├── relational_db.js            # Relational database engine & ACID transaction runner
│   ├── nosql_db.js                 # MongoDB document engine with telemetry tracker
│   ├── graph_db.js                 # Neo4j graph engine & Dijkstra shortest path solver
│   └── redis_cache.js              # Redis cache manager with TTL and hit/miss telemetry
│
├── controllers/
│   ├── authController.js           # Authentication, PBKDF2 password verification, JWT issuance
│   ├── relationalController.js     # CRUD for 11 entities, Views, and custom SQL console
│   ├── transactionController.js    # Multi-step ACID Order Placement & rollback demonstrator
│   ├── nosqlController.js          # Shipment timeline, IoT events, audit logs, notifications
│   ├── graphController.js          # Graph topology, Dijkstra pathfinder, Cypher execution
│   └── cacheController.js          # Cache stats, key invalidator, and latency benchmark
│
├── middleware/
│   └── authMiddleware.js           # PBKDF2 hashing, JWT verification, and RBAC guard
│
├── public/
│   ├── index.html                  # Responsive 8-tab Single Page Application dashboard
│   ├── styles.css                  # Modern Tailwind-inspired enterprise CSS
│   └── app.js                      # UI logic, canvas graph renderer, transaction trace animator
│
└── docs/
    ├── DATABASE_DESIGN_AND_ERD.md  # Detailed ER diagram, BCNF proof & indexing strategy
    ├── NOSQL_DESIGN.md             # Why NoSQL for tracking, MongoDB schema design
    ├── GRAPH_DATABASE_NEO4J.md     # Graph topology, Dijkstra algorithm, Cypher queries
    ├── REDIS_CACHING_GUIDE.md      # Cache-Aside pattern, TTL, benchmark comparison
    ├── TRANSACTION_MANAGEMENT_ACID.md # ACID deep dive, isolation levels, rollback trace
    ├── SECURITY_AND_RBAC.md        # Cryptographic hashing, JWT, RBAC matrix, SQLi prevention
    ├── CLOUD_DEPLOYMENT_AWS.md     # AWS production architecture & student tier guide
    └── VIVA_QUESTIONS_AND_ANSWERS.md # 25+ academic viva defense questions and model answers
```

---

## 4. Quickstart Guide (Local Execution)

### Prerequisites
* **Node.js**: v18.0.0 or higher.
* No external database installations are strictly required to demonstrate the full application—an intelligent multi-model engine is built-in with zero configuration! (Real PostgreSQL, MongoDB, Neo4j, and Redis instances can also be connected via `.env`).

### Step 1: Clone or Open Directory
```powershell
cd "C:\Users\Rishi Raj Singh\.gemini\antigravity\scratch\logistics-management-system"
```

### Step 2: Start Application
```powershell
node server.js
```

### Step 3: Open in Browser
Open your web browser and navigate to:
```
http://localhost:5000
```

---

## 5. Walkthrough of Dashboard Features for Viva Presentation

When presenting the project to professors or external examiners, demonstrate the tabs in this sequence:

### 1. Executive Overview Tab
* **KPI Metrics**: Active shipments, lifetime revenue (INR), active warehouses, and Redis cache hit ratio.
* **SQL View**: Live active shipments rendered directly from `v_active_shipments`.
* **NoSQL Alert Feed**: Dynamic road disruptions and weather incidents from MongoDB.
* **Role Switcher**: Use top-right dropdown to demonstrate **Role-Based Access Control (RBAC)** across `Admin`, `Logistics Manager`, `Dispatcher`, `Delivery Agent`, and `Customer`.

### 2. Relational Database Tab
* Browse through all **11 entities** (Customers, Products, Warehouses, Inventory, Orders, Shipments, Agents, Vehicles, Routes, Suppliers, Payments).
* Open the **Interactive SQL Console**:
  * Execute `SELECT * FROM v_warehouse_stock_alerts` to demonstrate stock health indicators.
  * Run custom `JOIN` queries between `products` and `suppliers`.
* Highlight table constraints: `CHECK (available_capacity <= total_capacity)`, `CHECK (credit_limit >= 0)`.

### 3. ACID Transaction Simulator Tab
* **Normal Execution**: Place an order for 2 units. Observe the live 8-step execution trace:
  1. `BEGIN TRANSACTION` (Row lock acquired).
  2. Inventory stock checked.
  3. Order header inserted.
  4. Order items attached.
  5. Inventory decremented.
  6. Shipment waybill created.
  7. Payment authorized.
  8. `COMMIT TRANSACTION`.
* **Rollback Demonstration**: Select "Simulate Insufficient Stock" or "Simulate Payment Gateway Failure".
  * Click **Execute ACID Transaction**.
  * Observe the immediate **`ROLLBACK TRANSACTION`**, leaving inventory and orders completely untouched.

### 4. NoSQL & Tracking (MongoDB) Tab
* Enter tracking code `TRK-IN-9812003` (Cold-Chain Vaccine Consignment).
* Inspect the embedded polymorphic IoT telemetry: Cargo temperature ($-18.2^\circ\text{C}$), ambient temperature, compressor state.
* Use the **Add Checkpoint** form to append a new live event and view the updated raw BSON document.

### 5. Graph Database & Routing (Neo4j) Tab
* **Interactive Canvas**: Drag and inspect the national logistics network (Warehouses, Hubs, Suppliers, Customers).
* **Dijkstra Shortest Path**: Select origin (Delhi `WH-DEL-01`) and destination (Chennai `HUB-CHE`).
* Choose optimization criteria: **Distance (km)**, **Transit Duration (mins)**, or **Highway Toll Cost (INR)**.
* Click **Compute Shortest Path** to see step-by-step corridor checkpoints and total distance (~2,200 km).
* Execute sample Cypher queries in the Cypher console.

### 6. Caching Layer (Redis) Tab
* View live **Cache Hits**, **Misses**, and active keys with **real-time TTL seconds countdown**.
* Click **Evict / Invalidate** on a key to demonstrate write-busting cache invalidation.
* Click **Run Test** on the Latency Benchmark Simulator:
  * Executes 50 sequential reads against Relational DB vs Redis RAM.
  * Shows **~38x speedup** and **~97% latency reduction**.

### 7. Cloud Architecture (AWS) & Viva Defense Tabs
* Review the production AWS architecture blueprint (ECS Fargate, RDS Multi-AZ, S3, ElastiCache).
* Review the interactive **25+ Viva Examination Questions & Answers**.

---

## 6. REST API Endpoint Reference

| Method | Endpoint | Description | Auth Role Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Authenticate user & issue JWT token | Public |
| `POST` | `/api/auth/switch-role` | Demo role switcher helper | Public |
| `GET` | `/api/customers` | Retrieve all registered customers | Any Authenticated |
| `POST` | `/api/customers` | Register a new customer | Admin, Manager |
| `GET` | `/api/products` | Retrieve catalog (Cache-Aside enabled) | Any Authenticated |
| `POST` | `/api/products` | Add new product SKU (Invalidates cache) | Admin, Manager |
| `GET` | `/api/inventory` | Retrieve warehouse stock levels | Any Authenticated |
| `POST` | `/api/inventory/restock` | Restock warehouse inventory | Admin, Manager |
| `GET` | `/api/orders` | Retrieve order headers & line items | Any Authenticated |
| `GET` | `/api/shipments` | Retrieve active shipments view | Any Authenticated |
| `PUT` | `/api/shipments/:trk/status` | Update shipment status (Invalidates cache & appends NoSQL) | Dispatcher, Agent, Admin |
| `POST` | `/api/transactions/order` | Execute multi-step ACID Order Transaction | Customer, Manager, Admin |
| `GET` | `/api/nosql/tracking/:trk` | Retrieve NoSQL shipment tracking timeline | Any Authenticated |
| `POST` | `/api/nosql/tracking/:trk/event` | Append live checkpoint with IoT telemetry | Dispatcher, Agent, Admin |
| `GET` | `/api/graph/network` | Retrieve full graph topology nodes & edges | Any Authenticated |
| `GET` | `/api/graph/shortest-path` | Execute Dijkstra shortest path calculation | Any Authenticated |
| `POST` | `/api/graph/cypher` | Execute Cypher query simulation | Admin |
| `GET` | `/api/cache/stats` | Retrieve Redis hits, misses & active TTL keys | Any Authenticated |
| `POST` | `/api/cache/invalidate` | Manually evict key pattern from Redis | Admin, Manager |
| `GET` | `/api/cache/benchmark` | Run 50-iteration DB vs RAM benchmark | Any Authenticated |
"# Logistics-Management-System" 
"# Logistics-Management-System" 
"# Logistics-Management-System" 
