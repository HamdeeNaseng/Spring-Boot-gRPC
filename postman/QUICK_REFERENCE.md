# 🧪 Postman Testing - Quick Reference

## Import Collection
```
File: postman/Redis-Session-Management-API.postman_collection.json
Method: Postman → Import → Upload Files
```

## 🎯 Test Sequence (Run in Order)

| # | Request | Method | Expected Result |
|---|---------|--------|-----------------|
| 1 | Health Check | GET | `status: "UP"`, `redis: "UP"` |
| 2 | Login | POST | Returns `sessionId`, sets cookie |
| 3 | Get Session Info | GET | Returns session details |
| 4 | Set Attribute (theme) | PUT | `message: "Attribute set successfully"` |
| 5 | Get Attribute (theme) | GET | Returns `key: "theme"`, `value: "dark"` |
| 6 | Get Session Count | GET | Returns `activeSessionCount >= 1` |
| 7 | Logout | POST | `message: "Logout successful"` |

## 📋 Collection Variables

Set these in Postman (Collection → Variables):

| Variable | Initial Value | Description |
|----------|---------------|-------------|
| `baseUrl` | `http://localhost:8080` | API Gateway URL |
| `sessionId` | (auto-set) | Current session ID |
| `userId` | (auto-set) | Current user ID |

## 🚀 Quick Actions

### Run All Tests (Collection Runner)
1. Click collection name → **Run**
2. Select all requests
3. Set **Iterations**: 1
4. Click **Run Redis Session Management API**
5. View test results

### Load Test (100 Sessions)
1. Select **Create Multiple Sessions** request
2. Click **Run** → Collection Runner
3. Set **Iterations**: 100
4. Set **Delay**: 50ms
5. Click **Run**

### Check Results
```
GET /api/session/count
Expected: activeSessionCount = 100
```

## 🧪 Test Assertions Included

Each request includes automatic tests:
- ✅ Status code validation (200 OK)
- ✅ Response time checks (< 200ms)
- ✅ Field presence validation
- ✅ Data type validation
- ✅ Business logic validation
- ✅ Cookie validation

## 📊 Test Results Located

- **Console**: View in Postman Console (bottom)
- **Test Results**: View in "Test Results" tab
- **Visualizer**: Auto-generated for complex responses

## 🔧 PowerShell Alternative

Run automated tests without Postman:

```powershell
cd postman
.\test-api.ps1
```

## 📖 Full Documentation

See `POSTMAN_TESTING_GUIDE.md` for:
- Detailed test scenarios
- Troubleshooting guide
- Advanced test cases
- Monitoring instructions

## 🌐 Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| API Gateway | http://localhost:8080 | - |
| Redis Commander | http://localhost:8081 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Jaeger | http://localhost:16686 | - |

## 💡 Pro Tips

1. **Use Environment**: Create different environments (dev, staging, prod)
2. **Enable Console**: View detailed logs in Postman Console
3. **Save Examples**: Save responses as examples for documentation
4. **Use Test Scripts**: All tests are pre-configured
5. **Monitor Metrics**: Check Prometheus while running tests

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Run login request first |
| Session not found | Cookie may have expired, login again |
| Connection refused | Check services: `docker-compose ps` |
| Tests failing | Clear cookies and restart collection |

---

**Happy Testing! 🚀**

For questions, see: `POSTMAN_TESTING_GUIDE.md`
