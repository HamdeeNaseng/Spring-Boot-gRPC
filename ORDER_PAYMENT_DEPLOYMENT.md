# 🚀 Order & Payment Services Deployment Guide

Complete guide for building and deploying the newly created Order Service and Payment Service.

---

## 📋 What Was Created

### 1. **Order Service** (gRPC Server + Kafka Producer)
- **Port**: 8081 (HTTP), 9090 (gRPC)
- **Technology**: Spring Boot, gRPC, Kafka Producer, PostgreSQL
- **Database**: ordersdb
- **Purpose**: Handle order creation via gRPC and publish events to Kafka

### 2. **Payment Service** (Kafka Consumer)
- **Port**: 8082 (HTTP)
- **Technology**: Spring Boot, Kafka Consumer, PostgreSQL
- **Database**: paymentsdb
- **Purpose**: Process order events and handle payments

### 3. **Proto Definitions**
- **File**: `proto/order.proto`
- **Services**: CreateOrder, GetOrder, ListOrders, UpdateOrderStatus

---

## 🏗️ Architecture Flow

```
┌──────────┐     gRPC      ┌──────────────┐     Kafka     ┌─────────────────┐
│  Client  │ ────────────► │ Order Service│ ────────────► │ Payment Service │
└──────────┘               └──────────────┘  order.created└─────────────────┘
                                 │                              │
                                 ▼                              ▼
                           ┌──────────┐                  ┌──────────┐
                           │PostgreSQL│                  │PostgreSQL│
                           │ ordersdb │                  │paymentsdb│
                           └──────────┘                  └──────────┘
```

---

## 📦 Project Structure

```
order-service/
├── src/main/java/com/spring/grpc/order/
│   ├── OrderServiceApplication.java
│   ├── config/KafkaProducerConfig.java
│   ├── controller/HealthController.java
│   ├── dto/OrderEvent.java
│   ├── entity/Order.java
│   ├── repository/OrderRepository.java
│   └── service/
│       ├── OrderBusinessService.java
│       └── OrderServiceImpl.java (gRPC)
├── src/main/resources/application.yml
├── Dockerfile
└── pom.xml

payment-service/
├── src/main/java/com/spring/grpc/payment/
│   ├── PaymentServiceApplication.java
│   ├── config/KafkaConsumerConfig.java
│   ├── consumer/OrderEventConsumer.java
│   ├── controller/
│   │   ├── HealthController.java
│   │   └── PaymentController.java
│   ├── dto/OrderEvent.java
│   ├── entity/Payment.java
│   ├── repository/PaymentRepository.java
│   └── service/PaymentService.java
├── src/main/resources/application.yml
├── Dockerfile
└── pom.xml
```

---

## 🚀 Quick Start

### Step 1: Build Services

```bash
# Navigate to project root
cd d:\imed-\GitHub\Spring-Boot-gRPC

# Build Order Service
cd order-service
mvn clean package -DskipTests
cd ..

# Build Payment Service
cd payment-service
mvn clean package -DskipTests
cd ..
```

### Step 2: Start All Services

```bash
# Start entire stack
docker-compose up -d

# Or start services individually
docker-compose up -d postgres redis kafka
docker-compose up -d order-service
docker-compose up -d payment-service
```

### Step 3: Verify Services

```bash
# Check all services
docker-compose ps

# Expected output:
# order-service    Up & healthy
# payment-service  Up & healthy
# postgres         Up & healthy
# kafka            Up & healthy
# redis            Up & healthy
```

### Step 4: Test Order Service

```bash
# Using grpcurl (install if needed: choco install grpcurl)
grpcurl -plaintext -d '{
  "user_id": "user123",
  "product_id": "laptop001",
  "product_name": "MacBook Pro",
  "quantity": 1,
  "price": 2499.99
}' localhost:9090 order.OrderService/CreateOrder
```

