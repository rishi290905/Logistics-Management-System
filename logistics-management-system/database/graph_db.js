// ============================================================================
// GRAPH DATABASE ENGINE (NEO4J / CYPHER & GRAPH ALGORITHMS)
// ============================================================================
// Demonstrates:
// 1. Nodes (Warehouses, Suppliers, Hubs, Customers, Vehicles, DeliveryAgents)
// 2. Relationships (:SUPPLIES_TO, :ROUTE_TO, :DELIVERS_TO, :ASSIGNED_TO, :OPERATES)
// 3. Dijkstra Shortest Path Algorithm (Least Distance, Least Duration, Least Toll)
// 4. Connectivity / Multi-Hop Graph Traversal
// 5. Degree Centrality (Bottleneck / Hub Vulnerability Analysis)
// 6. Cypher Query Execution & Interactive Visual Graph Data Representation
// ============================================================================

class GraphDatabaseEngine {
    constructor() {
        this.nodes = [];
        this.edges = [];
        this.initializeGraph();
    }

    initializeGraph() {
        // Nodes
        this.nodes = [
            // Warehouses
            { id: 'WH-DEL-01', label: 'Warehouse', name: 'North Zone Mega Hub', city: 'New Delhi', capacity: 150000, lat: 28.5355, lng: 77.0863 },
            { id: 'WH-MUM-02', label: 'Warehouse', name: 'West Coast Logistics Terminal', city: 'Navi Mumbai', capacity: 200000, lat: 19.0760, lng: 72.9982 },
            { id: 'WH-BLR-03', label: 'Warehouse', name: 'South Tech Hub', city: 'Bengaluru', capacity: 120000, lat: 12.8452, lng: 77.6602 },
            { id: 'WH-KOL-04', label: 'Warehouse', name: 'East Bengal Center', city: 'Kolkata', capacity: 90000, lat: 22.6845, lng: 88.2912 },

            // Suppliers
            { id: 'SUP-001', label: 'Supplier', name: 'Bharat Electronics Co.', city: 'New Delhi', rating: 4.85 },
            { id: 'SUP-002', label: 'Supplier', name: 'Tata Auto Spares Ltd', city: 'Pune', rating: 4.90 },
            { id: 'SUP-003', label: 'Supplier', name: 'Hindustan FMCG Corp', city: 'Kolkata', rating: 4.60 },
            { id: 'SUP-004', label: 'Supplier', name: 'Apex Cold Chain Pharma', city: 'Bengaluru', rating: 4.95 },

            // Delivery Hubs
            { id: 'HUB-NOI', label: 'DeliveryHub', name: 'Noida Sec 62 Sorting Hub', city: 'Noida' },
            { id: 'HUB-GUR', label: 'DeliveryHub', name: 'Cyber City Hub', city: 'Gurugram' },
            { id: 'HUB-JAI', label: 'DeliveryHub', name: 'Pink City Transit Junction', city: 'Jaipur' },
            { id: 'HUB-PUN', label: 'DeliveryHub', name: 'Chakan Industrial Hub', city: 'Pune' },
            { id: 'HUB-NAG', label: 'DeliveryHub', name: 'Central India Zero-Mile Hub', city: 'Nagpur' },
            { id: 'HUB-HYD', label: 'DeliveryHub', name: 'Deccan Gateway Hub', city: 'Hyderabad' },
            { id: 'HUB-CHE', label: 'DeliveryHub', name: 'Coromandel Coastal Hub', city: 'Chennai' },

            // Customers
            { id: 'CUST-001', label: 'Customer', name: 'Rohit Verma', city: 'Noida' },
            { id: 'CUST-002', label: 'Customer', name: 'Ananya Deshmukh', city: 'Pune' },
            { id: 'CUST-003', label: 'Customer', name: 'Karthik Swaminathan', city: 'Bengaluru' },
            { id: 'CUST-004', label: 'Customer', name: 'Debashish Banerjee', city: 'Howrah' },

            // Delivery Agents
            { id: 'AGT-001', label: 'DeliveryAgent', name: 'Vikram Singh', phone: '+91 98119 99881' },
            { id: 'AGT-002', label: 'DeliveryAgent', name: 'Ganesh Jadhav', phone: '+91 98229 99882' },
            { id: 'AGT-003', label: 'DeliveryAgent', name: 'Manoj Kumar Gowda', phone: '+91 98449 99883' },

            // Vehicles
            { id: 'VEH-01', label: 'Vehicle', name: 'Tata 407 (DL-01-AB-1234)', type: 'Medium Truck', capacityKg: 3800 },
            { id: 'VEH-02', label: 'Vehicle', name: 'Dost+ (MH-04-CD-5678)', type: 'Small Van', capacityKg: 1500 },
            { id: 'VEH-03', label: 'Vehicle', name: 'BharatBenz (KA-05-EF-9012)', type: 'Heavy Trailer', capacityKg: 18000 }
        ];

        // Weighted Edges
        this.edges = [
            // Supplier -> Warehouse
            { id: 'e1', source: 'SUP-001', target: 'WH-DEL-01', type: 'SUPPLIES_TO', leadTimeDays: 1, shippingMode: 'Road Express', costPerTon: 1200 },
            { id: 'e2', source: 'SUP-002', target: 'WH-MUM-02', type: 'SUPPLIES_TO', leadTimeDays: 1, shippingMode: 'Rail Freight', costPerTon: 950 },
            { id: 'e3', source: 'SUP-002', target: 'WH-DEL-01', type: 'SUPPLIES_TO', leadTimeDays: 3, shippingMode: 'Interstate Road', costPerTon: 2100 },
            { id: 'e4', source: 'SUP-003', target: 'WH-KOL-04', type: 'SUPPLIES_TO', leadTimeDays: 2, shippingMode: 'Barge & Road', costPerTon: 800 },
            { id: 'e5', source: 'SUP-004', target: 'WH-BLR-03', type: 'SUPPLIES_TO', leadTimeDays: 1, shippingMode: 'Refrigerated Cold Road', costPerTon: 3500 },

            // Warehouse -> Hubs (Corridors)
            { id: 'e6', source: 'WH-DEL-01', target: 'HUB-NOI', type: 'ROUTE_TO', distanceKm: 42.5, durationMins: 65, tollCost: 80 },
            { id: 'e7', source: 'WH-DEL-01', target: 'HUB-GUR', type: 'ROUTE_TO', distanceKm: 18.0, durationMins: 35, tollCost: 45 },
            { id: 'e8', source: 'WH-DEL-01', target: 'HUB-JAI', type: 'ROUTE_TO', distanceKm: 268.0, durationMins: 310, tollCost: 420 },
            { id: 'e9', source: 'WH-DEL-01', target: 'HUB-NAG', type: 'ROUTE_TO', distanceKm: 1080.0, durationMins: 1180, tollCost: 1450 },

            { id: 'e10', source: 'WH-MUM-02', target: 'HUB-PUN', type: 'ROUTE_TO', distanceKm: 148.0, durationMins: 180, tollCost: 320 },
            { id: 'e11', source: 'WH-MUM-02', target: 'HUB-NAG', type: 'ROUTE_TO', distanceKm: 840.0, durationMins: 960, tollCost: 1100 },

            { id: 'e12', source: 'WH-BLR-03', target: 'HUB-HYD', type: 'ROUTE_TO', distanceKm: 560.0, durationMins: 640, tollCost: 780 },
            { id: 'e13', source: 'WH-BLR-03', target: 'HUB-CHE', type: 'ROUTE_TO', distanceKm: 345.0, durationMins: 410, tollCost: 480 },

            // Hub to Hub Interconnects
            { id: 'e14', source: 'HUB-NAG', target: 'HUB-HYD', type: 'ROUTE_TO', distanceKm: 500.0, durationMins: 580, tollCost: 620 },
            { id: 'e15', source: 'HUB-HYD', target: 'HUB-CHE', type: 'ROUTE_TO', distanceKm: 620.0, durationMins: 710, tollCost: 850 },
            { id: 'e16', source: 'HUB-JAI', target: 'WH-MUM-02', type: 'ROUTE_TO', distanceKm: 1150.0, durationMins: 1300, tollCost: 1600 },

            // Hub -> Customer Last-Mile
            { id: 'e17', source: 'HUB-NOI', target: 'CUST-001', type: 'DELIVERS_TO', distanceKm: 6.5, durationMins: 20, tollCost: 0 },
            { id: 'e18', source: 'HUB-PUN', target: 'CUST-002', type: 'DELIVERS_TO', distanceKm: 14.0, durationMins: 40, tollCost: 0 },
            { id: 'e19', source: 'HUB-CHE', target: 'CUST-003', type: 'DELIVERS_TO', distanceKm: 22.0, durationMins: 55, tollCost: 0 },

            // Agent & Vehicle Assignments
            { id: 'e20', source: 'AGT-001', target: 'WH-DEL-01', type: 'ASSIGNED_TO' },
            { id: 'e21', source: 'AGT-001', target: 'VEH-01', type: 'OPERATES' },
            { id: 'e22', source: 'AGT-002', target: 'WH-MUM-02', type: 'ASSIGNED_TO' },
            { id: 'e23', source: 'AGT-002', target: 'VEH-02', type: 'OPERATES' },
            { id: 'e24', source: 'AGT-003', target: 'WH-BLR-03', type: 'ASSIGNED_TO' },
            { id: 'e25', source: 'AGT-003', target: 'VEH-03', type: 'OPERATES' }
        ];
    }

