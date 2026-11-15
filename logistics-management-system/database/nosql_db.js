// ============================================================================
// NOSQL (MONGODB) DATABASE ENGINE & DOCUMENT REPOSITORY
// ============================================================================
// Handles:
// 1. Dynamic polymorphic schemas (temperature logs, vehicle telemetry, exceptions)
// 2. High write throughput for shipment checkpoints and audit logging
// 3. Document embedding (events array nested in tracking documents)
// 4. Aggregation pipelines (timeline grouping, severity filters)
// ============================================================================

const fs = require('fs');
const path = require('path');

class NoSQLDatabaseEngine {
    constructor() {
        this.collections = {
            shipment_tracking_events: [],
            customer_activity_logs: [],
            notifications: [],
            delivery_remarks: [],
            dynamic_logistics_events: []
        };
        this.loadSampleData();
    }

    loadSampleData() {
        try {
            const raw = fs.readFileSync(path.join(__dirname, 'mongo_schemas.json'), 'utf8');
            const data = JSON.parse(raw);
            for (const colName of Object.keys(data.collections)) {
                if (this.collections[colName]) {
                    this.collections[colName] = [...(data.collections[colName].sample_documents || [])];
                }
            }
        } catch (e) {
            console.error('Failed to load mongo sample data:', e.message);
        }
    }

    find(collectionName, query = {}) {
        if (!this.collections[collectionName]) throw new Error(`Collection ${collectionName} does not exist`);
        return this.collections[collectionName].filter(doc => {
            for (const key of Object.keys(query)) {
                if (doc[key] !== query[key]) return false;
            }
            return true;
        });
    }

    findOne(collectionName, query = {}) {
        const results = this.find(collectionName, query);
        return results.length > 0 ? results[0] : null;
    }

    insertOne(collectionName, doc) {
        if (!this.collections[collectionName]) throw new Error(`Collection ${collectionName} does not exist`);
        const newDoc = {
            _id: '673' + Math.random().toString(16).substring(2, 10) + '00' + Math.floor(1000 + Math.random() * 9000),
            ...doc,
            created_at: new Date().toISOString()
        };
        this.collections[collectionName].unshift(newDoc);
        return newDoc;
    }

    updateOne(collectionName, query, updateFields) {
        const doc = this.findOne(collectionName, query);
        if (!doc) return null;
        Object.assign(doc, updateFields, { updated_at: new Date().toISOString() });
        return doc;
    }

    /**
     * Add a real-time tracking event with polymorphic payload
     */
    addTrackingEvent(trackingNumber, { status, locationName, city, coordinates, handler, remarks, iotTelemetry = null }) {
        let doc = this.findOne('shipment_tracking_events', { tracking_number: trackingNumber });
        if (!doc) {
            doc = this.insertOne('shipment_tracking_events', {
                tracking_number: trackingNumber,
                order_number: 'ORD-AUTO',
                current_status: status,
                last_checkpoint: locationName,
                last_updated: new Date().toISOString(),
                events: []
            });
        }

        const newEvent = {
            event_id: `EVT-${Date.now().toString().slice(-5)}`,
            timestamp: new Date().toISOString(),
            status,
            location: {
                name: locationName,
                city,
                coordinates: coordinates || [77.2090, 28.6139]
            },
            handler: handler || 'Automated Transit Scanner',
            remarks: remarks || 'Checkpoint passage logged',
            ...(iotTelemetry ? { iot_telemetry: iotTelemetry } : {})
        };

        doc.events.push(newEvent);
        doc.current_status = status;
        doc.last_checkpoint = locationName;
        doc.last_updated = newEvent.timestamp;

        return { trackingDocument: doc, newEvent };
    }

    /**
     * Audit log creator
     */
    logCustomerActivity(userId, username, action, resource, ipAddress = '127.0.0.1', meta = {}) {
        return this.insertOne('customer_activity_logs', {
            user_id: userId,
            username,
            action,
            resource,
            ip_address: ipAddress,
            user_agent: 'Antigravity Enterprise Web Client',
            timestamp: new Date().toISOString(),
            metadata: meta
        });
    }

    /**
     * Aggregate queries (e.g. status counts, telemetry analysis)
     */
    getTrackingSummary() {
        const statusCounts = {};
        for (const doc of this.collections.shipment_tracking_events) {
            statusCounts[doc.current_status] = (statusCounts[doc.current_status] || 0) + 1;
        }
        return {
            totalTrackedShipments: this.collections.shipment_tracking_events.length,
            statusDistribution: statusCounts,
            activeLogisticsIncidents: this.collections.dynamic_logistics_events.filter(e => e.is_active).length,
            totalAuditLogs: this.collections.customer_activity_logs.length
        };
    }
}

const nosqlDb = new NoSQLDatabaseEngine();
module.exports = nosqlDb;
