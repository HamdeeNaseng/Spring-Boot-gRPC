# Redis Session Management API - Automated Test Script
# Run this script to test all endpoints and verify functionality

Write-Host "🚀 Redis Session Management API - Automated Tests" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$testsPassed = 0
$testsFailed = 0

# Helper function to display test results
function Test-Endpoint {
    param (
        [string]$Name,
        [scriptblock]$TestBlock
    )
    
    Write-Host "▶ Testing: $Name" -ForegroundColor Yellow
    try {
        & $TestBlock
        Write-Host "  ✅ PASSED" -ForegroundColor Green
        $script:testsPassed++
    } catch {
        Write-Host "  ❌ FAILED: $_" -ForegroundColor Red
        $script:testsFailed++
    }
    Write-Host ""
}

# Test 1: Health Check
Test-Endpoint "Health Check" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/health" -Method Get
    if ($response.status -ne "UP") { throw "Service is not UP" }
    if ($response.redis -ne "UP") { throw "Redis is not UP" }
    Write-Host "  ℹ Service: $($response.service) - Status: $($response.status)" -ForegroundColor White
    Write-Host "  ℹ Redis: $($response.redis)" -ForegroundColor White
}

# Test 2: Create Session (Login)
Write-Host "▶ Testing: Create Session (Login)" -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "test_user_$(Get-Random -Maximum 9999)"
        password = "test_password"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody `
        -SessionVariable session

    if (-not $response.sessionId) { throw "No session ID returned" }
    if ($response.message -ne "Login successful") { throw "Login message incorrect" }
    
    $sessionId = $response.sessionId
    $userId = $response.userId
    
    Write-Host "  ✅ PASSED" -ForegroundColor Green
    Write-Host "  ℹ Session ID: $sessionId" -ForegroundColor White
    Write-Host "  ℹ User ID: $userId" -ForegroundColor White
    $testsPassed++
} catch {
    Write-Host "  ❌ FAILED: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Test 3: Get Session Info
Test-Endpoint "Get Session Info" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/info" `
        -Method Get `
        -WebSession $session
    
    if (-not $response.sessionId) { throw "No session ID in response" }
    if (-not $response.userId) { throw "No user ID in response" }
    
    Write-Host "  ℹ Session ID: $($response.sessionId)" -ForegroundColor White
    Write-Host "  ℹ User ID: $($response.userId)" -ForegroundColor White
    Write-Host "  ℹ Max Inactive Interval: $($response.maxInactiveInterval)s" -ForegroundColor White
}

# Test 4: Set Session Attribute
Test-Endpoint "Set Session Attribute (theme=dark)" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/attribute?key=theme&value=dark" `
        -Method Put `
        -WebSession $session
    
    if ($response.message -ne "Attribute set successfully") { throw "Attribute not set" }
    if ($response.key -ne "theme") { throw "Key mismatch" }
    if ($response.value -ne "dark") { throw "Value mismatch" }
    
    Write-Host "  ℹ Attribute: $($response.key) = $($response.value)" -ForegroundColor White
}

# Test 5: Set Multiple Attributes
Test-Endpoint "Set Session Attribute (language=en)" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/attribute?key=language&value=en" `
        -Method Put `
        -WebSession $session
    
    if ($response.message -ne "Attribute set successfully") { throw "Attribute not set" }
    Write-Host "  ℹ Attribute: $($response.key) = $($response.value)" -ForegroundColor White
}

# Test 6: Get Session Attribute
Test-Endpoint "Get Session Attribute (theme)" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/attribute/theme" `
        -Method Get `
        -WebSession $session
    
    if ($response.key -ne "theme") { throw "Key mismatch" }
    if ($response.value -ne "dark") { throw "Value mismatch" }
    
    Write-Host "  ℹ Retrieved: $($response.key) = $($response.value)" -ForegroundColor White
}

# Test 7: Get Active Session Count
Test-Endpoint "Get Active Session Count" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/count" -Method Get
    
    if ($null -eq $response.activeSessionCount) { throw "No session count returned" }
    if ($response.activeSessionCount -lt 1) { throw "Session count should be at least 1" }
    
    Write-Host "  ℹ Active Sessions: $($response.activeSessionCount)" -ForegroundColor White
}

# Test 8: Verify Session in Redis
Test-Endpoint "Verify Session in Redis" {
    $redisKeys = docker exec redis-session redis-cli KEYS "spring:session:sessions:*" 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Could not query Redis" }
    
    $keyCount = ($redisKeys | Measure-Object -Line).Lines
    if ($keyCount -lt 1) { throw "No sessions found in Redis" }
    
    Write-Host "  ℹ Redis Session Keys: $keyCount" -ForegroundColor White
}

# Test 9: Actuator Health
Test-Endpoint "Actuator Health Endpoint" {
    $response = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method Get
    
    if ($response.status -ne "UP") { throw "Actuator health is not UP" }
    Write-Host "  ℹ Actuator Status: $($response.status)" -ForegroundColor White
}

# Test 10: Prometheus Metrics
Test-Endpoint "Prometheus Metrics Available" {
    $metrics = Invoke-WebRequest -Uri "$baseUrl/actuator/prometheus" -Method Get -UseBasicParsing
    
    if ($metrics.StatusCode -ne 200) { throw "Metrics endpoint returned $($metrics.StatusCode)" }
    if ($metrics.Content -notmatch "http_server_requests") { throw "No HTTP metrics found" }
    
    Write-Host "  ℹ Metrics Available: Yes" -ForegroundColor White
    Write-Host "  ℹ Content Length: $($metrics.Content.Length) bytes" -ForegroundColor White
}

# Test 11: Create Multiple Sessions (Load Test)
Write-Host "▶ Testing: Create Multiple Sessions (Load Test)" -ForegroundColor Yellow
try {
    $sessionCount = 10
    $createdSessions = 0
    
    for ($i = 1; $i -le $sessionCount; $i++) {
        $loadBody = @{
            username = "load_test_user_$i"
            password = "password$i"
        } | ConvertTo-Json
        
        $loadResponse = Invoke-RestMethod -Uri "$baseUrl/api/session/login" `
            -Method Post `
            -ContentType "application/json" `
            -Body $loadBody
        
        if ($loadResponse.sessionId) { $createdSessions++ }
    }
    
    if ($createdSessions -ne $sessionCount) { 
        throw "Only $createdSessions/$sessionCount sessions created" 
    }
    
    Write-Host "  ✅ PASSED" -ForegroundColor Green
    Write-Host "  ℹ Created $createdSessions sessions successfully" -ForegroundColor White
    $testsPassed++
} catch {
    Write-Host "  ❌ FAILED: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Test 12: Verify Increased Session Count
Test-Endpoint "Verify Increased Session Count" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/count" -Method Get
    
    # Should have at least 11 sessions (1 original + 10 load test)
    if ($response.activeSessionCount -lt 11) { 
        throw "Session count ($($response.activeSessionCount)) is less than expected (11+)" 
    }
    
    Write-Host "  ℹ Active Sessions: $($response.activeSessionCount)" -ForegroundColor White
}

