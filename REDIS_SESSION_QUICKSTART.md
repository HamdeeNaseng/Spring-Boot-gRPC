# Redis Session Management - Quick Start Guide

## 🎯 What Was Added

Redis has been integrated into the API Gateway for distributed session management. This allows:
- ✅ Stateless API Gateway instances
- ✅ Session sharing across multiple gateway instances
- ✅ Session persistence across application restarts
- ✅ Centralized session monitoring
- ✅ Automatic session expiration (30 minutes default)

---

## 🚀 Quick Start (3 Steps)

### 1. Start Services

```bash
docker-compose up -d
```

This will start:
- Redis (Session Store) - Port 6379
- Redis Commander (UI) - Port 8081
- API Gateway - Port 8080
- All other services...

### 2. Create a Session

```bash
curl -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john","password":"secret"}'
```

Response:
```json
{
  "sessionId": "abc123-456def-789ghi",
  "userId": "john",
  "message": "Login successful"
}
```

### 3. View Sessions in Redis

**Option A: Redis Commander UI**
- Open http://localhost:8081
- Navigate to `spring:session:gateway:sessions`
- See all active sessions visually

**Option B: Redis CLI**
```bash
docker exec -it redis-session redis-cli
KEYS spring:session:gateway:*
```

---

## 📁 Files Created

### API Gateway Service
```
api-gateway/
├── pom.xml                          # Maven dependencies (Redis, Session)
├── Dockerfile                       # Container image
├── README.md                        # Detailed documentation
└── src/main/
    ├── java/com/spring/grpc/gateway/
    │   ├── GatewayApplication.java  # Main app with @EnableRedisHttpSession
    │   ├── config/
    │   │   └── RedisConfig.java     # Redis template configuration
    │   └── controller/
    │       ├── SessionController.java  # Session API endpoints
    │       └── HealthController.java   # Health check with Redis status
    └── resources/
        └── application.yml          # Redis & session configuration
```

### Infrastructure Updates
```
compose.yaml                         # Added api-gateway, enhanced redis
proto/prometheus.yml                 # Added api-gateway metrics scraping
Architecture.md                      # Updated with Redis architecture
```

---

## 🔗 API Endpoints

Base URL: `http://localhost:8080`

### Session Management

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/api/session/login` | POST | Create session | `{"username":"john","password":"pass"}` |
| `/api/session/info` | GET | Get session details | Requires Cookie header |
| `/api/session/logout` | POST | Destroy session | Requires Cookie header |
| `/api/session/count` | GET | Active session count | No auth required |
| `/api/session/attribute?key=X&value=Y` | PUT | Set custom attribute | Requires Cookie |
| `/api/session/attribute/{key}` | GET | Get custom attribute | Requires Cookie |

### Health & Monitoring

| Endpoint | Description |
|----------|-------------|
| `/api/health` | Health check (includes Redis status) |
| `/actuator/prometheus` | Prometheus metrics (includes Redis metrics) |
| `/actuator/health` | Spring Boot actuator health |

---

## 🧪 Test Scenarios

### Test 1: Basic Session Flow

```bash
# 1. Login (creates session)
curl -v -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret"}' \
  -c cookies.txt

# 2. Get session info (using saved cookie)
curl -b cookies.txt http://localhost:8080/api/session/info

# 3. Logout
curl -b cookies.txt -X POST http://localhost:8080/api/session/logout
```

### Test 2: Session Persistence

```bash
# 1. Create session
curl -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"bob","password":"pass"}' \
  -c session.txt

# 2. Restart API Gateway
docker-compose restart api-gateway

# 3. Wait for startup (5-10 seconds)
sleep 10

# 4. Session still works! (stored in Redis)
curl -b session.txt http://localhost:8080/api/session/info
```

### Test 3: Custom Session Attributes

```bash
# Set custom session data
curl -b cookies.txt -X PUT \
  "http://localhost:8080/api/session/attribute?key=theme&value=dark"

curl -b cookies.txt -X PUT \
  "http://localhost:8080/api/session/attribute?key=language&value=en"

