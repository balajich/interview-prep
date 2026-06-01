# Hibernate & JPA — Answers

> Each answer restates the problem briefly, gives a complete explanation or implementation, and highlights the key idea.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. Entity Mapping

---

### 💚 E1 — Basic entity

**Problem:** Write a minimal JPA entity with an auto-generated id, constrained name, and price.

```java
@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", length = 100, nullable = false)
    private String name;

    @Column(name = "price", precision = 10, scale = 2)
    private BigDecimal price;

    // JPA requires a no-arg constructor (may be protected)
    protected Product() { }

    public Product(String name, BigDecimal price) {
        this.name = name;
        this.price = price;
    }

    // getters...
}
```

**Requirements:** Every JPA entity must have `@Entity`, a no-arg constructor (at least package-private), and exactly one field annotated `@Id`. The class must not be `final`.

---

### 💚 E2 — Embeddable

**Problem:** Model `Address` as an embeddable and embed it in `Person`.

```java
@Embeddable
public class Address {
    private String street;
    private String city;
    private String country;
    // no @Id — not an entity
}

@Entity
public class Person {
    @Id @GeneratedValue
    private Long id;
    private String name;

    @Embedded
    private Address address;
}
```

**Table structure:** A single `person` table with columns: `id`, `name`, `street`, `city`, `country`. No join, no separate table. Use `@AttributeOverride` to rename embeddable columns:

```java
@Embedded
@AttributeOverrides({
    @AttributeOverride(name = "street", column = @Column(name = "home_street"))
})
private Address address;
```

---

### 💚 E3 — Enum mapping

**Problem:** Map `OrderStatus` as a string column.

```java
public enum OrderStatus { PENDING, PROCESSING, SHIPPED, DELIVERED }

@Entity
public class Order {
    @Id @GeneratedValue
    private Long id;

    @Enumerated(EnumType.STRING)   // stores "PENDING", "SHIPPED", etc.
    @Column(nullable = false)
    private OrderStatus status;
}
```

**Why STRING over ORDINAL:**  
`EnumType.ORDINAL` stores `0, 1, 2, 3`. Inserting or reordering an enum constant changes all existing ordinal values — a silent, catastrophic data migration. `EnumType.STRING` stores the name; adding constants or reordering is safe.

---

### 🟡 E4 — Inheritance strategies

| Strategy | Tables | Use case |
|---|---|---|
| `SINGLE_TABLE` | One table for all subclasses; `DTYPE` discriminator column | Simple hierarchies, no nullable column concerns |
| `JOINED` | One table per class; subclass tables joined to parent by PK | Wide hierarchies where nullable columns are unacceptable |
| `TABLE_PER_CLASS` | One complete table per concrete class; no shared table | Rarely used; polymorphic queries are expensive (UNION ALL) |

```java
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class Payment { @Id @GeneratedValue Long id; double amount; }

@Entity
public class CreditCardPayment extends Payment { String cardNumber; }

@Entity
public class BankTransferPayment extends Payment { String iban; }
```

---

### 🟡 E5 — Composite key

**Problem:** Model `OrderItem` with a composite PK using `@EmbeddedId`.

```java
@Embeddable
public class OrderItemId implements Serializable {
    private Long orderId;
    private Long productId;
    // equals() and hashCode() are required
}

@Entity
public class OrderItem {
    @EmbeddedId
    private OrderItemId id;

    @ManyToOne
    @MapsId("orderId")    // maps the orderId field in the embeddable
    private Order order;

    @ManyToOne
    @MapsId("productId")
    private Product product;

    private int quantity;
}
```

The embeddable id class must implement `Serializable` and override `equals`/`hashCode`.

---

### 🟡 E6 — Column naming and DDL

`@Column(name = "first_name")` explicitly sets the column name.

Without `@Column`, Hibernate uses an `ImplicitNamingStrategy` to derive the name from the field name. The default (`SpringImplicitNamingStrategy` in Spring Boot) converts camelCase to snake_case: `firstName` → `first_name`.

**DDL auto configuration:**

```properties
# Development — recreate schema on each restart
spring.jpa.hibernate.ddl-auto=create-drop

# Development with existing data — add new tables/columns only
spring.jpa.hibernate.ddl-auto=update

# Production — never touch the schema (use Flyway or Liquibase instead)
spring.jpa.hibernate.ddl-auto=validate
```

