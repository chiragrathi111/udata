@SpringBootApplication

below 3 define above annotation :-

@Configuration       → this class can define Spring beans
@EnableAutoConfiguration → Spring Boot auto-configures everything (DB, web, etc.)
@ComponentScan       → scans this package and sub-packages for components

@Entity

@Table(name = "students")

@Data

@NoArgsConstructor

@AllArgsConstructor

@Id

@GeneratedValue(strategy = GenerationType.IDENTITY)

@Column(nullable = false, unique = true, length = 150)

@Repository

@Service

@Autowired

@RestController

@RequestMapping("/api/students")

@PostMapping

@GetMapping

@PutMapping("/{id}")

@DeleteMapping("/{id}")