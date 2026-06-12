# 01 — Project Setup

## Create Project
Go to https://start.spring.io and select:
```
Project  : Maven
Language : Java
Version  : Spring Boot 4.x (or latest stable)
Group    : org.example
Artifact : student
Java     : 17
```

Add dependencies: **Spring Web**, **Spring Data JPA**, **Lombok**, **DevTools**

---

## pom.xml — All Dependencies (full project)

```xml
<dependencies>

    <!-- ── CORE ────────────────────────────────────── -->

    <!-- Web: @RestController, @GetMapping, ResponseEntity -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- JPA: @Entity, @Repository, JpaRepository -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- PostgreSQL driver -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>

    <!-- Lombok: @Data, @NoArgsConstructor, @AllArgsConstructor -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

    <!-- DevTools: auto-restart on code change -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <scope>runtime</scope>
        <optional>true</optional>
    </dependency>

    <!-- ── SECURITY + JWT ──────────────────────────── -->

    <!-- Spring Security -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>

    <!-- JWT API -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.3</version>
    </dependency>
    <!-- JWT Implementation -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.12.3</version>
        <scope>runtime</scope>
    </dependency>
    <!-- JWT Jackson (JSON parsing) -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.12.3</version>
        <scope>runtime</scope>
    </dependency>

    <!-- ── RATE LIMITING ───────────────────────────── -->

    <!-- bucket4j: token bucket rate limiting -->
    <dependency>
        <groupId>com.bucket4j</groupId>
        <artifactId>bucket4j-core</artifactId>
        <version>8.7.0</version>
    </dependency>

    <!-- ── VALIDATION ──────────────────────────────── -->

    <!-- @Valid, @NotBlank, @Email, @Min, @Max -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <!-- ── TESTING ─────────────────────────────────── -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>

</dependencies>
```

> 💡 **Tip:** Add all dependencies at the start. Maven downloads them once.

---

## application.properties — Full Config

```properties
# ── App ──────────────────────────────────────────────
spring.application.name=Student
server.port=8081

# ── Database ─────────────────────────────────────────
# Option A: Direct values (for quick local testing)
spring.datasource.url=jdbc:postgresql://localhost:5432/postgres
spring.datasource.username=postgres
spring.datasource.password=postgres

# Option B: From .env file (recommended)
# spring.datasource.url=${DB_URL}
# spring.datasource.username=${DB_USERNAME}
# spring.datasource.password=${DB_PASSWORD}

spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# ── JWT ───────────────────────────────────────────────
jwt.secret=mySecretKey12345678901234567890AB
# 86400000 ms = 24 hours
jwt.expiration=86400000
```

---

## StudentCrudApplication.java — Main Class

```java
package org.example.student;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

// @SpringBootApplication = 3 annotations in one:
//   @Configuration       → this class defines Spring beans
//   @EnableAutoConfiguration → Spring auto-configures DB, web, etc.
//   @ComponentScan       → scans this package for @Service, @Repository, etc.
@SpringBootApplication
public class StudentCrudApplication {

    public static void main(String[] args) {
        loadEnvFile(".env");  // load .env BEFORE Spring starts
        SpringApplication.run(StudentCrudApplication.class, args);
    }

    // Reads .env file and sets each key as a System property
    // So Spring can read ${DB_URL} from application.properties
    private static void loadEnvFile(String filename) {
        try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq == -1) continue;
                String key   = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                // Don't override if OS/server already set it (production safe)
                if (System.getProperty(key) == null && System.getenv(key) == null) {
                    System.setProperty(key, value);
                }
            }
        } catch (IOException e) {
            System.out.println("No .env file — using system environment variables");
        }
    }
}
```

---

## Project Folder Structure
```
Student/                          ← project root
├── .env                          ← secrets (never push to Git!)
├── .gitignore
├── pom.xml
└── src/
    └── main/
        ├── java/org/example/student/
        │   ├── StudentCrudApplication.java
        │   ├── controller/
        │   ├── model/
        │   ├── repository/
        │   ├── service/
        │   ├── security/
        │   └── exception/
        └── resources/
            └── application.properties
```

## .gitignore — Important!
```
# Secrets
.env

# Build
target/
*.class
*.jar

# IDE
.idea/
*.iml
.vscode/
```

## Run the App
```bash
# Using Maven wrapper
./mvnw spring-boot:run

# Or in IntelliJ: click the green Run button
# App starts at: http://localhost:8081
```

---

## Common Errors on First Run

| Error | Cause | Fix |
|---|---|---|
| `Port 8080 in use` | Another app using port | Change `server.port=8081` in properties |
| `DB connection refused` | PostgreSQL not running | Start PostgreSQL service |
| `Driver not found` | Missing PostgreSQL dep | Check pom.xml for postgresql dependency |
| `Red errors in Controller` | Missing web dependency | Add `spring-boot-starter-web` to pom.xml |
