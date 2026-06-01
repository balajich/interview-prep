# Hibernate & JPA — Practice Questions

> **How to use:** Work through each question on your own before opening the answers file.  
> Questions mix conceptual explanation with entity/query implementation.  
> 💚 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## Table of Contents
1. [Entity Mapping](#1-entity-mapping)
2. [Relationships](#2-relationships)
3. [Querying](#3-querying)
4. [Caching & Performance](#4-caching--performance)
5. [Transactions & Locking](#5-transactions--locking)

---

## 1. Entity Mapping

### 💚 Beginner

**E1 — Basic entity**  
Write a minimal JPA entity `Product` with an auto-generated `Long` id, a `String` name (max 100 characters, not nullable), and a `BigDecimal` price. Which annotation marks the class as an entity, and what requirement does the class have?

```java
// implement Product entity
```

---

**E2 — Embeddable**  
What is `@Embeddable`? Model a `Person` entity that has an embedded `Address` (street, city, country). Show both classes and explain what table structure results.

```java
// implement Address (embeddable) and Person (entity)
```

---

**E3 — Enum mapping**  
You have an enum `OrderStatus { PENDING, PROCESSING, SHIPPED, DELIVERED }`.  
Show how to map it to the database as a string (not an integer) and explain why string mapping is generally preferred.

```java
@Entity
public class Order {
    // map OrderStatus as a string column
}
```

---

### 🟡 Intermediate

**E4 — Inheritance strategies**  
JPA supports three inheritance mapping strategies. Name them, describe the resulting table structure for each, and give a use case where each is appropriate.

---

**E5 — Composite key**  
Model an `OrderItem` entity whose primary key is composed of `orderId` and `productId`. Show the `@EmbeddedId` approach.

```java
// implement OrderItemId (embeddable id) and OrderItem
```

---

**E6 — Column naming and DDL**  
Explain the difference between `@Column(name="...")` and Hibernate's `ImplicitNamingStrategy`. Show how to configure `spring.jpa.hibernate.ddl-auto` correctly for development vs production.

---

### 🔴 Advanced

**E7 — Auditing**  
Use Spring Data JPA auditing to automatically populate `createdAt`, `updatedAt`, `createdBy`, and `updatedBy` fields on every entity. What annotations, interface, and Spring configuration are required?

```java
// implement an auditable base entity
```

---

## 2. Relationships

### 💚 Beginner

**R1 — One-to-Many**  
Model `Department` and `Employee` with a bidirectional `@OneToMany`/`@ManyToOne`. Which side is the owner? What does `mappedBy` mean?

```java
// implement both entities
```

---

**R2 — Fetch types**  
What is the default fetch type for `@ManyToOne` and `@OneToMany`? Explain the difference between `EAGER` and `LAZY` loading and why `LAZY` is usually preferred.

---

### 🟡 Intermediate

**R3 — Many-to-Many**  
Model `Student` and `Course` with a `@ManyToMany`. Then extend it to a three-entity model that stores an extra `grade` field on the join table.

```java
// Part A: simple @ManyToMany
// Part B: explicit join entity with extra column
```

---

**R4 — Cascade types**  
List the six `CascadeType` values and explain each. What is the difference between `CascadeType.REMOVE` and `orphanRemoval = true`?

---

**R5 — One-to-One**  
Map a `User` and a `UserProfile` with a `@OneToOne` relationship sharing the same primary key (`@MapsId`). What is the SQL structure?

```java
// implement User and UserProfile
```

---

### 🔴 Advanced

**R6 — Collection performance**  
Compare `List`, `Set`, and `Map` as the collection type for a `@OneToMany`. What is the "bag" problem in Hibernate, and how does it lead to a `MultipleBagFetchException`? What are two solutions?

---

## 3. Querying

### 💚 Beginner

**Q1 — JPQL basics**  
Write JPQL queries to:
1. Find all products with price greater than 100
2. Find a single employee by email (return `Optional`)
3. Count all orders with status `SHIPPED`

```java
// write the @Query annotations on repository methods
```

---

**Q2 — Named parameters vs positional**  
Show the same JPQL query written with named parameters (`@Param`) and with positional parameters (`?1`). Which style is preferred and why?

---

### 🟡 Intermediate

**Q3 — Projections**  
You only need `id` and `name` from a large `Product` entity. Show two ways to avoid loading all columns:
1. Interface-based projection
2. DTO projection using a JPQL constructor expression

```java
// implement both approaches
```

---

**Q4 — Criteria API**  
Write a Criteria API query that finds all employees in a given department who earn more than a given salary. When would you choose Criteria API over JPQL?

```java
public List<Employee> findHighEarners(String department, BigDecimal minSalary) {
    // implement with CriteriaBuilder
}
```

---

**Q5 — Pagination and sorting**  
Show how to use `Pageable` in a Spring Data repository to retrieve page 2 (0-indexed) of 10 employees, sorted by last name ascending then salary descending.

```java
// show repository method and calling code
```

---

### 🔴 Advanced

**Q6 — Bulk update and delete**  
Write a JPQL bulk update that raises the salary of all employees in the "Engineering" department by 10%. What is the critical risk of bulk updates in a JPA context and how do you mitigate it?

```java
@Modifying
@Query("...")
int raiseSalaries(String department, BigDecimal factor);
```

---

## 4. Caching & Performance

### 💚 Beginner

**P1 — First-level cache**  
What is Hibernate's first-level (L1) cache? What is its scope, and when is it cleared?

---

### 🟡 Intermediate

**P2 — Second-level cache**  
What is the second-level (L2) cache? What dependency and annotations are needed to enable it with Ehcache or Caffeine? What types of data are good candidates for L2 caching?

```java
// show entity annotation for L2 cache
```

---

**P3 — Query cache**  
What is the query cache? How does it relate to the L2 cache, and what is the invalidation strategy?

---

**P4 — Batch inserts**  
You need to insert 10,000 records. What two Hibernate/JPA properties must be set to enable JDBC batch inserts, and what constraint on the ID generation strategy must be satisfied?

---

### 🔴 Advanced

**P5 — Statistics and slow queries**  
How do you enable Hibernate statistics? What metric would you examine to detect an N+1 problem in production, and what logging property shows the generated SQL with bind parameters?

---

## 5. Transactions & Locking

### 💚 Beginner

**T1 — Session and transaction**  
What is a Hibernate `Session`, and how does it map to a JPA `EntityManager`? Describe what "persistence context" means.

---

### 🟡 Intermediate

**T2 — Dirty checking**  
What is Hibernate's dirty checking mechanism? Show an example where a field change on a managed entity is persisted without calling `save()`.

```java
@Transactional
public void giveRaise(Long employeeId, BigDecimal increase) {
    // demonstrate dirty checking
}
```

---

**T3 — Detached entities**  
Explain the four entity states: transient, managed, detached, removed. Show how to reattach a detached entity and the difference between `merge()` and `update()`.

---

### 🔴 Advanced

**T4 — Optimistic locking with retry**  
Write a service method that retries the operation up to 3 times when an `OptimisticLockException` is thrown. What Spring annotation can automate this?

```java
public void transferStock(Long fromId, Long toId, int quantity) {
    // implement with retry logic
}
```

---

**T5 — Read-only transactions**  
What performance benefit does `@Transactional(readOnly = true)` provide in Hibernate? List at least three optimizations Hibernate and Spring apply when the transaction is marked read-only.

---

> 📁 Answers are in `hibernate-answers.md`
