Inheritance :-

One class acquires/recive/obtain/gain properties and method of another class that is call inheritance.

Encapsulation :-

Binding data and method togather into one unit that is called Encapsulation.
Hiding internal data from outside access.

🔥 Real Life Example

ATM Machine:

You can:

withdraw money
check balance

But you CANNOT directly access:

bank database
server logic

This is encapsulation.

✅ In Java

We use:

private variables
getter/setter methods

Q: Why encapsulation important?

Because it:

protects data
avoids invalid data
improves security


Abstraction :-

Showing only important data, Hiding implementation

🔥 Real Life Example

Car:

You know:

steering
brake
accelerator

But internally:

engine logic
wiring

Hidden from user.

✅ In Java Abstraction Achieved By
Abstract class
Interface

Interface vs Abstract Class (VERY IMPORTANT)

Feature					Interface				Abstract Class
Keyword					interface				abstract
Multiple inheritance	✅ Yes					❌ No
Constructor				❌ No					✅ Yes
Variables				public static final		Any type
Methods				abstract/default/static		abstract + normal
Object creation			❌ No					❌ No

✅ Q1. Difference between abstraction and encapsulation?
Abstraction	Encapsulation
Hides implementation	Hides data
Focus on behavior	Focus on security
✅ Q2. Why interface used?

For:

loose coupling
multiple inheritance
standard rules

--------------------------------------------------------------------------
Week 2 :-

List vs Set vs Map

This is VERY common interview question.

Feature	List	Set	Map
Duplicate	YES	NO	Key unique
Order	Maintains	Mostly no guarantee	Key-value
Index	YES	NO	NO
Example	ArrayList	HashSet	HashMap
🔥 LIST

Stores ordered elements.

Example:

List<String> names =
        new ArrayList<>();

names.add("Chirag");

names.add("Rahul");

names.add("Chirag");

Output:

Chirag
Rahul
Chirag

Duplicates allowed.

🔥 SET

No duplicates.

Set<String> names =
        new HashSet<>();

names.add("Chirag");

names.add("Rahul");

names.add("Chirag");

Output:

Chirag
Rahul

Second Chirag ignored.

🔥 MAP

Stores:

key → value

Example:

Map<Integer,String> students =
        new HashMap<>();

students.put(101,"Chirag");

students.put(102,"Rahul");

Output:

101 → Chirag
102 → Rahul

------------------------------------------
1. List → Ordered data + duplicate allowed

Use when sequence important ho.

a. ArrayList Scenario

Best when: Read operations jyada ho.

Real examples:

Student records
Employee list
Product list API response

Syntex :
ArrayList<Student> students = new ArrayList<>();

b. LinkedList Scenario

Best when:

Insert/Delete frequent

Example:

Train coach system

Coach1 <-> Coach2 <-> Coach3

Add coach middle me:

LinkedList<String> coaches = new LinkedList<>();

coaches.add("S1");
coaches.add("S2");

coaches.addFirst("Engine");

Use case:

Browser history
Undo/Redo
Playlist

c. Vector

Old synchronized ArrayList.

Vector<String> v = new Vector<>();

Mostly legacy code.

Interview:

ArrayList → non synchronized
Vector → synchronized

Modern projects me rarely use.

2. Set → Unique values only

Duplicate nahi chahiye.

Syntex :-
Set<String> emails = new HashSet<>();

Real scenarios:

Unique user IDs
Unique emails
Unique tags

3. Queue → FIFO
First In First Out

Example:

Print queue:

Doc1
Doc2
Doc3

Doc1 pehle print.

Code:

Queue<String> q = new LinkedList<>();

q.offer("Task1");
q.offer("Task2");

System.out.println(q.poll());

Use cases:

Ticket booking
Notification queue
Background jobs

Spring Boot:

RabbitMQ / Kafka concept same.


4. Map → Key Value

Most used in backend.

Example:

Map<Integer,String> students = new HashMap<>();

students.put(101,"Rahul");
students.put(102,"Amit");

Retrieve:

students.get(101);

