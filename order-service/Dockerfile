FROM eclipse-temurin:17-jre-alpine

# Working directory
WORKDIR /app

# Copy JAR file
COPY target/order-service-1.0.0.jar app.jar

# Install curl for health checks
RUN apk add --no-cache curl

# Expose ports
EXPOSE 8081 9090

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8081/api/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
