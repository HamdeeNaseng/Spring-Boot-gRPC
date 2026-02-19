# API Gateway with Redis Session Management

This is the API Gateway service that handles HTTP/REST requests and communicates with backend services via gRPC. It uses Redis for distributed session management.

## Features

- ✅ RESTful API endpoints
- ✅ gRPC client for backend services
- ✅ Redis-based session management
- ✅ Prometheus metrics
- ✅ Distributed tracing
- ✅ Health checks
- ✅ CORS support

## Prerequisites

- Java 17+
- Maven 3.6+
- Redis server running (or use Docker Compose)

## Build

```bash
mvn clean package
```

## Run Locally

```bash
# Make sure Redis is running
docker run -d -p 6379:6379 redis:7-alpine

# Run the application
mvn spring-boot:run
```

Or with environment variables:

```bash
REDIS_HOST=localhost REDIS_PORT=6379 mvn spring-boot:run
```

## Run with Docker

```bash
# Build the image
docker build -t api-gateway:1.0.0 .

# Run the container
docker run -p 8080:8080 \
  -e REDIS_HOST=redis \
  -e ORDER_SERVICE_HOST=order-service \
  api-gateway:1.0.0
```

## API Endpoints

### Session Management

#### Login (Create Session)
```bash
POST http://localhost:8080/api/session/login
Content-Type: application/json

{
  "username": "john.doe",
  "password": "secret123"
}
```

Response:
```json
{
  "sessionId": "abc123...",
  "userId": "john.doe",
  "message": "Login successful"
}
```

#### Get Session Info
```bash
GET http://localhost:8080/api/session/info
Cookie: SESSION=abc123...
```

#### Logout (Invalidate Session)
```bash
POST http://localhost:8080/api/session/logout
Cookie: SESSION=abc123...
```

#### Set Session Attribute
```bash
PUT http://localhost:8080/api/session/attribute?key=theme&value=dark
Cookie: SESSION=abc123...
```

#### Get Session Attribute
```bash
GET http://localhost:8080/api/session/attribute/theme
Cookie: SESSION=abc123...
```

#### Get Active Session Count
```bash
GET http://localhost:8080/api/session/count
```

### Health Check

```bash
GET http://localhost:8080/api/health
```

### Metrics (Prometheus)

```bash
GET http://localhost:8080/actuator/prometheus
```

### Actuator Endpoints

```bash
GET http://localhost:8080/actuator
GET http://localhost:8080/actuator/health
GET http://localhost:8080/actuator/metrics
GET http://localhost:8080/actuator/info
```

## Configuration

See [application.yml](src/main/resources/application.yml) for all configuration options.

Key configurations:
- Redis host/port
- Session timeout (default: 30 minutes)
- gRPC client settings
- Metrics and tracing

## Testing Redis Sessions

### Using Redis CLI

```bash
# Connect to Redis
redis-cli

# List all session keys
KEYS spring:session:gateway:*

# Get session data
GET spring:session:gateway:sessions:{session-id}

# Check session expiration
TTL spring:session:gateway:sessions:{session-id}
```

### Using Redis Commander UI

Access Redis Commander at: http://localhost:8081

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| REDIS_HOST | localhost | Redis server hostname |
| REDIS_PORT | 6379 | Redis server port |
| REDIS_PASSWORD | (empty) | Redis password if required |
| ORDER_SERVICE_HOST | localhost | Order service hostname |
| ORDER_SERVICE_PORT | 9090 | Order service gRPC port |

## Monitoring

- **Prometheus metrics**: http://localhost:8080/actuator/prometheus
- **Health check**: http://localhost:8080/actuator/health
- **Redis UI**: http://localhost:8081

## Architecture

```
Client → API Gateway (REST) → Redis (Sessions)
            ↓
        gRPC Client → Order Service
```

Session data is stored in Redis with the following naming convention:
- Namespace: `spring:session:gateway`
- Keys: `spring:session:gateway:sessions:{session-id}`
- Expiration: 30 minutes (configurable)

## Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 10 -C "SESSION=your-session-id" http://localhost:8080/api/session/info

# Using curl in a loop
for i in {1..100}; do 
  curl -X POST http://localhost:8080/api/session/login \
    -H "Content-Type: application/json" \
    -d '{"username":"user'$i'","password":"pass"}';
done
```

## Troubleshooting

### Redis Connection Issues

```bash
# Check if Redis is running
docker ps | grep redis

# Test Redis connection
redis-cli ping

# Check logs
docker logs redis-session
```

### Session Not Persisting

1. Check Redis connection in logs
2. Verify `@EnableRedisHttpSession` annotation
3. Check session timeout configuration
4. Verify client is sending cookies

## License

MIT
