# 10 — Next Steps Roadmap

## What You Have Built (Phase 1 Complete ✅)

```
✅ Student CRUD API          → REST endpoints working
✅ PostgreSQL Database       → real data storage
✅ .env File                 → no hardcoded secrets
✅ JWT Authentication        → login, register, token
✅ Role-Based Access         → ADMIN vs USER
✅ Rate Limiting             → 429 after limit exceeded
✅ Input Validation          → @Valid, @NotBlank, @Email
✅ Global Exception Handler  → clean JSON error responses
```

---

## Phase 2 — Code Quality

### Step A: DTO Pattern
**Why:** Right now User model with password field could accidentally get sent in response.
**What:** Create separate Request/Response objects.

```java
// Instead of returning User directly:
public User getUser() { ... }  // BAD — has password field!

// Create UserResponseDTO:
public class UserResponseDTO {
    private Long id;
    private String email;
    private String role;
    // NO password field!
}

public UserResponseDTO getUser() { ... }  // GOOD ✅
```

Files to add:
```
dto/
├── StudentRequestDTO.java    ← what client sends
├── StudentResponseDTO.java   ← what server returns
└── AuthResponseDTO.java      ← login response (token, email, role)
```

---

### Step B: Swagger / OpenAPI Documentation

**Why:** Auto-generates browser UI to test your API. No CURL needed!
**URL after setup:** http://localhost:8081/swagger-ui.html

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

```java
// Annotate your controller
@Operation(summary = "Get all students", description = "Returns list of all students")
@ApiResponse(responseCode = "200", description = "Students found")
@ApiResponse(responseCode = "401", description = "Unauthorized")
@GetMapping
public ResponseEntity<List<Student>> getAllStudents() { ... }
```

---

### Step C: Logging

**Why:** Track what happened and when. Essential for debugging production issues.

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class StudentService {
    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    public Student createStudent(Student student) {
        log.info("Creating student with email: {}", student.getEmail());
        // ...
        log.info("Student created successfully with id: {}", saved.getId());
        return saved;
    }
}
```

---

## Phase 3 — Testing

### Unit Testing (JUnit 5 + Mockito)

**Why:** Test Service layer WITHOUT hitting the real database.

```xml
<!-- already included in spring-boot-starter-test -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

```java
@ExtendWith(MockitoExtension.class)
class StudentServiceTest {

    @Mock                                    // fake repository — no real DB
    private StudentRepository studentRepository;

    @InjectMocks                             // inject mock into service
    private StudentService studentService;

    @Test
    void createStudent_ShouldReturnStudent_WhenEmailNotExists() {
        // Arrange — set up test data
        Student student = new Student(null, "Ravi", "ravi@test.com", 21);
        when(studentRepository.existsByEmail("ravi@test.com")).thenReturn(false);
        when(studentRepository.save(student)).thenReturn(new Student(1L, "Ravi", "ravi@test.com", 21));

        // Act — call the method
        Student result = studentService.createStudent(student);

        // Assert — verify the result
        assertNotNull(result.getId());
        assertEquals("Ravi", result.getName());
    }

    @Test
    void createStudent_ShouldThrowException_WhenEmailExists() {
        Student student = new Student(null, "Ravi", "ravi@test.com", 21);
        when(studentRepository.existsByEmail("ravi@test.com")).thenReturn(true);

        assertThrows(RuntimeException.class, () -> studentService.createStudent(student));
    }
}
```

### Integration Testing (MockMvc)
```java
@SpringBootTest
@AutoConfigureMockMvc
class StudentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void getAllStudents_ShouldReturn401_WhenNoToken() throws Exception {
        mockMvc.perform(get("/api/students"))
               .andExpect(status().isUnauthorized());
    }
}
```

---

## Phase 4 — Docker

### What is Docker?
Package your app + all dependencies into a container.
Runs the same on any machine — your laptop, your teammate's laptop, AWS server.

