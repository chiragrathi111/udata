# 🍃 Spring Boot Complete Project Guide
## From Zero to Production-Ready API

---

## What You Will Build
A fully secured REST API with:
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ PostgreSQL database
- ✅ JWT Authentication (login, register, role-based access)
- ✅ Rate Limiting (protect from abuse)
- ✅ Input Validation (clean data)
- ✅ Global Exception Handler (clean error responses)
- ✅ Environment Variables (.env file, no hardcoded secrets)

---

## Guide Index

| File | What it covers |
|---|---|
| `01-Project-Setup.md` | pom.xml, project structure, run the app |
| `02-CRUD.md` | Model, Repository, Service, Controller |
| `03-Database.md` | H2 vs PostgreSQL vs MongoDB differences |
| `04-Environment-Variables.md` | .env file, AWS Parameter Store |
| `05-JWT-Authentication.md` | Login, Register, Token, Role-based access |
| `06-Rate-Limiting.md` | bucket4j, Token Bucket, per-user limits |
| `07-Validation.md` | @Valid, @NotBlank, @Email, @Min |
| `08-Exception-Handler.md` | @ControllerAdvice, clean error JSON |
| `09-CURL-Testing.md` | All test commands |
| `10-Roadmap.md` | Next steps: Docker, AWS, Testing, Redis |

---

## Final Project Structure
```
org/example/student/
├── StudentCrudApplication.java       ← main + .env loader
├── controller/
│   ├── StudentController.java        ← CRUD endpoints
│   └── AuthController.java           ← login + register
├── model/
│   ├── Student.java                  ← DB entity + validation
│   ├── User.java                     ← login users
│   └── ErrorResponse.java            ← error format
├── repository/
│   ├── StudentRepository.java
│   └── UserRepository.java
├── service/
│   └── StudentService.java
├── security/
│   ├── JwtUtil.java                  ← token create/validate
│   ├── JwtFilter.java                ← check token per request
│   ├── RateLimitFilter.java          ← limit requests per user
│   └── SecurityConfig.java           ← route protection rules
└── exception/
    └── GlobalExceptionHandler.java
```

## Every Request Flow
```
HTTP Request
     ↓
RateLimitFilter  →  429 Too Many Requests ❌
     ↓
JwtFilter        →  401 Unauthorized ❌
     ↓
SecurityConfig   →  403 Forbidden ❌
     ↓
GlobalExceptionHandler (wraps below)
     ↓
Controller → Service → Repository → DB
     ↓
200 OK ✅
```

---

## Annotation Quick Reference

| Annotation | Layer | What it does |
|---|---|---|
| `@SpringBootApplication` | Main | Boots the whole app (3-in-1) |
| `@Entity` | Model | Maps class → DB table |
| `@Table(name="x")` | Model | Sets exact table name |
| `@Id` | Model | Primary key |
| `@GeneratedValue` | Model | Auto-increment ID |
| `@Column` | Model | Customize column rules |
| `@Data` | Model | Lombok: getters + setters |
| `@NoArgsConstructor` | Model | Empty constructor |
| `@AllArgsConstructor` | Model | Full constructor |
| `@Repository` | Repository | DB access layer |
| `@Service` | Service | Business logic layer |
| `@RestController` | Controller | HTTP handler + JSON |
| `@RequestMapping` | Controller | Base URL prefix |
| `@GetMapping` | Controller | HTTP GET |
| `@PostMapping` | Controller | HTTP POST |
| `@PutMapping` | Controller | HTTP PUT |
| `@DeleteMapping` | Controller | HTTP DELETE |
| `@PathVariable` | Controller | Read {id} from URL |
| `@RequestBody` | Controller | JSON → Java object |
| `@Autowired` | Any | Inject Spring bean |
| `@Valid` | Controller | Trigger validation |
| `@Component` | Any | Generic Spring bean |
| `@Configuration` | Security | Settings class |
| `@Bean` | Security | Spring-managed object |
| `@RestControllerAdvice` | Exception | Global error handler |
| `@ExceptionHandler` | Exception | Handle specific exception |

---
*Spring Boot 4.x | Java 17 | JWT 0.12.3 | bucket4j 8.7.0*
