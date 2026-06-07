Step 1 — What you do on AWS (one time setup)
1a. Create the secret in AWS Console
Go to AWS Console → Secrets Manager → Store a new secret
Secret type  → Other type of secret (key/value)

Add these keys:
┌──────────────┬─────────────────────────────────────────┐
│ DB_URL       │ jdbc:postgresql://your-rds-host:5432/db │
│ DB_USERNAME  │ produser                                │
│ DB_PASSWORD  │ yourStrongPassword123                   │
└──────────────┴─────────────────────────────────────────┘

Secret name → student-app/production
1b. Create IAM Role (permission card)
Go to AWS Console → IAM → Roles → Create Role
Trusted entity → EC2 (or ECS if using containers)

Attach this policy:
{
  "Effect": "Allow",
  "Action": ["secretsmanager:GetSecretValue"],
  "Resource": "arn:aws:secretsmanager:ap-south-1:YOUR_ACCOUNT:secret:student-app/production"
}

Role name → student-app-role
Then attach this role to your EC2 server → your app gets permission automatically, no hardcoded AWS keys needed!

Step 2 — Add AWS dependency to pom.xml
xml<!-- AWS Spring Cloud (reads Secrets Manager automatically) -->
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-aws-starter-secrets-manager</artifactId>
    <version>3.1.0</version>
</dependency>

Step 3 — Two application.properties files
src/main/resources/
├── application.properties          ← common (both use this)
├── application-local.properties    ← only on your laptop
└── application-prod.properties     ← only on AWS server

application.properties (common for both):
propertiesspring.application.name=Student
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

application-local.properties (your laptop):
server.port=8081
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

application-prod.properties (AWS server):
server.port=8080
spring.cloud.aws.secretsmanager.enabled=true
spring.cloud.aws.region.static=ap-south-1
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

Step 4 — Your main class stays same
java@SpringBootApplication
public class StudentCrudApplication {

    public static void main(String[] args) {
        // Only works on local (prod has no .env file, just skips)
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
                String key = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                // Dont override AWS values if already set
                if (System.getProperty(key) == null && System.getenv(key) == null) {
                    System.setProperty(key, value);
                }
            }
        } catch (IOException e) {
            System.out.println("No .env → using AWS Secrets Manager");
        }
    }
}

Step 5 — How to run
On your laptop:
mvn spring-boot:run -Dspring-boot.run.profiles=local

On AWS EC2 server:
java -jar student.jar --spring.profiles.active=prod

Full picture — What happens where
YOUR LAPTOP                         AWS SERVER
───────────────                     ──────────────────
.env file exists                    .env file nahi hai
    ↓                                   ↓
loadEnvFile() reads it              IOException → skip
    ↓                                   ↓
DB_URL set as System property       AWS Spring Cloud
    ↓                                reads Secrets Manager
Spring reads ${DB_URL}                  ↓
    ↓                               DB_URL inject hota hai
Connects to localhost:5432              ↓
                                    Spring reads ${DB_URL}
                                        ↓
                                    Connects to RDS
Same Java code, same application.properties structure — only the profile changes! 🚀

Learning Path for you
Now        → CRUD working (done ✓)
Next       → JWT authentication
Then       → Docker basics
Then       → Deploy to AWS EC2
Then       → Add AWS RDS + Secrets Manager
Abhi AWS ki chinta mat karo — JWT seekho pehle! Jab deploy karna ho tab AWS setup karenge step by step. 

========================================================================================================================================
Parameter :-

Step 1 — Add dependency in pom.xml
xml<!-- AWS Spring Cloud for Parameter Store -->
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-aws-starter-parameter-store</artifactId>
    <version>3.1.0</version>
</dependency>
Also add Spring Cloud BOM above <dependencies>:
xml<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.awspring.cloud</groupId>
            <artifactId>spring-cloud-aws-dependencies</artifactId>
            <version>3.1.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

Step 2 — Create parameters in AWS Console
Go to AWS Console → Systems Manager → Parameter Store → Create parameter
Create these 3 parameters one by one:
Name  : /student-app/prod/DB_URL
Type  : String
Value : jdbc:postgresql://your-rds-host:5432/studentdb

Name  : /student-app/prod/DB_USERNAME
Type  : String
Value : postgres

Name  : /student-app/prod/DB_PASSWORD
Type  : SecureString        ← this encrypts the password FREE!
Value : yourStrongPassword

/student-app/prod/ is just a folder path — helps organise params


Step 3 — IAM Role (permission)
Go to AWS Console → IAM → Roles → Create Role
Trusted entity type → AWS Service → EC2

Add this permission policy:
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ],
    "Resource": "arn:aws:ssm:ap-south-1:YOUR_ACCOUNT_ID:parameter/student-app/*"
  }]
}

Role name → student-app-ec2-role
Then go to EC2 → Your Instance → Actions → Security → Modify IAM Role → attach student-app-ec2-role

Step 4 — application-prod.properties
properties# application-prod.properties

server.port=8080
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Tell Spring WHERE to find params in Parameter Store
spring.cloud.aws.parameterstore.enabled=true
spring.cloud.aws.region.static=ap-south-1

# Path prefix — Spring reads /student-app/prod/DB_URL automatically
spring.config.import=aws-parameterstore:/student-app/prod/

# Now use them normally!
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

Step 5 — application-local.properties stays same
properties# application-local.properties (your laptop)

server.port=8081
spring.cloud.aws.parameterstore.enabled=false   # disable AWS locally!

spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
Your .env + loadEnvFile() in main class handles local as before.

Step 6 — Run commands
bash# Your laptop
mvn spring-boot:run -Dspring-boot.run.profiles=local

# AWS EC2 server
java -jar student.jar --spring.profiles.active=prod

=====================================================================================================================