---

### 🔴 E7 — Auditing

```java
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class Auditable {

    @CreatedDate
    @Column(updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    @CreatedBy
    @Column(updatable = false)
    private String createdBy;

    @LastModifiedBy
    private String updatedBy;
}

@Entity
public class Product extends Auditable { }
```

Enable auditing in a `@Configuration` class:
```java
@Configuration
@EnableJpaAuditing
public class JpaConfig {

    @Bean
    public AuditorAware<String> auditorProvider() {
        // return the currently authenticated user
        return () -> Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
                             .map(Authentication::getName);
    }
}
```

---

## 2. Relationships

---

### 💚 R1 — One-to-Many

```java
@Entity
public class Department {
    @Id @GeneratedValue
    private Long id;
    private String name;

    @OneToMany(mappedBy = "department", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Employee> employees = new ArrayList<>();

    public void addEmployee(Employee e) {
        employees.add(e);
        e.setDepartment(this);
    }
}

@Entity
public class Employee {
    @Id @GeneratedValue
    private Long id;
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")  // FK column lives here
    private Department department;
}
```

**Owner side:** The `@ManyToOne` side (`Employee`) is the owner — it holds the foreign key column. `mappedBy` on the `@OneToMany` side says "this collection is managed by the `department` field on the other side; do not create a join table."

---

### 💚 R2 — Fetch types

| Association | Default fetch |
|---|---|
| `@ManyToOne` | `EAGER` |
| `@OneToOne` | `EAGER` |
| `@OneToMany` | `LAZY` |
| `@ManyToMany` | `LAZY` |

`EAGER` — Hibernate loads the associated data immediately in the same query (or an additional query).  
`LAZY` — Hibernate loads the associated data only when the getter is first called (proxy/collection wrapper).

**Why LAZY is preferred:**
- You pay only for what you use
- Prevents accidentally loading entire object graphs
- Easier to control fetch strategy per query with `JOIN FETCH`

Always override to EAGER explicitly at the query level when needed (`JOIN FETCH`), not at the mapping level.

---

### 🟡 R3 — Many-to-Many

**Part A — Simple `@ManyToMany`:**
```java
@Entity
public class Student {
    @Id @GeneratedValue Long id;

    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id"))
    private Set<Course> courses = new HashSet<>();
}

@Entity
public class Course {
    @Id @GeneratedValue Long id;

    @ManyToMany(mappedBy = "courses")
    private Set<Student> students = new HashSet<>();
}
```

**Part B — Explicit join entity with extra column:**
```java
@Entity
public class Enrollment {
    @EmbeddedId
    private EnrollmentId id;

    @ManyToOne @MapsId("studentId")
    private Student student;

    @ManyToOne @MapsId("courseId")
    private Course course;

    private char grade;   // extra column
}

@Embeddable
public class EnrollmentId implements Serializable {
    private Long studentId;
    private Long courseId;
}
```

Use the explicit join entity approach whenever the join table has extra columns — `@ManyToMany` cannot model them.

---

### 🟡 R4 — Cascade types

| CascadeType | Effect |
|---|---|
| `PERSIST` | Saving the parent also saves new children |
| `MERGE` | Merging the parent also merges children |
| `REMOVE` | Deleting the parent also deletes associated children |
| `REFRESH` | Refreshing the parent also refreshes children |
| `DETACH` | Detaching the parent also detaches children |
| `ALL` | All of the above |

**`REMOVE` vs `orphanRemoval`:**
- `CascadeType.REMOVE` — deletes children when the parent entity is deleted
- `orphanRemoval = true` — additionally deletes a child when it is **removed from the parent's collection** (even if the parent is not deleted):

```java
department.getEmployees().remove(employee);  // with orphanRemoval=true, employee is deleted on flush
```

---

### 🟡 R5 — One-to-One with shared PK

```java
@Entity
public class User {
    @Id @GeneratedValue
    private Long id;
    private String username;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private UserProfile profile;
}

@Entity
public class UserProfile {
    @Id
    private Long id;  // same value as User.id

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId               // UserProfile.id is derived from User.id
    @JoinColumn(name = "id")
    private User user;

    private String bio;
    private String avatarUrl;
}
```