### Dockerfile
```dockerfile
# Use Java 17 base image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory inside container
WORKDIR /app

# Copy the built jar file
COPY target/student-0.0.1-SNAPSHOT.jar app.jar

# Run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### docker-compose.yml
```yaml
version: '3.8'
services:

  # Your Spring Boot app
  student-app:
    build: .
    ports:
      - "8081:8081"
    environment:
      - DB_URL=jdbc:postgresql://db:5432/studentdb
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - JWT_SECRET=mySecretKey12345678901234567890AB
    depends_on:
      - db

  # PostgreSQL database
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=studentdb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data  # data survives container restart

volumes:
  postgres_data:
```

### Run with Docker
```bash
# Build jar first
./mvnw clean package -DskipTests

# Start everything
docker-compose up --build

# Stop everything
docker-compose down

# Stop and delete all data
docker-compose down -v
```

---

## Phase 5 — AWS Deployment

### Services You Need
```
EC2             → virtual server to run your app
RDS             → managed PostgreSQL database
Parameter Store → store secrets (FREE)
S3              → store files (if needed)
```

### Steps
```
1. Create RDS PostgreSQL instance
   → get endpoint: your-db.xxxx.ap-south-1.rds.amazonaws.com

2. Create Parameter Store params
   /student-app/prod/DB_URL      → jdbc:postgresql://your-db:5432/studentdb
   /student-app/prod/DB_USERNAME → postgres
   /student-app/prod/DB_PASSWORD → (SecureString)

3. Launch EC2 instance (Amazon Linux 2023)
   → install Java 17
   → copy jar file
   → set profile to prod
   → run: java -jar student.jar --spring.profiles.active=prod

4. Create IAM role
   → allow EC2 to read from Parameter Store
   → attach role to EC2 instance
```

---

## Phase 6 — CI/CD (GitHub Actions)

**Why:** Push code to GitHub → automatically test → automatically deploy to AWS.

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Java 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build with Maven
        run: ./mvnw clean package -DskipTests

      - name: Run tests
        run: ./mvnw test

      - name: Deploy to EC2
        # Copy jar and restart app on EC2
        run: |
          scp target/student-*.jar ec2-user@${{ secrets.EC2_HOST }}:~/app.jar
          ssh ec2-user@${{ secrets.EC2_HOST }} 'sudo systemctl restart student-app'
```

---

## Phase 7 — Advanced Topics

### Redis Caching
```java
// application.properties
spring.cache.type=redis
spring.data.redis.host=localhost
spring.data.redis.port=6379

// Service
@Cacheable(value = "students", key = "#id")  // cache result
public Student getStudentById(Long id) { ... }

@CacheEvict(value = "students", key = "#id") // clear cache on update/delete
public void deleteStudent(Long id) { ... }
```

### Pagination (for large datasets)
```java
// Repository
Page<Student> findAll(Pageable pageable);

// Controller
@GetMapping
public Page<Student> getAllStudents(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size) {
    return studentService.getAllStudents(PageRequest.of(page, size));
}

// Request: GET /api/students?page=0&size=10
```

---

## Recommended Weekly Plan

```
Week 1 → DTO Pattern + Swagger + Logging
Week 2 → Unit Tests (JUnit + Mockito)
Week 3 → Integration Tests (MockMvc)
Week 4 → Docker + docker-compose
Week 5 → AWS EC2 + RDS
Week 6 → CI/CD with GitHub Actions
Week 7 → Redis Caching + Pagination
After  → Microservices with Spring Cloud
```

---

## Final Complete Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client (Postman/Browser)              │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTP Request
┌─────────────────────▼───────────────────────────────────┐
│                    Spring Boot API                       │
│                                                         │
│  RateLimitFilter → JwtFilter → SecurityConfig           │
│                      ↓                                  │
│  GlobalExceptionHandler wraps everything below          │
│                      ↓                                  │
│  Controller (@Valid) → Service → Repository             │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│              PostgreSQL Database                         │
│  users table     | students table                       │
└─────────────────────────────────────────────────────────┘
```

---

*You have built a production-ready API. Keep going! 🚀*
*Next project: start from 01-Project-Setup.md and follow the same steps.*