# Retrieve custom data
curl -b cookies.txt http://localhost:8080/api/session/attribute/theme
curl -b cookies.txt http://localhost:8080/api/session/info
```

### Test 4: Load Test (100 Sessions)

```bash
# Create 100 concurrent sessions
for i in {1..100}; do
  curl -X POST http://localhost:8080/api/session/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"user$i\",\"password\":\"pass\"}" &
done
wait

# Check session count
curl http://localhost:8080/api/session/count

# View in Redis Commander
open http://localhost:8081
```

---

## 📊 Monitoring

### Redis Commander (Visual UI)

1. Open http://localhost:8081
2. Expand `spring:session:gateway` namespace
3. View all active sessions
4. See session data, TTL, and expiration times

### Prometheus Metrics

```bash
# View metrics
curl http://localhost:8080/actuator/prometheus | grep redis

# Example metrics:
# - redis_commands_total
# - redis_connection_active
# - http_server_requests_seconds (session endpoints)
```

### Grafana Dashboard

1. Open http://localhost:3000 (admin/admin)
2. Import dashboard or create custom panels:
   - Active session count
   - Session creation rate
   - Redis memory usage
   - Session endpoint latency

---

## 🔍 Inspecting Redis Data

### Using Redis CLI

```bash
# Enter Redis container
docker exec -it redis-session redis-cli

# List all session keys
127.0.0.1:6379> KEYS spring:session:gateway:*

# Get session details
127.0.0.1:6379> GET spring:session:gateway:sessions:<session-id>

# Check expiration time (seconds)
127.0.0.1:6379> TTL spring:session:gateway:sessions:<session-id>

# Count active sessions
127.0.0.1:6379> KEYS spring:session:gateway:sessions:* | wc -l

# Monitor real-time commands
127.0.0.1:6379> MONITOR
```

### Session Data Structure

Sessions are stored as JSON with namespace: `spring:session:gateway`

Example key: `spring:session:gateway:sessions:abc123-456def`

Session contains:
- Session ID
- Creation time
- Last accessed time
- Max inactive interval
- Session attributes (userId, loginTime, role, custom attributes)

---

## ⚙️ Configuration

### Change Session Timeout

Edit `api-gateway/src/main/resources/application.yml`:

```yaml
spring:
  session:
    timeout: 30m  # Change to 1h, 2h, 15m, etc.
```

### Redis Connection Settings

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: ""  # Set if using authentication
```

### Environment Variables (Docker)

Edit `compose.yaml`:

```yaml
api-gateway:
  environment:
    - REDIS_HOST=redis
    - REDIS_PORT=6379
```

---

## 🐛 Troubleshooting

### Sessions Not Persisting

```bash
# Check Redis is running
docker ps | grep redis

# Test Redis connection
docker exec -it redis-session redis-cli ping
# Should return: PONG

# Check API Gateway logs
docker logs api-gateway | grep -i redis
```

### Redis Connection Refused

```bash
# Verify Redis is healthy
docker exec redis-session redis-cli ping

# Check network connectivity
docker network inspect spring-boot-grpc_grpc_network

# Restart Redis
docker-compose restart redis
```

### Session Not Found After Creation

1. Check cookies are being sent
2. Verify session timeout hasn't expired
3. Check Redis has the session key:
   ```bash
   docker exec -it redis-session redis-cli KEYS "*"
   ```

---

## 🚀 Next Steps

1. **Add Authentication**: Integrate Spring Security with Redis sessions
2. **Session Metrics**: Create Grafana dashboard for session analytics
3. **Multiple Gateway Instances**: Scale to multiple API Gateway instances
4. **Rate Limiting**: Use Redis for rate limiting per session
5. **Session Events**: Listen to session creation/destruction events

---

## 📚 Key Dependencies

```xml
<!-- Redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- Session -->
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
</dependency>
```

---

## 🎉 Success Checklist

- [ ] Services started: `docker-compose ps` shows all healthy
- [ ] Redis accessible: http://localhost:8081
- [ ] Created a session: POST `/api/session/login`
- [ ] Viewed session in Redis Commander
- [ ] Retrieved session: GET `/api/session/info`
- [ ] Checked metrics: http://localhost:8080/actuator/prometheus
- [ ] Tested session persistence across restart

---

**Need help?** Check [api-gateway/README.md](api-gateway/README.md) for detailed documentation.
