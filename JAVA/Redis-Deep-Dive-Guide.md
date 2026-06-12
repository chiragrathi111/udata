# Redis Deep Dive Guide
## Complete Redis — Definition + Spring Boot + Plain Java + 10 Real Use Cases

---

## Table of Contents
1. [What is Redis](#1-what-is-redis)
2. [How Redis Works Internally](#2-how-redis-works-internally)
3. [Redis Data Types](#3-redis-data-types)
4. [Redis in Spring Boot](#4-redis-in-spring-boot)
5. [Redis Without Spring Boot — Plain Java](#5-redis-without-spring-boot--plain-java)
6. [10 Real Industry Use Cases](#6-10-real-industry-use-cases)
7. [Redis vs Database — When to Use What](#7-redis-vs-database--when-to-use-what)
8. [Redis Commands Reference](#8-redis-commands-reference)
9. [Common Errors and Fixes](#9-common-errors-and-fixes)
10. [Interview Questions](#10-interview-questions)

---

## 1. What is Redis

### Official Definition
```
Redis = Remote Dictionary Server

An open-source, in-memory data structure store that can be used as:
  - Database
  - Cache
  - Message broker
  - Queue

Key features:
  - Stores data in RAM (not disk) → extremely fast
  - Supports multiple data types (String, List, Set, Hash, ZSet)
  - Data can expire automatically (TTL — Time To Live)
  - Single-threaded → no race conditions
  - Persistence options (can save to disk if needed)
```

### Hindi mein — Simple explanation
```
Normal Database (PostgreSQL):
  Data → Hard Disk pe store hota hai
  Read karo → Disk se padho → 5-50ms lagta hai
  1000 users ek saath → 1000 DB queries → server slow!

Redis:
  Data → RAM mein store hota hai
  Read karo → RAM se padho → 0.1ms lagta hai!
  1000 users ek saath → 1000 Redis reads → still fast! ✅

Jaise:
  DB = Library ka storage room (books pile mein hain, dhundna padega)
  Redis = Teacher ki table ke upar rakhi kitaab
          (seedha haath badhao aur le lo — instant!)

Real life example:
  Zomato pe "Nearby Restaurants" → same 100 log dekhte hain
  Without Redis: 100 baar DB query → slow
  With Redis:    1 baar DB query → Redis mein store
                 99 baar Redis → instant! ✅
```

### When was Redis created?
```
Created: 2009 by Salvatore Sanfilippo (Italian developer)
Written in: C language
Current version: Redis 7.x
License: BSD (open source, free)
Used by: Twitter, GitHub, Instagram, Snapchat, Stack Overflow,
         Airbnb, Tinder, Uber, Pinterest...

Speed benchmark:
  Redis: 100,000+ operations per second!
  PostgreSQL: ~10,000 operations per second
  Redis is 10x faster!
```

---

## 2. How Redis Works Internally

### Memory Architecture
```
Your App                    Redis Server (RAM)
──────────                  ──────────────────
GET students ──────────────→ checks RAM
                              key "students::all" found?
                                YES → return value instantly ✅
                                NO  → return null (app hits DB)

SET students value ────────→ stores in RAM
                              key = "students::all"
                              value = JSON data
                              TTL = 10 minutes (then auto-delete)
```

### TTL (Time To Live) — Auto Expiry
```
When you store data in Redis, you can set expiry time:

SET user:123 "Ravi" EX 300   ← expires in 300 seconds (5 min)

After 5 minutes → Redis automatically deletes it
Why useful?
  Fresh data: users always get data not older than 5 minutes
  Memory management: old data cleaned automatically
  Session management: user sessions expire after inactivity
```

### How Cache Works — Step by Step
```
Request comes for GET /api/students

Step 1: App checks Redis
  → Key "students::all" exists in Redis?

Step 2a: Cache HIT (key exists)
  → Return data from Redis instantly
  → DB not touched ✅ (fast!)

Step 2b: Cache MISS (key doesn't exist)
  → Go to PostgreSQL DB
  → Get data
  → Store in Redis with TTL
  → Return data to user

Next request: Step 2a (Cache HIT) ✅
```

---

## 3. Redis Data Types

### String (most common)
```bash
SET name "Ravi Kumar"           # store string
GET name                        # get string → "Ravi Kumar"
SET counter 0                   # store number as string
INCR counter                    # increment → 1
INCRBY counter 5                # increment by 5 → 6
EXPIRE name 300                 # expire in 300 seconds
TTL name                        # check remaining time
DEL name                        # delete
```

### Hash (like Java Map / object)
```bash
HSET user:1 name "Ravi" email "ravi@gmail.com" age 21
HGET user:1 name              # → "Ravi"
HGETALL user:1                # → all fields
HSET user:1 age 22            # update one field
HDEL user:1 age               # delete one field
```

### List (like Java ArrayList)
```bash
LPUSH queue "task1"           # add to left (front)
RPUSH queue "task2"           # add to right (back)
LPOP queue                    # remove from left → "task1"
RPOP queue                    # remove from right
LRANGE queue 0 -1             # get all items
LLEN queue                    # length
```

### Set (like Java HashSet — unique values)
```bash
SADD tags "java" "spring" "redis"
SMEMBERS tags                 # all members
SISMEMBER tags "java"         # exists? → 1 (true)
SCARD tags                    # count → 3
SREM tags "redis"             # remove member
```

### Sorted Set / ZSet (like Set but with score for ordering)
```bash
ZADD leaderboard 100 "Ravi"   # score=100
ZADD leaderboard 250 "Priya"  # score=250
ZADD leaderboard 180 "Amit"   # score=180
ZRANGE leaderboard 0 -1 WITHSCORES  # sorted by score
ZRANK leaderboard "Ravi"      # rank of Ravi → 2 (0-based)
ZREVRANK leaderboard "Priya"  # rank from top → 0 (first!)
```

---

## 4. Redis in Spring Boot

### Install Redis
```bash
# Ubuntu/Linux
sudo apt-get install -y redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo systemctl status redis-server

# Test
redis-cli ping   # → PONG ✅

# Redis CLI — interact directly
redis-cli
> SET name "Ravi"
> GET name
> KEYS *        # all keys
> FLUSHALL      # clear everything
> EXIT
```

### pom.xml
```xml
<!-- Spring Data Redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- Spring Cache -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

### application.properties
```properties
# Redis connection
spring.data.redis.host=localhost
spring.data.redis.port=6379

# No password for local Redis
# spring.data.redis.password=yourpassword  ← for production

# Cache settings
spring.cache.type=redis
spring.cache.redis.time-to-live=600000
# 600000ms = 10 minutes

# See cache activity in logs
logging.level.org.springframework.cache=DEBUG
```

### Enable Caching — Main Class
```java
@SpringBootApplication
@EnableCaching   // ← REQUIRED — enables cache processing
public class StudentCrudApplication {
    public static void main(String[] args) {
        SpringApplication.run(StudentCrudApplication.class, args);
    }
}
```

### Make DTO Serializable — REQUIRED for Redis
```java
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentResponseDTO implements Serializable {
    // Serializable = can be converted to bytes for Redis storage
    private Long id;
    private String name;
    private String email;
    private Integer age;
}
```

### Cache Annotations — Complete Guide

#### @Cacheable — Read from cache
```java
// First call: executes method → stores result in Redis
// Next calls: returns from Redis → method NOT executed!

@Cacheable(value = "students", key = "'all'")
public List<StudentResponseDTO> getAllStudents() {
    // This code runs ONLY on cache miss!
    log.info("Cache MISS — hitting DB");
    return studentRepository.findAll()
            .stream().map(this::toResponseDTO)
            .collect(Collectors.toList());
}

// Different key for different student:
@Cacheable(value = "student", key = "#id")
public StudentResponseDTO getStudentById(Long id) {
    // Cached separately for each id!
    // student::1, student::2, student::3...
    return studentRepository.findById(id)
            .map(this::toResponseDTO)
            .orElseThrow(() -> new RuntimeException("Not found: " + id));
}

// Conditional caching:
@Cacheable(value = "student", key = "#id", condition = "#id > 0")
public StudentResponseDTO getStudentById(Long id) {
    // Only cache if id > 0
}
```

#### @CacheEvict — Clear cache
```java
// Clear specific key:
@CacheEvict(value = "student", key = "#id")
public void deleteStudent(Long id) {
    studentRepository.deleteById(id);
}

// Clear ALL entries in a cache:
@CacheEvict(value = "students", allEntries = true)
public StudentResponseDTO createStudent(StudentRequestDTO dto) {
    // When new student added → list cache is outdated → clear it!
    return toResponseDTO(studentRepository.save(toEntity(dto)));
}

// Clear before method executes:
@CacheEvict(value = "students", allEntries = true, beforeInvocation = true)
public void clearCache() {
    // Cache cleared before this method runs
}
```

#### @CachePut — Update cache
```java
// Always executes method AND updates cache
// Different from @Cacheable which skips method if cached!

@CachePut(value = "student", key = "#id")
public StudentResponseDTO updateStudent(Long id, StudentRequestDTO dto) {
    Student existing = studentRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Not found"));
    existing.setName(dto.getName());
    Student updated = studentRepository.save(existing);
    return toResponseDTO(updated);
    // Return value automatically stored in cache! ✅
}
```

#### @Caching — Combine multiple annotations
```java
// Update student: update cache for id + clear list cache
@Caching(
    put   = { @CachePut(value = "student",  key = "#id") },
    evict = { @CacheEvict(value = "students", allEntries = true) }
)
public StudentResponseDTO updateStudent(Long id, StudentRequestDTO dto) { ... }

// Delete student: remove from both caches
@Caching(evict = {
    @CacheEvict(value = "student",  key = "#id"),
    @CacheEvict(value = "students", allEntries = true)
})
public void deleteStudent(Long id) { ... }
```

### Complete StudentService.java with Redis
```java
@Service
public class StudentService {

    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    @Autowired
    private StudentRepository studentRepository;

    private StudentResponseDTO toResponseDTO(Student s) {
        return new StudentResponseDTO(s.getId(), s.getName(), s.getEmail(), s.getAge());
    }

    private Student toEntity(StudentRequestDTO dto) {
        Student s = new Student();
        s.setName(dto.getName());
        s.setEmail(dto.getEmail());
        s.setAge(dto.getAge());
        return s;
    }

    @CacheEvict(value = "students", allEntries = true)
    public StudentResponseDTO createStudent(StudentRequestDTO dto) {
        log.info("Creating student: {}", dto.getEmail());
        if (studentRepository.existsByEmail(dto.getEmail()))
            throw new RuntimeException("Email already exists: " + dto.getEmail());
        return toResponseDTO(studentRepository.save(toEntity(dto)));
    }

    @Cacheable(value = "students", key = "'all'")
    public List<StudentResponseDTO> getAllStudents() {
        log.info("Cache MISS — fetching all from DB");
        return studentRepository.findAll().stream()
                .map(this::toResponseDTO).collect(Collectors.toList());
    }

    @Cacheable(value = "student", key = "#id")
    public StudentResponseDTO getStudentById(Long id) {
        log.info("Cache MISS for id: {}", id);
        return studentRepository.findById(id).map(this::toResponseDTO)
                .orElseThrow(() -> new RuntimeException("Student not found: " + id));
    }

    @Caching(
        put   = { @CachePut(value = "student", key = "#id") },
        evict = { @CacheEvict(value = "students", allEntries = true) }
    )
    public StudentResponseDTO updateStudent(Long id, StudentRequestDTO dto) {
        log.info("Updating student: {}", id);
        Student existing = studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found: " + id));
        existing.setName(dto.getName());
        existing.setEmail(dto.getEmail());
        existing.setAge(dto.getAge());
        return toResponseDTO(studentRepository.save(existing));
    }

    @Caching(evict = {
        @CacheEvict(value = "student",  key = "#id"),
        @CacheEvict(value = "students", allEntries = true)
    })
    public void deleteStudent(Long id) {
        log.info("Deleting student: {}", id);
        studentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Student not found: " + id));
        studentRepository.deleteById(id);
    }
}
```

### Verify Cache is Working
```bash
# Run app
./mvnw spring-boot:run

# First call → hits DB (see "Cache MISS" in logs)
curl http://localhost:8081/api/students/getAll \
  -H "Authorization: Bearer TOKEN"
# Log shows: "Cache MISS — fetching all from DB"

# Second call → from Redis (NO log!)
curl http://localhost:8081/api/students/getAll \
  -H "Authorization: Bearer TOKEN"
# No log = served from Redis ✅

# Check Redis directly
redis-cli
> KEYS *
# 1) "students::all"
# 2) "student::1"

> TTL students::all
# 598  (seconds remaining before expiry)
```

---

## 5. Redis Without Spring Boot — Plain Java

### Yes! Redis works with any Java project — no Spring needed!

### Add Jedis dependency (pom.xml)
```xml
<!-- Jedis = Java Redis Client library -->
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>5.1.0</version>
</dependency>
```

### Basic Jedis Usage
```java
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisExample {

    public static void main(String[] args) {

        // ── Connect to Redis ──────────────────────────────────
        try (Jedis jedis = new Jedis("localhost", 6379)) {

            // ── String operations ─────────────────────────────
            jedis.set("name", "Ravi Kumar");
            String name = jedis.get("name");
            System.out.println("Name: " + name);   // Ravi Kumar

            // Set with expiry (300 seconds)
            jedis.setex("session:user1", 300, "active");
            System.out.println("TTL: " + jedis.ttl("session:user1")); // 300

            // Increment counter
            jedis.set("visitors", "0");
            jedis.incr("visitors");
            jedis.incr("visitors");
            jedis.incrBy("visitors", 5);
            System.out.println("Visitors: " + jedis.get("visitors")); // 7

            // ── Hash operations ───────────────────────────────
            jedis.hset("user:1", "name", "Ravi");
            jedis.hset("user:1", "email", "ravi@gmail.com");
            jedis.hset("user:1", "age", "21");
            System.out.println("User name: " + jedis.hget("user:1", "name"));
            System.out.println("All fields: " + jedis.hgetAll("user:1"));

            // ── List operations ───────────────────────────────
            jedis.rpush("queue", "task1", "task2", "task3");
            System.out.println("Queue: " + jedis.lrange("queue", 0, -1));
            System.out.println("Pop: " + jedis.lpop("queue")); // task1

            // ── Set operations ────────────────────────────────
            jedis.sadd("tags:java", "spring", "redis", "docker");
            System.out.println("Tags: " + jedis.smembers("tags:java"));
            System.out.println("Has redis? " + jedis.sismember("tags:java", "redis"));

            // ── Delete ────────────────────────────────────────
            jedis.del("name");
            System.out.println("After delete: " + jedis.get("name")); // null

        } // jedis.close() called automatically
    }
}
```

### Jedis Connection Pool (recommended for production)
```java
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisConnectionPool {

    // Create pool once at startup — reuse connections!
    private static final JedisPool pool = createPool();

    private static JedisPool createPool() {
        JedisPoolConfig config = new JedisPoolConfig();
        config.setMaxTotal(10);        // max 10 connections
        config.setMaxIdle(5);          // max 5 idle connections
        config.setMinIdle(1);          // min 1 idle connection
        config.setTestOnBorrow(true);  // test connection before use
        return new JedisPool(config, "localhost", 6379);
    }

    // Use this in your code
    public static String getValue(String key) {
        try (Jedis jedis = pool.getResource()) {
            return jedis.get(key);
        }
    }

    public static void setValue(String key, String value, int ttlSeconds) {
        try (Jedis jedis = pool.getResource()) {
            jedis.setex(key, ttlSeconds, value);
        }
    }

    public static void deleteValue(String key) {
        try (Jedis jedis = pool.getResource()) {
            jedis.del(key);
        }
    }

    public static void main(String[] args) {
        setValue("user:session", "active", 3600);
        System.out.println(getValue("user:session")); // active
        deleteValue("user:session");
    }
}
```

### Manual Cache in Plain Java — No Spring annotations
```java
import com.fasterxml.jackson.databind.ObjectMapper;
import redis.clients.jedis.Jedis;
import java.util.List;

// Manual cache service — works with any Java project!
public class ManualCacheService {

    private final Jedis jedis = new Jedis("localhost", 6379);
    private final ObjectMapper mapper = new ObjectMapper();

    // Generic get from cache
    public <T> T getFromCache(String key, Class<T> type) {
        String json = jedis.get(key);
        if (json == null) return null;
        try {
            return mapper.readValue(json, type);
        } catch (Exception e) {
            return null;
        }
    }

    // Generic store in cache
    public void storeInCache(String key, Object value, int ttlSeconds) {
        try {
            String json = mapper.writeValueAsString(value);
            jedis.setex(key, ttlSeconds, json);
        } catch (Exception e) {
            // log error
        }
    }

    // Clear cache key
    public void clearCache(String key) {
        jedis.del(key);
    }

    // Example: cache student list
    public List<Student> getAllStudents(StudentRepository repository) {
        String cacheKey = "students:all";

        // Try cache first
        List<Student> cached = getFromCache(cacheKey, List.class);
        if (cached != null) {
            System.out.println("Cache HIT!");
            return cached;
        }

        // Cache miss → go to DB
        System.out.println("Cache MISS → hitting DB");
        List<Student> students = repository.findAll();

        // Store in cache for 10 minutes
        storeInCache(cacheKey, students, 600);

        return students;
    }
}
```

### Without Maven — Jedis with JAR file
```
1. Download jedis JAR: https://mvnrepository.com/artifact/redis.clients/jedis
2. Add to classpath: javac -cp jedis-5.1.0.jar MyApp.java
3. Run: java -cp .:jedis-5.1.0.jar MyApp
```

---

## 6. Ten Real Industry Use Cases

### Use Case 1 — API Response Caching (your Student project)
```java
// Problem: Same list of students fetched 1000 times per minute
// Solution: Cache the list, return from Redis

@Cacheable(value = "students", key = "'all'")
public List<StudentResponseDTO> getAllStudents() {
    return studentRepository.findAll()...
}

// Real example: Swiggy restaurant list, Flipkart product list
// Impact: DB load reduced 95%!
```

### Use Case 2 — User Session Management
```java
// Problem: User login data stored in DB → slow on every request
// Solution: Store session in Redis with TTL

public class SessionService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // Store session on login
    public void createSession(String userId, UserSession session) {
        String key = "session:" + userId;
        redisTemplate.opsForValue().set(key, session, 30, TimeUnit.MINUTES);
        // Auto-expires after 30 minutes inactivity!
    }

    // Get session on every request
    public UserSession getSession(String userId) {
        return (UserSession) redisTemplate.opsForValue().get("session:" + userId);
    }

    // Delete session on logout
    public void deleteSession(String userId) {
        redisTemplate.delete("session:" + userId);
    }
}

// Real example: Every website login (Amazon, Flipkart, Gmail)
// "Remember me for 30 days" = Redis TTL of 30 days!
```

### Use Case 3 — Rate Limiting (better than bucket4j!)
```java
// Problem: One user making 1000 requests per minute (abuse)
// Solution: Count requests in Redis, block if exceeded

public class RedisRateLimiter {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public boolean isAllowed(String userId) {
        String key = "rate:" + userId;

        Long count = redisTemplate.opsForValue().increment(key);

        if (count == 1) {
            // First request — set expiry of 1 minute
            redisTemplate.expire(key, 1, TimeUnit.MINUTES);
        }

        return count <= 10; // Allow max 10 requests per minute
    }
}

// Usage in Filter:
// if (!rateLimiter.isAllowed(userId)) → 429 Too Many Requests

// Real example: Twitter API (300 requests/15min),
//               GitHub API (5000 requests/hour)
```

### Use Case 4 — OTP Storage
```java
// Problem: Store OTP temporarily, expire after 5 minutes
// Solution: Redis SET with TTL

public class OtpService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    // Generate and store OTP
    public String generateOtp(String phone) {
        String otp = String.valueOf((int)(Math.random() * 900000) + 100000);
        String key = "otp:" + phone;

        // Store OTP for 5 minutes only!
        redisTemplate.opsForValue().set(key, otp, 5, TimeUnit.MINUTES);

        return otp; // send via SMS
    }

    // Verify OTP
    public boolean verifyOtp(String phone, String enteredOtp) {
        String key = "otp:" + phone;
        String storedOtp = (String) redisTemplate.opsForValue().get(key);

        if (storedOtp != null && storedOtp.equals(enteredOtp)) {
            redisTemplate.delete(key); // OTP used → delete!
            return true;
        }
        return false;
    }
}

// Real example: Paytm, PhonePe, Ola — OTP expires in 5 minutes
// Without Redis: Would need cron job to clean expired OTPs from DB!
```

### Use Case 5 — Leaderboard / Rankings
```java
// Problem: Real-time game leaderboard, top 10 players
// Solution: Redis Sorted Set (ZSet) — automatically sorted!

public class LeaderboardService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    // Add/update score
    public void updateScore(String gameId, String userId, double score) {
        String key = "leaderboard:" + gameId;
        redisTemplate.opsForZSet().add(key, userId, score);
    }

    // Get top 10 players
    public Set<ZSetOperations.TypedTuple<String>> getTop10(String gameId) {
        String key = "leaderboard:" + gameId;
        return redisTemplate.opsForZSet()
                .reverseRangeWithScores(key, 0, 9); // top 10, highest first
    }

    // Get player rank
    public Long getPlayerRank(String gameId, String userId) {
        String key = "leaderboard:" + gameId;
        return redisTemplate.opsForZSet().reverseRank(key, userId);
    }
}

// Real example: PUBG, Free Fire leaderboards
//               Swiggy "Top Restaurants in your area"
//               LinkedIn "Top Skills" rankings
```

### Use Case 6 — Shopping Cart
```java
// Problem: Cart data must be fast, temporary (until checkout)
// Solution: Redis Hash per user

public class CartService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // Add item to cart
    public void addToCart(String userId, String productId, int quantity) {
        String key = "cart:" + userId;
        redisTemplate.opsForHash().put(key, productId, quantity);
        redisTemplate.expire(key, 7, TimeUnit.DAYS); // cart expires in 7 days
    }

    // Get cart
    public Map<Object, Object> getCart(String userId) {
        return redisTemplate.opsForHash().entries("cart:" + userId);
    }

    // Remove item
    public void removeFromCart(String userId, String productId) {
        redisTemplate.opsForHash().delete("cart:" + userId, productId);
    }

    // Clear cart after checkout
    public void clearCart(String userId) {
        redisTemplate.delete("cart:" + userId);
    }
}

// Real example: Amazon, Flipkart, Meesho cart
// If you add item and don't buy → cart remembers for 7 days!
```

### Use Case 7 — Pub/Sub Messaging
```java
// Problem: Real-time notifications (chat, live scores)
// Solution: Redis Pub/Sub

// Publisher (sends message)
public class NotificationPublisher {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public void sendNotification(String userId, String message) {
        redisTemplate.convertAndSend("notifications:" + userId, message);
        // All subscribers on this channel receive it instantly!
    }
}

// Subscriber (receives message)
@Component
public class NotificationSubscriber implements MessageListener {

    @Override
    public void onMessage(Message message, byte[] pattern) {
        System.out.println("Notification received: " + message.toString());
        // Send to WebSocket, push notification, etc.
    }
}

// Real example:
//   WhatsApp "message delivered" notifications
//   IPL live score updates
//   Zomato "Your order is on the way!" notifications
```

### Use Case 8 — Job Queue / Task Queue
```java
// Problem: Send 10,000 emails — don't block the API
// Solution: Push to Redis Queue → worker processes async

public class EmailQueueService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    // API adds email task to queue (instant, non-blocking)
    public void queueEmail(String email, String subject) {
        String task = email + "|" + subject;
        redisTemplate.opsForList().rightPush("email-queue", task);
        System.out.println("Email queued: " + email);
    }

    // Worker (separate thread/service) processes queue
    public void processEmailQueue() {
        while (true) {
            // BLPOP = blocking pop, waits for item
            String task = (String) redisTemplate.opsForList()
                    .leftPop("email-queue");
            if (task != null) {
                String[] parts = task.split("\\|");
                sendEmail(parts[0], parts[1]); // actual email send
            }
        }
    }

    private void sendEmail(String email, String subject) {
        // send email logic
    }
}

// Real example:
//   Flipkart order confirmation emails
//   Bank OTP SMS
//   Swiggy "Your food is being prepared" notifications
```

### Use Case 9 — Distributed Lock
```java
// Problem: Two servers running same code, both trying to update same data
// Solution: Redis lock — only one server can hold the lock

public class DistributedLockService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    // Acquire lock
    public boolean acquireLock(String lockKey, String lockValue, int ttlSeconds) {
        Boolean success = redisTemplate.opsForValue()
                .setIfAbsent(lockKey, lockValue, ttlSeconds, TimeUnit.SECONDS);
        // setIfAbsent = SET only if key doesn't exist (atomic!)
        return Boolean.TRUE.equals(success);
    }

    // Release lock
    public void releaseLock(String lockKey, String lockValue) {
        String currentValue = (String) redisTemplate.opsForValue().get(lockKey);
        if (lockValue.equals(currentValue)) {
            redisTemplate.delete(lockKey);
        }
    }

    // Usage example
    public void processOrder(String orderId) {
        String lockKey = "order-lock:" + orderId;
        String lockValue = UUID.randomUUID().toString();

        if (acquireLock(lockKey, lockValue, 30)) {
            try {
                // Only ONE server processes this order!
                processPayment(orderId);
            } finally {
                releaseLock(lockKey, lockValue);
            }
        } else {
            throw new RuntimeException("Order already being processed!");
        }
    }
}

// Real example:
//   Payment processing (don't charge twice!)
//   Ticket booking (don't book same seat twice!)
//   Flash sale (don't oversell limited stock!)
```

### Use Case 10 — Autocomplete / Search Suggestions
```java
// Problem: "Type 'Ra' → suggest Ravi, Rahul, Raj..." instantly
// Solution: Redis Sorted Set with alphabetical scoring

public class AutoCompleteService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    // Add word to autocomplete index
    public void addWord(String word) {
        // Add all prefixes: "r", "ra", "rav", "ravi"
        for (int i = 1; i <= word.length(); i++) {
            String prefix = word.substring(0, i);
            redisTemplate.opsForZSet().add("autocomplete", prefix, 0);
        }
        redisTemplate.opsForZSet().add("autocomplete", word + "*", 0);
        // * marks complete words
    }

    // Get suggestions for prefix
    public List<String> getSuggestions(String prefix, int count) {
        // Get all entries starting with prefix
        Set<String> results = redisTemplate.opsForZSet()
                .rangeByLex("autocomplete",
                    "[" + prefix,
                    "[" + prefix + "\xff");

        return results.stream()
                .filter(s -> s.endsWith("*"))  // complete words only
                .map(s -> s.replace("*", ""))
                .limit(count)
                .collect(Collectors.toList());
    }
}

// Real example:
//   Google search suggestions
//   Amazon product search autocomplete
//   Swiggy restaurant name suggestions
```

---

## 7. Redis vs Database — When to Use What

```
USE REDIS WHEN:                    USE DATABASE WHEN:
──────────────                     ─────────────────
Frequently read data               Primary data storage
Data changes rarely                Complex queries needed
Temporary data (sessions, OTP)     Permanent data
Real-time counters                 Relationships (JOIN)
Leaderboards                       Financial transactions
Rate limiting                      Audit trails
Caching DB results                 Reporting

NEVER use Redis for:               ALWAYS use Redis for:
  Primary permanent storage          Caching
  Complex queries                    Sessions
  Transactions (bank)                OTP
  GDPR/compliance data               Rate limiting
                                     Leaderboards
                                     Real-time features
```

### Memory vs Speed Trade-off
```
Redis stores in RAM:
  Advantage: Extremely fast (0.1ms)
  Disadvantage: RAM is expensive, limited

PostgreSQL stores on Disk:
  Advantage: Cheap storage, unlimited
  Disadvantage: Slower (5-50ms)

Best practice: Use BOTH!
  Hot data (frequent access) → Redis
  Cold data (permanent)      → PostgreSQL
```

---

## 8. Redis Commands Reference

```bash
# ── Connection ───────────────────────────────────────────
redis-cli                    # start Redis CLI
redis-cli -h host -p port    # connect to remote Redis
redis-cli ping               # test connection → PONG
AUTH password                # authenticate

# ── String ───────────────────────────────────────────────
SET key value                # store
GET key                      # retrieve
SETEX key seconds value      # store with TTL
TTL key                      # check remaining TTL (-1=no expiry, -2=expired)
EXPIRE key seconds           # set expiry on existing key
PERSIST key                  # remove expiry (make permanent)
INCR key                     # increment by 1
INCRBY key amount            # increment by amount
DEL key                      # delete
EXISTS key                   # check if exists (1=yes, 0=no)

# ── Hash ─────────────────────────────────────────────────
HSET key field value         # set one field
HMSET key f1 v1 f2 v2        # set multiple fields
HGET key field               # get one field
HGETALL key                  # get all fields
HKEYS key                    # all field names
HVALS key                    # all values
HDEL key field               # delete field
HEXISTS key field            # field exists?

# ── List ─────────────────────────────────────────────────
LPUSH key value              # add to left (front)
RPUSH key value              # add to right (back)
LPOP key                     # remove from left
RPOP key                     # remove from right
LRANGE key start end         # get range (0 -1 = all)
LLEN key                     # length
BLPOP key timeout            # blocking pop (waits for item)

# ── Set ──────────────────────────────────────────────────
SADD key member              # add member
SMEMBERS key                 # all members
SCARD key                    # count
SISMEMBER key member         # is member?
SREM key member              # remove member
SUNION key1 key2             # union of two sets
SINTER key1 key2             # intersection

# ── Sorted Set (ZSet) ────────────────────────────────────
ZADD key score member        # add with score
ZRANGE key start end         # range by rank (low to high)
ZREVRANGE key start end      # range by rank (high to low)
ZRANGEBYSCORE key min max    # range by score
ZRANK key member             # rank (0-based, low to high)
ZREVRANK key member          # rank (0-based, high to low)
ZSCORE key member            # score of member
ZREM key member              # remove member
ZCARD key                    # count

# ── Server ───────────────────────────────────────────────
KEYS *                       # all keys (careful in production!)
KEYS user:*                  # keys matching pattern
DBSIZE                       # total key count
FLUSHDB                      # clear current DB
FLUSHALL                     # clear ALL DBs (dangerous!)
INFO                         # server info and stats
MONITOR                      # watch all commands in real-time
CONFIG GET maxmemory         # check memory limit
```

---

## 9. Common Errors and Fixes

### Error: Redis connection refused
```
Error: Unable to connect to Redis at localhost:6379

Fix 1: Start Redis
  sudo systemctl start redis

Fix 2: Check Redis is running
  redis-cli ping   → should return PONG

Fix 3: Check application.properties
  spring.data.redis.host=localhost
  spring.data.redis.port=6379

Fix 4: Check firewall (EC2)
  Security Group → Add inbound rule port 6379
```

### Error: Cannot serialize (Serializable)
```
Error: DefaultSerializer requires a Serializable payload

Fix: Add implements Serializable to your DTO/Model
  public class StudentResponseDTO implements Serializable { }
```

### Error: Cache not working (always Cache MISS)
```
Symptom: logs show "Cache MISS" on every request

Fix 1: @EnableCaching missing from main class
  @SpringBootApplication
  @EnableCaching   ← add this!
  public class StudentCrudApplication { }

Fix 2: Self-invocation problem
  WRONG: calling @Cacheable method from same class
  service.getAllStudents()  ← from SAME class (Spring AOP bypassed!)
  
  RIGHT: call from DIFFERENT class (controller calling service)
  
Fix 3: Method must be public
  private List<> getAllStudents() ← private doesn't work!
  public List<> getAllStudents()  ← must be public ✅
```

### Error: RedisTemplate NullPointerException
```
Fix: Use @Autowired for RedisTemplate
  @Autowired
  private RedisTemplate<String, Object> redisTemplate;
  
  Don't use: new RedisTemplate() ← not managed by Spring!
```

### Error: Redis out of memory
```
Error: OOM command not allowed when used memory > maxmemory

Fix 1: Set eviction policy in Redis config
  redis-cli CONFIG SET maxmemory-policy allkeys-lru
  # lru = Least Recently Used → remove oldest unused items

Fix 2: Set memory limit
  redis-cli CONFIG SET maxmemory 256mb
```

---

## 10. Interview Questions

### Basic Questions
```
Q: What is Redis?
A: Redis is an open-source in-memory data store used as cache,
   database and message broker. It stores data in RAM making it
   extremely fast — 100,000+ operations per second.

Q: Why use Redis when we have a database?
A: Database stores data on disk — 5-50ms per query.
   Redis stores in RAM — 0.1ms per operation.
   For frequently accessed data, Redis reduces DB load by 95%
   and response time by 10-25x.

Q: What data types does Redis support?
A: String, Hash, List, Set, Sorted Set (ZSet), and more.
   Each type has specific use cases:
   String → simple values, counters
   Hash → objects (user profile)
   List → queues, recent items
   Set → unique tags, online users
   ZSet → leaderboards, rankings

Q: What is TTL in Redis?
A: TTL = Time To Live. It's the expiry time for a Redis key.
   After TTL expires, Redis automatically deletes the key.
   Example: OTP expires in 5 min, session expires in 30 min.
```

### Intermediate Questions
```
Q: What is the difference between @Cacheable and @CachePut?
A: @Cacheable checks cache first — if found, returns cached value
   without executing the method. If not found, executes method
   and stores result.
   @CachePut always executes the method AND updates the cache.
   Use @Cacheable for reads, @CachePut for updates.

Q: What is cache eviction?
A: Removing data from cache. Done with @CacheEvict.
   allEntries=true removes all entries in that cache.
   Used when data changes — like after creating/deleting a student,
   clear the students list cache so users get fresh data.

Q: What is Redis Pub/Sub?
A: Publisher/Subscriber messaging pattern.
   Publisher sends message to a channel.
   All subscribers on that channel receive it instantly.
   Used for real-time notifications, live updates.

Q: How is Redis different from Memcached?
A: Redis supports multiple data types (String, Hash, List, Set, ZSet).
   Memcached only supports String.
   Redis has persistence — can save to disk.
   Redis has replication and clustering.
   Redis has Pub/Sub messaging.
   Memcached is simpler but limited.
```

### Advanced Questions
```
Q: How do you handle cache consistency?
A: Cache-aside pattern: App checks cache → miss → DB → update cache
   Write-through: Write to DB and cache simultaneously
   TTL-based: Cache expires after set time — stale data acceptable
   Event-driven: DB change → clear cache (most consistent)

Q: What is a distributed lock in Redis?
A: Redis SET NX (set if not exists) creates atomic locks.
   Used when multiple servers must not process same request twice.
   Example: Payment processing — acquire lock → process → release.
   Prevents double-charging or overselling.

Q: How do you handle Redis failure?
A: Fall back to DB if Redis is down.
   Use try-catch around Redis calls.
   Spring Cache automatically falls back to method execution.
   Use Redis Sentinel or Cluster for high availability.

Q: Explain the 10 real use cases of Redis.
A: 1. API Response Caching — reduce DB load
   2. Session Management — fast user auth
   3. Rate Limiting — prevent API abuse
   4. OTP Storage — temporary with TTL
   5. Leaderboards — sorted set rankings
   6. Shopping Cart — temporary user data
   7. Pub/Sub Messaging — real-time notifications
   8. Job Queue — async task processing
   9. Distributed Lock — prevent duplicate processing
   10. Autocomplete — instant search suggestions
```

---

*Redis Deep Dive Complete!*
*From basic caching to 10 real industry use cases — Spring Boot + Plain Java! 🚀*
