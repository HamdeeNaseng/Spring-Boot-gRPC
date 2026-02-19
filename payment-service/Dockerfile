FROM eclipse-temurin:17-jre-alpine

# Working directory
WORKDIR /app

# Copy JAR file
COPY target/payment-service-1.0.0.jar app.jar

# Install curl for health checks
RUN apk add --no-cache curl

# Expose port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8082/api/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
