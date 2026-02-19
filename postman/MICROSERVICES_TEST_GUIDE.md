# 🧪 Microservices Infrastructure Testing Guide

Complete guide for testing the Spring Boot Microservices architecture using the comprehensive test suite.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Test Scenarios](#test-scenarios)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Performance Testing](#performance-testing)
- [Interpreting Results](#interpreting-results)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The **Microservices Infrastructure Test** collection provides comprehensive testing for:

- ✅ **Infrastructure Health** - All services and components
- 🔐 **Session Management** - Redis-based distributed sessions
- 🌐 **API Gateway** - Entry point and routing
- 📨 **Event-Driven Flow** - Kafka event processing simulation
- 📊 **Observability** - Metrics, logs, and tracing
- 🚀 **Performance** - Load testing and throughput
- 🧹 **Cleanup** - Proper teardown and verification

### Test Architecture

```
┌─────────────────────────────────────────┐
│   Postman Test Collection               │
│                                         │
│   1. Infrastructure Health Checks       │
│      ├─ API Gateway ✓                   │
│      ├─ Redis ✓                         │
│      ├─ Prometheus ✓                    │
│      ├─ Grafana ✓                       │
│      └─ Jaeger ✓                        │
│                                         │
│   2. Session Management Tests           │
│      ├─ Create Session                  │
│      ├─ Verify Persistence              │
│      └─ Context Management              │
│                                         │
│   3. API Gateway Integration            │
│      ├─ Route Discovery                 │
│      ├─ Metrics Collection              │
│      └─ Session Distribution            │
│                                         │
│   4. Event-Driven Architecture          │
│      ├─ Order Context Preparation       │
│      └─ Event Flow Verification         │
│                                         │
│   5. Observability & Monitoring         │
│      ├─ JVM Metrics                     │
│      ├─ Application Info                │
│      ├─ Environment Config              │
│      └─ Loggers Configuration           │
│                                         │
│   6. Load Testing & Performance         │
│      ├─ Concurrent Sessions             │
│      ├─ Throughput Testing              │
│      └─ Load Metrics Verification       │
│                                         │
│   7. Cleanup & Teardown                 │
│      ├─ Session Destruction             │
│      └─ Final Health Verification       │
└─────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Step 1: Prerequisites

Ensure all services are running:

```powershell
# Verify all services are up
docker-compose ps

# Expected output: All services should show "Up" and "healthy"
```

### Step 2: Import Collection

1. Open **Postman**
2. Click **Import** button
3. Select file: `postman/Test-Infra-microservice.json`
4. Collection will appear in your workspace

### Step 3: Run Complete Test Suite

**Option A: Collection Runner (Recommended)**

1. Click on **Test-Infra-microservice** collection
2. Click **Run** button (▶️)
3. Select all folders (default)
4. Click **Run Microservices Infrastructure Test**
5. Watch tests execute in sequence

**Option B: Manual Testing**

1. Expand folders in collection
2. Click each request individually
3. Click **Send** button
4. Review test results in **Test Results** tab

### Step 4: View Results

Monitor test output in Console:
- ✅ Green checkmarks = Tests passed
- ❌ Red X = Tests failed
- 📊 View response times and status codes

---

## 📝 Test Scenarios

### Scenario 1: Infrastructure Validation

**Purpose**: Verify all microservices and infrastructure components are healthy and accessible.

**Tests Included**:
1. **API Gateway Health** - Core service health check
2. **Actuator Health (Detailed)** - Spring Boot health details
3. **Redis Commander UI** - Redis management interface
4. **Prometheus Metrics** - Metrics collection endpoint
5. **Jaeger UI** - Distributed tracing interface

**Expected Results**:
- All health checks return `200 OK`
- Status shows `"UP"` for all components
- UIs are accessible via browser
- Metrics endpoint returns Prometheus format

**Run Command** (Collection Runner):
```
Select folder 1: "Infrastructure Health Checks"
Run 5 requests
```

---

### Scenario 2: Session Management Flow

**Purpose**: Test distributed session management with Redis as the backing store.

**Tests Included**:
1. **Create User Session** - Login and session creation
2. **Verify Session Persistence** - Confirm Redis storage
3. **Set Session Context Data** - Store custom attributes

**Expected Results**:
- Session ID returned on login
- Session persists across requests
- Session data stored in Redis
- Custom attributes preserved

**Key Assertions**:
```javascript
✓ Session created successfully
✓ Session ID is returned
✓ User ID is correct
✓ Session is persisted
✓ User data is preserved
✓ Session has timestamps
✓ Session attribute set
```

**Run Command**:
```
Select folder 2: "Session Management (Redis)"
Run 3 requests
```

---

### Scenario 3: API Gateway Integration

**Purpose**: Test API Gateway as central entry point for microservices.

**Tests Included**:
1. **Gateway Routes Discovery** - Find available endpoints
2. **Gateway Request Metrics** - Verify metrics collection
3. **Session Distribution Check** - Validate distributed sessions

**Expected Results**:
- Actuator endpoints available
- HTTP metrics captured
- Session count > 0
- Gateway routes discoverable

**Key Metrics Checked**:
- `http_server_requests_*`
- `jvm_memory_*`
- Active session count

**Run Command**:
```
Select folder 3: "API Gateway Integration"
Run 3 requests
```

---

### Scenario 4: Event-Driven Architecture

**Purpose**: Simulate order processing flow through Kafka event stream.

**Tests Included**:
1. **Prepare Order Context** - Set order data in session
2. **Verify Event Flow Metrics** - Check event processing metrics

**Expected Results**:
- Order ID generated and stored
- Metrics capture event flow
- Session contains order context

**Event Flow Simulation**:
```
User Session → Order Context → (Future: Kafka Event) → Payment Processing
```

**Run Command**:
```
Select folder 4: "Event-Driven Architecture Test"
Run 2 requests
```

---

### Scenario 5: Observability Testing

**Purpose**: Verify comprehensive monitoring and observability stack.

**Tests Included**:
1. **Check JVM Metrics** - Memory, GC, threads
2. **Application Info** - Build and version details
3. **Environment Variables** - Configuration check
4. **Loggers Configuration** - Logging setup

**Expected Results**:
- JVM metrics available in Prometheus format
- Application metadata accessible
- Environment properly configured
- Logger levels configured

**Key Metrics**:
- `jvm_memory_used_bytes`
- `jvm_gc_*`
- `jvm_threads_*`
- `http_server_requests_*`

**Run Command**:
```
Select folder 5: "Observability & Monitoring"
Run 4 requests
```

---

### Scenario 6: Performance & Load Testing

**Purpose**: Evaluate system performance under load conditions.

**Tests Included**:
1. **Concurrent Session Creation** - Create sessions with random users
2. **Session Throughput Test** - Measure retrieval performance
3. **Verify Load Metrics** - Check metrics after load

**Expected Results**:
- Sessions created under 1000ms
- Retrieval under 100ms
- Load metrics captured
- No degradation in response times

**Load Test Configuration**:
```yaml
Iterations: 100 (recommended)
Delay: 0ms (concurrent)
Data: Random users and timestamps
```

**Performance Targets**:
- Session creation: < 1000ms
- Session retrieval: < 100ms
- All tests pass: 100%

**Run Command**:
```
Select folder 6: "Load Testing & Performance"
Set iterations: 100
Run folder
```

---

### Scenario 7: Cleanup & Verification

**Purpose**: Properly clean up test data and verify system stability.

**Tests Included**:
1. **Logout Test Session** - Destroy session
2. **Final Health Check** - System health after tests

**Expected Results**:
- Session destroyed successfully
- Variables cleared
- System still healthy
- No resource leaks

**Run Command**:
```
Select folder 7: "Cleanup & Teardown"
Run 2 requests
```

---

## 🏃‍♂️ Running Tests

### Full Test Suite (Recommended)

```bash
# Run all 24 tests in sequence
1. Open Collection Runner
2. Select "Test-Infra-microservice"
3. Enable all folders (default)
4. Click "Run"
```

**Duration**: ~10-15 seconds

---

### Individual Test Folders

Run specific test categories:

```bash
# Infrastructure only
Run folder 1: Infrastructure Health Checks (5 tests)

# Session management only
Run folder 2: Session Management (3 tests)

# Load testing only
Run folder 6: Load Testing & Performance (3 tests)
```

---

### Load Testing Configuration

For performance testing, use Collection Runner with iterations:

1. Select folder: **"Load Testing & Performance"**
2. Set **Iterations**: `100`
3. Set **Delay**: `0ms`
4. Click **Run**

**Expected Results**:
- 100 sessions created
- Session count increases to 100+
- Response times remain consistent

---

### Automated CI/CD Testing

Use Newman for automated testing:

```bash
# Install Newman
npm install -g newman

# Run collection
newman run postman/Test-Infra-microservice.json \
  --environment postman/environment.json \
  --iteration-count 1 \
  --reporters cli,json

# Load test (100 iterations)
newman run postman/Test-Infra-microservice.json \
  --folder "6. Load Testing & Performance" \
  --iteration-count 100 \
  --reporters cli,htmlextra
```

---

## 📊 Test Coverage

### Complete Test Matrix

| Category | Tests | Assertions | Coverage |
|----------|-------|------------|----------|
| Infrastructure | 5 | 15 | Health, UI accessibility, Metrics |
| Session Management | 3 | 12 | Create, Persist, Attributes |
| API Gateway | 3 | 9 | Routes, Metrics, Distribution |
| Event-Driven | 2 | 5 | Order context, Event flow |
| Observability | 4 | 8 | JVM, App info, Config, Logs |
| Performance | 3 | 9 | Load, Throughput, Metrics |
| Cleanup | 2 | 4 | Logout, Final health |
| **Total** | **22** | **62** | **Full Stack** |

---

### Coverage Areas

✅ **API Gateway**: Session management, Health checks, Actuator endpoints  
✅ **Redis**: Session storage, Persistence, TTL, Memory  
✅ **Prometheus**: Metrics collection, Exposition format  
✅ **Jaeger**: Tracing UI accessibility  
✅ **Grafana**: Dashboard UI accessibility  
✅ **Spring Boot**: Actuator, Info, Environment, Loggers  
✅ **Performance**: Load testing, Throughput, Response times  

---

## 📈 Interpreting Results

### Success Indicators

**✅ All Tests Pass**:
```
Test Results: (62/62 passed)
Passed:  62
Failed:  0
Skipped: 0
```

**Console Output**:
```
✅ API Gateway Health Check PASSED
✅ SESSION CREATED
✅ SESSION PERSISTED IN REDIS
✅ GATEWAY ROUTES DISCOVERED
✅ JVM METRICS CAPTURED
✅ LOAD TEST SESSION CREATED
✅ SESSION DESTROYED
🎉 ALL MICROSERVICE TESTS COMPLETED SUCCESSFULLY
```

---

### Performance Metrics

**Good Performance**:
```
API Gateway Health: < 500ms
Session Creation: < 1000ms
Session Retrieval: < 100ms
Metrics Endpoint: < 200ms
```

**Review Response Times**:
```javascript
// In Collection Runner results
View "Response Time" column
Sort by time to find slowest requests
```

---

### Common Test Failures

#### ❌ Health Check Fails

**Error**: `Service is DOWN`

**Solutions**:
```bash
# Check service status
docker-compose ps

# Restart unhealthy service
docker-compose restart api-gateway

# Check logs
docker-compose logs api-gateway
```

---

#### ❌ Session Not Created

**Error**: `Session ID is null`

**Solutions**:
```bash
# Verify Redis is running
docker exec redis-session redis-cli ping

# Check API Gateway can reach Redis
docker logs api-gateway | grep -i redis

# Restart services
docker-compose restart api-gateway redis
```

---

#### ❌ Metrics Not Available

**Error**: `Metrics endpoint returns 404`

**Solutions**:
```yaml
# Verify actuator configuration in application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
```

---

## 🔧 Troubleshooting

### Pre-Test Checklist

Before running tests, verify:

```bash
# 1. All services running
docker-compose ps
# All should show "Up" and "healthy"

# 2. API Gateway accessible
curl http://localhost:8080/api/health

# 3. Redis accessible
docker exec redis-session redis-cli ping

# 4. Ports not blocked
netstat -ano | findstr :8080
netstat -ano | findstr :6379
```

---

### During Test Issues

#### Tests Timeout

```bash
# Increase timeout in Postman settings
Settings → Request timeout → 30000ms

# Or use Collection Runner → Advanced → Request timeout
```

---

#### Variables Not Set

```bash
# Check collection variables
Collection → Variables tab

# Reset variables if needed
sessionId: (empty)
userId: (empty)
orderId: (empty)
```

---

#### Redis Connection Failed

```bash
# Test Redis connection
docker exec redis-session redis-cli KEYS "*"

# Check session storage
docker exec redis-session redis-cli KEYS "spring:session:*"

# Verify Redis memory
docker exec redis-session redis-cli INFO memory
```

---

### Post-Test Cleanup

```bash
# Clear old sessions (optional)
docker exec redis-session redis-cli FLUSHALL

# Restart services for clean state
docker-compose restart

# Check final health
curl http://localhost:8080/api/health
```

---

## 🎯 Best Practices

### Before Testing

1. ✅ Ensure all services healthy
2. ✅ Clear old test data (optional)
3. ✅ Check network connectivity
4. ✅ Review collection variables

### During Testing

1. ✅ Run full suite first
2. ✅ Review each test result
3. ✅ Check console output
4. ✅ Monitor response times

### After Testing

1. ✅ Review test summary
2. ✅ Check for failed tests
3. ✅ Analyze performance metrics
4. ✅ Run cleanup requests

---

## 📚 Additional Resources

### Related Documentation

- [Redis Session Quick Start](../REDIS_SESSION_QUICKSTART.md)
- [API Gateway README](../api-gateway/README.md)
- [Architecture Documentation](../Architecture.md)
- [Main README](../README.md)

### Monitoring Dashboards

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Jaeger**: http://localhost:16686
- **Redis Commander**: http://localhost:8081

### Newman Documentation

- [Newman GitHub](https://github.com/postmanlabs/newman)
- [Newman CLI Options](https://learning.postman.com/docs/running-collections/using-newman-cli/command-line-integration-with-newman/)

---

## 🤝 Contributing

Found issues or want to add more tests?

1. Fork the repository
2. Add new test scenarios
3. Update this guide
4. Submit pull request

---

## 📄 License

MIT License - See [LICENSE](../LICENSE) for details

---

<div align="center">

**🎉 Happy Testing!**

*Part of the Spring Boot Microservices with gRPC, Kafka & Redis project*

[GitHub Repository](https://github.com/HamdeeNaseng/Spring-Boot-gRPC) | [Report Issues](https://github.com/HamdeeNaseng/Spring-Boot-gRPC/issues)

</div>
