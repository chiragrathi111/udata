# 04 — Environment Variables & Secrets

## Why Not Hardcode?
```
# BAD — pushed to GitHub → anyone can see your DB password!
spring.datasource.password=mypassword123

# GOOD — value comes from outside the code
spring.datasource.password=${DB_PASSWORD}
```

---

## Solution — .env File

### Step 1: Create .env in project root
```
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_URL=jdbc:postgresql://localhost:5432/postgres
JWT_SECRET=mySecretKey12345678901234567890AB
```

### Step 2: application.properties uses ${} placeholders
```properties
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000
```

### Step 3: Load .env in main class BEFORE Spring starts
```java
@SpringBootApplication
public class StudentCrudApplication {

    public static void main(String[] args) {
        loadEnvFile(".env");   // ← must be FIRST line
        SpringApplication.run(StudentCrudApplication.class, args);
    }

    private static void loadEnvFile(String filename) {
        try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();

                // Skip empty lines and comments
                if (line.isEmpty() || line.startsWith("#")) continue;

                // Split KEY=VALUE
                int eq = line.indexOf('=');
                if (eq == -1) continue;

                String key   = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();

                // IMPORTANT: don't override if already set by OS/server
                // This makes it safe for production too!
                if (System.getProperty(key) == null && System.getenv(key) == null) {
                    System.setProperty(key, value);
                }
            }
        } catch (IOException e) {
            // .env not found = production server, OS variables will be used
            System.out.println("No .env file — using system environment variables");
        }
    }
}
```

### Step 4: Add .env to .gitignore
```
# .gitignore
.env
target/
.idea/
```

---

## How it Works Per Environment

```
YOUR LAPTOP                      PRODUCTION SERVER
──────────────                   ──────────────────
.env file exists                 .env file does NOT exist
     ↓                                ↓
loadEnvFile() reads it           IOException → skipped
     ↓                                ↓
System.setProperty(DB_URL, ...)  OS environment variables used
     ↓                                ↓
Spring reads ${DB_URL} ✅        Spring reads ${DB_URL} ✅

Same code. Same application.properties. Different secret source.
```

---

## Production: Set OS Environment Variables

```bash
# Linux/Mac production server
export DB_URL=jdbc:postgresql://prod-server:5432/studentdb
export DB_USERNAME=produser
export DB_PASSWORD=superStrongPassword123

# Permanent (add to /etc/environment)
echo "DB_URL=jdbc:postgresql://prod-server:5432/studentdb" >> /etc/environment

# Then run app
java -jar student.jar
```

---

## Docker: Pass Variables via docker-compose

```yaml
# docker-compose.yml
services:
  student-app:
    image: student-app:latest
    environment:
      - DB_URL=jdbc:postgresql://db:5432/studentdb
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - JWT_SECRET=myProductionSecret123456789012
    ports:
      - "8081:8081"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=studentdb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
```

---

## AWS Parameter Store (FREE Tier)

Best option for cloud production deployments.

### Step 1: Create parameters in AWS Console
```
AWS Console → Systems Manager → Parameter Store → Create parameter

Name  : /student-app/prod/DB_URL
Type  : String
Value : jdbc:postgresql://your-rds-host:5432/studentdb

Name  : /student-app/prod/DB_USERNAME
Type  : String
Value : produser

Name  : /student-app/prod/DB_PASSWORD
Type  : SecureString    ← encrypted for FREE with KMS!
Value : superStrongPassword
```

### Step 2: Add dependency
```xml
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-aws-starter-parameter-store</artifactId>
    <version>3.1.0</version>
</dependency>
```

### Step 3: application-prod.properties
```properties
spring.cloud.aws.parameterstore.enabled=true
spring.cloud.aws.region.static=ap-south-1
spring.config.import=aws-parameterstore:/student-app/prod/

spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
```

### Step 4: Run with prod profile on AWS
```bash
java -jar student.jar --spring.profiles.active=prod
```

### Cost
```
Standard tier:
  Storage  → FREE (up to 10,000 params)
  API calls → FREE (up to 40,000/month)
  SecureString → FREE (KMS free tier)

Your app with 3 params = ₹0 per month 🎉
```

---

## Secrets Checklist
- [ ] `.env` file created in project root
- [ ] `.env` added to `.gitignore`
- [ ] `application.properties` uses `${VARIABLE_NAME}`
- [ ] `loadEnvFile()` added to main class
- [ ] Never commit actual passwords to Git
- [ ] Production uses OS env vars or AWS Parameter Store
