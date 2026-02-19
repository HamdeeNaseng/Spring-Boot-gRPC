# 💳 Payment Service

Spring Boot microservice for processing payments via Kafka event-driven architecture.

## 🎯 Purpose

- **Kafka Consumer** - Listen to order events
- **Payment Processing** - Handle payment transactions
- **PostgreSQL Integration** - Persist payment records
- **Observability** - Metrics and distributed tracing

---

## 🚀 Features

- ✅ Consume order events from Kafka
- ✅ Automatic payment processing
- ✅ Payment status tracking
- ✅ REST API for payment queries
- ✅ PostgreSQL persistence
- ✅ Prometheus metrics
- ✅ Distributed tracing with Jaeger
- ✅ Health checks

---

## 🛠️ Tech Stack

- **Framework**: Spring Boot 3.2
- **Language**: Java 17
- **Messaging**: Kafka (Consumer)
- **Database**: PostgreSQL
- **Metrics**: Micrometer + Prometheus
- **Tracing**: Zipkin/Jaeger

---

## 📡 Endpoints

### HTTP REST API (Port 8082)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/payments` | GET | Get all payments |
| `/api/payments/order/{orderId}` | GET | Get payment by order ID |
| `/api/payments/user/{userId}` | GET | Get payments by user ID |
| `/api/payments/stats` | GET | Payment statistics |
| `/actuator/health` | GET | Actuator health |
| `/actuator/metrics` | GET | Metrics list |
| `/actuator/prometheus` | GET | Prometheus metrics |

---

## 🔧 Configuration

### Environment Variables

```yaml
POSTGRES_HOST: localhost
POSTGRES_DB: paymentsdb
POSTGRES_USER: postgres
POSTGRES_PASSWORD: postgres
KAFKA_BOOTSTRAP_SERVERS: localhost:9092
SERVER_PORT: 8082
ZIPKIN_URL: http://localhost:9411/api/v2/spans
```

### Kafka Topics (Consumed)

- `order.created` - New order events
- `order.updated` - Order status updates

---

## 🏗️ Build & Run

### Local Development

```bash
# Build
mvn clean package -DskipTests

# Run
java -jar target/payment-service-1.0.0.jar
```

### Docker

```bash
# Build image
docker build -t payment-service:latest .

# Run container
docker run -p 8082:8082 \
  -e POSTGRES_HOST=postgres \
  -e KAFKA_BOOTSTRAP_SERVERS=kafka:9092 \
  payment-service:latest
```

### Docker Compose

```bash
docker-compose up -d payment-service
```

---

## 🧪 Testing

### Check Health

```bash
curl http://localhost:8082/api/health
```

### Get All Payments

```bash
curl http://localhost:8082/api/payments
```

### Get Payment by Order ID

```bash
curl http://localhost:8082/api/payments/order/{orderId}
```

### Get Payment Statistics

```bash
curl http://localhost:8082/api/payments/stats
```

**Sample Response:**
```json
{
  "totalPayments": 25,
  "completed": 22,
  "failed": 2,
  "pending": 0,
  "processing": 1,
  "totalAmountProcessed": 45678.90,
  "successRate": 88.0
}
```

---

## 📊 Monitoring

### Prometheus Metrics

```
http://localhost:8082/actuator/prometheus
```

**Key Metrics:**
- `kafka_consumer_records_consumed_total`
- `kafka_consumer_fetch_manager_records_lag`
- `jvm_memory_used_bytes`
- `http_server_requests_seconds`

### Jaeger Tracing

```
http://localhost:16686
```

Search for service: `payment-service`

---

## 📁 Project Structure

```
payment-service/
├── src/main/java/com/spring/grpc/payment/
│   ├── PaymentServiceApplication.java
│   ├── config/
│   │   └── KafkaConsumerConfig.java
│   ├── consumer/
│   │   └── OrderEventConsumer.java
│   ├── controller/
│   │   ├── HealthController.java
│   │   └── PaymentController.java
│   ├── dto/
│   │   └── OrderEvent.java
│   ├── entity/
│   │   └── Payment.java
│   ├── repository/
│   │   └── PaymentRepository.java
│   └── service/
│       └── PaymentService.java
├── src/main/resources/
│   └── application.yml
├── Dockerfile
└── pom.xml
```

---

## 🔄 Payment Flow

```
1. Order Created Event → Kafka Topic
2. Payment Service Consumes Event
3. Payment Record Created (Status: PENDING)
4. Payment Processing Started (Status: PROCESSING)
5. Payment Gateway Simulation (90% success rate)
6. Final Status: COMPLETED or FAILED
```

### Payment Status States

```
PENDING → PROCESSING → COMPLETED
                  ↓
                FAILED
```

---

## 📨 Event Processing

### Order Created Event

When an order is created, the payment service:

1. **Creates Payment Record**
   - Order ID
   - User ID
   - Amount
   - Status: PENDING

2. **Processes Payment Asynchronously**
   - Simulates payment gateway call
   - Updates status to PROCESSING
   - Completes or fails (90% success simulation)
   - Generates transaction ID on success

3. **Logs Results**
   - Success: Transaction ID
   - Failure: Error message

### Order Updated Event

When an order is updated:

- **CANCELLED** status → Log cancellation (in production: refund)
- Other status changes → Log for audit

---

## 🐛 Troubleshooting

### Kafka Consumer Not Receiving Events

```bash
# Check Kafka topics
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Check consumer group
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group payment-service-group \
  --describe
```

### Database Connection Issues

```bash
# Check PostgreSQL
docker exec postgres psql -U postgres -d paymentsdb -c "\dt"

# Test connection
docker logs payment-service | grep -i postgres
```

### Payment Processing Issues

```bash
# Check application logs
docker logs -f payment-service

# Check for errors
docker logs payment-service | grep -i error
```

---

## 📄 License

MIT License - See [LICENSE](../LICENSE)

---

<div align="center">

**Part of Spring Boot Microservices Architecture**

[Main Documentation](../README.md) | [Architecture](../Architecture.md)

</div>
