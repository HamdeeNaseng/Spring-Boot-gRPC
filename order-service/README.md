# 📦 Order Service

Spring Boot microservice providing gRPC-based order management with Kafka event streaming.

## 🎯 Purpose

- **gRPC Server** - Accept order creation and management requests
- **Kafka Producer** - Publish order events for downstream services
- **PostgreSQL Integration** - Persist order data
- **Observability** - Metrics and distributed tracing

---

## 🚀 Features

- ✅ Create orders via gRPC
- ✅ List orders with pagination
- ✅ Update order status
- ✅ Publish events to Kafka
- ✅ PostgreSQL persistence
- ✅ Prometheus metrics
- ✅ Distributed tracing with Jaeger
- ✅ Health checks

---

## 🛠️ Tech Stack

- **Framework**: Spring Boot 3.2
- **Language**: Java 17
- **RPC**: gRPC 1.59
- **Messaging**: Kafka
- **Database**: PostgreSQL
- **Metrics**: Micrometer + Prometheus
- **Tracing**: Zipkin/Jaeger

---

## 📡 Endpoints

### gRPC Service (Port 9090)

```protobuf
service OrderService {
  rpc CreateOrder (CreateOrderRequest) returns (CreateOrderResponse);
  rpc GetOrder (GetOrderRequest) returns (GetOrderResponse);
  rpc ListOrders (ListOrdersRequest) returns (ListOrdersResponse);
  rpc UpdateOrderStatus (UpdateOrderStatusRequest) returns (UpdateOrderStatusResponse);
}
```

### HTTP Endpoints (Port 8081)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/actuator/health` | GET | Actuator health |
| `/actuator/metrics` | GET | Metrics list |
| `/actuator/prometheus` | GET | Prometheus metrics |

---

## 🔧 Configuration

### Environment Variables

```yaml
POSTGRES_HOST: localhost
POSTGRES_DB: ordersdb
POSTGRES_USER: postgres
POSTGRES_PASSWORD: postgres
KAFKA_BOOTSTRAP_SERVERS: localhost:9092
GRPC_PORT: 9090
SERVER_PORT: 8081
ZIPKIN_URL: http://localhost:9411/api/v2/spans
```

### Kafka Topics

- `order.created` - Published when order is created
- `order.updated` - Published when order status changes

---

## 🏗️ Build & Run

### Local Development

```bash
# Build
mvn clean package -DskipTests

# Run
java -jar target/order-service-1.0.0.jar
```

### Docker

```bash
# Build image
docker build -t order-service:latest .

# Run container
docker run -p 8081:8081 -p 9090:9090 \
  -e POSTGRES_HOST=postgres \
  -e KAFKA_BOOTSTRAP_SERVERS=kafka:9092 \
  order-service:latest
```

### Docker Compose

```bash
docker-compose up -d order-service
```

---

## 🧪 Testing

### gRPC Client (grpcurl)

```bash
# Create order
grpcurl -plaintext -d '{
  "user_id": "user123",
  "product_id": "prod456",
  "product_name": "Laptop",
  "quantity": 2,
  "price": 1200.50
}' localhost:9090 order.OrderService/CreateOrder

# Get order
grpcurl -plaintext -d '{
  "order_id": "uuid-here"
}' localhost:9090 order.OrderService/GetOrder

# List orders
grpcurl -plaintext -d '{
  "page": 0,
  "size": 10,
  "user_id": "user123"
}' localhost:9090 order.OrderService/ListOrders
```

### Health Check

```bash
curl http://localhost:8081/api/health
```

---

## 📊 Monitoring

### Prometheus Metrics

```
http://localhost:8081/actuator/prometheus
```

**Key Metrics:**
- `grpc_server_requests_total`
- `kafka_producer_record_send_total`
- `jvm_memory_used_bytes`
- `http_server_requests_seconds`

### Jaeger Tracing

```
http://localhost:16686
```

Search for service: `order-service`

---

## 📁 Project Structure

```
order-service/
├── src/main/java/com/spring/grpc/order/
│   ├── OrderServiceApplication.java
│   ├── config/
│   │   └── KafkaProducerConfig.java
│   ├── controller/
│   │   └── HealthController.java
│   ├── dto/
│   │   └── OrderEvent.java
│   ├── entity/
│   │   └── Order.java
│   ├── repository/
│   │   └── OrderRepository.java
│   └── service/
│       ├── OrderBusinessService.java
│       └── OrderServiceImpl.java (gRPC)
├── src/main/resources/
│   └── application.yml
├── Dockerfile
└── pom.xml
```

---

## 🔄 Order Status Flow

```
PENDING → CONFIRMED → PROCESSING → COMPLETED
              ↓
          CANCELLED
```

---

## 📨 Kafka Event Schema

```json
{
  "orderId": "uuid",
  "userId": "user123",
  "productId": "prod456",
  "productName": "Laptop",
  "quantity": 2,
  "price": 1200.50,
  "totalAmount": 2401.00,
  "status": "PENDING",
  "createdAt": "2026-02-19T10:30:00",
  "eventType": "CREATED"
}
```

---

## 🐛 Troubleshooting

### gRPC Connection Issues

```bash
# Check if gRPC server is listening
netstat -ano | findstr :9090

# Test with grpcurl
grpcurl -plaintext localhost:9090 list
```

### Kafka Connection Issues

```bash
# Check Kafka logs
docker logs kafka

# Verify topics
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Database Issues

```bash
# Check PostgreSQL connection
docker exec postgres psql -U postgres -d ordersdb -c "\dt"
```

---

## 📄 License

MIT License - See [LICENSE](../LICENSE)

---

<div align="center">

**Part of Spring Boot Microservices Architecture**

[Main Documentation](../README.md) | [Architecture](../Architecture.md)

</div>
