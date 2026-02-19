# Spring Boot gRPC Microservices - Testing Guide

## 🚀 Services Overview

All services are now running successfully on Docker!

### Service Endpoints

| Service | Port | Health Endpoint |
|---------|------|----------------|
| **Order Service** | 8081 (HTTP), 9091 (gRPC) | http://localhost:8081/api/health |
| **Payment Service** | 8082 | http://localhost:8082/api/health |
| **API Gateway** | 8080 | http://localhost:8080/actuator/health |
| **PostgreSQL** | 5432 | - |
| **Redis** | 6379 | - |
| **Kafka** | 9092 | - |
| **Prometheus** | 9090 | http://localhost:9090 |
| **Grafana** | 3000 | http://localhost:3000 |
| **Jaeger** | 16686 | http://localhost:16686 |
| **Redis UI** | 8083 | http://localhost:8083 |

## 📦 Postman Collection

A Postman collection has been created in your workspace:
- **Collection Name**: Spring Boot gRPC - Order & Payment Services
- **Collection ID**: 30673319-c55d3f8f-d83b-4b7b-8fa8-3806c1af10b1

### Collection Structure

1. **Health Checks**
   - Order Service Health
   - Payment Service Health
   - API Gateway Health

2. **Order Service API**
   - Get All Orders
   - Create Order
   - Get Order by ID
   - UpDate Order Status
   - Get Orders by User ID
   - Get Orders by Status

3. **Payment Service API**
   - Get All Payments
   - Get Payment by ID
   - Get Payment by Order ID
   - Get Payments by User ID
   - Get Payments by Status
   - Get Payment Statistics

4. **Integration Tests**
   - Complete Order → Payment Flow

## 🧪 Manual Testing with cURL

### Order Service Tests

#### 1. Health Check
```bash
curl http://localhost:8081/api/health
```

Expected Response:
```json
{
  "status": "UP",
  "service": "order-service",
  "database": "UP",
  "kafka": "UP"
}
```

#### 2. Create Order
```bash
curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-001",
    "productId": "prod-12345",
    "productName": "Macbook Pro",
    "quantity": 1,
    "price": 2499.99
  }'
```

Expected Response (201 Created):
```json
{
  "orderId": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "user-001",
  "productId": "prod-12345",
   "productName": "Macbook Pro",
  "quantity": 1,
  "price": 2499.99,
  "totalAmount": 2499.99,
  "status": "PENDING",
  "createdAt": "2026-02-19T10:00:00",
  "updatedAt": "2026-02-19T10:00:00"
}
```

**Note:** Save the `orderId` from the response for subsequent tests!

#### 3. Get All Orders
```bash
curl "http://localhost:8081/api/orders?page=0&size=10"
```

#### 4. Get Order by ID
```bash
curl http://localhost:8081/api/orders/{ORDER_ID}
```
*Replace {ORDER_ID} with the actual order ID*

#### 5. Get Orders by User
```bash
curl "http://localhost:8081/api/orders/user/user-001?page=0&size=10"
```

#### 6. Get Orders by Status
```bash
curl "http://localhost:8081/api/orders/status/PENDING?page=0&size=10"
```

Valid statuses: `PENDING`, `CONFIRMED`, `SHIPPED`, `DELIVERED`, `CANCELLED`

#### 7. Update Order Status
```bash
curl -X PUT http://localhost:8081/api/orders/{ORDER_ID}/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "CONFIRMED"
  }'
```

### Payment Service Tests

#### 1. Health Check
```bash
curl http://localhost:8082/api/health
```

#### 2. Get All Payments
```bash
curl "http://localhost:8082/api/payments?page=0&size=10"
```

#### 3. Get Payment by Order ID
```bash
curl http://localhost:8082/api/payments/order/{ORDER_ID}
```

**Note:** After creating an order, wait 2-3 seconds for Kafka to process the event and create the payment automatically.

#### 4. Get Payments by User
```bash
curl "http://localhost:8082/api/payments/user/user-001?page=0&size=10"
```

#### 5. Get Payments by Status
```bash
curl "http://localhost:8082/api/payments/status/COMPLETED?page=0&size=10"
```

