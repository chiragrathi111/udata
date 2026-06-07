What is rate limiting?

Rate limiting = ek user kitni baar API call kar sakta hai ek time period mein.

Jaise: 10 requests per minute. 11th request? → 429 Too Many Requests ❌
Token Bucket Algorithm (bucket4j uses this)
Tokens available (bucket capacity = 10)

Send request ↗   Refill tokens ↗  Reset

Without vs With rate limiting		

Without rate limiting
❌ Server crash ho sakta hai
❌ One user sab resources le sakta hai
❌ DDoS attacks easy hain
❌ DB overload
❌ Fair usage impossible

With rate limiting (bucket4j)
✅ Server protected
✅ Fair usage for all users
✅ DDoS mitigation
✅ DB safe
✅ 429 response with retry info

In your Student project — per user limits
Each user gets their own bucket based on JWT email

ADMIN    admin@example.com   10 req/min
USER     user@example.com    5 req/min
NO TOKEN anonymous           2 req/min

---------------------------------------------------------

Step 1 — Add dependency in pom.xml

<!-- Bucket4j — rate limiting library -->
<dependency>
    <groupId>com.bucket4j</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>8.7.0</version>
</dependency>


Step 2 — RateLimitFilter.java (new file in security/ folder)

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

// OncePerRequestFilter = har request pe ek baar run hoga
// JwtFilter ke BAAD run hoga (SecurityConfig mein order set karenge)
@Component
public class RateLimitFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    // ConcurrentHashMap = thread-safe map
    // Har user ka apna bucket hoga: email → bucket
    // Jaise: "admin@example.com" → {10 tokens}
    //        "user@example.com"  → {5 tokens}
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        // User identify karo — JWT token se ya IP se
        String key = getUserKey(request);

        // Is user ka bucket lo (ya banao agar nahi hai)
        Bucket bucket = buckets.computeIfAbsent(key, k -> createBucket(key));

        // Token consume karne ki koshish karo
        if (bucket.tryConsume(1)) {
            // Token mila → request allow karo
            // Remaining tokens header mein bhejo (client ko pata chale)
            response.setHeader("X-Rate-Limit-Remaining",
                    String.valueOf(bucket.getAvailableTokens()));
            filterChain.doFilter(request, response);

        } else {
            // Token nahi mila → 429 Too Many Requests
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write(
                "{\"error\": \"Too many requests! Please wait before retrying.\","
                + "\"status\": 429}"
            );
        }
    }

    // ─── USER KEY BANANA ──────────────────────────────────────
    // JWT token hai → email se identify (per-user limit)
    // Token nahi hai → IP address se identify (per-IP limit)
    private String getUserKey(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            if (jwtUtil.validateToken(token)) {
                // Logged-in user → email as key
                return "user:" + jwtUtil.extractEmail(token);
            }
        }

        // Anonymous → IP as key
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        }
        return "ip:" + ip;
    }

    // ─── BUCKET BANANA ────────────────────────────────────────
    // Key dekho → kaun hai → uske hisaab se limit set karo
    private Bucket createBucket(String key) {

        if (key.startsWith("user:")) {
            // Logged-in users ko zyada tokens
            // 10 requests per minute
            return Bucket.builder()
                    .addLimit(Bandwidth.classic(
                            10,                              // capacity = 10 tokens
                            Refill.greedy(10, Duration.ofMinutes(1)) // 1 min mein 10 refill
                    ))
                    .build();

        } else {
            // Anonymous (no token) = strict limit
            // 2 requests per minute
            return Bucket.builder()
                    .addLimit(Bandwidth.classic(
                            2,
                            Refill.greedy(2, Duration.ofMinutes(1))
                    ))
                    .build();
        }
    }
}

Step 3 — Update SecurityConfig.java
Add RateLimitFilter to the security chain. Only 2 lines to add:

package org.example.student.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtFilter jwtFilter;

    @Autowired
    private RateLimitFilter rateLimitFilter; // ← ADD THIS

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/students/**").hasAnyRole("USER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/students/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/students/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/students/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            // Filter order:
            // RateLimitFilter → JwtFilter → Controller
            .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class) // ← ADD THIS
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

Step 4 — Test it with CURL
# 1. Login to get token

TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: $TOKEN"

# 2. Spam requests — after 10th you get 429
for i in {1..12}; do
  echo "Request $i:"
  curl -s -o /dev/null -w "Status: %{http_code}\n" \
    http://localhost:8081/api/students \
    -H "Authorization: Bearer $TOKEN"
done

# Expected output:
# Request 1:  Status: 200
# Request 2:  Status: 200
# ...
# Request 10: Status: 200
# Request 11: Status: 429  ← rate limit hit!
# Request 12: Status: 429

# 3. Try without token — limit is only 2 requests
for i in {1..4}; do
  echo "Anonymous request $i:"
  curl -s -o /dev/null -w "Status: %{http_code}\n" \
    http://localhost:8081/api/students
done

# Expected:
# Anonymous request 1: Status: 401 (no token)
# Anonymous request 2: Status: 401
# Anonymous request 3: Status: 429 ← rate limit!

How all 3 filters work together
HTTP Request
     ↓
RateLimitFilter  → tokens available? → No  → 429 Too Many Requests ❌
     ↓ Yes
JwtFilter        → token valid?      → No  → 401 Unauthorized ❌
     ↓ Yes
SecurityConfig   → role allowed?     → No  → 403 Forbidden ❌
     ↓ Yes
StudentController → process request  → 200 OK ✅

------------------------------------------------------------------------------------