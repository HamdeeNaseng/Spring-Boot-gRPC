# Spring Boot + gRPC + Kafka + Redis Microservices Demo

Production-ready microservices architecture demo showcasing Spring Boot, gRPC, Kafka, PostgreSQL, Redis session management, and full observability stack (Prometheus, Grafana, Jaeger).

## 🚀 Features

- ✅ **API Gateway** with REST endpoints and gRPC client
- ✅ **Redis Session Management** for distributed sessions
- ✅ **gRPC** for inter-service communication
- ✅ **Apache Kafka** for event-driven architecture
- ✅ **PostgreSQL** for persistent data storage
- ✅ **Prometheus** for metrics collection
- ✅ **Grafana** for metrics visualization
- ✅ **Jaeger** for distributed tracing
- ✅ **Redis Commander** UI for session monitoring
- ✅ **Docker Compose** for easy deployment

## 📋 Architecture

See [Architecture.md](Architecture.md) for detailed architecture documentation.

```
Client → API Gateway (REST + Redis Sessions) → gRPC → Order Service → Kafka → Payment Service → PostgreSQL
                ↓
            Redis (Sessions)
```

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Spring Boot 3.2 |
| RPC | gRPC |
| Event Streaming | Apache Kafka |
| Database | PostgreSQL |
| Session Store | Redis |
| Metrics | Prometheus |
| Dashboard | Grafana |
| Tracing | Jaeger |
| Container | Docker |

## 📦 Services

- **API Gateway** (`:8080`) - REST API with Redis session management
- **Order Service** (`:9090`) - gRPC server + Kafka producer
- **Payment Service** (`:9091`) - Kafka consumer
- **Redis** (`:6379`) - Session store
- **Redis Commander** (`:8081`) - Redis UI
- **PostgreSQL** (`:5432`) - Database
- **Kafka** (`:9092`) - Message broker
- **Prometheus** (`:9090`) - Metrics
- **Grafana** (`:3000`) - Dashboards
- **Jaeger** (`:16686`) - Tracing UI

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Java 17+ (for local development)
- Maven 3.6+ (for local development)

### Start All Services

```bash
# Clone the repository
git clone <repository-url>
cd Spring-Boot-gRPC

# Start all services with Docker Compose
docker-compose up -d

# Check service status
docker-compose ps
```

### Test Redis Session Management

```bash
# Login (creates session in Redis)
curl -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john.doe","password":"secret123"}'

# Response will include sessionId
# Use the session cookie in subsequent requests

# Get session info
curl -X GET http://localhost:8080/api/session/info \
  -H "Cookie: SESSION=<session-id>"

# View active sessions count
curl http://localhost:8080/api/session/count
```

### Monitor Sessions in Redis

#### Using Redis CLI
```bash
# Connect to Redis container
docker exec -it redis-session redis-cli

# List all session keys
KEYS spring:session:gateway:*

# View session details
GET spring:session:gateway:sessions:<session-id>

# Check TTL
TTL spring:session:gateway:sessions:<session-id>
```

#### Using Redis Commander UI
Open http://localhost:8081 in your browser to view sessions graphically.

## 📊 Monitoring & Observability

### Prometheus Metrics
- URL: http://localhost:9090
- Scrapes metrics from all services including Redis session metrics
- Query examples:
  - `http_server_requests_seconds_count` - Request count
  - `redis_commands_total` - Redis operations
  - `jvm_memory_used_bytes` - Memory usage

### Grafana Dashboard
- URL: http://localhost:3000
- Default credentials: `admin / admin`
- Pre-configured dashboards for:
  - HTTP request rates
  - Redis session count
  - JVM metrics
  - Kafka lag
  - Database connections

### Jaeger Tracing
- URL: http://localhost:16686
- Distributed traces across:
  - Client → Gateway → Order Service → Kafka → Payment Service

## 🧪 Testing Session Management

### Load Test Sessions

```bash
# Create 100 sessions
for i in {1..100}; do
  curl -X POST http://localhost:8080/api/session/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"user$i\",\"password\":\"pass\"}"
done

# Check active session count
curl http://localhost:8080/api/session/count
```

### Session Persistence Test

```bash
# 1. Create a session
SESSION_ID=$(curl -s -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"pass"}' \
  | jq -r '.sessionId')

# 2. Restart API Gateway
docker-compose restart api-gateway

# 3. Session should still work (stored in Redis)
curl http://localhost:8080/api/session/info \
  -H "Cookie: SESSION=$SESSION_ID"
```

## 🔧 Development

### Build API Gateway

```bash
cd api-gateway
mvn clean package
```

### Run Locally (with Docker Redis)

```bash
# Start only Redis
docker-compose up -d redis

# Run API Gateway locally
cd api-gateway
REDIS_HOST=localhost mvn spring-boot:run
```

### Hot Reload with Spring DevTools

```bash
mvn spring-boot:run -Dspring-boot.run.fork=false
```

## 📚 API Documentation

### Session Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/session/login` | Create session (login) |
| GET | `/api/session/info` | Get current session info |
| POST | `/api/session/logout` | Invalidate session |
| PUT | `/api/session/attribute` | Set session attribute |
| GET | `/api/session/attribute/{key}` | Get session attribute |
| GET | `/api/session/count` | Get active session count |

### Health & Metrics

| Endpoint | Description |
|----------|-------------|
| `/api/health` | Health check (includes Redis) |
| `/actuator/health` | Spring actuator health |
| `/actuator/prometheus` | Prometheus metrics |
| `/actuator/metrics` | Available metrics |

See [api-gateway/README.md](api-gateway/README.md) for detailed API documentation.

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api-gateway
docker-compose logs -f redis

# Restart a service
docker-compose restart api-gateway

# Stop all services
docker-compose down

# Stop and remove volumes (clears data)
docker-compose down -v
```

## ⚙️ Configuration

### Redis Session Configuration

Edit `api-gateway/src/main/resources/application.yml`:

```yaml
spring:
  session:
    store-type: redis
    timeout: 30m  # Session timeout
    redis:
      namespace: spring:session:gateway
```

### Environment Variables

```bash
# API Gateway
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# Session timeout (in application.yml)
spring.session.timeout=30m
```

## 🔒 Security Considerations

For production:

1. **Enable Redis password**:
   ```yaml
   # docker-compose.yml
   redis:
     command: redis-server --requirepass ${REDIS_PASSWORD}
   ```

2. **Use TLS for Redis**:
   ```yaml
   spring.data.redis.ssl: true
   ```

3. **Secure session cookies**:
   ```yaml
   server.servlet.session.cookie.secure: true
   server.servlet.session.cookie.http-only: true
   ```

## 🎯 Demo Scenarios

### 1. Session Management Demo
1. Create multiple user sessions
2. Monitor in Redis Commander
3. View session count metrics in Grafana
4. Test session persistence across gateway restarts

### 2. Load Testing
1. Generate 1000+ sessions
2. Monitor Redis memory usage
3. Check session cleanup (TTL expiration)
4. View metrics spike in Prometheus

### 3. Distributed Sessions
1. Scale API Gateway (multiple instances)
2. Sessions shared across all instances via Redis
3. Load balance requests
4. Demonstrate session persistence

## 📖 References

- [Spring Session](https://spring.io/projects/spring-session)
- [Spring Data Redis](https://spring.io/projects/spring-data-redis)
- [Redis Documentation](https://redis.io/docs/)
- [gRPC Java](https://grpc.io/docs/languages/java/)
- [Apache Kafka](https://kafka.apache.org/documentation/)

## 📄 License

MIT

## 👥 Contributing

Contributions welcome! Please read the contributing guidelines first.
