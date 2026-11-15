// ============================================================================
// NOSQL CONTROLLER (Shipment Timeline, IoT Telemetry, Audit Logs, & Notifications)
// ============================================================================

const nosqlDb = require('../database/nosql_db');

module.exports = {
    /**
     * Get tracking timeline for a specific shipment
     */
    getShipmentTrackingTimeline: (req, res) => {
        const { trackingNumber } = req.params;
        const record = nosqlDb.findOne('shipment_tracking_events', { tracking_number: trackingNumber });
        if (!record) {
            return res.status(404).json({
                success: false,
                error: `No tracking timeline found for tracking code: ${trackingNumber}`
            });
        }
        res.json({ success: true, trackingNumber, data: record });
    },

    /**
     * Add new checkpoint event to a shipment timeline
     */
    addTrackingEvent: (req, res) => {
        const { trackingNumber } = req.params;
        const { status, locationName, city, coordinates, handler, remarks, iotTelemetry } = req.body;

        if (!status || !locationName) {
            return res.status(400).json({ success: false, error: 'Status and locationName are required.' });
        }

        const result = nosqlDb.addTrackingEvent(trackingNumber, {
            status,
            locationName,
            city: city || 'Transit Checkpoint',
            coordinates: coordinates || [77.2, 28.6],
            handler: handler || req.user?.username || 'Field Scanner',
            remarks: remarks || 'Checkpoint passage confirmed',
            iotTelemetry
        });

        res.status(201).json({ success: true, message: 'Tracking event recorded', data: result });
    },

    /**
     * Customer Activity Logs (High-throughput audit records)
     */
    getActivityLogs: (req, res) => {
        const logs = nosqlDb.find('customer_activity_logs');
        res.json({ success: true, count: logs.length, data: logs });
    },

    /**
     * Asynchronous Notifications
     */
    getNotifications: (req, res) => {
        const notifications = nosqlDb.find('notifications');
        res.json({ success: true, count: notifications.length, data: notifications });
    },

    /**
     * Proof of Delivery (POD) & Delivery Remarks
     */
    getDeliveryRemarks: (req, res) => {
        const remarks = nosqlDb.find('delivery_remarks');
        res.json({ success: true, count: remarks.length, data: remarks });
    },

    /**
     * Dynamic Logistics Road Disruptions / Weather Alerts
     */
    getLogisticsEvents: (req, res) => {
        const events = nosqlDb.find('dynamic_logistics_events');
        res.json({ success: true, count: events.length, data: events });
    },

    /**
     * High-level summary of NoSQL analytics
     */
    getNoSQLSummary: (req, res) => {
        const summary = nosqlDb.getTrackingSummary();
        res.json({
            success: true,
            summary,
            academicComparison: {
                relationalLimitation: 'SQL schemas require uniform column definitions and ALTER TABLE operations for polymorphic IoT attributes (e.g., vaccine cold-chain temp vs heavy machinery tilt). High-frequency GPS checkpoint writes create index update contention and lock escalation on relational tables.',
                nosqlAdvantage: 'MongoDB document model stores arbitrary nested sensor telemetry inside an embedded `events` array without schema migrations. BSON documents scale horizontally via range/hash sharding and handle write-heavy append-only event logs with zero lock overhead.'
            }
        });
    }
};
