# Ubuntu/Linux
sudo apt-get install -y redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo systemctl status redis-server

# Verify Redis is running
redis-cli ping
# Expected: PONG ✅


# Add dependencies :-

<!-- Redis + Spring Cache -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- Spring Cache abstraction -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>


# Added below line in the application.properties :-

# Redis connection
spring.data.redis.host=localhost
spring.data.redis.port=6379

# Cache config
spring.cache.type=redis
spring.cache.redis.time-to-live=600000
# 600000ms = 10 minutes — cache expires after 10 min

# Enable Caching to main class :-

package org.example.student;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

@SpringBootApplication
@EnableCaching   // ← ADD THIS — enables Spring Cache globally
public class StudentCrudApplication {

    public static void main(String[] args) {
        loadEnvFile(".env");
        SpringApplication.run(StudentCrudApplication.class, args);
    }

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
                if (System.getProperty(key) == null
                        && System.getenv(key) == null) {
                    System.setProperty(key, value);
                }
            }
        } catch (IOException e) {
            System.out.println("No .env file — using environment variables");
        }
    }
}

# Add Cache Annotation Student class because this class frequently used :-

package org.example.student.service;

import org.example.student.dto.StudentRequestDTO;
import org.example.student.dto.StudentResponseDTO;
import org.example.student.model.Student;
import org.example.student.repository.StudentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentService {

    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    @Autowired
    private StudentRepository studentRepository;

    // ── Converters ────────────────────────────────────────────────
    private StudentResponseDTO toResponseDTO(Student student) {
        return new StudentResponseDTO(
            student.getId(),
            student.getName(),
            student.getEmail(),
            student.getAge()
        );
    }

    private Student toEntity(StudentRequestDTO dto) {
        Student s = new Student();
        s.setName(dto.getName());
        s.setEmail(dto.getEmail());
        s.setAge(dto.getAge());
        return s;
    }

    // ── CREATE ────────────────────────────────────────────────────
    // @CacheEvict = clear "students" cache when new student added
    // allEntries=true = clear ALL entries in students cache
    // Why? Because getAllStudents() cache is now outdated!
    @CacheEvict(value = "students", allEntries = true)
    public StudentResponseDTO createStudent(StudentRequestDTO dto) {
        log.info("Creating student with email: {}", dto.getEmail());
        if (studentRepository.existsByEmail(dto.getEmail())) {
            log.warn("Email already exists: {}", dto.getEmail());
            throw new RuntimeException("Email already exists: " + dto.getEmail());
        }
        Student saved = studentRepository.save(toEntity(dto));
        log.info("Student created with id: {}", saved.getId());
        return toResponseDTO(saved);
    }

    // ── READ ALL ──────────────────────────────────────────────────
    // @Cacheable = cache the result
    // value = cache name ("students")
    // key = cache key ("'all'")
    // First call → hits DB → result stored in Redis
    // Next calls → returns from Redis → NO DB call!
    @Cacheable(value = "students", key = "'all'")
    public List<StudentResponseDTO> getAllStudents() {
        log.info("Cache MISS — fetching all students from DB");
        // This log only shows on FIRST call!
        // If you see this on every call → cache not working
        return studentRepository.findAll()
                .stream()
                .map(this::toResponseDTO)
                .collect(Collectors.toList());
    }

    // ── READ ONE ──────────────────────────────────────────────────
    // key = "#id" means use the id parameter as cache key
    // So getStudentById(1) and getStudentById(2) are cached separately!
    @Cacheable(value = "student", key = "#id")
    public StudentResponseDTO getStudentById(Long id) {
        log.info("Cache MISS — fetching student {} from DB", id);
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Student not found with id: {}", id);
                    return new RuntimeException("Student not found with id: " + id);
                });
        return toResponseDTO(student);
    }

    // ── UPDATE ────────────────────────────────────────────────────
    // @CachePut = update cache with new value (dont evict, just update)
    // @CacheEvict = also clear the "all students" list cache
    // @Caching = combine multiple cache annotations
    @Caching(
        put    = { @CachePut(value = "student", key = "#id") },
        evict  = { @CacheEvict(value = "students", allEntries = true) }
    )
    public StudentResponseDTO updateStudent(Long id, StudentRequestDTO dto) {
        log.info("Updating student with id: {}", id);
        Student existing = studentRepository.findById(id)
                .orElseThrow(() ->
                    new RuntimeException("Student not found with id: " + id));
        existing.setName(dto.getName());
        existing.setEmail(dto.getEmail());
        existing.setAge(dto.getAge());
        Student updated = studentRepository.save(existing);
        log.info("Student updated with id: {}", id);
        return toResponseDTO(updated);
    }

    // ── DELETE ────────────────────────────────────────────────────
    // Remove from both caches when deleted
    @Caching(evict = {
        @CacheEvict(value = "student",  key = "#id"),
        @CacheEvict(value = "students", allEntries = true)
    })
    public void deleteStudent(Long id) {
        log.info("Deleting student with id: {}", id);
        studentRepository.findById(id)
                .orElseThrow(() ->
                    new RuntimeException("Student not found with id: " + id));
        studentRepository.deleteById(id);
        log.info("Student deleted with id: {}", id);
    }
}

# Make DTOs Serializable :-

// StudentResponseDTO.java
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentResponseDTO implements Serializable {
    // ↑ ADD implements Serializable
    private Long id;
    private String name;
    private String email;
    private Integer age;
}

# Test Redis Caching :-

# Start app
./mvnw spring-boot:run

if getting any error run below commands :-
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./mvnw spring-boot:run

# First call — hits DB (slow, shows "Cache MISS" in log)
curl http://localhost:8081/api/students/getAll \
  -H "Authorization: Bearer YOUR_TOKEN"

# Check logs — should see:
# "Cache MISS — fetching all students from DB"

# Second call — hits Redis cache (fast, no log!)
curl http://localhost:8081/api/students/getAll \
  -H "Authorization: Bearer YOUR_TOKEN"

# Check logs — NO "Cache MISS" log!
# That means Redis served the response ✅

# Verify in Redis directly
redis-cli
> KEYS *
> GET students::all

------------------------------------------------------------------------------------------------------------
Cache behavior summary :-

Action          | Cache effect
─────────────── | ──────────────────────────────────────
GET /students   | First call → DB + store in cache
                | Next calls → from cache (no DB!) ✅
GET /students/1 | First call → DB + store in cache
                | Next calls → from cache ✅
POST /students  | New student → clear "students" cache
                | (so getAllStudents returns fresh data)
PUT /students/1 | Update cache for id=1 + clear list cache
DELETE /students/1 | Remove id=1 from cache + clear list