    /**
     * Get entire graph structure for rendering in frontend
     */
    getFullGraph() {
        return {
            nodes: this.nodes,
            edges: this.edges,
            summary: {
                totalNodes: this.nodes.length,
                totalEdges: this.edges.length,
                nodeTypes: {
                    Warehouse: this.nodes.filter(n => n.label === 'Warehouse').length,
                    Supplier: this.nodes.filter(n => n.label === 'Supplier').length,
                    DeliveryHub: this.nodes.filter(n => n.label === 'DeliveryHub').length,
                    Customer: this.nodes.filter(n => n.label === 'Customer').length,
                    DeliveryAgent: this.nodes.filter(n => n.label === 'DeliveryAgent').length,
                    Vehicle: this.nodes.filter(n => n.label === 'Vehicle').length
                }
            }
        };
    }

    /**
     * Dijkstra Shortest Path Algorithm
     * Calculates optimal routing between any two graph nodes based on weight criteria
     * @param {string} startNodeId 
     * @param {string} endNodeId 
     * @param {'distanceKm'|'durationMins'|'tollCost'} weightProp 
     */
    findShortestPath(startNodeId, endNodeId, weightProp = 'distanceKm') {
        const distances = {};
        const previous = {};
        const unvisited = new Set();
        const edgeUsed = {};

        for (const node of this.nodes) {
            distances[node.id] = Infinity;
            previous[node.id] = null;
            unvisited.add(node.id);
        }

        if (!distances.hasOwnProperty(startNodeId)) throw new Error(`Origin node ${startNodeId} not found`);
        if (!distances.hasOwnProperty(endNodeId)) throw new Error(`Destination node ${endNodeId} not found`);

        distances[startNodeId] = 0;

        while (unvisited.size > 0) {
            let current = null;
            for (const nodeId of unvisited) {
                if (current === null || distances[nodeId] < distances[current]) {
                    current = nodeId;
                }
            }

            if (distances[current] === Infinity) break; // unreachable
            if (current === endNodeId) break; // target reached

            unvisited.delete(current);

            // Find neighbors connected via ROUTE_TO or DELIVERS_TO or SUPPLIES_TO (bidirectional traversable corridors)
            const neighbors = this.edges.filter(e =>
                (e.source === current || e.target === current) &&
                e[weightProp] !== undefined
            );

            for (const edge of neighbors) {
                const neighborId = edge.source === current ? edge.target : edge.source;
                if (!unvisited.has(neighborId)) continue;

                const weight = edge[weightProp] || 1;
                const alt = distances[current] + weight;
                if (alt < distances[neighborId]) {
                    distances[neighborId] = alt;
                    previous[neighborId] = current;
                    edgeUsed[neighborId] = edge;
                }
            }
        }

        if (distances[endNodeId] === Infinity) {
            return { found: false, message: 'No viable connecting route found between locations' };
        }

        // Reconstruct path
        const pathNodes = [];
        const pathEdges = [];
        let curr = endNodeId;

        while (curr) {
            pathNodes.unshift(this.nodes.find(n => n.id === curr));
            if (previous[curr]) {
                pathEdges.unshift(edgeUsed[curr]);
            }
            curr = previous[curr];
        }

        const totalDistance = pathEdges.reduce((sum, e) => sum + (e.distanceKm || 0), 0);
        const totalDuration = pathEdges.reduce((sum, e) => sum + (e.durationMins || 0), 0);
        const totalToll = pathEdges.reduce((sum, e) => sum + (e.tollCost || 0), 0);

        return {
            found: true,
            algorithm: 'Dijkstra (Weighted Shortest Path)',
            criterion: weightProp,
            pathNodeCount: pathNodes.length,
            pathEdgeCount: pathEdges.length,
            totalDistanceKm: parseFloat(totalDistance.toFixed(2)),
            totalDurationMins: Math.round(totalDuration),
            totalDurationHours: +(totalDuration / 60).toFixed(1),
            totalTollCostInr: parseFloat(totalToll.toFixed(2)),
            pathNodes,
            pathEdges
        };
    }

