# Spring Boot — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Questions mix conceptual explanation with short code implementation.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Core Concepts](#1-core-concepts)
2. [Dependency Injection & Beans](#2-dependency-injection--beans)
3. [REST & Web](#3-rest--web)
4. [Data Access](#4-data-access)
5. [Configuration & Profiles](#5-configuration--profiles)
6. [Testing](#6-testing)

---

## 1. Core Concepts

### 💚 Beginner

**C1 — Auto-configuration**  
What is Spring Boot auto-configuration? How does `@SpringBootApplication` enable it, and how can you exclude a specific auto-configuration class?

---

**C2 — Starter dependencies**  
What is a Spring Boot "starter"? Name three common starters and explain what each pulls in.

---

**C3 — Embedded server**  
Spring Boot embeds a web server by default. Which server does `spring-boot-starter-web` use, and how do you switch to Jetty?

---

### 🟡 Intermediate

**C4 — Application context lifecycle**  
Describe the lifecycle of a Spring `ApplicationContext`. At what points can you hook custom logic via `ApplicationListener` or `@EventListener`?

---

**C5 — Actuator endpoints**  
What is Spring Boot Actuator? List four built-in endpoints and explain what each exposes. How do you expose all endpoints over HTTP in `application.properties`?

---

**C6 — Conditional beans**  
Explain `@ConditionalOnProperty`, `@ConditionalOnMissingBean`, and `@ConditionalOnClass`. Write a `@Configuration` class that registers a `DataSource` bean only when the property `app.use-custom-datasource=true` is set.

```java
@Configuration
public class DataSourceConfig {
    // implement conditional bean registration
}
```

---

### 🔴 Advanced

**C7 — Custom auto-configuration**  
Walk through all the steps needed to ship a reusable Spring Boot auto-configuration module (e.g., a custom metrics library). What files and annotations are required?

---

**C8 — Startup performance**  
Name at least four techniques to reduce Spring Boot application startup time. What does lazy bean initialization do, and what is the trade-off?

---

## 2. Dependency Injection & Beans

### 💚 Beginner

**B1 — Bean scopes**  
List four Spring bean scopes and describe when you would choose each.

---

**B2 — Constructor vs field injection**  
Compare constructor injection and field injection (`@Autowired` on a field). Which does Spring recommend and why?

---

**B3 — Component stereotypes**  
What is the difference between `@Component`, `@Service`, `@Repository`, and `@Controller`? Are there any functional differences beyond semantics?

---

### 🟡 Intermediate

**B4 — Circular dependency**  
What is a circular dependency in Spring? How does Spring handle it for singleton beans with constructor injection vs setter injection? Write an example that would cause a startup failure and explain how to fix it.

---

**B5 — Bean lifecycle callbacks**  
What is the order of execution for: constructor, `@PostConstruct`, `InitializingBean.afterPropertiesSet()`, and `init-method`? Why might you prefer `@PostConstruct` over `InitializingBean`?

---

**B6 — Primary and Qualifier**  
You have two beans implementing the same interface. Implement a configuration where one is the default (`@Primary`) and callers can opt into the other via `@Qualifier`.

```java
interface NotificationService { void send(String message); }

@Service
class EmailNotificationService implements NotificationService { }

@Service
class SmsNotificationService implements NotificationService { }

@Service
class OrderService {
    // inject the default (email) service
    // also show how to inject the SMS service explicitly
}
```

---

### 🔴 Advanced

**B7 — Prototype beans inside singletons**  
If you inject a `@Scope("prototype")` bean into a singleton bean, how many prototype instances are created and why? What are two ways to get a fresh prototype instance every time it is needed?

---

## 3. REST & Web

### 💚 Beginner

**R1 — Controller annotations**  
What is the difference between `@Controller` and `@RestController`? When would you use each?

---

**R2 — Request mapping**  
Implement a `GET /users/{id}` endpoint that returns a `User` as JSON, and a `POST /users` endpoint that accepts a JSON body and returns `201 Created` with a `Location` header.

```java
@RestController
@RequestMapping("/users")
public class UserController {
    // implement GET /users/{id}
    // implement POST /users
}
```

---

**R3 — Exception handling**  
What does `@ControllerAdvice` combined with `@ExceptionHandler` do? Write a global handler that catches `ResourceNotFoundException` and returns a `404` response with a JSON error body.

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    // implement handler
}
```

---

### 🟡 Intermediate

**R4 — Validation**  
Using Bean Validation (JSR-380), annotate a `CreateUserRequest` record with appropriate constraints and enable validation in the controller. What annotation triggers validation on a method parameter?

```java
record CreateUserRequest(String name, String email, int age) { }

@RestController
public class UserController {
    // show how to trigger validation
}
```

---

**R5 — Filter vs Interceptor**  
Compare a Servlet `Filter` and a Spring `HandlerInterceptor`. For each, describe at what point in the request lifecycle it runs and a typical use case.

---

**R6 — Content negotiation**  
A single endpoint must return XML when the client sends `Accept: application/xml` and JSON otherwise. How do you configure this in Spring Boot without changing the controller method?

---

### 🔴 Advanced

**R7 — WebFlux vs Spring MVC**  
Explain the threading model of Spring MVC (blocking) vs Spring WebFlux (reactive/non-blocking). Under what circumstances would you choose WebFlux, and what are the limitations?

---

## 4. Data Access

### 💚 Beginner

**D1 — Spring Data JPA basics**  
What does extending `JpaRepository<Entity, ID>` give you for free? Name five methods available without writing any implementation.

---

**D2 — Query methods**  
Write the Spring Data JPA method signatures (no implementation needed) for:
- Find all users with a given last name
- Find the first user whose email contains a given substring
- Count users older than a given age

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // add method signatures
}
```

---

### 🟡 Intermediate

**D3 — Transaction management**  
What does `@Transactional` do? Explain the difference between `REQUIRED` and `REQUIRES_NEW` propagation. What happens if you call a `@Transactional` method from within the same class?

---

**D4 — N+1 problem**  
Describe the N+1 select problem in JPA. Show a `@OneToMany` mapping that would trigger it, and demonstrate two ways to fix it (one using JPQL, one using entity graph).

```java
@Entity
public class Author {
    @OneToMany(mappedBy = "author")
    private List<Book> books;
}
// show the N+1 problem and fixes
```

---

**D5 — Custom query**  
Write a `@Query` method using JPQL and a separate one using a native SQL query that finds users registered in the last 30 days with more than 5 orders.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // JPQL version
    // native SQL version
}
```

---

### 🔴 Advanced

**D6 — Optimistic vs pessimistic locking**  
Compare optimistic and pessimistic locking in JPA. Show the annotation and field needed for optimistic locking, and when you would choose pessimistic locking instead.

---

## 5. Configuration & Profiles

### 💚 Beginner

**P1 — application.properties vs YAML**  
List two advantages of using `application.yml` over `application.properties`. Show the same multi-level property in both formats.

---

**P2 — @Value injection**  
Show how to inject a property value using `@Value`, including a default value if the property is absent.

```java
@Service
public class PaymentService {
    // inject payment.gateway.url with a default of "https://sandbox.example.com"
}
```

---

### 🟡 Intermediate

**P3 — @ConfigurationProperties**  
What advantages does `@ConfigurationProperties` offer over `@Value`? Bind the following YAML block to a Java record:

```yaml
app:
  mail:
    host: smtp.example.com
    port: 587
    auth: true
```

```java
// implement the record and binding
```

---

**P4 — Profiles**  
You need different database URLs for `dev`, `staging`, and `prod`. Show the file naming convention for profile-specific property files and how to activate a profile at runtime (two ways).

---

### 🔴 Advanced

**P5 — Externalized configuration order**  
Spring Boot resolves properties from many sources. List at least six sources in priority order (highest first) and explain why this order matters for production deployments.

---

## 6. Testing

### 💚 Beginner

**T1 — @SpringBootTest**  
What does `@SpringBootTest` do? How does `webEnvironment = RANDOM_PORT` differ from `MOCK`?

---

### 🟡 Intermediate

**T2 — Slice tests**  
What is a "slice test"? Explain `@WebMvcTest` and `@DataJpaTest`, including what parts of the context each loads and what they exclude.

---

**T3 — MockMvc**  
Write a `@WebMvcTest` test for the `GET /users/{id}` endpoint that:
- Returns `200` with a JSON body when the user exists
- Returns `404` when the user is not found

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserService userService;

    // write both test cases
}
```

---

### 🔴 Advanced

**T4 — TestContainers**  
Describe how to use Testcontainers to run a real PostgreSQL container in a `@DataJpaTest`. What dependency is needed, and how do you wire the container's JDBC URL into the Spring context?

---

> 📁 Answers are in `springboot-answers.md`
