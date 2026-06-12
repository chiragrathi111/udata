# 03 — Database Guide (H2 / PostgreSQL / MongoDB)

## Which to Use?

| Database | Best for | Notes |
|---|---|---|
| H2 | Learning, quick testing | In-memory, no install needed |
| PostgreSQL | Production, real projects | Most popular SQL DB |
| MongoDB | Flexible/nested data | NoSQL, JSON documents |

---

## What Changes Between Databases

| Part | H2 | PostgreSQL | MongoDB |
|---|---|---|---|
| `pom.xml` | h2 | postgresql | spring-data-mongodb |
| `application.properties` | jdbc:h2:mem | jdbc:postgresql:// | mongodb:// |
| Model annotation | `@Entity` | `@Entity` (same!) | `@Document` |
| Column annotation | `@Column` | `@Column` (same!) | `@Field` |
| ID type | `Long` | `Long` | `String` |
| Repository extends | `JpaRepository<T, Long>` | `JpaRepository<T, Long>` | `MongoRepository<T, String>` |
| Controller/Service | No change | No change | ID type: Long → String |

> ✅ Controller and Service logic stays the same for H2 and PostgreSQL!

---

## H2 (In-Memory — for learning)

### pom.xml
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

### application.properties
```properties
spring.datasource.url=jdbc:h2:mem:studentdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.h2.console.enabled=true
# Visit http://localhost:8081/h2-console to see data
```

---

## PostgreSQL (Production)

### pom.xml
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### application.properties
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/studentdb
spring.datasource.username=postgres
spring.datasource.password=yourpassword
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

### Student.java — same @Entity annotations
```java
@Entity
@Table(name = "students")
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;           // Long for SQL databases

    @Column(nullable = false)
    private String name;
    // ...
}
```

---

## MongoDB (NoSQL)

### pom.xml — REMOVE jpa + postgresql, ADD mongodb
```xml
<!-- REMOVE these: -->
<!-- spring-boot-starter-data-jpa -->
<!-- postgresql -->

<!-- ADD this: -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

### application.properties
```properties
spring.data.mongodb.uri=mongodb://localhost:27017/studentdb
# No ddl-auto needed — MongoDB creates collections automatically!
```

### Student.java — different annotations
```java
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.index.Indexed;

@Document(collection = "students")  // like @Entity + @Table
public class Student {

    @Id
    private String id;              // ← String not Long!

    @Field("name")                  // like @Column
    private String name;

    @Indexed(unique = true)         // like @Column(unique=true)
    private String email;

    private Integer age;            // simple fields don't need @Field
}
```

### StudentRepository.java — MongoRepository
```java
import org.springframework.data.mongodb.repository.MongoRepository;

@Repository
public interface StudentRepository extends MongoRepository<Student, String> {
    //                                                              ↑ String ID
    Optional<Student> findByEmail(String email);  // works same way!
    boolean existsByEmail(String email);
}
```

### Service + Controller — only ID type changes
```java
// PostgreSQL
public Student getStudentById(Long id) { ... }

// MongoDB
public Student getStudentById(String id) { ... }
//                             ↑ String instead of Long
```

---

## Change Checklist When Switching DB

When moving from one DB to another, go through this list:

- [ ] `pom.xml` → swap dependency
- [ ] `application.properties` → update connection URL
- [ ] `Model` → swap `@Entity/@Column` ↔ `@Document/@Field`
- [ ] `ID type` → `Long` (SQL) ↔ `String` (MongoDB)
- [ ] `Repository` → `JpaRepository` ↔ `MongoRepository`
- [ ] `Service/Controller` → update ID parameter type (MongoDB only)
- [ ] Business logic → **NO CHANGE needed** ✅

---

## SQL vs NoSQL — When to Use

```
Use PostgreSQL when:
  ✅ Related data (students have courses, courses have teachers)
  ✅ Need transactions (bank transfers, order payments)
  ✅ Data structure is fixed and known
  ✅ Complex queries needed

Use MongoDB when:
  ✅ Data structure changes often
  ✅ Storing JSON-like documents (product catalogs, user profiles)
  ✅ No relationships between data
  ✅ Horizontal scaling needed (very large data)
```
