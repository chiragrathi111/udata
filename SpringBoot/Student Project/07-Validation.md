# 07 — Input Validation

## Why Validate?
Without validation, anyone can send bad data:
```json
{"name": "", "email": "not-an-email", "age": -999}
```
This would get saved to DB without any error!

With validation:
```json
{
  "status": 400,
  "errors": {
    "name": "Name is required",
    "email": "Please provide a valid email address",
    "age": "Age must be at least 1"
  }
}
```

---

## pom.xml — Add Dependency
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

---

## Student.java — Add Validation Annotations

```java
import jakarta.validation.constraints.*;   // ← add this import

@Entity
@Table(name = "students")
@Data @NoArgsConstructor @AllArgsConstructor
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // name cannot be null, empty, or just spaces
    // must be 2-100 characters
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    @Column(nullable = false, length = 100)
    private String name;

    // email cannot be empty
    // must be valid email format (contains @ and domain)
    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    @Column(nullable = false, unique = true, length = 150)
    private String email;

    // age cannot be null
    // must be between 1 and 150
    @NotNull(message = "Age is required")
    @Min(value = 1, message = "Age must be at least 1")
    @Max(value = 150, message = "Age must be less than 150")
    @Column(nullable = false)
    private Integer age;
}
```

---

## StudentController.java — Add @Valid

Only 2 places need `@Valid` — POST and PUT:

```java
import jakarta.validation.Valid;            // ← add import
import org.springframework.validation.annotation.Validated;

@RestController
@RequestMapping("/api/students")
@Validated                                  // ← add on class
public class StudentController {

    // POST — validate request body before processing
    @PostMapping
    public ResponseEntity<Student> createStudent(@Valid @RequestBody Student student) {
        //                                        ↑ @Valid triggers validation
        Student created = studentService.createStudent(student);
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<Student>> getAllStudents() {
        return new ResponseEntity<>(studentService.getAllStudents(), HttpStatus.OK);
        // No @Valid — GET has no body to validate
    }

    @GetMapping("/{id}")
    public ResponseEntity<Student> getStudentById(@PathVariable Long id) {
        return new ResponseEntity<>(studentService.getStudentById(id), HttpStatus.OK);
        // No @Valid — path variable only
    }

    // PUT — validate updated data too
    @PutMapping("/{id}")
    public ResponseEntity<Student> updateStudent(
            @PathVariable Long id,
            @Valid @RequestBody Student student) {
            // ↑ @Valid here too — update should also validate!
        return new ResponseEntity<>(studentService.updateStudent(id, student), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteStudent(@PathVariable Long id) {
        studentService.deleteStudent(id);
        return new ResponseEntity<>("Student deleted successfully!", HttpStatus.OK);
        // No @Valid — delete only needs ID
    }
}
```

> When @Valid fails → MethodArgumentNotValidException is thrown
> → GlobalExceptionHandler catches it → returns 400 with field errors

---

## All Validation Annotations — Reference

### String validations
```java
@NotBlank(message = "...")    // not null + not empty + not just spaces
@NotEmpty(message = "...")    // not null + not empty (allows spaces)
@NotNull(message = "...")     // not null (allows empty string)
@Size(min=2, max=100)         // string length range
@Email(message = "...")       // valid email format
@Pattern(regexp="[A-Z]{3}")  // must match regex pattern
@URL(message = "...")         // valid URL format
```

### Number validations
```java
@NotNull(message = "...")     // required for Integer/Long
@Min(value = 1)               // minimum value (inclusive)
@Max(value = 150)             // maximum value (inclusive)
@Positive(message = "...")    // must be > 0
@PositiveOrZero               // must be >= 0
@Negative                     // must be < 0
@DecimalMin("0.1")            // for BigDecimal min
@DecimalMax("999.9")          // for BigDecimal max
@Digits(integer=5, fraction=2) // max digits before and after decimal
```

### Date validations
```java
@Future(message = "...")      // date must be in the future
@FutureOrPresent              // date >= today
@Past(message = "...")        // date must be in the past
@PastOrPresent                // date <= today
```

### Custom message with field name
```java
// message can reference the field value
@Size(min = 2, max = 50, message = "Name must be {min}-{max} characters")
@Min(value = 18, message = "Minimum age is {value}")
```

---

## Real World Examples

### User Registration validation
```java
public class User {
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = ".*[A-Z].*", message = "Password must contain at least one uppercase letter")
    private String password;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be 2-50 characters")
    private String name;

    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Must be 18 or older")
    private Integer age;
}
```

### Product validation
```java
public class Product {
    @NotBlank(message = "Product name required")
    private String name;

    @NotNull(message = "Price required")
    @DecimalMin(value = "0.01", message = "Price must be greater than 0")
    private BigDecimal price;

    @Min(value = 0, message = "Stock cannot be negative")
    private Integer stock;
}
```

---

## What @Valid Does — Internally

```
POST /api/students {"name":"","email":"bad","age":-5}
          ↓
@Valid triggers validation on Student object
          ↓
@NotBlank checks name → FAILS (empty)
@Email    checks email → FAILS (invalid format)
@Min      checks age   → FAILS (less than 1)
          ↓
MethodArgumentNotValidException thrown with all 3 errors
          ↓
GlobalExceptionHandler.handleValidationErrors() catches it
          ↓
400 Bad Request + error map returned:
{
  "name": "Name is required",
  "email": "Please provide a valid email address",
  "age": "Age must be at least 1"
}
```

---

## Validation Does NOT Replace Service Checks!
```java
// @Valid catches: empty name, invalid email, negative age
// But you still need service-level checks for:

public Student createStudent(Student student) {
    // This can't be done with annotations — needs DB call
    if (studentRepository.existsByEmail(student.getEmail())) {
        throw new RuntimeException("Email already exists: " + student.getEmail());
    }
    return studentRepository.save(student);
}
```

Both layers work together:
- `@Valid` = input format checks (fast, no DB)
- Service checks = business rule checks (may need DB)