**SQL structure:** Two tables (`users`, `user_profiles`) with no separate FK column — `user_profiles.id` IS the FK, pointing to `users.id`.

---

### 🔴 R6 — Collection performance

| Type | Hibernate mapping | Notes |
|---|---|---|
| `List` | "bag" (unordered) or ordered list | Allows duplicates |
| `Set` | Set semantics | Removes duplicates; avoids bag issues |
| `Map` | Keyed by a column | Useful for maps of values |

**The bag problem:** Hibernate calls an unordered `List` a "bag." Fetching two bags in the same JPQL query with `JOIN FETCH` causes `MultipleBagFetchException` because Hibernate cannot produce a Cartesian product with correct row counts for both collections simultaneously.

**Fix 1 — Use `Set` instead of `List`:**
```java
@OneToMany(mappedBy = "author")
private Set<Book> books = new HashSet<>();    // no MultipleBagFetchException
```

**Fix 2 — Fetch one collection at a time** (separate queries or `@EntityGraph` with single path):
```java
// Two separate fetch queries instead of one JOIN FETCH for both
List<Author> authors = em.createQuery("SELECT a FROM Author a JOIN FETCH a.books", Author.class).getResultList();
// Then access tags lazily or via a second query
```

---

## 3. Querying

---

### 💚 Q1 — JPQL basics

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("SELECT p FROM Product p WHERE p.price > :minPrice")
    List<Product> findByPriceGreaterThan(@Param("minPrice") BigDecimal minPrice);
}

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    @Query("SELECT e FROM Employee e WHERE e.email = :email")
    Optional<Employee> findByEmail(@Param("email") String email);
}

public interface OrderRepository extends JpaRepository<Order, Long> {

    @Query("SELECT COUNT(o) FROM Order o WHERE o.status = :status")
    long countByStatus(@Param("status") OrderStatus status);
}
```

---

### 💚 Q2 — Named vs positional parameters

```java
// Named parameters — preferred
@Query("SELECT e FROM Employee e WHERE e.department = :dept AND e.salary > :minSalary")
List<Employee> findHighEarners(@Param("dept") String dept, @Param("minSalary") BigDecimal min);

// Positional parameters — fragile
@Query("SELECT e FROM Employee e WHERE e.department = ?1 AND e.salary > ?2")
List<Employee> findHighEarners(String dept, BigDecimal min);
```

**Why named parameters are preferred:** Positional parameters are order-dependent — reordering method parameters silently breaks the query. Named parameters are self-documenting and refactoring-safe.

---

### 🟡 Q3 — Projections

```java
// Interface-based projection
public interface ProductSummary {
    Long getId();
    String getName();
}

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<ProductSummary> findAllProjectedBy();   // Hibernate generates SELECT id, name only
}

// DTO constructor expression
public record ProductDto(Long id, String name) { }

public interface ProductRepository extends JpaRepository<Product, Long> {
    @Query("SELECT new com.example.ProductDto(p.id, p.name) FROM Product p")
    List<ProductDto> findAllDtos();
}
```

**When to use which:**
- Interface projection — less code; Spring Data generates the query automatically
- DTO projection — works with aggregations (`AVG`, `COUNT`), more explicit, avoids Spring Data proxy overhead

---

### 🟡 Q4 — Criteria API

```java
public List<Employee> findHighEarners(String department, BigDecimal minSalary) {
    CriteriaBuilder cb = entityManager.getCriteriaBuilder();
    CriteriaQuery<Employee> cq = cb.createQuery(Employee.class);
    Root<Employee> emp = cq.from(Employee.class);

    cq.select(emp).where(
        cb.equal(emp.get("department"), department),
        cb.greaterThan(emp.get("salary"), minSalary)
    );

    return entityManager.createQuery(cq).getResultList();
}
```

**Choose Criteria API when:**
- Query predicates are assembled dynamically at runtime (search/filter screens)
- Compile-time type safety is required (use with JPA Metamodel)
- Building a reusable query specification (Spring Data `Specification<T>`)

Choose JPQL for static queries — it is far more readable.

---

### 🟡 Q5 — Pagination and sorting

```java
public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    Page<Employee> findByDepartment(String department, Pageable pageable);
}

