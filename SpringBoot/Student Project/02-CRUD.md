# 02 — CRUD (Create, Read, Update, Delete)

## Layer Architecture
```
Request → Controller → Service → Repository → Database
Response ← Controller ← Service ← Repository ← Database
```
- **Controller** = handles HTTP, talks to outside world
- **Service**    = business logic, rules
- **Repository** = database operations

---

## Model — Student.java

```java
package org.example.student.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity                          // tells JPA: map this class to a DB table
@Table(name = "students")        // exact table name in PostgreSQL
@Data                            // Lombok: generates getters, setters, toString, equals
@NoArgsConstructor               // generates: Student s = new Student()
@AllArgsConstructor              // generates: Student s = new Student(id, name, email, age)
public class Student {

    @Id                                                    // PRIMARY KEY
    @GeneratedValue(strategy = GenerationType.IDENTITY)   // AUTO INCREMENT (1, 2, 3...)
    private Long id;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    @Column(nullable = false, length = 100)
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    @Column(nullable = false, unique = true, length = 150)  // unique = no duplicates
    private String email;

    @NotNull(message = "Age is required")
    @Min(value = 1, message = "Age must be at least 1")
    @Max(value = 150, message = "Age must be less than 150")
    @Column(nullable = false)
    private Integer age;
}
```

**DB table created automatically:**
```sql
CREATE TABLE students (
    id    BIGSERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    age   INTEGER NOT NULL
);
```

---

## Repository — StudentRepository.java

```java
package org.example.student.repository;

import org.example.student.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
// JpaRepository<Student, Long>:
//   Student = entity to manage
//   Long    = type of primary key
// FREE methods: save(), findAll(), findById(), deleteById(), count(), existsById()
public interface StudentRepository extends JpaRepository<Student, Long> {

    // Spring reads method name → auto-generates SQL
    // findByEmail → SELECT * FROM students WHERE email = ?
    Optional<Student> findByEmail(String email);

    // existsByEmail → SELECT COUNT(*) > 0 WHERE email = ?
    boolean existsByEmail(String email);
}
```

---

## Service — StudentService.java

```java
package org.example.student.service;

import org.example.student.model.Student;
import org.example.student.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service  // marks as business logic layer — Spring creates one instance (singleton)
public class StudentService {

    @Autowired  // Spring injects StudentRepository — no need for new StudentRepository()
    private StudentRepository studentRepository;

    // ── CREATE ─────────────────────────────────────────────
    public Student createStudent(Student student) {
        if (studentRepository.existsByEmail(student.getEmail())) {
            // GlobalExceptionHandler catches this → returns 409 Conflict
            throw new RuntimeException("Email already exists: " + student.getEmail());
        }
        return studentRepository.save(student);  // INSERT INTO students
    }

    // ── READ ALL ───────────────────────────────────────────
    public List<Student> getAllStudents() {
        return studentRepository.findAll();       // SELECT * FROM students
    }

    // ── READ ONE ───────────────────────────────────────────
    public Student getStudentById(Long id) {
        return studentRepository.findById(id)
                .orElseThrow(() ->
                    // GlobalExceptionHandler catches this → returns 404 Not Found
                    new RuntimeException("Student not found with id: " + id)
                );
    }

    // ── UPDATE ─────────────────────────────────────────────
    public Student updateStudent(Long id, Student updatedStudent) {
        Student existing = getStudentById(id);     // throws 404 if not found
        existing.setName(updatedStudent.getName());
        existing.setEmail(updatedStudent.getEmail());
        existing.setAge(updatedStudent.getAge());
        return studentRepository.save(existing);   // UPDATE students SET ...
    }

    // ── DELETE ─────────────────────────────────────────────
    public void deleteStudent(Long id) {
        getStudentById(id);                        // throws 404 if not found
        studentRepository.deleteById(id);          // DELETE FROM students WHERE id = ?
    }
}
```

---

## Controller — StudentController.java

```java
package org.example.student.controller;

import org.example.student.model.Student;
import org.example.student.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@RestController              // @Controller + @ResponseBody: handles HTTP + returns JSON
@RequestMapping("/api/students")  // all routes start with /api/students
@Validated                   // enables validation on method parameters
public class StudentController {

    @Autowired
    private StudentService studentService;

    // POST /api/students → CREATE
    // @RequestBody = read JSON body → convert to Student object
    // @Valid = validate Student fields (triggers @NotBlank, @Email, etc.)
    @PostMapping
    public ResponseEntity<Student> createStudent(@Valid @RequestBody Student student) {
        Student created = studentService.createStudent(student);
        return new ResponseEntity<>(created, HttpStatus.CREATED);  // 201
    }

    // GET /api/students → READ ALL
    @GetMapping
    public ResponseEntity<List<Student>> getAllStudents() {
        return new ResponseEntity<>(studentService.getAllStudents(), HttpStatus.OK);  // 200
    }

    // GET /api/students/1 → READ ONE
    // @PathVariable = read {id} value from URL
    @GetMapping("/{id}")
    public ResponseEntity<Student> getStudentById(@PathVariable Long id) {
        return new ResponseEntity<>(studentService.getStudentById(id), HttpStatus.OK);
    }

    // PUT /api/students/1 → UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<Student> updateStudent(
            @PathVariable Long id,
            @Valid @RequestBody Student student) {  // @Valid here too!
        return new ResponseEntity<>(studentService.updateStudent(id, student), HttpStatus.OK);
    }

    // DELETE /api/students/1 → DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteStudent(@PathVariable Long id) {
        studentService.deleteStudent(id);
        return new ResponseEntity<>("Student deleted successfully!", HttpStatus.OK);
    }
}
```

---

## HTTP Status Codes Used

| Code | Name | When |
|---|---|---|
| 200 | OK | GET, PUT, DELETE success |
| 201 | Created | POST success |
| 400 | Bad Request | Validation failed |
| 401 | Unauthorized | No/invalid JWT token |
| 403 | Forbidden | Valid token, wrong role |
| 404 | Not Found | Student ID doesn't exist |
| 409 | Conflict | Email already exists |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected error |
