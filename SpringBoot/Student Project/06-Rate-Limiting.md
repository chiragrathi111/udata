# 06 — Rate Limiting (bucket4j)

## What is Rate Limiting?
Limit how many API requests a user can make in a time period.
Protects your server from abuse, spam, and DDoS attacks.

```
User sends 10 requests in 1 minute → all allowed ✅
User sends 11th request            → 429 Too Many Requests ❌
After 1 minute                     → bucket refills → requests allowed again
```

## Token Bucket Algorithm
```
Bucket = container with N tokens
Each request = consumes 1 token
No tokens left = 429 response
After time period = tokens refill automatically

Example (10 tokens, 1 minute):
Request 1-10  → token consumed → 200 OK
Request 11    → no tokens → 429
Wait 1 minute → 10 tokens back → 200 OK again
```

---

## pom.xml — Add Dependency
```xml
<dependency>
    <groupId>com.bucket4j</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>8.7.0</version>
</dependency>
```

---

## RateLimitFilter.java (new file in security/ folder)
```java
package org.example.student.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    // Each user gets their own bucket
    // Key = "user:email" or "ip:127.0.0.1"
    // ConcurrentHashMap = thread-safe (multiple requests at same time are safe)
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        // Identify who is making the request
        String key    = getUserKey(request);

        // Get existing bucket or create new one
        Bucket bucket = buckets.computeIfAbsent(key, k -> createBucket(key));

        if (bucket.tryConsume(1)) {
            // Token available → allow request
            // Tell client how many requests they have left
            response.setHeader("X-Rate-Limit-Remaining",
                    String.valueOf(bucket.getAvailableTokens()));
            filterChain.doFilter(request, response);
        } else {
            // No tokens → reject with 429
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write(
                "{\"error\":\"Too many requests! Please wait before retrying.\"," +
                "\"status\":429}"
            );
        }
    }

    // Identify user:
    // JWT token present → use email (per-user limit)
    // No token → use IP address (per-IP limit)
    private String getUserKey(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            if (jwtUtil.validateToken(token)) {
                return "user:" + jwtUtil.extractEmail(token);
            }
        }
        // Anonymous request → limit by IP
        String ip = request.getHeader("X-Forwarded-For");  // behind proxy
        if (ip == null || ip.isEmpty()) ip = request.getRemoteAddr();
        return "ip:" + ip;
    }

    // Create bucket with limits based on who the user is
    private Bucket createBucket(String key) {
        if (key.startsWith("user:")) {
            // Logged-in users: 10 requests per minute
            return Bucket.builder()
                    .addLimit(Bandwidth.classic(
                            10,                                      // max tokens
                            Refill.greedy(10, Duration.ofMinutes(1)) // refill 10 every minute
                    ))
                    .build();
        }
        // Anonymous (no token): 2 requests per minute (strict!)
        return Bucket.builder()
                .addLimit(Bandwidth.classic(
                        2,
                        Refill.greedy(2, Duration.ofMinutes(1))
                ))
                .build();
    }
}
```

---

## Update SecurityConfig.java — Add RateLimitFilter

Add these 2 things to your existing SecurityConfig:

```java
// 1. Add this field (with existing @Autowired fields)
@Autowired private RateLimitFilter rateLimitFilter;

// 2. Add this line in filterChain — BEFORE jwtFilter
.addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
```

Full filter order:
```
Request → RateLimitFilter → JwtFilter → Controller
```

---

## Customize Limits — Easy Reference

```java
// 5 requests per minute
Bandwidth.classic(5, Refill.greedy(5, Duration.ofMinutes(1)))

// 100 requests per hour
Bandwidth.classic(100, Refill.greedy(100, Duration.ofHours(1)))

// 1000 requests per day
Bandwidth.classic(1000, Refill.greedy(1000, Duration.ofDays(1)))

// 3 requests per second
Bandwidth.classic(3, Refill.greedy(3, Duration.ofSeconds(1)))
```

## Per-Role Limits
```java
private Bucket createBucket(String key) {
    if (key.startsWith("user:")) {
        String email = key.replace("user:", "");

        // Get user role from DB or from token claims
        // Then apply different limits per role:

        // ADMIN: 100 requests per minute
        // USER:  10 requests per minute
        // (adjust as needed)
    }
    // ip: 2 per minute
}
```

---

## Response Headers
Your API now sends these headers with every response:
```
X-Rate-Limit-Remaining: 7    ← how many requests left in current window
```

Client can use this to avoid hitting the limit.

---

## Test Rate Limiting
```bash
# Make 12 requests — 11th should get 429
for i in {1..12}; do
  echo "Request $i:"
  curl -s -o /dev/null -w "Status: %{http_code}\n" \
    http://localhost:8081/api/students \
    -H "Authorization: Bearer YOUR_TOKEN"
done

# Expected output:
# Request 1:  Status: 200
# Request 2:  Status: 200
# ...
# Request 10: Status: 200
# Request 11: Status: 429   ← rate limit hit!
# Request 12: Status: 429
```

## 429 Response Body
```json
{
  "error": "Too many requests! Please wait before retrying.",
  "status": 429
}
```
