# Phase 2 — Code Quality Guide
## DTO Pattern + Swagger/OpenAPI + Logging

---

## Table of Contents
1. [What is Phase 2 and Why](#1-what-is-phase-2-and-why)
2. [DTO Pattern](#2-dto-pattern)
3. [Swagger / OpenAPI Documentation](#3-swagger--openapi-documentation)
4. [Logging](#4-logging)
5. [Complete File Structure](#5-complete-file-structure)
6. [Common Errors and Fixes](#6-common-errors-and-fixes)
7. [Quick Checklist](#7-quick-checklist)

---

## 1. What is Phase 2 and Why

### The Problem with Phase 1 code
```
Phase 1 was working but had these issues:

Issue 1 — Password leaking in response
  User entity has: id, email, password, role
  If you return User directly → password goes in response!
  Response: {"id":1,"email":"x@x.com","password":"$2a$10$xyz...","role":"ADMIN"} ❌

Issue 2 — No API documentation
  Other developers don't know what your API accepts/returns
  Testing needs CURL — no browser UI

Issue 3 — System.out.println everywhere
  Not professional
  No log levels (info vs error vs warning)
  Can't control what gets printed in production
```

### Phase 2 solves all 3
```
DTO Pattern      → password never goes in response ✅
Swagger          → browser UI to test and document API ✅
Logging (SLF4J)  → professional structured logs ✅
```

---

## 2. DTO Pattern

### What is DTO?
```
DTO = Data Transfer Object

Entity = DB model (has ALL fields including sensitive ones)
DTO    = custom object for specific purpose (only needed fields)

StudentRequestDTO  = what client SENDS  (no id — DB generates it)
StudentResponseDTO = what server RETURNS (clean, controlled fields)
LoginRequestDTO    = login credentials
AuthResponseDTO    = token + email + role (NO password!)
```

### Folder structure
```
src/main/java/org/example/student/
└── dto/
    ├── StudentRequestDTO.java    ← client sends this (POST/PUT)
    ├── StudentResponseDTO.java   ← server returns this
    ├── RegisterRequestDTO.java   ← register body
    ├── LoginRequestDTO.java      ← login body
    └── AuthResponseDTO.java      ← login response (token, email, role)
```

---

### StudentRequestDTO.java
```java
package org.example.student.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

// What client sends in POST /api/students and PUT /api/students/{id}
// Validation annotations moved here from Student.java entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentRequestDTO {

    // No id field — DB auto-generates it

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    private String email;

    @NotNull(message = "Age is required")
    @Min(value = 1, message = "Age must be at least 1")
    @Max(value = 150, message = "Age must be less than 150")
    private Integer age;
}
```

---

### StudentResponseDTO.java
```java
package org.example.student.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// What server returns for GET/POST/PUT /api/students
// Add extra fields here later (createdAt, updatedAt) without touching the entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentResponseDTO {
    private Long id;
    private String name;
    private String email;
    private Integer age;
}
```

---

### RegisterRequestDTO.java
```java
package org.example.student.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

// POST /api/auth/register body
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequestDTO {

    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    // Optional — defaults to USER if not provided
    private String role;
}
```

---

### LoginRequestDTO.java
```java
package org.example.student.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

// POST /api/auth/login body
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequestDTO {

    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;
}
```

---

### AuthResponseDTO.java
```java
package org.example.student.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// POST /api/auth/login response — NO password field!
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDTO {
    private String token;
    private String email;
    private String role;
    private String message;
}
```

---

### Updated StudentService.java — returns DTOs
```java
package org.example.student.service;

import org.example.student.dto.StudentRequestDTO;
import org.example.student.dto.StudentResponseDTO;
import org.example.student.model.Student;
import org.example.student.repository.StudentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentService {

    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    @Autowired
    private StudentRepository studentRepository;

    // ── Converter: Entity → ResponseDTO ─────────────────────────
    // One place for conversion — easy to maintain
    private StudentResponseDTO toResponseDTO(Student student) {
        return new StudentResponseDTO(
            student.getId(),
            student.getName(),
            student.getEmail(),
            student.getAge()
        );
    }

    // ── Converter: RequestDTO → Entity ──────────────────────────
    private Student toEntity(StudentRequestDTO dto) {
        Student student = new Student();
        student.setName(dto.getName());
        student.setEmail(dto.getEmail());
        student.setAge(dto.getAge());
        return student;
    }

    // ── CREATE ──────────────────────────────────────────────────
    public StudentResponseDTO createStudent(StudentRequestDTO dto) {
        log.info("Creating student with email: {}", dto.getEmail());
        if (studentRepository.existsByEmail(dto.getEmail())) {
            log.warn("Student creation failed — email already exists: {}", dto.getEmail());
            throw new RuntimeException("Email already exists: " + dto.getEmail());
        }
        Student saved = studentRepository.save(toEntity(dto));
        log.info("Student created successfully with id: {}", saved.getId());
        return toResponseDTO(saved);
    }

    // ── READ ALL ────────────────────────────────────────────────
    public List<StudentResponseDTO> getAllStudents() {
        log.info("Fetching all students");
        return studentRepository.findAll()
                .stream()
                .map(this::toResponseDTO)
                .collect(Collectors.toList());
    }

    // ── READ ONE ────────────────────────────────────────────────
    public StudentResponseDTO getStudentById(Long id) {
        log.info("Fetching student with id: {}", id);
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Student not found with id: {}", id);
                    return new RuntimeException("Student not found with id: " + id);
                });
        return toResponseDTO(student);
    }

    // ── UPDATE ──────────────────────────────────────────────────
    public StudentResponseDTO updateStudent(Long id, StudentRequestDTO dto) {
        log.info("Updating student with id: {}", id);
        Student existing = studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found with id: " + id));
        existing.setName(dto.getName());
        existing.setEmail(dto.getEmail());
        existing.setAge(dto.getAge());
        Student updated = studentRepository.save(existing);
        log.info("Student updated successfully with id: {}", id);
        return toResponseDTO(updated);
    }

    // ── DELETE ──────────────────────────────────────────────────
    public void deleteStudent(Long id) {
        log.info("Deleting student with id: {}", id);
        studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found with id: " + id));
        studentRepository.deleteById(id);
        log.info("Student deleted successfully with id: {}", id);
    }
}
```

---

### Updated StudentController.java — uses DTOs + Swagger annotations
```java
package org.example.student.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.example.student.dto.StudentRequestDTO;
import org.example.student.dto.StudentResponseDTO;
import org.example.student.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/students")
@Validated
@Tag(name = "Students", description = "Student management APIs")
@SecurityRequirement(name = "bearerAuth")   // shows lock icon on all student endpoints
public class StudentController {

    @Autowired
    private StudentService studentService;

    @Operation(summary = "Create a new student", description = "Only ADMIN can create students")
    @PostMapping
    public ResponseEntity<StudentResponseDTO> createStudent(
            @Valid @RequestBody StudentRequestDTO dto) {
        return new ResponseEntity<>(studentService.createStudent(dto), HttpStatus.CREATED);
    }

    @Operation(summary = "Get all students")
    @GetMapping("/getAll")
    public ResponseEntity<List<StudentResponseDTO>> getAllStudents() {
        return new ResponseEntity<>(studentService.getAllStudents(), HttpStatus.OK);
    }

    @Operation(summary = "Get student by ID")
    @GetMapping("/student/{id}")
    public ResponseEntity<StudentResponseDTO> getStudentById(@PathVariable Long id) {
        return new ResponseEntity<>(studentService.getStudentById(id), HttpStatus.OK);
    }

    @Operation(summary = "Update student", description = "Only ADMIN can update students")
    @PutMapping("/{id}")
    public ResponseEntity<StudentResponseDTO> updateStudent(
            @PathVariable Long id,
            @Valid @RequestBody StudentRequestDTO dto) {
        return new ResponseEntity<>(studentService.updateStudent(id, dto), HttpStatus.OK);
    }

    @Operation(summary = "Delete student", description = "Only ADMIN can delete students")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteStudent(@PathVariable Long id) {
        studentService.deleteStudent(id);
        return new ResponseEntity<>("Student deleted successfully!", HttpStatus.OK);
    }
}
```

---

### Updated AuthController.java — uses DTOs, no lock icon on auth
```java
package org.example.student.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.example.student.dto.AuthResponseDTO;
import org.example.student.dto.LoginRequestDTO;
import org.example.student.dto.RegisterRequestDTO;
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
@Tag(name = "Authentication", description = "Login and Register APIs")
// NO @SecurityRequirement here — these routes are public
public class AuthController {

    @Autowired private UserRepository userRepository;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private PasswordEncoder passwordEncoder;

    @Operation(
        summary  = "Register a new user",
        security = {}    // empty = no lock icon — this route is public
    )
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequestDTO dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", "Email already registered!"));
        }
        User user = new User();
        user.setEmail(dto.getEmail());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(dto.getRole() == null || dto.getRole().isEmpty()
                ? "USER" : dto.getRole().toUpperCase());
        userRepository.save(user);

        // Clean response — no password!
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
            "message", "User registered successfully!",
            "email",   user.getEmail(),
            "role",    user.getRole()
        ));
    }

    @Operation(
        summary  = "Login and get JWT token",
        security = {}    // empty = no lock icon — this route is public
    )
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO dto) {
        Optional<User> userOpt = userRepository.findByEmail(dto.getEmail());
        if (userOpt.isEmpty() ||
            !passwordEncoder.matches(dto.getPassword(), userOpt.get().getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }
        User user    = userOpt.get();
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole());

        // AuthResponseDTO — clean, no password
        return ResponseEntity.ok(new AuthResponseDTO(
            token,
            user.getEmail(),
            user.getRole(),
            "Login successful!"
        ));
    }
}
```

---

## 3. Swagger / OpenAPI Documentation

### What is Swagger?
```
Swagger = auto-generated browser UI for your API

Benefits:
  ✅ Test APIs from browser — no CURL needed
  ✅ Shows all endpoints with request/response examples
  ✅ Authorize button to add JWT token
  ✅ Team members can explore API without reading code
  ✅ Great for resume and client demos
```

### pom.xml — add dependency
```xml
<!-- Use 2.8.8+ for Spring Boot 4.x compatibility -->
<!-- Use 2.3.0 for Spring Boot 3.x -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.8.8</version>
</dependency>
```

### Version compatibility table
| Spring Boot | springdoc version |
|---|---|
| 2.x | 1.7.0 |
| 3.x | 2.3.0 |
| 4.x | 2.8.8 ← use this |

### application.properties — Swagger config
```properties
# Swagger settings
springdoc.api-docs.enabled=true
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.display-request-duration=true
springdoc.swagger-ui.disable-swagger-default-url=true
```

### config/SwaggerConfig.java — new file
```java
package org.example.student.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

@Configuration

// API info shown at top of Swagger UI page
@OpenAPIDefinition(
    info = @Info(
        title       = "Student CRUD API",
        version     = "1.0",
        description = "REST API with JWT Authentication, Rate Limiting, and Validation"
    ),
    // Applies bearerAuth to ALL endpoints by default
    // Individual endpoints can override with security = {} to remove lock
    security = @SecurityRequirement(name = "bearerAuth")
)

// Defines the JWT security scheme
// This adds the Authorize button in Swagger UI
@SecurityScheme(
    name         = "bearerAuth",           // must match @SecurityRequirement name
    type         = SecuritySchemeType.HTTP,
    scheme       = "bearer",
    bearerFormat = "JWT",
    in           = SecuritySchemeIn.HEADER,
    description  = "Paste your JWT token here. Get it from POST /api/auth/login"
)
public class SwaggerConfig {
    // No code needed — annotations handle everything
}
```

### SecurityConfig.java — allow Swagger URLs
Add these to `permitAll()`:
```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/auth/**").permitAll()

    // Allow all Swagger URLs without token
    .requestMatchers(
        "/swagger-ui.html",
        "/swagger-ui/**",
        "/swagger-ui/index.html",
        "/v3/api-docs",
        "/v3/api-docs/**",
        "/v3/api-docs.yaml",
        "/swagger-resources/**",
        "/webjars/**"
    ).permitAll()

    // Protected routes below
    .requestMatchers(HttpMethod.GET, "/api/students/**").hasAnyRole("USER", "ADMIN")
    .requestMatchers(HttpMethod.POST,   "/api/students/**").hasRole("ADMIN")
    .requestMatchers(HttpMethod.PUT,    "/api/students/**").hasRole("ADMIN")
    .requestMatchers(HttpMethod.DELETE, "/api/students/**").hasRole("ADMIN")
    .anyRequest().authenticated()
)
```

### RateLimitFilter.java — skip Swagger URLs
Add at the top of `doFilterInternal`:
```java
String path = request.getRequestURI();

// Skip rate limiting for Swagger static files
// Swagger loads 10+ JS/CSS files — rate limiting breaks it
if (path.startsWith("/swagger-ui") ||
    path.startsWith("/v3/api-docs") ||
    path.startsWith("/swagger-resources") ||
    path.startsWith("/webjars") ||
    path.equals("/favicon.ico")) {
    filterChain.doFilter(request, response);
    return;
}
```

### Swagger Annotations Reference
```java
// On Controller class — groups endpoints under a section
@Tag(name = "Students", description = "Student management APIs")

// On Controller class — adds lock icon to all endpoints
@SecurityRequirement(name = "bearerAuth")

// On each method — shows description in Swagger
@Operation(summary = "Create a new student", description = "Only ADMIN can create")

// On public methods — removes lock icon (public route)
@Operation(summary = "Login", security = {})
```

### How to use Swagger UI — Step by step
```
Step 1: Open browser → http://localhost:8081/swagger-ui/index.html

Step 2: Find POST /api/auth/login (Authentication section)
  → Click it → Try it out
  → Enter: {"email":"admin@example.com","password":"admin123"}
  → Execute
  → Copy the token value from response (just the string, not full JSON)

Step 3: Click Authorize button (top right, green button with lock icon)
  → Paste token in Value field
  → Click Authorize → Close

Step 4: Lock icons change from 🔓 to 🔒 — token is active!

Step 5: Test any protected endpoint
  → POST /api/students → Try it out → fill body → Execute → 201 Created ✅
```

### Lock icon meanings
```
🔓 Open lock = endpoint is public OR token not set
🔒 Closed lock = endpoint uses token (set via Authorize button)

IMPORTANT:
  Lock icon in Swagger = visual hint only
  Real security = SecurityConfig.java (permitAll vs hasRole)

  /api/auth/login has lock icon but security={} → actually public ✅
  /api/students has lock icon → actually protected ✅
```

---

## 4. Logging

### Why logging instead of System.out.println?
```
System.out.println problems:
  ❌ No log level (can't distinguish info vs error)
  ❌ Can't turn off in production
  ❌ No timestamp, no class name
  ❌ Not professional

SLF4J + Logback benefits:
  ✅ Log levels: TRACE, DEBUG, INFO, WARN, ERROR
  ✅ Control log level per package in properties
  ✅ Auto timestamp and class name
  ✅ Can write to file
  ✅ Already included in Spring Boot — no extra dependency!
```

### No new dependency needed!
```xml
<!-- SLF4J + Logback is ALREADY included in: -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
<!-- Just add the Logger lines to your classes -->
```

### How to add logger to any class
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class StudentService {

    // Add this ONE line at top of every class that needs logging
    private static final Logger log = LoggerFactory.getLogger(StudentService.class);
    //                                                          ↑ always use the current class name

    public Student createStudent(...) {
        log.info("Creating student with email: {}", dto.getEmail());
        // {} is a placeholder — value gets inserted automatically
        // Much better than: "Creating student with email: " + dto.getEmail()
    }
}
```

### Log levels — when to use which
```java
log.trace("Every tiny detail — method entry, variable value");  // very verbose
log.debug("Useful for debugging — flow information");           // dev only
log.info("Normal operations — created, updated, deleted");      // always on
log.warn("Something unexpected but app still works");           // attention needed
log.error("Something failed — exception, DB error");           // must investigate
```

### Real examples from your project
```java
// StudentService
log.info("Creating student with email: {}", dto.getEmail());
log.info("Student created successfully with id: {}", saved.getId());
log.warn("Student creation failed — email already exists: {}", dto.getEmail());
log.warn("Student not found with id: {}", id);
log.info("Fetching all students");
log.info("Deleting student with id: {}", id);

// RateLimitFilter — replace System.out.println
log.info("RateLimit allowed — key: {} | tokens left: {}", key, bucket.getAvailableTokens());
log.warn("Rate limit exceeded — key: {}", key);

// JwtFilter
log.debug("Valid JWT token for user: {}", email);
log.warn("Invalid JWT token received from IP: {}", request.getRemoteAddr());

// AuthController
log.info("User registered successfully: {}", dto.getEmail());
log.warn("Login failed — invalid credentials for: {}", dto.getEmail());
log.info("User logged in successfully: {}", user.getEmail());
```

### Updated RateLimitFilter.java — proper logging
```java
// Replace all System.out.println with:
private static final Logger log = LoggerFactory.getLogger(RateLimitFilter.class);

// In tryConsume block:
log.info("RateLimit allowed — key: {} | tokens left: {}",
         key, bucket.getAvailableTokens());

// In else block:
log.warn("Rate limit exceeded — key: {}", key);
```

### Updated JwtFilter.java — add logging
```java
private static final Logger log = LoggerFactory.getLogger(JwtFilter.class);

// After validateToken check:
if (jwtUtil.validateToken(token)) {
    log.debug("Valid JWT token for user: {}", email);
    // ... existing auth code
} else {
    log.warn("Invalid JWT token received");
}
```

### application.properties — logging config
```properties
# Your package → DEBUG shows everything during development
logging.level.org.example.student=DEBUG

# Spring internals → INFO is enough
logging.level.org.springframework=INFO
logging.level.org.hibernate.SQL=DEBUG

# Optional: save logs to file
logging.file.name=logs/student-app.log

# Console log format: time [thread] LEVEL class - message
logging.pattern.console=%d{HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n

# For production — change your package to INFO (less noise)
# logging.level.org.example.student=INFO
```

### Console output after logging setup
```
10:30:01 [main] INFO  StudentService - Creating student with email: ravi@example.com
10:30:01 [main] INFO  StudentService - Student created successfully with id: 1
10:30:02 [main] INFO  RateLimitFilter - RateLimit allowed — key: role:ADMIN:admin@example.com | tokens left: 9
10:30:05 [main] WARN  StudentService - Student not found with id: 999
10:30:10 [main] WARN  RateLimitFilter - Rate limit exceeded — key: role:USER:user@example.com
10:30:15 [main] DEBUG JwtFilter - Valid JWT token for user: admin@example.com
```

---

## 5. Complete File Structure

### New files added in Phase 2
```
src/main/java/org/example/student/
│
├── config/                           ← NEW folder
│   └── SwaggerConfig.java            ← NEW — Swagger setup + JWT auth button
│
├── dto/                              ← NEW folder
│   ├── StudentRequestDTO.java        ← NEW — POST/PUT request body
│   ├── StudentResponseDTO.java       ← NEW — GET/POST/PUT response
│   ├── RegisterRequestDTO.java       ← NEW — register body
│   ├── LoginRequestDTO.java          ← NEW — login body
│   └── AuthResponseDTO.java          ← NEW — login response (token, email, role)
│
├── controller/
│   ├── StudentController.java        ← UPDATED — uses DTOs + Swagger annotations
│   └── AuthController.java           ← UPDATED — uses DTOs + no lock on auth
│
├── service/
│   └── StudentService.java           ← UPDATED — returns DTOs + logging added
│
├── security/
│   ├── JwtUtil.java                  ← no change
│   ├── JwtFilter.java                ← UPDATED — logging added
│   ├── RateLimitFilter.java          ← UPDATED — System.out → log + skip swagger
│   └── SecurityConfig.java           ← UPDATED — Swagger URLs in permitAll()
│
└── (everything else unchanged)
```

### pom.xml — only 1 new dependency for Phase 2
```xml
<!-- Swagger / OpenAPI — use version matching your Spring Boot -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.8.8</version>  <!-- Spring Boot 4.x -->
</dependency>
```

---

## 6. Common Errors and Fixes

### Error: "Failed to load API definition — 500 /v3/api-docs"
```
Cause 1: Wrong springdoc version
Fix: Use 2.8.8 for Spring Boot 4.x

Cause 2: @ControllerAdvice conflict
Fix: springdoc 2.8.8 fixes this automatically

Cause 3: Spring Security blocking /v3/api-docs
Fix: Add to SecurityConfig permitAll():
  .requestMatchers("/v3/api-docs", "/v3/api-docs/**").permitAll()
```

### Error: "response status is 429" on Swagger UI
```
Cause: RateLimitFilter running on Swagger static files
  Browser loads 10+ JS/CSS files → hits anonymous limit instantly

Fix: Add at top of doFilterInternal in RateLimitFilter:
  if (path.startsWith("/swagger-ui") || path.startsWith("/v3/api-docs")) {
      filterChain.doFilter(request, response);
      return;
  }
```

### Error: "NoSuchMethodError ControllerAdviceBean"
```
Cause: springdoc version mismatch with Spring Framework version
  springdoc 2.3.0 uses Spring 6.x
  Spring Boot 4.x uses Spring 7.x → conflict!

Fix: Upgrade to springdoc 2.8.8
```

### Error: 403 on protected endpoints in Swagger
```
Cause: JWT token not set in Swagger Authorize

Fix:
  1. POST /api/auth/login → Execute → copy token
  2. Click Authorize button (top right)
  3. Paste token in Value field
  4. Click Authorize → Close
  5. Re-execute the request
```

### Error: Lock icon showing on public auth routes
```
Cause: @SecurityRequirement in @OpenAPIDefinition applies to ALL endpoints

Fix: Add security = {} on public endpoints:
  @Operation(summary = "Login", security = {})
  @PostMapping("/login")
  public ResponseEntity<?> login(...) { }
```

### Error: Port 8081 already in use
```
Fix: Kill the process
  Linux/Mac: sudo fuser -k 8081/tcp
  Windows:   netstat -ano | findstr :8081 → taskkill /PID <pid> /F
```

---

## 7. Quick Checklist

### DTO Pattern
- [ ] Created `dto/` folder
- [ ] `StudentRequestDTO.java` — with validation annotations
- [ ] `StudentResponseDTO.java` — with id, name, email, age
- [ ] `RegisterRequestDTO.java` — email, password, role
- [ ] `LoginRequestDTO.java` — email, password
- [ ] `AuthResponseDTO.java` — token, email, role, message
- [ ] `StudentService.java` — returns DTOs, uses toResponseDTO() helper
- [ ] `StudentController.java` — parameters use DTOs
- [ ] `AuthController.java` — parameters use DTOs, returns AuthResponseDTO
- [ ] Password never appears in any response ✅

### Swagger
- [ ] springdoc dependency added to pom.xml (version 2.8.8 for Boot 4.x)
- [ ] `config/SwaggerConfig.java` created
- [ ] `application.properties` has springdoc settings
- [ ] `SecurityConfig.java` permits swagger URLs
- [ ] `RateLimitFilter.java` skips swagger URLs
- [ ] `StudentController.java` has `@Tag` and `@SecurityRequirement`
- [ ] `AuthController.java` has `@Tag`, auth methods have `security = {}`
- [ ] Authorize button visible at top of Swagger UI ✅
- [ ] Can login, copy token, authorize, test protected endpoints ✅

### Logging
- [ ] `private static final Logger log = LoggerFactory.getLogger(ClassName.class)` added to all service/filter classes
- [ ] All `System.out.println` replaced with proper log levels
- [ ] `application.properties` has logging config
- [ ] Console shows structured log messages ✅

### Version Reference
| Library | Spring Boot 3.x | Spring Boot 4.x |
|---|---|---|
| springdoc | 2.3.0 | 2.8.8 |
| jjwt | 0.12.3 | 0.12.3 |
| bucket4j | 8.7.0 | 8.7.0 |

---

## Swagger UI URLs
```
Main UI:     http://localhost:8081/swagger-ui/index.html
API JSON:    http://localhost:8081/v3/api-docs
API YAML:    http://localhost:8081/v3/api-docs.yaml
```

---

*Phase 2 Complete! Next: Phase 3 — Testing (JUnit 5 + Mockito + MockMvc)*