// Calling code
Sort sort = Sort.by(Sort.Order.asc("lastName"), Sort.Order.desc("salary"));
Pageable pageable = PageRequest.of(1, 10, sort);   // page=1 (0-indexed), size=10
Page<Employee> page = employeeRepository.findByDepartment("Engineering", pageable);

List<Employee> employees = page.getContent();
long total = page.getTotalElements();
int totalPages = page.getTotalPages();
```

---

### 🔴 Q6 — Bulk update and delete

```java
@Modifying
@Transactional
@Query("UPDATE Employee e SET e.salary = e.salary * (1 + :factor) WHERE e.department = :dept")
int raiseSalaries(@Param("dept") String department, @Param("factor") BigDecimal factor);
```

**Critical risk — stale persistence context:**  
Bulk UPDATE/DELETE bypasses Hibernate's persistence context. Any `Employee` entities already loaded in the same session now have stale salary values in memory. If they are later flushed, their old values will overwrite the bulk update.

**Mitigation:**
```java
@Modifying(clearAutomatically = true)   // clears the persistence context after the query
@Transactional
@Query("UPDATE Employee e SET e.salary = e.salary * (1 + :factor) WHERE e.department = :dept")
int raiseSalaries(@Param("dept") String department, @Param("factor") BigDecimal factor);
```

`clearAutomatically = true` evicts all cached entities, forcing fresh loads on next access.

---

## 4. Caching & Performance

---

### 💚 P1 — First-level cache

The L1 cache is the **persistence context** (Hibernate `Session` / JPA `EntityManager`). It holds all entities loaded within the current session.

- **Scope:** Single `Session` / `EntityManager` — not shared between sessions or threads
- **Cleared when:** Session closes, `entityManager.clear()` is called, or `@Modifying(clearAutomatically=true)` fires
- **Effect:** Two `findById(1L)` calls in the same transaction return the same object reference — the second call never hits the database

---

### 🟡 P2 — Second-level cache

L2 cache is shared across sessions/threads for the same `SessionFactory` (application-scoped).

```xml
<!-- Maven dependency for Caffeine-based L2 cache (Spring Boot 3.x) -->
<dependency>
    <groupId>org.hibernate.orm</groupId>
    <artifactId>hibernate-jcache</artifactId>
