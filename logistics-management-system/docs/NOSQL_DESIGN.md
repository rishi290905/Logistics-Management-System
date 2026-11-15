# NoSQL Database Architecture (MongoDB)

## 1. Why NoSQL for Logistics Telemetry & Event History?

In a modern enterprise logistics ecosystem, certain workloads are ill-suited for rigid relational schemas. The Logistics Management System utilizes **MongoDB** for flexible, semi-structured, and write-heavy data streams.

---

## 2. Comparative Analysis: Relational (RDBMS) vs NoSQL (Document Model)

| Evaluation Metric | Relational Database (PostgreSQL / MySQL) | Document NoSQL (MongoDB) | Architectural Justification in LMS |
| :--- | :--- | :--- | :--- |
| **Schema Flexibility** | Rigid tabular DDL. Modifying columns requires `ALTER TABLE` locks. | Polymorphic BSON documents. Fields vary across documents without downtime. | Cold-chain cargo logs temperature/humidity; hazardous freight logs tilt/shock; regular freight logs GPS. NoSQL accommodates all without sparse NULL columns. |
| **Write Throughput** | Heavy overhead: row locks, transaction logs, and foreign key validations. | Append-optimized, low-latency writes to in-memory buffers (WiredTiger). | Telemetry trackers emit GPS checkpoints every 15-30 seconds across thousands of vehicles simultaneously. |
| **Data Hierarchy** | Requires multiple tables (`shipment_events`, `event_telemetry`) with 1:N JOINs. | Embedded array (`events: [...]`) stored within a single cohesive document. | A complete tracking timeline is retrieved in **a single disk read** (`findOne`) without multi-table JOIN latency. |
| **Horizontal Scalability** | Vertical scaling (bigger CPU/RAM) or complex master-slave read replica configs. | Native horizontal sharding across commodity clusters by shard key (`tracking_number`). | Historical tracking logs grow into millions of records; sharding partitions storage seamlessly. |

---

## 3. MongoDB Collection Schemas

### 3.1 `shipment_tracking_events` Collection
Stores full chronological checkpoint timelines for consignments.
```json
{
  "_id": "6735a1f2c901e4001a880003",
  "tracking_number": "TRK-IN-9812003",
  "order_number": "ORD-2026-1003",
  "current_status": "In Transit",
  "last_checkpoint": "NH-44 Toll Plaza Checkpoint, Mandya",
  "last_updated": "2026-11-12T18:30:00.000Z",
  "special_handling": "Cold-Chain Certified Pharma",
  "events": [
    {
      "event_id": "EVT-3001-1",
      "timestamp": "2026-11-12T14:30:00.000Z",
      "status": "Manifest Created",
      "location": {
        "name": "Electronic City Cold Storage Hub",
        "city": "Bengaluru",
        "coordinates": [77.6602, 12.8452]
      },
      "handler": "Deepak Shenoy",
      "remarks": "Insulated cryogenic container sealed. Temp verified at -18.4°C."
    },
    {
      "event_id": "EVT-3001-2",
      "timestamp": "2026-11-12T18:30:00.000Z",
      "status": "In Transit",
      "location": {
        "name": "NH-44 Toll Plaza Checkpoint",
        "city": "Mandya",
        "coordinates": [76.8958, 12.5244]
      },
      "handler": "Agent Manoj Kumar Gowda",
      "remarks": "Highway checkpoint passage recorded.",
      "iot_telemetry": {
        "cargo_temperature_celsius": -18.2,
        "ambient_temperature_celsius": 29.5,
        "refrigeration_compressor_state": "ACTIVE",
        "battery_backup_pct": 98,
        "door_sensor_state": "LOCKED"
      }
    }
  ]
}
```

### 3.2 `customer_activity_logs` Collection
Audit trails capturing user interactions, session metadata, and compliance events.
* **Fields**: `_id`, `user_id`, `username`, `action`, `resource`, `ip_address`, `user_agent`, `timestamp`, `duration_ms`, `query_parameters`.
* **Index**: `{ user_id: 1, timestamp: -1 }` (allows instantaneous retrieval of recent customer activity).

### 3.3 `delivery_remarks` & Proof of Delivery (POD)
Captures delivery confirmation signatures, photos, and feedback.
* **Fields**: `tracking_number`, `agent_id`, `recipient_name`, `delivery_timestamp`, `recipient_signature_base64`, `proof_of_delivery_s3_url`, `customer_feedback: { rating, comments }`.

### 3.4 `dynamic_logistics_events` Collection
Real-time unexpected disruptions (weather delays, highway blockages, landslides).
* **Fields**: `event_type`, `severity`, `affected_route_codes`, `location_name`, `coordinates`, `delay_estimate_mins`, `recommended_detour`, `is_active`.

---

## 4. Indexing & Aggregation Pipelines

### Indexing Strategy:
1. `{ "tracking_number": 1 }` - Unique index for instantaneous shipment tracking lookup ($O(1)$).
2. `{ "events.timestamp": -1 }` - Multikey index on embedded array elements for sorting events.
3. `{ "events.location.coordinates": "2dsphere" }` - Geospatial index for radius and distance queries (`$nearSphere`).

### Sample Aggregation Pipeline (Active Incident Delays by Region):
```javascript
db.dynamic_logistics_events.aggregate([
  { $match: { is_active: true } },
  { $group: {
      _id: "$severity",
      totalIncidents: { $sum: 1 },
      avgDelayMins: { $avg: "$delay_estimate_mins" },
      affectedRoutes: { $addToSet: "$affected_route_codes" }
  }},
  { $sort: { avgDelayMins: -1 } }
]);
```
