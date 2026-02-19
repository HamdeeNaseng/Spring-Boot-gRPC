# Quick rebuild of Order Service
Write-Host "Rebuilding Order Service..." -ForegroundColor Cyan

Set-Location "D:\imed-\GitHub\Spring-Boot-gRPC\order-service"

# Build with Maven
Write-Host "Building with Maven..." -ForegroundColor Yellow
mvn clean package -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Go back to root and rebuild Docker container
    Set-Location "D:\imed-\GitHub\Spring-Boot-gRPC"
    
    Write-Host "Rebuilding Docker container..." -ForegroundColor Yellow
    docker-compose build order-service
    
    Write-Host "Restarting service..." -ForegroundColor Yellow
    docker-compose up -d order-service
    
    Write-Host "Done! Waiting 20 seconds for service to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    Write-Host "Testing endpoint..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri "http://localhost:8081/api/health"
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}
