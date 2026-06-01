# Spring Boot — Answers

> Each answer restates the problem briefly, gives a complete explanation or implementation, and highlights the key idea.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. Core Concepts

---

### 💚 C1 — Auto-configuration

**Problem:** Explain auto-configuration and how to exclude a specific class.

`@SpringBootApplication` is a composed annotation that includes `@EnableAutoConfiguration`. This triggers Spring Boot's auto-configuration mechanism: at startup, it reads all `AutoConfiguration` class names listed in `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` (Spring Boot 3.x) and registers those that pass their `@Conditional` checks.

To exclude a specific auto-configuration:

```java
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class MyApp { }
```

Or via properties:
```properties
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
```

**Key idea:** Auto-configuration is opt-out, not opt-in. It registers beans only when nothing else has already provided them (`@ConditionalOnMissingBean`).

---

### 💚 C2 — Starter dependencies

**Problem:** What is a starter and name three common ones.

A starter is a curated set of dependency descriptors (a Maven/Gradle BOM fragment) that brings in all the libraries needed for a particular feature — no version conflicts, no missing transitive dependencies.

| Starter | What it provides |
|---|---|
| `spring-boot-starter-web` | Spring MVC, embedded Tomcat, Jackson (JSON) |
| `spring-boot-starter-data-jpa` | Spring Data JPA, Hibernate, JDBC, transaction management |
| `spring-boot-starter-security` | Spring Security, form login, CSRF protection |
| `spring-boot-starter-test` | JUnit 5, Mockito, AssertJ, MockMvc, Spring Test |

**Key idea:** Starters eliminate "dependency hell" — you declare intent (`I want JPA`) not individual jars.

---

### 💚 C3 — Embedded server

**Problem:** Default server and how to switch to Jetty.

`spring-boot-starter-web` includes Tomcat by default.

Switch to Jetty:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```

**Key idea:** The embedded server is just another auto-configured bean. Excluding the Tomcat starter stops its auto-configuration from firing; adding the Jetty starter triggers Jetty's auto-configuration instead.

---

### 🟡 C4 — Application context lifecycle

**Problem:** Describe the ApplicationContext lifecycle and hook points.

1. **Load bean definitions** — classpath scan, `@Configuration` classes, XML (if any)
2. **Post-process bean definitions** — `BeanFactoryPostProcessor` (e.g., `PropertySourcesPlaceholderConfigurer`)
3. **Instantiate beans** — constructor injection
4. **Post-process beans** — `BeanPostProcessor` (AOP proxies are created here)
5. **Lifecycle callbacks** — `@PostConstruct`, `afterPropertiesSet()`, `init-method`
6. **Context refresh complete** — `ContextRefreshedEvent` fired
7. **Application ready** — `ApplicationReadyEvent` fired (after all `CommandLineRunner`s)
8. **Shutdown** — `@PreDestroy`, `DisposableBean.destroy()`, `destroy-method`

Custom hooks:
```java
@Component
public class StartupHook implements ApplicationListener<ApplicationReadyEvent> {
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        // runs after context is fully started and ready to serve requests
    }
}

// Or with annotation:
@EventListener(ApplicationReadyEvent.class)
public void onReady() { }
```

---

### 🟡 C5 — Actuator endpoints

**Problem:** List four Actuator endpoints and how to expose all of them.

| Endpoint | What it exposes |
|---|---|
| `/actuator/health` | Application health (UP/DOWN) and component health indicators |
| `/actuator/metrics` | JVM, HTTP, datasource, and custom metrics |
| `/actuator/env` | All resolved property sources and their values |
| `/actuator/beans` | Every bean in the context with its type and dependencies |

Expose all endpoints:
```properties
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always
```

**Key idea:** By default only `/health` is exposed over HTTP — a deliberate security default. Exposing `env` and `beans` in production leaks internal structure.

---

### 🟡 C6 — Conditional beans

**Problem:** Register a DataSource only when `app.use-custom-datasource=true`.

```java
@Configuration
public class DataSourceConfig {