Valid statuses: `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED`, `REFUNDED`

#### 6. Get Payment Statistics
```bash
curl http://localhost:8082/api/payments/statistics
```

Expected Response:
```json
{
  "totalPayments": 10,
  "totalAmount": 15000.50,
  "completedPayments": 8,
  "pendingPayments": 1,
  "failedPayments": 1
}
```

## 🔄 Integration Test Flow

### Complete Order-to-Payment Flow

1. **Create an Order**
```bash
curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "integration-test-user",
    "productId": "prod-integration",
    "productName": "Integration Test Product",
    "quantity": 5,
    "price": 99.99
  }'
```

2. **Wait 3-5 seconds** for Kafka to process the event

3. **Verify Payment Created**
```bash
curl http://localhost:8082/api/payments/order/{ORDER_ID}
```

4. **Verify Payment Amount**
The payment amount should equal `quantity * price = 5 * 99.99 = 499.95`

## 🐛 Troubleshooting

### Check Service Logs
```bash
# Order Service
docker logs order-service --tail 50

# Payment Service
docker logs payment-service --tail 50

# Kafka
docker logs kafka --tail 50

# Check all running services
docker-compose ps
```

### Verify Kafka is Processing Messages
```bash
# Connect to Kafka container
docker exec -it kafka bash

# List topics
kafka-topics --list --bootstrap-server localhost:9092

# Consume order-events topic
kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic order-events --from-beginning
```

### Database Access
```bash
# Connect to PostgreSQL
docker exec -it postgres-db psql -U myuser

# List databases
\l

# Connect to ordersdb
\c ordersdb

# View orders table
SELECT * FROM orders;

# Connect to paymentsdb
\c paymentsdb

# View payments table
SELECT * FROM payments;
```

### Redis Access
Access Redis Commander UI: http://localhost:8083

## 📊 Monitoring & Observability

- **Prometheus Metrics**: http://localhost:9090
- **Grafana Dashboards**: http://localhost:3000 (admin/admin)
- **Jaeger Tracing**: http://localhost:16686
- **Redis Commander**: http://localhost:8083

## ✅ Pre-Deployment Fixes Applied

1. ✅ Fixed Kafka cluster ID mismatch by removing old volumes
2. ✅ Fixed port conflict on 9090 (changed gRPC port to 9091)
3. ✅ Created PostgreSQL databases: `ordersdb` and `paymentsdb`
4. ✅ Fixed Redis Commander port conflict (changed to 8083)
5. ✅ All services now healthy and running

## 🎯 Test Scenarios

### Scenario 1: Happy Path
1. Create order → Status: PENDING
2. Payment auto-created via Kafka → Status: COMPLETED
3. Update order status to CONFIRMED
4. Verify payment exists with correct amount

### Scenario 2: Multiple Orders
1. Create 5 orders for same user
2. Query orders by user ID
3. Verify 5 payments created
4. Check payment statistics

### Scenario 3: Order Status Updates
1. Create order
2. Update to CONFIRMED
3. Update to SHIPPED
4. Update to DELIVERED
5. Verify all status changes persisted

## 📝 Notes

- **Order Creation**: Automatically publishes event to Kafka topic `order-events`
- **Payment Processing**: Payment Service consumes from `order-events` and creates payment
- **Database**: Orders and Payments stored in separate PostgreSQL databases
- **Caching**: API Gateway uses Redis for session management
- **Tracing**: All requests traced via Jaeger (OpenTelemetry)
- **Metrics**: Prometheus collects metrics from all services

## 🔗 Architecture

```
Client → API Gateway (8080)
           ↓
       Order Service (8081, gRPC: 9091)
           ↓
       Kafka (order-events)
           ↓
       Payment Service (8082)
```

## 🎉 Success Criteria

All services are healthy and the complete stack is running:
- ✅ PostgreSQL (2 databases: ordersdb, paymentsdb)
- ✅ Redis + Redis Commander
- ✅ Kafka + Zookeeper
- ✅ Order Service (HTTP + gRPC)
- ✅ Payment Service
- ✅ API Gateway
- ✅ Prometheus, Grafana, Jaeger

**Your microservices are ready for testing!** 🚀