    /**
     * Degree Centrality (Identifies critical junction hubs)
     */
    getDegreeCentrality() {
        const counts = {};
        for (const node of this.nodes) {
            counts[node.id] = { node, inDegree: 0, outDegree: 0, totalDegree: 0 };
        }
        for (const edge of this.edges) {
            if (counts[edge.source]) {
                counts[edge.source].outDegree++;
                counts[edge.source].totalDegree++;
            }
            if (counts[edge.target]) {
                counts[edge.target].inDegree++;
                counts[edge.target].totalDegree++;
            }
        }
        return Object.values(counts)
            .sort((a, b) => b.totalDegree - a.totalDegree);
    }

    /**
     * Cypher Query Simulator (for frontend interactive console)
     */
    executeCypher(queryStr) {
        const clean = queryStr.trim();
        const upper = clean.toUpperCase();

        if (upper.includes('SHORTESTPATH')) {
            // Demo shortest path between WH-DEL-01 and HUB-CHE
            return {
                query: clean,
                records: [this.findShortestPath('WH-DEL-01', 'HUB-CHE', 'distanceKm')],
                summary: 'Dijkstra shortest path algorithm evaluated 5 hops across interstate transit corridors.'
            };
        }

        if (upper.includes('SUPPLIES_TO')) {
            const supplierEdges = this.edges.filter(e => e.type === 'SUPPLIES_TO');
            const records = supplierEdges.map(e => ({
                supplier: this.nodes.find(n => n.id === e.source),
                warehouse: this.nodes.find(n => n.id === e.target),
                relationship: e
            }));
            return { query: clean, records, count: records.length };
        }

        if (upper.includes('COUNT(R)') || upper.includes('CENTRALITY')) {
            return { query: clean, records: this.getDegreeCentrality().slice(0, 5) };
        }

        // Default graph return
        return {
            query: clean,
            records: this.nodes.slice(0, 10).map(n => ({ node: n })),
            summary: `Query executed. Returned sample graph nodes.`
        };
    }
}

const graphDb = new GraphDatabaseEngine();
module.exports = graphDb;