    @Bean
    @ConditionalOnProperty(name = "app.use-custom-datasource", havingValue = "true")
    public DataSource customDataSource(
            @Value("${app.datasource.url}") String url,
            @Value("${app.datasource.username}") String username,
            @Value("${app.datasource.password}") String password) {
        HikariDataSource ds = new HikariDataSource();
        ds.setJdbcUrl(url);
        ds.setUsername(username);
        ds.setPassword(password);
        return ds;
    }
}
```

- `@ConditionalOnProperty` — bean registered only if property equals the specified value
- `@ConditionalOnMissingBean` — registered only if no other bean of that type exists (used in auto-configuration to let user overrides win)
- `@ConditionalOnClass` — registered only if a class is present on the classpath

---

### 🔴 C7 — Custom auto-configuration

**Problem:** Steps to ship a reusable auto-configuration module.

1. Create a separate Maven/Gradle module (e.g., `my-library-spring-boot-autoconfigure`).
2. Write the configuration class:
```java
@AutoConfiguration
@ConditionalOnClass(MyLibrary.class)
@EnableConfigurationProperties(MyLibraryProperties.class)
public class MyLibraryAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public MyLibrary myLibrary(MyLibraryProperties props) {
        return new MyLibrary(props.getApiKey());
    }
}
```
3. Register it in `src/main/resources/META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`:
```
com.example.MyLibraryAutoConfiguration
```
4. Create a starter module that depends on both the auto-configure module and the library itself — users only add the starter.

**Key idea:** `@ConditionalOnMissingBean` is essential — it lets application developers override your defaults by defining their own bean.

---

### 🔴 C8 — Startup performance

**Problem:** Techniques to reduce startup time.

| Technique | Effect |
|---|---|
| `spring.main.lazy-initialization=true` | Beans created on first use, not at startup |
| GraalVM Native Image | Compiles to native binary; startup in < 100ms |
| `@Import` instead of component scan | Avoids scanning the entire classpath |
| Exclude unused auto-configurations | Fewer beans to wire |
| Spring Boot 3 AOT processing | Pre-computes reflection/proxy metadata at build time |

**Lazy initialization trade-off:** First request that triggers a lazy bean creation incurs a latency spike. If that bean fails to initialize (e.g., bad DB credentials), the error surfaces at request time rather than at startup — harder to detect in production.

---

## 2. Dependency Injection & Beans

---

### 💚 B1 — Bean scopes

| Scope | Lifecycle | Use case |
|---|---|---|
| `singleton` (default) | One instance per `ApplicationContext` | Stateless services, repositories |
| `prototype` | New instance every time it is requested | Stateful objects, command objects |
| `request` | One per HTTP request (web only) | Per-request data holders |
| `session` | One per HTTP session (web only) | Shopping cart, user preferences |

---

### 💚 B2 — Constructor vs field injection

```java
// Field injection — NOT recommended
@Service
public class OrderService {
    @Autowired
    private PaymentService paymentService;  // can't be final; hidden dependency
}

// Constructor injection — recommended
@Service
public class OrderService {
    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;  // explicit, testable, immutable
    }
}
```

**Why constructor injection is preferred:**
- Dependencies are explicit — visible in the constructor signature
- Field can be `final` (immutable after construction)
- Easily testable without Spring — just call `new OrderService(mockPayment)`
- Circular dependency detected at startup, not at runtime

---

### 💚 B3 — Component stereotypes

All four are detected by `@ComponentScan` and register a bean, but differ in semantics and additional behavior:

| Annotation | Semantic | Extra behavior |
|---|---|---|
| `@Component` | Generic component | None |
| `@Service` | Business logic layer | None (marker only) |
| `@Repository` | Data access layer | Translates persistence exceptions to `DataAccessException` |
| `@Controller` | Web layer | Enables Spring MVC request mapping |

**Key idea:** `@Repository` is the only one with a functional difference — the persistence exception translation post-processor wraps vendor-specific exceptions.

---

### 🟡 B4 — Circular dependency

```java
// This causes BeanCurrentlyInCreationException with constructor injection:
@Service
public class A {
    public A(B b) { }
}
@Service
public class B {
    public B(A a) { }   // Spring can't construct A without B, or B without A
}
```

**Fix 1 — Redesign (preferred):** Extract shared logic into a third bean `C` that both `A` and `B` depend on.

**Fix 2 — `@Lazy` on one constructor parameter:**
```java
@Service
public class A {
    public A(@Lazy B b) { }  // B is injected as a proxy; real instance created on first use
}
```

**Fix 3 — Setter/field injection on one side:** Spring can set the property after both beans are constructed.

With Spring Boot 2.6+, circular dependencies are prohibited by default (`spring.main.allow-circular-references=false`). This forces proper design.

---

### 🟡 B5 — Bean lifecycle callbacks

**Execution order:**
1. Constructor
2. Setter/field injection
3. `BeanPostProcessor.postProcessBeforeInitialization()`
4. `@PostConstruct`
5. `InitializingBean.afterPropertiesSet()`
6. `init-method` (declared in `@Bean(initMethod="...")`)
7. `BeanPostProcessor.postProcessAfterInitialization()`

**Why prefer `@PostConstruct` over `InitializingBean`:**
- `@PostConstruct` is a JSR-250 standard annotation — no Spring import in the class
- `InitializingBean` couples your code to Spring's API
- Both run at the same lifecycle phase; `@PostConstruct` runs first if both are present

---

### 🟡 B6 — Primary and Qualifier

```java
interface NotificationService { void send(String message); }

