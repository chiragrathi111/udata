IOC Container - This is using to getting object. IOC spring boot have one tool 
their according get object not need to create a new object because without 
using spring boot we craeted object.

@SpringBootApplication (This annotation using main class)
(above annotation generaly using for three work)
@Configuration,@EnableAutoCongiguration,@ComponentScan

@Component (IOC Container using this annotation)
(This Container using any class so class,interface,method and field all value 
getting object)  

@Autowired
this annotation using if any other class create obj on another class so 
using this annotation

@RestController
This annotation using for rest api class

@RequestMapping("/main")
This annotation using for whole class and this annotation only using class lavel

@GetMapping("/path") 
This annotation using for get api path 

@PostMapping("/path")
This annotation using for Post api path 
@RequestBody (annotation using this api have payload)
@PathVariable(annotation using for Get api)

@DeleteMapping("/path")

@PutMapping("/path")
-------------------------------------------------------------------------------
Example:-
@PostMapping("/path")
public void createData(@RequestBody Model_Name myEntry){ 
(myEntry is obj for that class and data store this obj)
}

-------------------------------------------------------------------------------
Example:-
@GetMapping("/id/{myid}")
public JournalEntry getJournalEntryById(@PathVariable Long myid){
	return journalEntry.get(myid);
}

Explanation:-
If you want any specific id through get any data so using this path ("/id/{myid}")
@PathVariable = our spring understand this have any value
Long = Data type
myid = value
journalEntry = Mapping object
-------------------------------------------------------------------------------
Example:-
@PutMapping("/id/{myid}")
public JournalEntry updateJournalEntryById(@PathVariable Long myid,@RequestBody Model_Name myEntry){
	return journalEntry.put(myid,myEntry);
}
-------------------------------------------------------------------------------
Example:-
@DeleteMapping("/id/{myid}")
public JournalEntry deleteJournalEntryById(@PathVariable Long myid){
	return journalEntry.remove(myid);
}
-------------------------------------------------------------------------------
Example:-  
@Component
public class Dog {

}

Diff. calss
@Component
public class Cat {

@Autowired
private Dog dog;
}
-------------------------------------------------------------------------------
object class:-

@Document (This class using for Row)
@Id (Table Primary key)
@Document(collation = "journal_entries") (create a record journal_entries table)

@Indexed(unique = true)  (Every value unique)
@NonNull  (Field value not null)
@DBRef (This annotation using for two different table link)
-------------------------------------------------------------------------------
ResponseEntity<?>
if using ? so we use this method any object
and if you want any specific object so fill object name

ResponseEntity<JournalEntry>
-------------------------------------------------------------------------------
Lombok:-
Lombok as tool,this using we dont need to create any getter,setter,and constructor
object class added two annotation
@Getter
@Setter
and first time Intellij Sugget please install plug in
and i added depency first time
<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<version>1.18.38</version>
		</dependency>

@Data (This one annotation use all Getter,setter,ToStrin,constructor)		
@NoArgsConstructor  (If use Data annotation so this is need)

-------------------------------------------------------------------------------
@Transactional  (if have two method one crete and one failed
and both are relation so this problem,I use this annotation so one failed means all failed
Success method automatic Roleback)

If we want use this annotation,so first added annotation to main class
@EnableTransactionManagement

@Bean 
-------------------------------------------------------------------------------
API security
@EnableWebSecurity

Example:-
@Configuration
@EnableWebSecurity
public class SpringSecurity extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/journal/**").authenticated()
                .anyRequest().permitAll()
                .and()
                .httpBasic();
    }
}

-------------------------------------------------------------------------------
API Auth Security:-
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-security</artifactId>
</dependency>	