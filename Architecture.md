นี่คือ **Architecture Demo: Spring Boot + gRPC + Kafka + Postgres + Metrics + Tracing + Dashboard View**
ออกแบบให้เป็น **Production-style Microservice Demo** เหมาะกับโชว์ในงาน Tech / Portfolio / Interview

---

# 🏗 High-Level Architecture

```
                ┌─────────────────────┐
                │      Client App      │
                │  (Web / Postman)     │
                └──────────┬──────────┘
                           │ HTTP / REST
                           ▼
                ┌─────────────────────┐      ┌──────────┐
                │  API Gateway (SB)   │◄─────┤  Redis   │
                │  + gRPC Client      │      │ Session  │
                └──────────┬──────────┘      └──────────┘
                           │ gRPC
                           ▼
                ┌─────────────────────┐
                │  Order Service      │
                │  Spring Boot + gRPC │
                │  + Kafka Producer   │
                └──────────┬──────────┘
                           │ Kafka Event
                           ▼
                ┌─────────────────────┐
                │  Payment Service    │
                │  Spring Boot        │
                │  Kafka Consumer     │
                └──────────┬──────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  PostgreSQL │
                    └─────────────┘

Observability Layer:
- Metrics → Prometheus
- Dashboard → Grafana
- Tracing → Jaeger / Zipkin
```

---

# 🧩 Tech Stack

| Layer           | Technology   |
| --------------- | ------------ |
| Framework       | Spring Boot  |
| RPC             | gRPC         |
| Event Streaming | Apache Kafka |
| Database        | PostgreSQL   |
| Session Store   | Redis        |
| Metrics         | Prometheus   |
| Dashboard       | Grafana      |
| Tracing         | Jaeger       |
| Container       | Docker       |

---

# 🔁 Flow การทำงาน

### 1️⃣ Client → REST

* Client เรียก `POST /orders`
* API Gateway รับ request
* Redis เก็บ session data (authentication, user context)

### 2️⃣ Gateway → gRPC

* Gateway เรียก `OrderService` ผ่าน gRPC

### 3️⃣ Order Service

* บันทึกข้อมูลลง PostgreSQL
* Publish Event → Kafka topic `order.created`

### 4️⃣ Payment Service

* Consume Event จาก Kafka
* Update payment status
* Save ลง PostgreSQL

### 5️⃣ Observability

* Micrometer → Prometheus scrape metrics
* OpenTelemetry → Jaeger tracing
* Grafana แสดง Dashboard

---

# 📦 Microservices Structure

```
microservices-demo/
│
├── api-gateway/
├── order-service/
├── payment-service/
├── proto/
├── docker-compose.yml
└── monitoring/
    ├── prometheus.yml
    └── grafana/
```

---

# 🧬 gRPC Proto Example

```proto
syntax = "proto3";

service OrderService {
  rpc CreateOrder (OrderRequest) returns (OrderResponse);
}

message OrderRequest {
  string productId = 1;
  int32 quantity = 2;
}

message OrderResponse {
  string orderId = 1;
  string status = 2;
}
```

---

# � Session Management (Redis)

Spring Boot config:

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: ${REDIS_PASSWORD:}
  session:
    store-type: redis
    timeout: 30m
    redis:
      namespace: spring:session
```

Dependency:

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'org.springframework.session:spring-session-data-redis'
```

หรือ Maven:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
</dependency>
```

ใช้งาน:

```java
@RestController
public class SessionController {
    
    @GetMapping("/session")
    public String setSession(HttpSession session) {
        session.setAttribute("user", "john.doe");
        return "Session created: " + session.getId();
    }
    
    @GetMapping("/session/get")
    public String getSession(HttpSession session) {
        return "User: " + session.getAttribute("user");
    }
}
```

Redis CLI ตรวจสอบ session:

```bash
redis-cli
> KEYS spring:session:*
> GET spring:session:sessions:{session-id}
```

---

# �📊 Metrics (Micrometer)

Spring Boot config:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: "*"
  metrics:
    export:
      prometheus:
        enabled: true
```

Endpoint:

```
http://localhost:8080/actuator/prometheus
```

Prometheus scrape:

```yaml
scrape_configs:
  - job_name: 'order-service'
    static_configs:
      - targets: ['order-service:8080']
```

---

# 🔎 Tracing (OpenTelemetry + Jaeger)

Dependency:

```gradle
implementation 'io.opentelemetry:opentelemetry-exporter-jaeger'
```

Tracing flow:

```
Client → Gateway → Order → Kafka → Payment
```

Grafana Tempo หรือ Jaeger UI:

```
http://localhost:16686
```

---

# 📊 Dashboard View (Grafana)

Dashboard แนะนำ:

* HTTP Request Rate
* Error Rate
* JVM Heap Usage
* Kafka Lag
* DB Connection Pool
* gRPC Latency
* Redis Session Count
* Redis Memory Usage

Access:

```
http://localhost:3000
```

---

# 🐳 docker-compose.yml (Core Services)


```

---

# 🔥 Demo Scenarios สำหรับโชว์

### 1️⃣ Happy Flow

* Create Order
* Kafka Event
* Payment Process
* View Grafana metrics

### 2️⃣ Failure Simulation

* Kill Payment Service
* Kafka Lag Increase
* Error Rate Spike
* Trace ดู latency jump

### 3️⃣ Load Test

* ยิง 1,000 req/sec
* ดู CPU / Memory
* ดู gRPC latency distribution

---

# 🧠 Architecture Pattern Used

* Microservices
* Event-driven Architecture
* CQRS (optional)
* Observability-first design
* Distributed tracing
* Async communication via Kafka
* Sync communication via gRPC
