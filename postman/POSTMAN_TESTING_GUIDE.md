# Postman Testing Guide - Redis Session Management API

## 📥 Import the Collection

### Method 1: Import from File
1. Open Postman Desktop or Web
2. Click **Import** button (top left)
3. Click **Upload Files**
4. Select `Redis-Session-Management-API.postman_collection.json`
5. Click **Import**

### Method 2: Import from Repository
1. Clone or download the repository
2. In Postman, click **Import**
3. Drag and drop the collection file
4. Collection will appear in the left sidebar

---

## 🚀 Quick Start Testing

### Step 1: Verify Services are Running

```powershell
# Check if all services are healthy
docker-compose ps
```

Expected: All services should show "Up" and "healthy" status

### Step 2: Test Basic Endpoints

Open Postman and follow this sequence:

#### Test 1: Health Check
- Request: `GET http://localhost:8080/api/health`
- Expected Response:
```json
{
  "service": "api-gateway",
  "redis": "UP",
  "status": "UP"
}
```

---

## 📝 Full Test Scenarios

### Scenario 1: Complete Session Lifecycle

#### 1️⃣ Create Session (Login)
**Request:**
```
POST http://localhost:8080/api/session/login
Content-Type: application/json

{
  "username": "john.doe",
  "password": "secret123"
}
```

**Expected Response (200 OK):**
```json
{
  "sessionId": "abc123-def456-...",
  "userId": "john.doe",
  "message": "Login successful"
}
```

**What Happens:**
- Session created in Redis
- Cookie `SESSION` is set automatically
- Session timeout: 30 minutes

#### 2️⃣ Get Session Info
**Request:**
```
GET http://localhost:8080/api/session/info
```

**Expected Response (200 OK):**
```json
{
  "sessionId": "abc123-def456-...",
  "userId": "john.doe",
  "loginTime": 1708327200000,
  "role": "USER",
  "maxInactiveInterval": 1800,
  "creationTime": 1708327200000,
  "lastAccessedTime": 1708327215000
}
```

**Note:** Cookie is sent automatically by Postman

#### 3️⃣ Set Custom Attribute
**Request:**
```
PUT http://localhost:8080/api/session/attribute?key=theme&value=dark
```

**Expected Response (200 OK):**
```json
{
  "message": "Attribute set successfully",
  "key": "theme",
  "value": "dark"
}
```

#### 4️⃣ Get Custom Attribute
**Request:**
```
GET http://localhost:8080/api/session/attribute/theme
```

**Expected Response (200 OK):**
```json
{
  "key": "theme",
  "value": "dark"
}
```

#### 5️⃣ Check Active Sessions
**Request:**
```
GET http://localhost:8080/api/session/count
```

**Expected Response (200 OK):**
```json
{
  "activeSessionCount": 1
}
```

#### 6️⃣ Logout
**Request:**
```
POST http://localhost:8080/api/session/logout
```

**Expected Response (200 OK):**
```json
{
  "message": "Logout successful",
  "sessionId": "abc123-def456-..."
}
```

**What Happens:**
- Session invalidated in Redis
- Session key deleted from Redis
- Cookie cleared

---

### Scenario 2: Multiple Users Testing

#### Create 5 Different Sessions

Run this sequence 5 times with different usernames:

```
POST http://localhost:8080/api/session/login

User 1: {"username": "alice", "password": "pass1"}
User 2: {"username": "bob", "password": "pass2"}
User 3: {"username": "charlie", "password": "pass3"}
User 4: {"username": "diana", "password": "pass4"}
User 5: {"username": "eve", "password": "pass5"}
```

**Then Check:**
```
GET http://localhost:8080/api/session/count
```

**Expected:** `activeSessionCount: 5`

**Verify in Redis Commander:**
- Open http://localhost:8081
- Navigate to `spring:session:sessions`
- You should see 5 session keys

---

### Scenario 3: Session Persistence Test