</dependency>
<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
</dependency>
```

```properties
spring.jpa.properties.hibernate.cache.use_second_level_cache=true
spring.jpa.properties.hibernate.cache.region.factory_class=jcache
spring.cache.type=caffeine
```

```java
@Entity
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)   // entity is L2-cacheable
public class Country { }
```

**Good L2 cache candidates:** Read-mostly reference data (countries, currencies, product categories). Poor candidates: frequently-updated entities (orders, account balances) — cache invalidation overhead outweighs benefit.

---

### 🟡 P3 — Query cache

The query cache caches the **result set identifiers** (a list of PKs) for a given JPQL query + parameters combination. The actual entities are still looked up via the L2 cache (so L2 must be enabled).

```properties
spring.jpa.properties.hibernate.cache.use_query_cache=true
```

```java
@QueryHints(@QueryHint(name = "org.hibernate.cacheable", value = "true"))
List<Country> findAll();
```

**Invalidation:** Any write to a table whose entities appear in a cached query result invalidates all query cache entries for that entity type — even unrelated queries. This makes the query cache counterproductive for frequently-written tables.

---

### 🟡 P4 — Batch inserts

```properties
spring.jpa.properties.hibernate.jdbc.batch_size=50
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true
```

**ID generation constraint:** `GenerationType.IDENTITY` (database auto-increment) disables JDBC batching — Hibernate must execute each insert individually to retrieve the generated key. Switch to `GenerationType.SEQUENCE` with `allocationSize` matching `batch_size`:

```java
@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "product_seq")
@SequenceGenerator(name = "product_seq", allocationSize = 50)
private Long id;
```

---

### 🔴 P5 — Statistics and slow queries

**Enable Hibernate statistics:**
```properties
spring.jpa.properties.hibernate.generate_statistics=true
logging.level.org.hibernate.stat=DEBUG
```

**Detect N+1 in production:**  
Look at `hibernate.statistics.session.load_count` vs `hibernate.statistics.entity.fetch_count`. If fetches far exceed loads, you have an N+1 problem. The `StatisticsService` MBean (via JMX) or Micrometer's Hibernate metrics integration expose these counters.

**Show SQL with bind parameters:**
```properties
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.orm.jdbc.bind=TRACE   # Hibernate 6
# Or for Hibernate 5:
logging.level.org.hibernate.type.descriptor.sql=TRACE
```

---

## 5. Transactions & Locking

---

### 💚 T1 — Session and EntityManager

`Session` is Hibernate's native API; `EntityManager` is the JPA standard. In Spring Boot with Spring Data JPA, you interact with `EntityManager` (or Spring Data repositories) — Spring creates and closes the underlying `Session` transparently.

**Persistence context:** The runtime cache of managed entities for a given unit of work. It:
- Tracks which entities have been loaded
- Detects changes (dirty checking)
- Ensures identity — only one Java object per database row per session

---

### 🟡 T2 — Dirty checking

```java
@Transactional
public void giveRaise(Long employeeId, BigDecimal increase) {
    Employee emp = employeeRepository.findById(employeeId).orElseThrow();
    emp.setSalary(emp.getSalary().add(increase));
    // NO save() call needed — Hibernate detects the change at flush time
}   // transaction commits → Hibernate flushes → UPDATE SQL generated automatically
```

**How it works:** At flush time (before commit or before a query), Hibernate compares the current state of each managed entity against the snapshot taken at load time. Any difference triggers an UPDATE.

---

### 🟡 T3 — Entity states

| State | Description | How to reach it |
|---|---|---|
| **Transient** | Not associated with any session; no DB row | `new Employee()` |
| **Managed** | Associated with session; changes tracked | `persist()`, `find()`, `merge()` result |
| **Detached** | Was managed; session closed or `detach()` called | Session closed, `entityManager.detach()` |
| **Removed** | Scheduled for deletion at flush | `remove()` |

**`merge()` vs `update()`:**
- `entityManager.merge(detached)` — copies state of detached entity onto a managed entity; returns the managed entity; detached instance is not altered
- `session.update(detached)` — Hibernate-specific; reattaches the exact instance; throws if another instance with the same id is already managed

In JPA (standard), always use `merge()`.

---

### 🔴 T4 — Optimistic locking with retry

```java
@Service
public class StockService {

    private static final int MAX_RETRIES = 3;

    @Autowired
    private ProductRepository productRepository;

    public void transferStock(Long fromId, Long toId, int quantity) {
        int attempt = 0;
        while (true) {
            try {
                doTransfer(fromId, toId, quantity);
                return;
            } catch (OptimisticLockException | ObjectOptimisticLockingFailureException e) {
                if (++attempt >= MAX_RETRIES) throw e;
            }
        }
    }

    @Transactional
    private void doTransfer(Long fromId, Long toId, int quantity) {
        Product from = productRepository.findById(fromId).orElseThrow();
        Product to   = productRepository.findById(toId).orElseThrow();
        from.setStock(from.getStock() - quantity);
        to.setStock(to.getStock() + quantity);
    }
}
```

**Spring Retry automation:**
```java
@Retryable(
    retryFor = ObjectOptimisticLockingFailureException.class,
    maxAttempts = 3,
    backoff = @Backoff(delay = 100))
@Transactional
public void transferStock(Long fromId, Long toId, int quantity) { ... }
```

Add `spring-retry` dependency and `@EnableRetry` on a `@Configuration` class.

---

### 🔴 T5 — Read-only transactions

```java
@Transactional(readOnly = true)
public List<Product> findAll() {
    return productRepository.findAll();
}
```

**Optimizations applied:**
1. **Dirty checking disabled** — Hibernate skips the entity state snapshot comparison at flush time (no need to detect changes that can't exist in a read-only transaction)
2. **Flush mode set to `NEVER`** — no automatic flush before queries; removes overhead
3. **Spring routes to read replica** — if a `AbstractRoutingDataSource` or R2DBC routing is configured, `readOnly=true` signals to route to a read replica
4. **Hibernate `Session` flush mode** — set to `MANUAL`, preventing accidental writes
5. **Database-level hint** — some drivers/databases apply optimistic concurrency controls when they know the transaction is read-only

---

> 📁 Questions are in `hibernate-questions.md`