@Service
@Primary
public class EmailNotificationService implements NotificationService {
    public void send(String message) { /* send email */ }
}

@Service
@Qualifier("sms")
public class SmsNotificationService implements NotificationService {
    public void send(String message) { /* send SMS */ }
}

@Service
public class OrderService {
    private final NotificationService defaultNotifier;
    private final NotificationService smsNotifier;

    public OrderService(
            NotificationService defaultNotifier,             // picks @Primary (email)
            @Qualifier("sms") NotificationService smsNotifier) {
        this.defaultNotifier = defaultNotifier;
        this.smsNotifier = smsNotifier;
    }
}
```

---

### 🔴 B7 — Prototype beans inside singletons

When a `@Scope("prototype")` bean is injected into a singleton, Spring performs the injection **once at construction time**. The singleton holds a reference to that single prototype instance forever — defeating the purpose of prototype scope.

**Fix 1 — `ApplicationContext.getBean()`:**
```java
@Service
public class ReportService {
    @Autowired
    private ApplicationContext ctx;

    public void generate() {
        ReportBuilder builder = ctx.getBean(ReportBuilder.class);  // fresh instance each call
    }
}
```

**Fix 2 — `ObjectProvider` (preferred):**
```java
@Service
public class ReportService {
    private final ObjectProvider<ReportBuilder> builderProvider;

    public ReportService(ObjectProvider<ReportBuilder> builderProvider) {
        this.builderProvider = builderProvider;
    }

    public void generate() {
        ReportBuilder builder = builderProvider.getObject();  // fresh instance
    }
}
```

`ObjectProvider` is lazy, Spring-aware, and more testable than `ApplicationContext`.

---

## 3. REST & Web

---

### 💚 R1 — Controller annotations

`@Controller` returns view names (resolves to templates via `ViewResolver`). Add `@ResponseBody` to a method to return data directly.

`@RestController` = `@Controller` + `@ResponseBody` on every method — all responses go through `HttpMessageConverter` (JSON by default).

Use `@Controller` when rendering HTML templates (Thymeleaf, FreeMarker). Use `@RestController` for REST APIs.

---

### 💚 R2 — Request mapping

```java
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        return userService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<User> createUser(
            @RequestBody @Valid CreateUserRequest request,
            UriComponentsBuilder uriBuilder) {
        User created = userService.create(request);
        URI location = uriBuilder.path("/users/{id}").buildAndExpand(created.id()).toUri();
        return ResponseEntity.created(location).body(created);
    }
}
```

---

### 💚 R3 — Exception handling

```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) { super(message); }
}

@ControllerAdvice
public class GlobalExceptionHandler {

    record ErrorResponse(int status, String message, Instant timestamp) { }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(404, ex.getMessage(), Instant.now()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> e.getField() + ": " + e.getDefaultMessage())
                .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest()
                .body(new ErrorResponse(400, msg, Instant.now()));
    }
}
```

---

### 🟡 R4 — Validation

```java
record CreateUserRequest(
    @NotBlank(message = "Name is required")
    String name,

    @Email(message = "Must be a valid email")
    @NotBlank
    String email,

    @Min(value = 18, message = "Must be at least 18")
    @Max(value = 120)
    int age
) { }

