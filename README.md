# 🚀 Spring Boot Microservices with gRPC, Kafka & Redis

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.org/)
[![gRPC](https://img.shields.io/badge/gRPC-1.59-blue.svg)](https://grpc.io/)
[![Redis](https://img.shields.io/badge/Redis-7-red.svg)](https://redis.io/)
[![Kafka](https://img.shields.io/badge/Kafka-7.5-black.svg)](https://kafka.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Production-ready microservices architecture** demonstrating modern distributed systems patterns with Spring Boot, gRPC communication, event-driven architecture using Kafka, Redis-based session management, and comprehensive observability stack.

Perfect for **learning**, **portfolios**, **tech demos**, and **interview preparation**.

---

## 📑 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#️-tech-stack)
- [Quick Start](#-quick-start)
- [Services Overview](#-services-overview)
- [API Testing](#-api-testing)
- [Monitoring & Observability](#-monitoring--observability)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### Core Capabilities
- 🌐 **RESTful API Gateway** - Spring Boot with comprehensive session management
- 🔐 **Redis Session Management** - Distributed sessions across multiple instances
- 🚄 **gRPC Communication** - High-performance RPC for inter-service calls
- 📨 **Event-Driven Architecture** - Kafka for asynchronous message processing
- 🗄️ **PostgreSQL Database** - Reliable persistent data storage
- 🔄 **Distributed Tracing** - End-to-end request tracking with Jaeger
- 📊 **Metrics & Monitoring** - Prometheus + Grafana dashboards
- 🎯 **Health Checks** - Comprehensive service health monitoring
- 🐳 **Docker Compose** - One-command deployment of entire stack

### Advanced Features
- ✅ Session persistence across restarts
- ✅ Automatic session expiration and cleanup
- ✅ Redis Commander UI for visual session inspection
- ✅ Postman collection with automated tests
- ✅ PowerShell test automation scripts
- ✅ Production-ready Docker configuration
- ✅ Comprehensive error handling
- ✅ Structured logging

---

## 🏗 Architecture

```
┌─────────────────────┐
│   Client / Browser  │
│   (REST Requests)   │
└──────────┬──────────┘
           │ HTTP/REST
           ▼
┌─────────────────────┐     ┌──────────────┐
│   API Gateway       │◄────┤    Redis     │
│   Spring Boot       │     │   Sessions   │
│   + gRPC Client     │     └──────────────┘
└──────────┬──────────┘
           │ gRPC
           ▼
┌─────────────────────┐
│  Order Service      │
│  gRPC Server        │
│  + Kafka Producer   │
└──────────┬──────────┘
           │ Kafka Events
           ▼
┌─────────────────────┐
│  Payment Service    │
│  Kafka Consumer     │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │  PostgreSQL  │
    │   Database   │
    └──────────────┘

    Observability Layer:
    ┌─────────────┬──────────────┬────────────┐
    │ Prometheus  │   Grafana    │   Jaeger   │
    │  (Metrics)  │ (Dashboards) │ (Tracing)  │
    └─────────────┴──────────────┴────────────┘
```

**Key Patterns:**
- 🔄 **API Gateway Pattern** - Single entry point for clients
- 📬 **Event-Driven Architecture** - Asynchronous communication via Kafka
- 🎯 **Service Mesh Ready** - Health checks and observability built-in
- 🔐 **Stateless Services** - Session state externalized to Redis
- 📊 **Observability First** - Metrics, logs, and traces from day one

For detailed architecture, see [Architecture.md](Architecture.md)

---

## 🛠️ Tech Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Language** | Java | 17 | Primary programming language |
| **Framework** | Spring Boot | 3.2 | Application framework |
| **RPC** | gRPC | 1.59 | Inter-service communication |
| **Messaging** | Apache Kafka | 7.5 | Event streaming |
| **Database** | PostgreSQL | 16 | Relational data storage |
| **Cache/Session** | Redis | 7 | Session management & caching |
| **Metrics** | Prometheus | Latest | Metrics collection |
| **Visualization** | Grafana | Latest | Metrics dashboards |
| **Tracing** | Jaeger | Latest | Distributed tracing |
| **Container** | Docker Compose | Latest | Service orchestration |
| **Build Tool** | Maven | 3.6+ | Dependency management |

---

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:

```bash
✅ Docker & Docker Compose
✅ Java 17+ (for local development)
✅ Maven 3.6+ (for building)
```

### 1️⃣ Clone Repository

```bash
git clone https://github.com/HamdeeNaseng/Spring-Boot-gRPC.git
cd Spring-Boot-gRPC
```

### 2️⃣ Build API Gateway

```bash
cd api-gateway
mvn clean package -DskipTests
cd ..
```

### 3️⃣ Start All Services

```bash
docker-compose up -d
```

### 4️⃣ Verify Services

```bash
docker-compose ps
```

All services should show **"Up"** and **"healthy"** status.

### 5️⃣ Test the API

```powershell
# Health check
curl http://localhost:8080/api/health

# Create a session
curl -X POST http://localhost:8080/api/session/login `
  -H "Content-Type: application/json" `
  -d '{"username":"testuser","password":"secret123"}'

# Check active sessions
curl http://localhost:8080/api/session/count
```

**🎉 Success!** Your microservices are running.

---

## 📦 Services Overview

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| 🌐 **API Gateway** | 8080 | http://localhost:8080 | REST API + Session Management |
| 🎯 **Order Service** | 9090 | - | gRPC Server + Kafka Producer |
| 💳 **Payment Service** | 9091 | - | Kafka Consumer |
| 🔴 **Redis** | 6379 | - | Session Store |
| 🎛️ **Redis Commander** | 8081 | http://localhost:8081 | Redis UI |
| 🐘 **PostgreSQL** | 5432 | - | Database |
| 📨 **Kafka** | 9092 | - | Message Broker |
| 📊 **Prometheus** | 9090 | http://localhost:9090 | Metrics |
| 📈 **Grafana** | 3000 | http://localhost:3000 | Dashboards (admin/admin) |
| 🔍 **Jaeger** | 16686 | http://localhost:16686 | Tracing UI |

---

## 🧪 API Testing

### Using Postman

1. **Import Collection**
   ```
   File: postman/Redis-Session-Management-API.postman_collection.json
   ```

2. **Run Tests**
   - Open Postman
   - Import the collection
   - Run requests in sequence
   - View automated test results

3. **Load Testing**
   - Use Collection Runner
   - Set iterations: 100
   - Monitor session count growth

**📖 Full Guide:** [postman/POSTMAN_TESTING_GUIDE.md](postman/POSTMAN_TESTING_GUIDE.md)

### Using PowerShell Script

```powershell
cd postman
.\test-api.ps1
```

Runs automated tests for all endpoints with detailed reporting.

### Manual Testing

```bash
# 1. Create Session
curl -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john","password":"secret"}' \
  -c cookies.txt

# 2. Get Session Info
curl -b cookies.txt http://localhost:8080/api/session/info

# 3. Set Custom Attribute
curl -b cookies.txt -X PUT \
  "http://localhost:8080/api/session/attribute?key=theme&value=dark"

# 4. Check Session Count
curl http://localhost:8080/api/session/count

# 5. Logout
curl -b cookies.txt -X POST http://localhost:8080/api/session/logout
```

---

## 📊 Monitoring & Observability

### Prometheus Metrics

**URL:** http://localhost:9090

**Key Metrics:**
```promql
# HTTP request rate
rate(http_server_requests_seconds_count[5m])

# Session count
redis_sessions_active

# JVM memory
jvm_memory_used_bytes

# Request latency
histogram_quantile(0.95, http_server_requests_seconds_bucket)
```

### Grafana Dashboards

**URL:** http://localhost:3000 (admin/admin)

**Pre-configured Panels:**
- HTTP Request Rates
- Error Rates
- Session Analytics
- Redis Memory Usage
- JVM Metrics
- Kafka Lag
- Database Connections

### Jaeger Tracing

**URL:** http://localhost:16686

**Trace Flow:**
```
Client → API Gateway → Order Service → Kafka → Payment Service
```

View end-to-end latency and identify bottlenecks.

### Redis Commander

**URL:** http://localhost:8081

Visually inspect:
- Active sessions
- Session data
- TTL (expiration times)
- Redis memory usage

---

## 📁 Project Structure

```
Spring-Boot-gRPC/
│
├── api-gateway/                 # API Gateway service
│   ├── src/main/java/          # Java source code
│   │   └── com/spring/grpc/gateway/
│   │       ├── GatewayApplication.java
│   │       ├── config/         # Configuration classes
│   │       └── controller/     # REST controllers
│   ├── src/main/resources/     # Configuration files
│   │   └── application.yml     # Application config
│   ├── Dockerfile              # Container image
│   ├── pom.xml                 # Maven dependencies
│   └── README.md               # Service documentation
│
├── order-service/              # Order processing service
│   └── (gRPC server implementation)
│
├── payment-service/            # Payment processing service
│   └── (Kafka consumer implementation)
│
├── postman/                    # API testing resources
│   ├── Redis-Session-Management-API.postman_collection.json
│   ├── POSTMAN_TESTING_GUIDE.md
│   ├── QUICK_REFERENCE.md
│   └── test-api.ps1            # Automated test script
│
├── proto/                      # Protocol Buffers & configs
│   ├── prometheus.yml          # Prometheus configuration
│   └── grafana/                # Grafana dashboards
│
├── compose.yaml                # Docker Compose configuration
├── Architecture.md             # Architecture documentation
├── REDIS_SESSION_QUICKSTART.md # Redis session guide
├── README.md                   # This file
└── LICENSE                     # MIT License
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Architecture.md](Architecture.md) | Detailed architecture and tech stack |
| [REDIS_SESSION_QUICKSTART.md](REDIS_SESSION_QUICKSTART.md) | Redis session management guide |
| [api-gateway/README.md](api-gateway/README.md) | API Gateway documentation |
| [postman/POSTMAN_TESTING_GUIDE.md](postman/POSTMAN_TESTING_GUIDE.md) | Complete testing guide |
| [postman/QUICK_REFERENCE.md](postman/QUICK_REFERENCE.md) | Quick reference card |

---

## 💻 Development

### Local Development Setup

#### 1. Run Services Individually

```bash
# Start infrastructure only
docker-compose up -d redis postgres kafka zookeeper

# Build and run API Gateway locally
cd api-gateway
REDIS_HOST=localhost mvn spring-boot:run
```

#### 2. Hot Reload (DevTools)

```bash
# Enable automatic restart on code changes
mvn spring-boot:run -Dspring-boot.run.fork=false
```

#### 3. Run Tests

```bash
# Unit tests
mvn test

# Integration tests
mvn verify

# Skip tests during build
mvn clean package -DskipTests
```

### Build from Source

```bash
# Build all services
mvn clean install

# Build specific service
cd api-gateway
mvn clean package
```

### Docker Commands

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f api-gateway
docker-compose logs -f redis

# Restart specific service
docker-compose restart api-gateway

# Stop all services
docker-compose down

# Remove volumes (clean state)
docker-compose down -v

# Check service health
docker-compose ps
```

### Code Quality

```bash
# Run checkstyle
mvn checkstyle:check

# Run PMD
mvn pmd:check

# Run SpotBugs
mvn spotbugs:check
```

---

## 🧪 Testing Guide

### Automated Testing (Recommended)

```powershell
# Run comprehensive API tests
cd postman
.\test-api.ps1
```

**Output:**
- ✅ Test results for all endpoints
- 📊 Performance metrics
- 🔍 Detailed console logs

### Manual Testing

#### Create Session
```bash
curl -X POST http://localhost:8080/api/session/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john","password":"secret"}' \
  -c cookies.txt
```

#### Get Session Info
```bash
curl -b cookies.txt http://localhost:8080/api/session/info
```

#### Set Attribute
```bash
curl -b cookies.txt -X PUT \
  "http://localhost:8080/api/session/attribute?key=theme&value=dark"
```

#### Session Count
```bash
curl http://localhost:8080/api/session/count
```

#### Logout
```bash
curl -b cookies.txt -X POST http://localhost:8080/api/session/logout
```

### Load Testing

```bash
# Create 100 concurrent sessions
for i in {1..100}; do
  curl -X POST http://localhost:8080/api/session/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"user$i\",\"password\":\"pass$i\"}" &
done
wait

# Check results
curl http://localhost:8080/api/session/count
```

### Postman Collection

1. Import `postman/Redis-Session-Management-API.postman_collection.json`
2. Run Collection Runner
3. Set iterations for load testing
4. View automated test results

**📖 See:** [postman/POSTMAN_TESTING_GUIDE.md](postman/POSTMAN_TESTING_GUIDE.md)

---

## 🔧 Troubleshooting

### Common Issues

#### Services Not Starting

```bash
# Check Docker is running
docker version

# Check service logs
docker-compose logs <service-name>

# Restart all services
docker-compose restart
```

#### Redis Connection Refused

```bash
# Verify Redis is running
docker ps | grep redis

# Test connection
docker exec redis-session redis-cli ping

# Check Redis logs
docker logs redis-session
```

#### Sessions Not Persisting

```bash
# Check Redis keys
docker exec redis-session redis-cli KEYS "spring:session:*"

# Verify API Gateway can reach Redis
docker exec api-gateway ping redis

# Check application logs
docker logs api-gateway | grep -i redis
```

#### Build Failures

```bash
# Clean Maven cache
mvn clean

# Update dependencies
mvn dependency:purge-local-repository

# Skip tests
mvn clean package -DskipTests
```

#### Port Conflicts

```bash
# Check if ports are in use
netstat -ano | findstr :8080
netstat -ano | findstr :6379

# Stop conflicting processes or change ports in compose.yaml
```

### Health Checks

```bash
# API Gateway health
curl http://localhost:8080/api/health

# Actuator health
curl http://localhost:8080/actuator/health

# Redis ping
docker exec redis-session redis-cli ping

# All services status
docker-compose ps
```

### Logs & Debugging

```bash
# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs api-gateway

# Last 100 lines
docker-compose logs --tail=100 api-gateway

# Enable debug logging (application.yml)
logging.level.com.spring.grpc: DEBUG
```

---

## 🚢 Production Deployment

### Security Best Practices

1. **Enable Redis Authentication**
   ```yaml
   redis:
     command: redis-server --requirepass ${REDIS_PASSWORD}
   ```

2. **Use TLS/SSL**
   ```yaml
   spring.data.redis.ssl: true
   ```

3. **Secure Session Cookies**
   ```yaml
   server.servlet.session.cookie:
     secure: true
     http-only: true
     same-site: strict
   ```

4. **Environment Variables**
   - Never hardcode passwords
   - Use secret management (Vault, AWS Secrets Manager)
   - Rotate credentials regularly

### Performance Tuning

```yaml
# JVM Options
JAVA_OPTS: "-Xmx2g -Xms1g -XX:+UseG1GC"

# Redis Configuration
maxmemory: 1gb
maxmemory-policy: allkeys-lru

# Connection Pooling
spring.data.redis.lettuce.pool:
  max-active: 16
  max-idle: 8
  min-idle: 2
```

### Scaling

```yaml
# Scale API Gateway
docker-compose up -d --scale api-gateway=3

# Use load balancer (nginx, HAProxy)
# Sessions shared via Redis automatically
```

### Monitoring in Production

- Set up alerting in Prometheus
- Configure Grafana notifications
- Enable distributed tracing
- Use structured logging
- Monitor Redis memory usage

---

## 🎓 Learning Resources

### Concepts Demonstrated

- ✅ Microservices Architecture
- ✅ API Gateway Pattern
- ✅ Event-Driven Architecture
- ✅ Distributed Session Management
- ✅ Service Discovery
- ✅ Health Checks & Circuit Breakers
- ✅ Observability (Metrics, Logs, Traces)
- ✅ Containerization
- ✅ RESTful API Design
- ✅ gRPC Communication

### Use Cases

Perfect for learning and demonstrating:
- 🎯 **Microservices** - Decomposed services with clear boundaries
- 🎯 **Event Sourcing** - Kafka-based event processing
- 🎯 **Session Management** - Stateless services with Redis
- 🎯 **Observability** - Full monitoring stack
- 🎯 **Docker Orchestration** - Multi-container applications
- 🎯 **API Testing** - Automated test suites

---

## 📋 API Reference

### Session Management Endpoints

#### POST /api/session/login
Create a new session (login).

**Request:**
```json
{
  "username": "john.doe",
  "password": "secret123"
}
```

**Response (200):**
```json
{
  "sessionId": "abc123-def456-...",
  "userId": "john.doe",
  "message": "Login successful"
}
```

#### GET /api/session/info
Get current session information.

**Response (200):**
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

#### PUT /api/session/attribute
Set custom session attribute.

**Query Parameters:**
- `key` - Attribute key
- `value` - Attribute value

**Response (200):**
```json
{
  "message": "Attribute set successfully",
  "key": "theme",
  "value": "dark"
}
```

#### GET /api/session/attribute/{key}
Get session attribute by key.

**Response (200):**
```json
{
  "key": "theme",
  "value": "dark"
}
```

#### GET /api/session/count
Get active session count.

**Response (200):**
```json
{
  "activeSessionCount": 42
}
```

#### POST /api/session/logout
Destroy current session.

**Response (200):**
```json
{
  "message": "Logout successful",
  "sessionId": "abc123-def456-..."
}
```

### Health Endpoints

#### GET /api/health
Application health status.

**Response (200):**
```json
{
  "service": "api-gateway",
  "redis": "UP",
  "status": "UP"
}
```

#### GET /actuator/health
Spring Boot Actuator health.

#### GET /actuator/prometheus
Prometheus metrics in exposition format.

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Java code conventions
- Write unit tests for new features
- Update documentation
- Keep commits atomic and meaningful
- Test locally before submitting PR

### Reporting Issues

- Use GitHub Issues
- Provide clear description
- Include steps to reproduce
- Add relevant logs/screenshots

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 HamdeeNaseng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 👤 Author

**HamdeeNaseng**

- GitHub: [@HamdeeNaseng](https://github.com/HamdeeNaseng)
- Repository: [Spring-Boot-gRPC](https://github.com/HamdeeNaseng/Spring-Boot-gRPC)

---

## 🌟 Acknowledgments

- Spring Boot Team for excellent framework
- gRPC Community for high-performance RPC
- Redis Labs for amazing in-memory data store
- Apache Kafka for event streaming
- Docker for containerization
- Postman for API testing tools

---

## 📞 Support

If you find this project helpful:

- ⭐ Star this repository
- 🐛 Report bugs via Issues
- 💡 Suggest features
- 🤝 Submit pull requests
- 📢 Share with others

---

<div align="center">

### 🚀 Ready to explore microservices?

**[Get Started](#-quick-start)** | **[View Docs](#-documentation)** | **[Run Tests](#-api-testing)**

---

Made with ❤️ for learning and demonstrating modern microservices architecture

**Spring Boot + gRPC + Kafka + Redis + Observability**

</div>
