1. @SpringBootApplication

Use: Main class start karne ke liye

@SpringBootApplication
public class StudentApplication {

    public static void main(String[] args) {
        SpringApplication.run(
            StudentApplication.class,args);
    }
}

Use case: Project entry point

Equivalent:

@Configuration
@EnableAutoConfiguration
@ComponentScan


2. @RestController

Use: API banane ke liye

@RestController
public class StudentController {

}

Real example:

@GetMapping("/hello")
public String hello(){
   return "Hello";
}

Use case:

Frontend → Controller → JSON response


3. @RequestMapping

Use: Base URL

@RestController
@RequestMapping("/student")
public class StudentController {
}

URL:

/student/save
/student/all


4. @GetMapping

Read API

@GetMapping("/all")

public List<Student> getAll(){

   return service.getAll();

}

Use case:

GET /student/all

Fetch records


5. @PostMapping

Save data

@PostMapping("/save")

public Student save(
@RequestBody Student student){

   return service.save(student);

}

Use:

POST /student/save


6. @PutMapping

Update API

@PutMapping("/update")

public Student update(
@RequestBody Student student){

   return service.update(student);

}

Use:

Update student marks


7. @DeleteMapping

Delete record

@DeleteMapping("/{id}")

public void delete(
@PathVariable Integer id){

   service.delete(id);

}

Use:

DELETE /student/101


8. @RequestBody

JSON → Java object

JSON:

{
"name":"Rahul",
"marks":90
}

Code:

@PostMapping

public Student save(
@RequestBody Student student){

}

Use:

Postman request body


9. @PathVariable

Get value from URL

URL:

/student/101

Code:

@GetMapping("/{id}")

public Student getById(
@PathVariable Integer id){

}

Output:

id = 101


10. @RequestParam

Query parameter

URL:

/student?id=101

Code:

@GetMapping

public Student get(
@RequestParam Integer id){

}

Use:

Search API

PathVariable = mandatory path data
RequestParam = optional query/filter data


11. @Autowired

Dependency injection

@Service
public class StudentService {

   @Autowired

   StudentRepository repo;

}

Use:

Spring object automatically inject karega


12. @Service

Business logic layer

@Service
public class StudentService {

}

Use:

Validation

if(marks<0)

Calculations


13. @Repository

DB layer

@Repository

public interface StudentRepo
extends JpaRepository<Student,Integer>{

}

Use:

DB operations


14. @Component

General bean

@Component
public class EmailUtil{

}

Use case:

Email
Utility
Helper classes


15. @Entity

Table mapping

@Entity
public class Student {

}

Use:

Java → Database table


16. @Table

Table name define

@Entity
@Table(name="student")
public class Student{

}

DB:

student


17. @Id

Primary key

@Id

private Integer id;

Use:

PRIMARY KEY


18. @GeneratedValue

Auto increment

@Id

@GeneratedValue(
strategy=
GenerationType.IDENTITY)

private Integer id;

DB:

1
2
3

Auto generate


19. @Column

Customize column

@Column(
name="student_name")

private String name;

DB:

student_name


20. @Transactional

Transaction management

@Transactional

public void saveAll(){

   saveStudent();

   saveMarks();

}

Use:

If one fail → rollback

Bank example:

Debit
Credit


21. @ExceptionHandler

Custom exception

@ExceptionHandler(
RuntimeException.class)

public String handle(){

   return "Error";

}

Use:

Global error handling


22. @ControllerAdvice

Global exception class

@ControllerAdvice

public class GlobalException{

}

Use:

All project exception handling


23. @Bean

Manual object create

@Configuration

public class Config {

   @Bean

   public RestTemplate rt(){

      return new RestTemplate();

   }

}

Use:

Custom beans


24. @Configuration

Configuration class

@Configuration

public class AppConfig{

}

Use:

Bean setup


25. @Value

Read properties

application.properties

app.name=StudentAPI

Code:

@Value("${app.name}")

private String appName;

Output:

StudentAPI