@RestController
@RequestMapping("/users")
public class UserController {

    @PostMapping
    public ResponseEntity<User> create(@RequestBody @Valid CreateUserRequest request) {
        // @Valid triggers Bean Validation; MethodArgumentNotValidException thrown on failure
        return ResponseEntity.ok(userService.create(request));
    }
}
```

`@Valid` (JSR-380) or `@Validated` (Spring) on the parameter triggers validation. The `@ControllerAdvice` handler catches `MethodArgumentNotValidException` if any constraint fails.

---

### 🟡 R5 — Filter vs Interceptor

| | Servlet Filter | HandlerInterceptor |
|---|---|---|
| Lives in | Servlet container | Spring MVC DispatcherServlet |
| Runs | Before DispatcherServlet | After DispatcherServlet resolves handler |
| Access to | Raw `HttpServletRequest/Response` | Handler method, `ModelAndView` |
| Use case | CORS, logging, authentication (JWT) | Role-based access, request timing, locale |

```java
// Filter example
@Component
public class RequestLoggingFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        // pre-processing
        chain.doFilter(req, res);
        // post-processing
    }
}

// Interceptor example
@Component
public class TimingInterceptor implements HandlerInterceptor {
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
        req.setAttribute("startTime", System.currentTimeMillis());
        return true;  // return false to abort the request
    }
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                Object handler, Exception ex) {
        long duration = System.currentTimeMillis() - (Long) req.getAttribute("startTime");
        // log duration
    }
}
```

---

### 🟡 R6 — Content negotiation

Add the Jackson XML dependency and configure content negotiation:

```xml
<dependency>
    <groupId>com.fasterxml.jackson.dataformat</groupId>
    <artifactId>jackson-dataformat-xml</artifactId>
</dependency>
```

```properties
spring.mvc.contentnegotiation.favor-parameter=false
spring.mvc.contentnegotiation.favor-path-extension=false
```

Spring Boot auto-configures `MappingJackson2XmlHttpMessageConverter` when the dependency is on the classpath. The controller method stays unchanged — Spring picks the converter based on the `Accept` header.

---

### 🔴 R7 — WebFlux vs Spring MVC

| | Spring MVC | Spring WebFlux |
|---|---|---|
| Threading model | One thread per request (blocking) | Event loop + non-blocking I/O |
| API | `@RestController`, `RestTemplate` | `@RestController`, `WebClient`, Router functions |
| Max concurrency | Limited by thread pool size | Very high (few threads handle many connections) |
| Backpressure | None | Built-in via Project Reactor |

**Choose WebFlux when:**
- Handling many concurrent connections with low CPU work (chat servers, streaming)
- Making many downstream HTTP calls — non-blocking avoids thread starvation
- Building fully reactive pipelines (R2DBC, reactive MongoDB)

**Limitations:**
- Entire stack must be reactive — mixing blocking JDBC calls in a reactive pipeline defeats the purpose
- Steeper learning curve (Mono/Flux semantics)
- Less ecosystem coverage than Spring MVC for blocking libraries

---

## 4. Data Access

---

### 💚 D1 — Spring Data JPA basics

`JpaRepository<Entity, ID>` provides:
- `save(entity)` / `saveAll()`
- `findById(id)` → `Optional<T>`
- `findAll()` / `findAll(Sort)` / `findAll(Pageable)`
- `deleteById(id)` / `delete(entity)`
- `count()`
- `existsById(id)`

All backed by Hibernate under the hood; no SQL required.

---

### 💚 D2 — Query methods

```java
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByLastName(String lastName);
    Optional<User> findFirstByEmailContaining(String substring);
    long countByAgeGreaterThan(int age);
}
```

Spring Data parses the method names and generates JPQL automatically. Keywords: `findBy`, `countBy`, `deleteBy`, `existsBy`, combined with `And`, `Or`, `Containing`, `GreaterThan`, `First`, `Top`, etc.

---

### 🟡 D3 — Transaction management

`@Transactional` wraps the method in a transaction boundary — if an unchecked exception escapes, the transaction rolls back; on normal return, it commits.

| Propagation | Behavior |
|---|---|
| `REQUIRED` (default) | Join existing transaction; create one if none exists |
| `REQUIRES_NEW` | Always start a new transaction; suspend existing one |

**Self-invocation problem:**
```java
@Service
public class OrderService {
    public void placeOrder() {
        this.processPayment();  // WRONG — calls real object, not proxy → @Transactional ignored
    }

