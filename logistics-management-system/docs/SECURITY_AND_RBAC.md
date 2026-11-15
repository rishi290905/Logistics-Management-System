# Database & Application Security Architecture

## 1. Security Philosophy
Information Management Systems handling supply chain assets, customer personally identifiable information (PII), and financial transactions require rigorous defense-in-depth security. The Logistics Management System enforces security at the **database layer**, **API transport layer**, and **application access layer**.

---

## 2. Password Hashing (Cryptographic Defense)

Passwords are **never stored in plaintext**. The system employs **PBKDF2 (Password-Based Key Derivation Function 2)** with HMAC-SHA512:

$$\text{DerivedKey} = \text{PBKDF2}(\text{PRF}=\text{HMAC-SHA512}, \text{Password}, \text{Salt}, c=10000, \text{dkLen}=64)$$

### Security Safeguards:
1. **Cryptographic Salt**: A unique 16-byte random salt is generated per user via `crypto.randomBytes(16)`. This neutralizes **Rainbow Table** precomputation attacks.
2. **Work Factor (10,000 Iterations)**: Deliberately introduces computational cost to slow down brute-force attacks while remaining imperceptible to legitimate users (~15ms per login).
3. **Constant-Time Comparison**: Hash verification uses `crypto.timingSafeEqual()` to eliminate **timing side-channel attacks**.

---

## 3. Stateless JWT Authentication

Upon successful credential verification, the authentication service issues a signed **JSON Web Token (JWT)**:
* **Header**: `{"alg": "HS256", "typ": "JWT"}`
* **Payload**: `{"id": 1, "username": "admin", "role": "admin", "exp": 1731750000}`
* **Signature**: $\text{HMAC-SHA256}(\text{Base64Url}(\text{Header}) + "." + \text{Base64Url}(\text{Payload}), \text{Secret})$

The token is passed in the HTTP Authorization header (`Authorization: Bearer <token>`), enabling stateless horizontal scaling across load-balanced application instances without sticky session dependencies.

---

## 4. Role-Based Access Control (RBAC) Matrix

| Resource / Action | Admin | Logistics Manager | Fleet Dispatcher | Delivery Agent | Customer |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Manage Users & Roles** | Full Access | No Access | No Access | No Access | No Access |
| **Create / Modify Warehouses** | Full Access | Full Access | No Access | No Access | No Access |
| **Procure / Restock Inventory** | Full Access | Full Access | No Access | No Access | No Access |
| **Manage Catalog Products** | Full Access | Full Access | No Access | No Access | Read Only |
| **Place Orders (ACID Txn)** | Full Access | Full Access | No Access | No Access | Self Orders |
| **Assign Agents & Vehicles** | Full Access | Full Access | Full Access | No Access | No Access |
| **Update Shipment Status / Checkpoints** | Full Access | Full Access | Full Access | Assigned Shipments | No Access |
| **View Tracking Timelines** | Full Access | Full Access | Full Access | Full Access | Self Shipments |
| **Execute Raw SQL / Cypher Consoles** | Full Access | No Access | No Access | No Access | No Access |

Middleware guard implementation:
```javascript
function authorizeRoles(...allowedRoles) {
    return (req, res, next) => {
        if (!allowedRoles.includes(req.user.role) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                error: `Forbidden: Role '${req.user.role}' lacks required permissions.`
            });
        }
        next();
    };
}
```

---

## 5. SQL Injection Prevention

SQL Injection occurs when untrusted user input is directly concatenated into SQL query strings:
* **Vulnerable Pattern (AVOID)**:
  ```javascript
  const sql = "SELECT * FROM users WHERE username = '" + req.body.username + "'";
  ```
* **Defense Implemented (Parameterized Queries)**:
  All database queries utilize **parameterized statements** with placeholders (`$1, $2` in PostgreSQL or `?` in MySQL/SQLite):
  ```javascript
  const sql = "SELECT * FROM users WHERE username = $1";
  await db.query(sql, [req.body.username]);
  ```
  The database query planner treats the parameters strictly as literal data values, completely preventing malicious SQL command injection.

---

## 6. Secure Secrets Management
Database passwords, JWT signing keys, and cloud credentials are never committed to version control. They are loaded exclusively from **`.env`** configuration files at runtime via environment variables:
* `JWT_SECRET`
* `PG_PASSWORD`
* `MONGO_URI`
* `NEO4J_PASSWORD`
* `AWS_SECRET_ACCESS_KEY`
