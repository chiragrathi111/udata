# 08 — Global Exception Handler

## Why Do You Need This?

Without handler — ugly error users see:
```json
{
  "timestamp": "2026-05-27T05:01:23.945+00:00",
  "status": 500,
  "error": "Internal Server Error",
  "path": "/api/students"
}
```

With handler — clean professional error:
```json
{
  "status": 404,
  "message": "Student not found with id: 99",
  "timestamp": "2026-05-27T10:30:00"
}
```

## New Files
```
model/
  └── ErrorResponse.java            ← defines error JSON format
exception/
  └── GlobalExceptionHandler.java   ← catches ALL exceptions
```

---

## ErrorResponse.java (in model/ folder)

```java
package org.example.student.model;

import java.time.LocalDateTime;
import java.util.Map;

// Defines what every error response looks like as JSON
public class ErrorResponse {

    private int status;                   // HTTP code: 400, 404, 500
    private String message;               // human-readable error description
    private LocalDateTime timestamp;      // when the error happened
    private Map<String, String> errors;   // field-level errors (for validation)

    // For general errors (404 Not Found, 409 Conflict, 500 etc.)
    public ErrorResponse(int status, String message) {
        this.status    = status;
        this.message   = message;
        this.timestamp = LocalDateTime.now();
    }

    // For validation errors (400 Bad Request) — includes field error map
    public ErrorResponse(int status, String message, Map<String, String> errors) {
        this.status    = status;
        this.message   = message;
        this.timestamp = LocalDateTime.now();
        this.errors    = errors;
    }

    // Getters — needed for Jackson to serialize to JSON
    public int getStatus()                 { return status; }
    public String getMessage()             { return message; }
    public LocalDateTime getTimestamp()    { return timestamp; }
    public Map<String, String> getErrors() { return errors; }
}
```

---

## GlobalExceptionHandler.java (in exception/ folder)

```java
package org.example.student.exception;

import org.example.student.model.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import java.util.HashMap;
import java.util.Map;

// @RestControllerAdvice = global umbrella over all @RestController classes
// Any exception thrown in any controller/service → comes here first
// = @ControllerAdvice + @ResponseBody
@RestControllerAdvice
public class GlobalExceptionHandler {

    // ── 1. VALIDATION ERRORS → 400 ──────────────────────────────
    // Triggered when @Valid fails in controller
    // Contains ALL field errors at once
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(
            MethodArgumentNotValidException ex) {

        // Collect all field → error message pairs
        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult()
          .getAllErrors()
          .forEach(error -> {
              String field   = ((FieldError) error).getField();
              String message = error.getDefaultMessage();
              errors.put(field, message);
          });

        ErrorResponse response = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),               // 400
            "Validation failed — please check your input",
            errors                                        // field errors map
        );

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    // ── 2. RUNTIME EXCEPTIONS → 404 / 409 / 400 ─────────────────
    // Thrown from StudentService:
    //   "Student not found with id: 1"  → 404
    //   "Email already exists: x@x.com" → 409
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(RuntimeException ex) {

        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";

        if (msg.contains("not found")) {
            return new ResponseEntity<>(
                new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage()),
                HttpStatus.NOT_FOUND   // 404
            );
        }

        if (msg.contains("already exists")) {
            return new ResponseEntity<>(
                new ErrorResponse(HttpStatus.CONFLICT.value(), ex.getMessage()),
                HttpStatus.CONFLICT    // 409
            );
        }

        // Default → 400 Bad Request
        return new ResponseEntity<>(
            new ErrorResponse(HttpStatus.BAD_REQUEST.value(), ex.getMessage()),
            HttpStatus.BAD_REQUEST
        );
    }

    // ── 3. ALL OTHER EXCEPTIONS → 500 ───────────────────────────
    // DB down, NullPointerException, unexpected errors
    // IMPORTANT: do NOT expose internal details in production!
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {

        // Log the actual error for developers (add logging later)
        // log.error("Unexpected error: ", ex);

        return new ResponseEntity<>(
            new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),   // 500
                "Something went wrong! Please try again later."
                // Don't use ex.getMessage() here — could expose internal details!
            ),
            HttpStatus.INTERNAL_SERVER_ERROR
        );
    }
}
```

---

## How It All Connects

```
StudentService.getStudentById(999)
        ↓
throw new RuntimeException("Student not found with id: 999")
        ↓
GlobalExceptionHandler.handleRuntimeException() catches it
        ↓
message.contains("not found") → true
        ↓
Returns: 404 Not Found
{
  "status": 404,
  "message": "Student not found with id: 999",
  "timestamp": "2026-05-27T10:30:00"
}
```

```
POST /api/students {"name":"","email":"bad","age":-5}
        ↓
@Valid triggers → MethodArgumentNotValidException thrown
        ↓
GlobalExceptionHandler.handleValidationErrors() catches it
        ↓
Returns: 400 Bad Request
{
  "status": 400,
  "message": "Validation failed — please check your input",
  "timestamp": "2026-05-27T10:30:00",
  "errors": {
    "name": "Name is required",
    "email": "Please provide a valid email address",
    "age": "Age must be at least 1"
  }
}
```

---

## Adding Custom Exceptions (Optional — Better Practice)

Instead of generic RuntimeException, create specific exception classes:

```java
// exception/StudentNotFoundException.java
public class StudentNotFoundException extends RuntimeException {
    public StudentNotFoundException(Long id) {
        super("Student not found with id: " + id);
    }
}

// exception/EmailAlreadyExistsException.java
public class EmailAlreadyExistsException extends RuntimeException {
    public EmailAlreadyExistsException(String email) {
        super("Email already exists: " + email);
    }
}
```

Use in StudentService:
```java
public Student getStudentById(Long id) {
    return studentRepository.findById(id)
            .orElseThrow(() -> new StudentNotFoundException(id));
    //                         ↑ specific exception — cleaner!
}
```

Handle in GlobalExceptionHandler:
```java
@ExceptionHandler(StudentNotFoundException.class)
public ResponseEntity<ErrorResponse> handleStudentNotFound(StudentNotFoundException ex) {
    return new ResponseEntity<>(
        new ErrorResponse(404, ex.getMessage()),
        HttpStatus.NOT_FOUND
    );
}
```

---

## All Error Response Examples

### 400 — Validation Error
```json
{
  "status": 400,
  "message": "Validation failed — please check your input",
  "timestamp": "2026-05-27T10:30:00",
  "errors": {
    "name": "Name is required",
    "email": "Please provide a valid email address"
  }
}
```

### 401 — Unauthorized (from JwtFilter)
```json
{
  "status": 401,
  "message": "Unauthorized"
}
```

### 403 — Forbidden (from SecurityConfig)
```json
{
  "status": 403,
  "message": "Forbidden"
}
```

### 404 — Not Found
```json
{
  "status": 404,
  "message": "Student not found with id: 99",
  "timestamp": "2026-05-27T10:30:00"
}
```

### 409 — Conflict
```json
{
  "status": 409,
  "message": "Email already exists: ravi@example.com",
  "timestamp": "2026-05-27T10:30:00"
}
```

### 429 — Too Many Requests (from RateLimitFilter)
```json
{
  "error": "Too many requests! Please wait before retrying.",
  "status": 429
}
```

### 500 — Internal Server Error
```json
{
  "status": 500,
  "message": "Something went wrong! Please try again later.",
  "timestamp": "2026-05-27T10:30:00"
}
```