    @Transactional
    public void processPayment() { }
}
```

Spring's `@Transactional` works via AOP proxy. Calling a method on `this` bypasses the proxy. Fix: inject `OrderService` into itself (`@Lazy`), or extract `processPayment` into a separate bean.

---

### 🟡 D4 — N+1 problem

```java
// N+1: one query to load 100 authors, then 100 queries for each author's books
List<Author> authors = authorRepository.findAll();
for (Author a : authors) {
    System.out.println(a.getBooks().size());  // triggers lazy load per author
}

// Fix 1 — JPQL JOIN FETCH
@Query("SELECT a FROM Author a JOIN FETCH a.books")
List<Author> findAllWithBooks();

// Fix 2 — Entity Graph
@EntityGraph(attributePaths = {"books"})
List<Author> findAll();  // override findAll with entity graph
```

**Key idea:** Both solutions generate a single SQL JOIN instead of N+1 separate SELECTs.

---

### 🟡 D5 — Custom query

```java
public interface UserRepository extends JpaRepository<User, Long> {

    // JPQL version
    @Query("SELECT u FROM User u WHERE u.registeredAt >= :since AND SIZE(u.orders) > :minOrders")
    List<User> findRecentActiveUsers(
        @Param("since") LocalDateTime since,
        @Param("minOrders") int minOrders);

    // Native SQL version
    @Query(
        value = "SELECT * FROM users u WHERE u.registered_at >= :since " +
                "AND (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) > :minOrders",
        nativeQuery = true)
    List<User> findRecentActiveUsersNative(
        @Param("since") LocalDateTime since,
        @Param("minOrders") int minOrders);
}
```

---

### 🔴 D6 — Optimistic vs pessimistic locking

**Optimistic locking** — assumes conflicts are rare; checks at commit time:
```java
@Entity
public class Product {
    @Id Long id;
    int stock;

    @Version
    int version;  // Hibernate includes this in UPDATE's WHERE clause
                  // throws OptimisticLockException if version mismatch
}
```

**Pessimistic locking** — locks the row immediately:
```java
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("SELECT p FROM Product p WHERE p.id = :id")
Optional<Product> findByIdForUpdate(@Param("id") Long id);
```

**Choose pessimistic when:**
- Conflicts are frequent (high contention on the same rows)
- Retry on `OptimisticLockException` is unacceptable (financial transactions)
- Short transactions that can afford the lock overhead

---

## 5. Configuration & Profiles

---

### 💚 P1 — Properties vs YAML

**Advantages of YAML:**
1. Hierarchical structure — avoids repetition (`app.mail.host`, `app.mail.port` → nested under `app.mail:`)
2. Supports lists natively with `-` syntax

```properties
# application.properties
app.mail.host=smtp.example.com
app.mail.port=587
```

```yaml
# application.yml
app:
  mail:
    host: smtp.example.com
    port: 587
```

---

### 💚 P2 — @Value injection

```java
@Service
public class PaymentService {

    @Value("${payment.gateway.url:https://sandbox.example.com}")
    private String gatewayUrl;

    // The colon after the property name separates the key from the default value
}
```

---

### 🟡 P3 — @ConfigurationProperties

```yaml
app:
  mail:
    host: smtp.example.com
    port: 587
    auth: true
```

```java
@ConfigurationProperties(prefix = "app.mail")
public record MailProperties(String host, int port, boolean auth) { }

@SpringBootApplication
@ConfigurationPropertiesScan   // or @EnableConfigurationProperties(MailProperties.class)
public class MyApp { }

