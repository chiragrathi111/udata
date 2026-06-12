# 05 — JWT Authentication

## What is JWT?
JSON Web Token = a self-contained token with user info.
Server verifies the token WITHOUT hitting the database every time.

```
WITHOUT JWT: every request → DB check → slow ❌
WITH JWT:    every request → token verify → fast ✅
```

## Token Structure
```
eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbkBleGFtcGxlLmNvbSIsInJvbGUiOiJBRE1JTiJ9.SflKxwRJSMeKKF2QT4fw
        HEADER       .                        PAYLOAD                               .      SIGNATURE

Header  = {"alg":"HS256","typ":"JWT"}            → algorithm info
Payload = {"sub":"admin@example.com","role":"ADMIN","exp":...}  → user data
Signature = HMAC_SHA256(header+payload, secret)  → tamper-proof seal
```

> ⚠️ Payload is base64 encoded (NOT encrypted) — anyone can decode it.
> NEVER store passwords or sensitive data in payload!

## New Files Needed
```
model/
  └── User.java                     ← stores login users in DB
repository/
  └── UserRepository.java           ← find user by email
controller/
  └── AuthController.java           ← /register and /login
security/
  ├── JwtUtil.java                  ← create and validate tokens
  ├── JwtFilter.java                ← check token on every request
  └── SecurityConfig.java           ← route protection rules
```

## Existing Files — What Changes
```
pom.xml                  → 4 dependencies added
application.properties   → 2 lines added (jwt.secret, jwt.expiration)
StudentController.java   → NO CHANGE (SecurityConfig protects it)
StudentService.java      → NO CHANGE
StudentRepository.java   → NO CHANGE
Student.java             → NO CHANGE
```

---

## pom.xml — Add Dependencies
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

## application.properties — Add JWT Config
```properties
jwt.secret=mySecretKey12345678901234567890AB
jwt.expiration=86400000
# 86400000 ms = 24 hours
# For longer: 604800000 ms = 7 days
```

---

## User.java
```java
package org.example.student.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    // ALWAYS stored as BCrypt hash — NEVER plain text!
    // "password123" → "$2a$10$xyz..." (cannot be reversed)
    @Column(nullable = false)
    private String password;

    // "ADMIN" or "USER"
    @Column(nullable = false)
    private String role;
}
```

## UserRepository.java
```java
package org.example.student.repository;

import org.example.student.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

---

## JwtUtil.java
```java
package org.example.student.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // Call this on successful login → returns token string
    public String generateToken(String email, String role) {
        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey())
                .compact();
    }

    // Extract email from token
    public String extractEmail(String token) {
        return Jwts.parser().verifyWith(getSigningKey()).build()
                .parseSignedClaims(token).getPayload().getSubject();
    }

    // Extract role from token
    public String extractRole(String token) {
        return Jwts.parser().verifyWith(getSigningKey()).build()
                .parseSignedClaims(token).getPayload().get("role", String.class);
    }

    // Returns true if token is valid and not expired
    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

---

## JwtFilter.java
```java
package org.example.student.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.List;

// Runs ONCE per request — before the controller
// Like a security guard checking ID at the door
@Component
public class JwtFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");
        // Format: "Bearer eyJhbGci..."

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);  // cut off "Bearer "

            if (jwtUtil.validateToken(token)) {
                String email = jwtUtil.extractEmail(token);
                String role  = jwtUtil.extractRole(token);

                // Tell Spring Security: "this user is authenticated"
                // ROLE_ prefix is required by Spring Security
                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(
                                email, null,
                                List.of(new SimpleGrantedAuthority("ROLE_" + role))
                        );
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }

        filterChain.doFilter(request, response);  // continue to next filter/controller
    }
}
```

---

## SecurityConfig.java
```java
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

    @Autowired private JwtFilter jwtFilter;
    @Autowired private RateLimitFilter rateLimitFilter;  // add after Step 6

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())        // REST API doesn't need CSRF
            .sessionManagement(s ->
                s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))  // no sessions — JWT is stateless

            .authorizeHttpRequests(auth -> auth
                // ── Open routes ──────────────────────────────────
                .requestMatchers("/api/auth/**").permitAll()     // anyone can register/login

                // ── Protected routes ──────────────────────────────
                // GET = both USER and ADMIN can view students
                .requestMatchers(HttpMethod.GET, "/api/students/**").hasAnyRole("USER", "ADMIN")
                // POST, PUT, DELETE = only ADMIN
                .requestMatchers(HttpMethod.POST,   "/api/students/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT,    "/api/students/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/students/**").hasRole("ADMIN")

                // everything else requires authentication
                .anyRequest().authenticated()
            )

            // Filter order: RateLimit → JWT → Controller
            .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // BCrypt password encoder — used to hash and verify passwords
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

---

## AuthController.java
```java
package org.example.student.controller;

import org.example.student.model.User;
import org.example.student.repository.UserRepository;
import org.example.student.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private UserRepository userRepository;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private PasswordEncoder passwordEncoder;

    // POST /api/auth/register
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if (userRepository.existsByEmail(user.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", "Email already registered!"));
        }
        // Hash password before saving — NEVER store plain text
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Default role = USER if not provided
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("USER");
        }

        User saved = userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
            "message", "User registered successfully!",
            "email",   saved.getEmail(),
            "role",    saved.getRole()
        ));
    }

    // POST /api/auth/login
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        String email    = request.get("email");
        String password = request.get("password");

        Optional<User> userOpt = userRepository.findByEmail(email);

        // Check user exists and password matches
        if (userOpt.isEmpty() ||
            !passwordEncoder.matches(password, userOpt.get().getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        User user = userOpt.get();
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole());

        return ResponseEntity.ok(Map.of(
            "token",   token,
            "email",   user.getEmail(),
            "role",    user.getRole(),
            "message", "Login successful!"
        ));
    }
}
```

---

## JWT Request Flow
```
POST /api/auth/login {email, password}
         ↓
AuthController finds user in DB
         ↓
BCrypt verifies password
         ↓
JwtUtil.generateToken(email, role)
         ↓
Response: {"token": "eyJhbGci..."}
         ↓
Client stores token
         ↓
GET /api/students
Header: Authorization: Bearer eyJhbGci...
         ↓
JwtFilter validates token
         ↓
SecurityConfig checks role
         ↓
StudentController returns data ✅
```

## Role-Based Access
```
ADMIN token → GET ✅  POST ✅  PUT ✅  DELETE ✅
USER token  → GET ✅  POST ❌  PUT ❌  DELETE ❌  (403 Forbidden)
No token    → GET ❌  POST ❌  PUT ❌  DELETE ❌  (401 Unauthorized)
```