# Test 13: Logout
Test-Endpoint "Logout (Destroy Session)" {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/session/logout" `
        -Method Post `
        -WebSession $session
    
    if ($response.message -ne "Logout successful") { throw "Logout failed" }
    
    Write-Host "  ℹ Logged out from session: $($response.sessionId)" -ForegroundColor White
}

# Test 14: Verify Redis Commander UI
Test-Endpoint "Redis Commander UI Accessibility" {
    try {
        $redisUI = Invoke-WebRequest -Uri "http://localhost:8081" -Method Get -UseBasicParsing -TimeoutSec 5
        if ($redisUI.StatusCode -ne 200) { throw "Redis Commander returned $($redisUI.StatusCode)" }
        Write-Host "  ℹ Redis Commander is accessible at http://localhost:8081" -ForegroundColor White
    } catch {
        throw "Redis Commander UI is not accessible"
    }
}

# Summary
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "📊 Test Summary" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "✅ Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "❌ Tests Failed: $testsFailed" -ForegroundColor Red
Write-Host "📈 Success Rate: $([math]::Round(($testsPassed / ($testsPassed + $testsFailed)) * 100, 2))%" -ForegroundColor Cyan
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "🎉 All tests passed! Your API is working correctly!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 You can now:" -ForegroundColor White
    Write-Host "  1. Import Postman collection from: postman/Redis-Session-Management-API.postman_collection.json" -ForegroundColor White
    Write-Host "  2. View sessions in Redis Commander: http://localhost:8081" -ForegroundColor White
    Write-Host "  3. Check metrics in Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  4. View dashboards in Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️ Some tests failed. Please check the errors above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔍 Troubleshooting:" -ForegroundColor White
    Write-Host "  1. Check if all services are running: docker-compose ps" -ForegroundColor White
    Write-Host "  2. Check API Gateway logs: docker logs api-gateway" -ForegroundColor White
    Write-Host "  3. Check Redis logs: docker logs redis-session" -ForegroundColor White
    Write-Host ""
}

# URLs for reference
Write-Host "🔗 Useful URLs:" -ForegroundColor Cyan
Write-Host "  API Health:        $baseUrl/api/health" -ForegroundColor White
Write-Host "  Redis Commander:   http://localhost:8081" -ForegroundColor White
Write-Host "  Prometheus:        http://localhost:9090" -ForegroundColor White
Write-Host "  Grafana:           http://localhost:3000" -ForegroundColor White
Write-Host "  Jaeger:            http://localhost:16686" -ForegroundColor White
Write-Host ""
