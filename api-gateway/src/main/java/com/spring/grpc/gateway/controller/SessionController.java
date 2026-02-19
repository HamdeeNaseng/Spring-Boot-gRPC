package com.spring.grpc.gateway.controller;

import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@Slf4j
@RestController
@RequestMapping("/api/session")
public class SessionController {

    private final RedisTemplate<String, Object> redisTemplate;

    public SessionController(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody LoginRequest request, HttpSession session) {
        log.info("Login request for user: {}", request.getUsername());
        
        // Store user info in session
        session.setAttribute("userId", request.getUsername());
        session.setAttribute("loginTime", System.currentTimeMillis());
        session.setAttribute("role", "USER");
        
        Map<String, Object> response = new HashMap<>();
        response.put("sessionId", session.getId());
        response.put("userId", request.getUsername());
        response.put("message", "Login successful");
        
        return response;
    }

    @GetMapping("/info")
    public Map<String, Object> getSessionInfo(HttpSession session) {
        Map<String, Object> sessionInfo = new HashMap<>();
        sessionInfo.put("sessionId", session.getId());
        sessionInfo.put("userId", session.getAttribute("userId"));
        sessionInfo.put("loginTime", session.getAttribute("loginTime"));
        sessionInfo.put("role", session.getAttribute("role"));
        sessionInfo.put("maxInactiveInterval", session.getMaxInactiveInterval());
        sessionInfo.put("creationTime", session.getCreationTime());
        sessionInfo.put("lastAccessedTime", session.getLastAccessedTime());
        
        return sessionInfo;
    }

    @PostMapping("/logout")
    public Map<String, String> logout(HttpSession session) {
        String sessionId = session.getId();
        session.invalidate();
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Logout successful");
        response.put("sessionId", sessionId);
        
        return response;
    }

    @GetMapping("/count")
    public Map<String, Object> getActiveSessionCount() {
        Set<String> keys = redisTemplate.keys("spring:session:sessions:*");
        
        Map<String, Object> response = new HashMap<>();
        response.put("activeSessionCount", keys != null ? keys.size() : 0);
        
        return response;
    }

    @PutMapping("/attribute")
    public Map<String, String> setAttribute(@RequestParam String key, 
                                           @RequestParam String value, 
                                           HttpSession session) {
        session.setAttribute(key, value);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Attribute set successfully");
        response.put("key", key);
        response.put("value", value);
        
        return response;
    }

    @GetMapping("/attribute/{key}")
    public Map<String, Object> getAttribute(@PathVariable String key, HttpSession session) {
        Object value = session.getAttribute(key);
        
        Map<String, Object> response = new HashMap<>();
        response.put("key", key);
        response.put("value", value);
        
        return response;
    }

    // Inner class for login request
    public static class LoginRequest {
        private String username;
        private String password;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