**Expected Response:**
```json
{
  "orderId": "uuid-generated",
  "userId": "user123",
  "productId": "laptop001",
  "productName": "MacBook Pro",
  "quantity": 1,
  "price": 2499.99,
  "totalAmount": 2499.99,
  "status": "PENDING",
  "createdAt": "2026-02-19T...",
  "message": "Order created successfully"
}
```

### Step 5: Verify Payment Processing

```bash
# Check payment was created and processed
curl http://localhost:8082/api/payments

# Get payment statistics
curl http://localhost:8082/api/payments/stats
```

---

## 🧪 Testing Scenarios

### 1. Complete Order Flow Test

```bash
# 1. Create order (gRPC)
grpcurl -plaintext -d '{
  "user_id": "testuser",
  "product_id": "prod123",
  "product_name": "Gaming Laptop",
  "quantity": 2,
  "price": 1200.50
}' localhost:9090 order.OrderService/CreateOrder

# Save the orderId from response

# 2. Wait 3 seconds for payment processing

# 3. Check payment status
curl http://localhost:8082/api/payments/order/{orderId}

# 4. Check order details
grpcurl -plaintext -d '{
  "order_id": "your-order-id"
}' localhost:9090 order.OrderService/GetOrder
```

### 2. List All Orders

```bash
grpcurl -plaintext -d '{
  "page": 0,
  "size": 10
}' localhost:9090 order.OrderService/ListOrders
```

### 3. Update Order Status

```bash
grpcurl -plaintext -d '{
  "order_id": "your-order-id",
  "status": "CONFIRMED"
}' localhost:9090 order.OrderService/UpdateOrderStatus
```

### 4. Check Payment Statistics

```bash
curl http://localhost:8082/api/payments/stats
```

**Sample Response:**
```json
{
  "totalPayments": 5,
  "completed": 4,
  "failed": 1,
  "pending": 0,
  "processing": 0,
  "totalAmountProcessed": 7899.96,
  "successRate": 80.0
}
```

---

## 📊 Monitoring

### Check Service Health

```bash
# Order Service
curl http://localhost:8081/api/health

# Payment Service
curl http://localhost:8082/api/health
```

### Prometheus Metrics

```bash
# Order Service metrics
curl http://localhost:8081/actuator/prometheus

# Payment Service metrics
curl http://localhost:8082/actuator/prometheus

# View in Prometheus UI
# http://localhost:9090
# Query: kafka_producer_record_send_total
# Query: kafka_consumer_records_consumed_total
```

### Grafana Dashboards

```
http://localhost:3000 (admin/admin)

Create dashboards for:
- Order creation rate
- Payment success rate
- Kafka lag
- Response times
```

### Jaeger Tracing

```
http://localhost:16686

Search for:
- Service: order-service
- Service: payment-service

View full request traces across services
```

---

## 🔍 Kafka Inspection

### Check Topics

```bash
docker exec kafka kafka-topics \
  --list \
  --bootstrap-server localhost:9092
```

**Expected topics:**
- order.created
- order.updated

### Monitor Messages

```bash
# Monitor order.created topic
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic order.created \
  --from-beginning

# Monitor order.updated topic
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic order.updated \
  --from-beginning
```

### Check Consumer Groups

```bash
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group payment-service-group \
  --describe
```

---

## 💾 Database Inspection

### Order Service Database

```bash
# Connect to PostgreSQL
docker exec -it postgres-db psql -U myuser -d ordersdb

# List orders
SELECT * FROM orders;

# Exit
\q
```

### Payment Service Database

```bash
# Connect to PostgreSQL
docker exec -it postgres-db psql -U myuser -d paymentsdb

# List payments
SELECT * FROM payments;

# Payment statistics
SELECT 
  status, 
  COUNT(*) as count, 
  SUM(amount) as total_amount 
FROM payments 
GROUP BY status;

# Exit
\q
```

---

## 🔧 Troubleshooting

### Services Not Starting

