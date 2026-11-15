// ============================================================================
// GRAPH CONTROLLER (Neo4j / Graph Theory, Routing & Cypher Analytics)
// ============================================================================

const graphDb = require('../database/graph_db');

module.exports = {
    /**
     * Complete network graph structure for canvas visualization
     */
    getNetworkGraph: (req, res) => {
        const graphData = graphDb.getFullGraph();
        res.json({ success: true, ...graphData });
    },

    /**
     * Dijkstra Shortest Path Finder between any two nodes
     */
    findShortestPath: (req, res) => {
        const { from, to, criteria } = req.query;
        if (!from || !to) {
            return res.status(400).json({
                success: false,
                error: "Both 'from' (origin node code) and 'to' (destination node code) are required."
            });
        }

        try {
            const weightProp = criteria === 'duration' ? 'durationMins' : criteria === 'toll' ? 'tollCost' : 'distanceKm';
            const result = graphDb.findShortestPath(from, to, weightProp);
            res.json({ success: true, ...result });
        } catch (e) {
            res.status(404).json({ success: false, error: e.message });
        }
    },

    /**
     * Degree Centrality (Identifies critical junctions and bottlenecks)
     */
    getDegreeCentrality: (req, res) => {
        const centrality = graphDb.getDegreeCentrality();
        res.json({ success: true, count: centrality.length, data: centrality });
    },

    /**
     * Cypher Query Execution Simulator
     */
    executeCypher: (req, res) => {
        const { cypher } = req.body;
        if (!cypher) {
            return res.status(400).json({ success: false, error: 'Cypher query string is required.' });
        }
        const result = graphDb.executeCypher(cypher);
        res.json({ success: true, ...result });
    }
};