Output:

Rahul
HashMap Scenario

Fast lookup.

Real example:

Student ID -> Student Name
Product ID -> Product
User ID -> User

Spring Boot API:

Map<Integer,Student> db = new HashMap<>();

Search O(1).

TreeMap Scenario

Sorted order chahiye.

TreeMap<Integer,String> map = new TreeMap<>();

map.put(103,"Ravi");
map.put(101,"Rahul");
map.put(102,"Amit");

Output:

101 Rahul
102 Amit
103 Ravi

Use:

Ranking system
Leaderboard
Sorted reports

If we need all records showing in Map so we need loop :-

Map<Integer,String> students = new HashMap<>();

for(Map.Entry<Integer,String> entry: students.entrySet()){
System.out.println(entry.getKey() + " " + entry.getValue());

}

-----------------------------------------------------
Throw & Throws :-

Ultimate Difference
throw						throws
Used inside method			Used in method signature
Creates exception			Declares exception
Immediate action			Warning
Single exception object		Multiple possible

throw :-
throw new RuntimeException("Age invalid");

throws :-
void check()

throws Exception


Both Together Example

class Voting {

    void vote(int age) throws Exception{

        if(age<18){
            throw new Exception("Not Eligible");
        }

        System.out.println("Vote Success");
    }
}

Main:

public class Main {

    public static void main(String[] args){
		Voting v = new Voting();

        try{
			v.vote(15);
        }

        catch(Exception e){
            System.out.println(e.getMessage());
        }
    }
}

Note :- If we use Throw ,then error showing and brake work, but if i use Throws then I show manually error and this is shwoing message instead of error. 

---------------------------------------------------------------
Maven :-

What is Maven?

Maven is a Build Tool + Dependency Management Tool.

Maven helps:

✅ Download libraries automatically
✅ Build project
✅ Compile code
✅ Run tests
✅ Package JAR/WAR
✅ Manage project structure

----------------------------------------------------
Spring Boot :-

What is Spring Boot?

Before Spring Boot:

Create API means:

Configure XML
Configure server
Add dependencies manually
Configure servlet
Tomcat setup
Lots of configuration 😭

Spring Boot solved this.

Definition:

Spring Boot =
Spring + Auto Configuration + Embedded Server

Benefits:

✅ Fast setup
✅ Less configuration
✅ Embedded Tomcat
✅ Production ready
✅ Easy REST APIs


Flow:

Postman

   ↓

Controller
"Request aaya"

   ↓

Service
"Business logic"

   ↓

Repository
"DB operation"

   ↓

MySQL
Store data

1. Controller Layer

Controller = Entry Gate

Request lena
Response dena
URL mapping

Example:

@RestController
@RequestMapping("/student")
public class StudentController {

    @Autowired
    StudentService service;

    @PostMapping("/save")
    public Student saveStudent(
            @RequestBody Student student){

        return service.saveStudent(student);

    }
}

User hit:

POST /student/save

Controller bolta:

Request aa gaya
Service ko bhejo

Controller me business logic nahi likhte.

2. Service Layer

Brain of application

Business logic
Validation
Calculations
Rules

Example:

@Service
public class StudentService {

    @Autowired
    StudentRepository repo;

    public Student saveStudent(
            Student student){

        if(student.getMarks()<0){

            throw new RuntimeException(
            "Invalid marks");

        }

        return repo.save(student);
    }
}

Example logic:

Marks > 100 ?

Duplicate email ?

Age > 18 ?

Salary calculate ?

Ye sab Service me

3. Repository Layer

Repository = Database se baat karna.

Example:

@Repository
public interface StudentRepository
extends JpaRepository<Student,Integer>{

}

Spring automatically de deta:

save()

findById()

findAll()

delete()

No SQL required basic case me.

Use:

repo.save(student);

repo.findAll();

repo.deleteById(101);

4. Database Layer

Entity:

@Entity
@Table(name="student")
public class Student {

    @Id
    private Integer id;

    private String name;

    private Integer marks;

}
---------------------------------------------------