#### Test Session Survives Gateway Restart

1. **Create a session:**
```
POST http://localhost:8080/api/session/login
Body: {"username": "persistent_user", "password": "test123"}
```
**Save the SESSION cookie!**

2. **Verify session works:**
```
GET http://localhost:8080/api/session/info
```
Should return user data.

3. **Restart API Gateway:**
```powershell
docker-compose restart api-gateway
```

4. **Wait 15 seconds for startup**

5. **Test session again (use same cookie):**
```
GET http://localhost:8080/api/session/info
```

**Expected:** Session still works! Data retrieved from Redis.

---

### Scenario 4: Session Expiration Test

1. **Create session with custom attributes:**
```
POST http://localhost:8080/api/session/login
PUT http://localhost:8080/api/session/attribute?key=testKey&value=testValue
```

2. **Check in Redis:**
```powershell
docker exec redis-session redis-cli TTL "spring:session:sessions:<session-id>"
```
Should show ~1800 seconds (30 minutes)

3. **Wait 30+ minutes or manually expire:**
```powershell
docker exec redis-session redis-cli EXPIRE "spring:session:sessions:<session-id>" 1
```

4. **Try to access session:**
```
GET http://localhost:8080/api/session/info
```

**Expected:** New session created (old one expired)

---

### Scenario 5: Load Testing with Collection Runner

#### Setup Collection Runner

1. In Postman, click on the collection name
2. Click **Run** button
3. Select **Create Multiple Sessions** request
4. Set **Iterations**: 100
5. Set **Delay**: 100ms
6. Click **Run**

#### What Happens:
- Creates 100 sessions with random usernames
- Each session stored in Redis
- Simulates concurrent user load

#### Verify Results:
```
GET http://localhost:8080/api/session/count
```
Should show ~100 active sessions

#### Monitor Performance:
- Open http://localhost:3000 (Grafana)
- Check HTTP request rates
- Monitor Redis memory usage

---

## 🔍 Monitoring & Verification

### Redis Commander (Visual Inspection)

1. **Open Redis UI:**
   - URL: http://localhost:8081
   
2. **Navigate to sessions:**
   - Click on database (db0)
   - Browse `spring:session:sessions` keys
   
3. **View session data:**
   - Click on any session key
   - See JSON data with userId, loginTime, role

### Redis CLI (Command Line)

```powershell
# Connect to Redis
docker exec -it redis-session redis-cli

# List all sessions
KEYS spring:session:sessions:*

# Get session count
KEYS spring:session:sessions:* | wc -l

# View specific session data
GET spring:session:sessions:<session-id>

# Check TTL (time to live)
TTL spring:session:sessions:<session-id>

# Delete specific session
DEL spring:session:sessions:<session-id>

# Monitor real-time commands
MONITOR
```

### Prometheus Metrics

```
http://localhost:8080/actuator/prometheus
```

Search for:
- `http_server_requests_seconds_count{uri="/api/session/login"}`
- `http_server_requests_seconds_count{uri="/api/session/info"}`
- `redis_commands_total`

### Actuator Endpoints

```
# All actuator endpoints
GET http://localhost:8080/actuator

# Health check
GET http://localhost:8080/actuator/health

# Metrics
GET http://localhost:8080/actuator/metrics

# Session metrics
GET http://localhost:8080/actuator/metrics/spring.session.redis.commands
```

---

## 🧪 Advanced Test Cases

### Test 1: Concurrent Session Access

Use Postman Collection Runner:
1. Create a session
2. Export session cookie
3. Import into 10 different requests
4. Run all 10 simultaneously
5. All should succeed (same session)

### Test 2: Session Attribute Overflow

```
PUT /api/session/attribute?key=key1&value=value1
PUT /api/session/attribute?key=key2&value=value2
PUT /api/session/attribute?key=key3&value=value3
... (add 50+ attributes)

GET /api/session/info
```

Verify all attributes are stored.

### Test 3: Invalid Session Handling