@Service
public class MailService {
    private final MailProperties props;
    public MailService(MailProperties props) { this.props = props; }
}
```

**Advantages over `@Value`:**
- Grouped — all related properties in one typed object
- Supports validation via `@Validated` + Bean Validation annotations
- IDE auto-completion when combined with `spring-boot-configuration-processor`
- Works with relaxed binding (`mail-host`, `MAIL_HOST`, `mailHost` all map to `host`)

---

### 🟡 P4 — Profiles

File naming convention:
```
application.properties          ← always loaded (base)
application-dev.properties      ← loaded when 'dev' profile is active
application-staging.properties
application-prod.properties
```

Activate a profile:
```bash
# At runtime via JVM argument
java -jar app.jar --spring.profiles.active=prod

# Via environment variable
SPRING_PROFILES_ACTIVE=prod java -jar app.jar
```

---

### 🔴 P5 — Externalized configuration order (highest priority first)

1. Command-line arguments (`--server.port=8081`)
2. `SPRING_APPLICATION_JSON` environment variable
3. OS environment variables (`SERVER_PORT=8081`)
4. JVM system properties (`-Dserver.port=8081`)
5. Profile-specific files outside jar (`application-prod.properties` in current dir)
6. Profile-specific files inside jar
7. `application.properties` outside jar (current directory / `config/` subdirectory)
8. `application.properties` inside jar
9. `@PropertySource` annotations
10. Default properties (`SpringApplication.setDefaultProperties`)

**Why it matters:** In production, secrets (DB password, API keys) are injected via environment variables (rule 3) and override the placeholder values checked into source control — no secrets in the jar.

---

## 6. Testing

---

### 💚 T1 — @SpringBootTest

`@SpringBootTest` bootstraps the full `ApplicationContext` (all beans, auto-configuration, etc.).

| `webEnvironment` | Description |
|---|---|
| `MOCK` (default) | Loads a mock `WebApplicationContext`; use with `MockMvc` |
| `RANDOM_PORT` | Starts a real embedded server on a random port; use with `TestRestTemplate` or `WebTestClient` |
| `DEFINED_PORT` | Real server on the port in config |
| `NONE` | No web environment (for non-web tests) |

`RANDOM_PORT` is used for full integration tests that exercise HTTP end-to-end including filters and error pages. `MOCK` is faster and simpler for controller-level logic.

---

### 🟡 T2 — Slice tests

Slice tests load only a subset of the application context for speed and isolation.

| Annotation | Loads | Excludes |
|---|---|---|
| `@WebMvcTest` | `@Controller`, `@ControllerAdvice`, `@JsonComponent`, `Filter`, `MockMvc` | `@Service`, `@Repository`, full auto-config |
| `@DataJpaTest` | JPA repositories, `EntityManager`, in-memory H2 by default | Web layer, `@Service` |
| `@JsonTest` | Jackson configuration only | Everything else |

Use `@MockBean` inside slice tests to provide dependencies the slice does not load.

---

### 🟡 T3 — MockMvc test

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired MockMvc mockMvc;
    @MockBean  UserService userService;

    @Test
    void getUser_exists_returns200() throws Exception {
        User user = new User(1L, "Alice", "alice@example.com");
        when(userService.findById(1L)).thenReturn(Optional.of(user));

        mockMvc.perform(get("/users/1").accept(MediaType.APPLICATION_JSON))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.name").value("Alice"))
               .andExpect(jsonPath("$.email").value("alice@example.com"));
    }

    @Test
    void getUser_notFound_returns404() throws Exception {
        when(userService.findById(99L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/users/99"))
               .andExpect(status().isNotFound());
    }
}
```

---

### 🔴 T4 — Testcontainers

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-testcontainers</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <scope>test</scope>
</dependency>
```

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)  // don't replace with H2
@Testcontainers
class UserRepositoryTest {

    @Container
    @ServiceConnection   // Spring Boot 3.1+ — wires JDBC URL automatically
    static PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgres:16-alpine");

    @Autowired UserRepository userRepository;

    @Test
    void save_and_find() {
        User user = userRepository.save(new User("Alice", "alice@example.com"));
        assertThat(userRepository.findById(user.id())).isPresent();
    }
}
```

`@ServiceConnection` (Spring Boot 3.1+) reads the container's JDBC URL, username, and password and creates a `ConnectionDetails` bean — no manual `@DynamicPropertySource` needed.

---

> 📁 Questions are in `springboot-questions.md`