```bash
# Check logs
docker logs order-service
docker logs payment-service

# Rebuild images
docker-compose build order-service payment-service
docker-compose up -d order-service payment-service
```

### gRPC Connection Issues

```bash
# Test gRPC server is listening
netstat -ano | findstr :9090

# List gRPC services
grpcurl -plaintext localhost:9090 list

# List methods
grpcurl -plaintext localhost:9090 list order.OrderService
```

### Kafka Connection Issues

```bash
# Check Kafka is running
docker logs kafka

# Test connection from order-service
docker exec order-service curl kafka:29092

# Restart Kafka
docker-compose restart kafka
```

### Payment Processing Not Working

```bash
# Check if consumer is running
docker logs payment-service | grep -i "kafka"

# Verify consumer group
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
docker exec postgres-db pg_isready -U myuser

# Check if databases exist
docker exec postgres-db psql -U myuser -c "\l"

# Create databases if missing
docker exec postgres-db psql -U myuser -c "CREATE DATABASE ordersdb;"
docker exec postgres-db psql -U myuser -c "CREATE DATABASE paymentsdb;"
```

---

## 🔄 Rebuild After Code Changes

```bash
# Rebuild specific service
cd order-service
mvn clean package -DskipTests
cd ..
docker-compose build order-service
docker-compose up -d order-service

# Or rebuild all
mvn clean package -DskipTests -f order-service/pom.xml
mvn clean package -DskipTests -f payment-service/pom.xml
docker-compose build
docker-compose up -d
```

---

## 📈 Performance Metrics

### Key Metrics to Monitor

**Order Service:**
- `grpc_server_requests_total` - Total gRPC requests
- `kafka_producer_record_send_total` - Kafka messages sent
- `http_server_requests_seconds` - HTTP response times
- `jvm_memory_used_bytes` - Memory usage

**Payment Service:**
- `kafka_consumer_records_consumed_total` - Messages consumed
- `kafka_consumer_fetch_manager_records_lag` - Consumer lag
- `http_server_requests_seconds` - HTTP response times
- `jvm_memory_used_bytes` - Memory usage

---

## 🎯 Load Testing

### Using Artillery (install: npm install -g artillery)

Create `load-test.yml`:
```yaml
config:
  target: "http://localhost:9090"
  phases:
    - duration: 60
      arrivalRate: 10
scenarios:
  - name: "Create orders"
    flow:
      - post:
          url: "/"
          json:
            user_id: "load_test_user"
            product_id: "prod_{{ $randomNumber(1, 1000) }}"
            product_name: "Product {{ $randomNumber(1, 1000) }}"
            quantity: "{{ $randomNumber(1, 5) }}"
            price: "{{ $randomNumber(10, 1000) }}"
```

Run:
```bash
artillery run load-test.yml
```

---

## 📄 API Documentation

### Order Service gRPC API

See: [order-service/README.md](order-service/README.md)

### Payment Service REST API

See: [payment-service/README.md](payment-service/README.md)

---

## 🎉 Success Checklist

- ✅ Both services built successfully
- ✅ Docker containers running and healthy
- ✅ Order creation via gRPC works
- ✅ Kafka events published to `order.created`
- ✅ Payment service consumes events
- ✅ Payments created and processed
- ✅ PostgreSQL databases populated
- ✅ Prometheus scraping metrics
- ✅ Jaeger showing traces
- ✅ Health endpoints responding

---

## 📚 Additional Resources

- [Main README](README.md)
- [Architecture Documentation](Architecture.md)
- [Order Service README](order-service/README.md)
- [Payment Service README](payment-service/README.md)
- [Postman Testing Guide](postman/MICROSERVICES_TEST_GUIDE.md)

---

<div align="center">

**🎉 Order & Payment Services Ready!**

*Complete event-driven microservices architecture with gRPC and Kafka*

[GitHub Repository](https://github.com/HamdeeNaseng/Spring-Boot-gRPC)

</div>