1. Manually delete session from Redis:
```powershell
docker exec redis-session redis-cli DEL "spring:session:sessions:<id>"
```

2. Try to access with old cookie:
```
GET http://localhost:8080/api/session/info
```

**Expected:** New session created automatically

### Test 4: Session Cookie Security

1. **Check cookie attributes:**
   - Open Browser DevTools
   - Check Application > Cookies
   - Verify: HttpOnly, SameSite, Secure flags

2. **Test CSRF protection:**
   - Try POST without proper headers
   - Should be protected by Spring Security

---

## 📊 Performance Benchmarks

### Expected Response Times

| Endpoint | Expected Response Time |
|----------|----------------------|
| POST /session/login | < 50ms |
| GET /session/info | < 20ms |
| PUT /session/attribute | < 30ms |
| GET /session/count | < 100ms (depends on session count) |

### Load Capacity

- **Concurrent Sessions:** 10,000+
- **Redis Memory:** ~1KB per session
- **Requests/Second:** 1,000+ (with proper scaling)

---

## 🐛 Troubleshooting

### Issue: Session Not Created

**Symptoms:** Login returns 200 but session count is 0

**Check:**
```powershell
# Redis is running?
docker ps | grep redis

# Redis is accessible?
docker exec redis-session redis-cli PING

# API Gateway logs
docker logs api-gateway | grep -i redis
```

### Issue: Cookie Not Sent

**Solution:**
- In Postman, enable cookie management
- Settings > General > Enable "Automatically follow redirects"
- Use `-c cookies.txt` flag in curl

### Issue: Session Expired Immediately

**Check:**
- Redis memory is not full
- Check Redis eviction policy:
```powershell
docker exec redis-session redis-cli CONFIG GET maxmemory-policy
```

---

## 📋 Postman Collection Structure

```
Redis Session Management API
│
├── Session Management
│   ├── 1. Login (Create Session)           [POST]
│   ├── 2. Get Session Info                 [GET]
│   ├── 3. Set Session Attribute            [PUT]
│   ├── 4. Get Session Attribute            [GET]
│   ├── 5. Get Active Session Count         [GET]
│   └── 6. Logout (Destroy Session)         [POST]
│
├── Health & Monitoring
│   ├── Health Check                        [GET]
│   ├── Actuator Health                     [GET]
│   ├── Prometheus Metrics                  [GET]
│   └── Actuator Metrics                    [GET]
│
└── Test Scenarios
    ├── Create Multiple Sessions            [POST]
    └── Set Multiple Attributes             [PUT]
```

---

## ✅ Testing Checklist

- [ ] Import Postman collection
- [ ] Verify all services are running (`docker-compose ps`)
- [ ] Test health endpoint
- [ ] Create a session (login)
- [ ] Verify session in Redis Commander
- [ ] Get session info
- [ ] Set custom attributes
- [ ] Get custom attributes
- [ ] Check active session count
- [ ] Test session persistence (restart gateway)
- [ ] Logout and verify session deleted
- [ ] Run Collection Runner (10 iterations)
- [ ] Check Prometheus metrics
- [ ] Monitor in Grafana

---

## 🎯 Next Steps

1. **Integrate with Frontend:**
   - Use SESSION cookie in your web app
   - Handle session expiration gracefully

2. **Add Authentication:**
   - Integrate Spring Security
   - Add JWT tokens with Redis sessions

3. **Scale Horizontally:**
   - Run multiple API Gateway instances
   - Sessions shared via Redis

4. **Production Hardening:**
   - Enable Redis password
   - Use Redis TLS
   - Configure session cookie security

---

## 📚 Resources

- [Postman Collection](Redis-Session-Management-API.postman_collection.json)
- [API Documentation](../api-gateway/README.md)
- [Quick Start Guide](../REDIS_SESSION_QUICKSTART.md)
- [Architecture](../Architecture.md)

**Happy Testing! 🚀**
