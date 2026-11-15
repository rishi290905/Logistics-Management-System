// ============================================================================
// AUTHENTICATION CONTROLLER (User Login, JWT Generation, & RBAC Session)
// ============================================================================

const relationalDb = require('../database/relational_db');
const { verifyPassword, generateToken, hashPassword } = require('../middleware/authMiddleware');
const nosqlDb = require('../database/nosql_db');

module.exports = {
    /**
     * User Login
     */
    login: async (req, res) => {
        const { username, password } = req.body;
        if (!username || !password) {
            return res.status(400).json({ success: false, error: 'Username and password are required' });
        }

        const user = relationalDb.tables.users.find(u => u.username.toLowerCase() === username.toLowerCase());
        if (!user) {
            return res.status(401).json({ success: false, error: 'Invalid username or password' });
        }

        const isValid = verifyPassword(password, user.password_hash);
        if (!isValid) {
            return res.status(401).json({ success: false, error: 'Invalid username or password' });
        }

        const token = generateToken({
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role
        });

        // Audit log in NoSQL
        nosqlDb.logCustomerActivity(user.id, user.username, 'USER_LOGIN_SUCCESS', 'AUTH_SERVICE', req.ip || '127.0.0.1');

        res.json({
            success: true,
            message: `Authentication successful. Logged in as [${user.role.toUpperCase()}]`,
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                role: user.role
            }
        });
    },

    /**
     * Quick Demo Switch Role (Helper for presentation viva)
     */
    switchDemoRole: (req, res) => {
        const { role } = req.body;
        const validRoles = ['admin', 'logistics_manager', 'dispatcher', 'delivery_agent', 'customer'];
        if (!validRoles.includes(role)) {
            return res.status(400).json({ success: false, error: `Invalid role. Choose from: ${validRoles.join(', ')}` });
        }

        const demoUser = relationalDb.tables.users.find(u => u.role === role) || {
            id: 99,
            username: `demo_${role}`,
            email: `${role}@logistics.com`,
            role
        };

        const token = generateToken({
            id: demoUser.id,
            username: demoUser.username,
            email: demoUser.email,
            role: demoUser.role
        });

        res.json({
            success: true,
            message: `Active session switched to ${role}`,
            token,
            user: demoUser
        });
    },

    /**
     * Get Current Authenticated Profile
     */
    getProfile: (req, res) => {
        res.json({ success: true, user: req.user });
    }
};
