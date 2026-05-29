# SQL Interview Questions

> Try every query in the live database before checking answers.  
> 🟢 Beginner · 🟡 Advanced · 🔴 Expert

---

## Quick Start

```bash
# Spin up Postgres + pgAdmin
docker-compose up -d

# Connect via terminal
docker exec -it sql_interview_db psql -U interview -d interviewdb

# Browser UI
# http://localhost:5050  →  admin@interview.com / admin
# Register server: Host=postgres  Port=5432  DB=interviewdb  User=interview  Pass=interview
```

---

## Schema Reference

```
departments   id, name, budget, location
employees     id, first_name, last_name, department_id, salary, hire_date, manager_id
customers     id, name, email, city, country, created_at
products      id, name, category, price, stock_quantity, metadata (JSONB)
orders        id, customer_id, order_date, total_amount, status
order_items   id, order_id, product_id, quantity, unit_price

order.status values: pending | processing | shipped | delivered | cancelled
```

---

## 🟢 Beginner

---

**B1 — Basic SELECT with ORDER BY**

List every employee's full name and salary, ordered by salary from highest to lowest.

```sql
-- your query here
```

---

**B2 — Filtering with WHERE and a date condition**

Find all employees hired on or after January 1, 2022.  
Show their full name, hire date, and salary.

```sql
-- your query here
```

---

**B3 — GROUP BY with COUNT**

How many employees are in each department?  
Show the department name and employee count, ordered by count descending.

```sql
-- your query here
```

---

**B4 — HAVING**

Which departments have **more than 3** employees?  
Show department name and the count.

```sql
-- your query here
```

---

**B5 — INNER JOIN**

List every employee's full name alongside their department name and the department's location.

```sql
-- your query here
```

---

**B6 — LEFT JOIN to find missing relationships**

Find all customers who have **never placed an order**.  
Show customer name, email, and country.

```sql
-- your query here
```

---

**B7 — Aggregate functions**

In a single query, show:
- the highest salary across the whole company
- the lowest salary
- the average salary (rounded to 2 decimal places)

```sql
-- your query here
```

---

**B8 — LIKE pattern matching**

Find all products whose name contains the word `"Pro"`.  
Show product name, category, and price.

```sql
-- your query here
```

---

**B9 — IN with a list of values**

List all orders with a status of either `'shipped'` or `'delivered'`.  
Show order id, customer_id, order_date, total_amount, and status.

```sql
-- your query here
```

---

**B10 — BETWEEN**

Find all products priced between **$20 and $150** inclusive.  
Show product name, category, and price, ordered by price ascending.

```sql
-- your query here
```

---

**B11 — DISTINCT**

List all unique countries from the customers table, ordered alphabetically.

```sql
-- your query here
```

---

**B12 — COUNT with a date filter**

How many orders were placed in the year **2023**?

```sql
-- your query here
```

---

**B13 — SUM with a status filter**

What is the total revenue from **delivered** orders only?

```sql
-- your query here
```

---

**B14 — COALESCE for NULL handling**

List every employee's full name and their manager's id.  
If an employee has no manager, display the string `'No Manager'` instead of NULL.

```sql
-- your query here
```

---

**B15 — Scalar subquery in WHERE**

Find all employees whose salary is **above the company-wide average salary**.  
Show their full name, department_id, and salary.

```sql
-- your query here
```

---

## 🟡 Advanced

---

**A1 — ROW_NUMBER window function**

For each department, rank employees by salary (highest = rank 1).  
Return only the **top earner** from each department.  
Show department name, employee full name, and salary.

```sql
-- your query here
```

---

**A2 — RANK vs DENSE_RANK**

Show every employee's salary along with both their `RANK()` and `DENSE_RANK()` across the whole company (not per department), ordered by salary descending.

Then explain: **what is the difference between RANK and DENSE_RANK, and when does it matter?**

```sql
-- your query here
```

*(Written answer below the query)*

---

**A3 — LAG for month-over-month comparison**

For each calendar month in 2023, show:
- the month
- total revenue that month
- the previous month's total revenue
- the absolute change

```sql
-- your query here
```

---

**A4 — Running total with SUM OVER**

For each order (ordered by order_date), show the order id, date, total_amount, and a running cumulative total of all revenue up to and including that order.

```sql
-- your query here
```

---

**A5 — CTE (Common Table Expression)**

Using a CTE, find all employees who earn **more than their own department's average salary**.  
Show employee full name, department name, their salary, and the department average.

```sql
-- your query here
```

---

**A6 — Correlated subquery**

Without using window functions or CTEs, find the **highest-paid employee in each department** using a correlated subquery.

```sql
-- your query here
```

---

**A7 — EXISTS**

Find all customers who have placed **at least one order** with `total_amount > $500`.  
Use `EXISTS` (not `IN` or a JOIN).

```sql
-- your query here
```

---

**A8 — CASE WHEN salary banding**

Classify every employee into a salary band and show their name, salary, and band:

| Salary range      | Band       |
|-------------------|------------|
| Below $60,000     | `Junior`   |
| $60,000–$99,999   | `Mid`      |
| $100,000 and above| `Senior`   |

```sql
-- your query here
```

---

**A9 — UNION vs UNION ALL**

Part A: Write a query that produces a single list of **all names** from both the `customers` table and the `employees` table (full names), labelled with a `source` column (`'customer'` or `'employee'`).

Part B (written): What is the difference between `UNION` and `UNION ALL`? Which is faster and why?

```sql
-- your query here
```

---

**A10 — Detecting duplicates**

Find all email addresses in the `customers` table that appear **more than once**.  
Show the email and the number of times it appears.

```sql
-- your query here
```

---

**A11 — PIVOT with CASE WHEN**

Without using any extension, produce a single row showing the count of orders for each status as separate columns:

```
pending | processing | shipped | delivered | cancelled
```

```sql
-- your query here
```

---

**A12 — Self JOIN for hierarchy**

List every employee's full name and their **manager's full name**.  
Employees without a manager should still appear (show `NULL` or `'—'` for the manager).

```sql
-- your query here
```

---

**A13 — Nth highest value without LIMIT**

Find the **3rd highest salary** in the company using a subquery — do not use `LIMIT`/`OFFSET`.

```sql
-- your query here
```

---

**A14 — DELETE duplicates, keep one**

The `customers` table has rows with duplicate emails. Write a statement that **deletes all duplicates**, keeping only the row with the **lowest id** for each email.

```sql
-- your query here
```

---

**A15 — EXCEPT set operation**

Use `EXCEPT` to find all `product_id` values that have **never appeared in any order_items row**.

```sql
-- your query here
```

---

## 🔴 Expert

---

**E1 — Recursive CTE: full reporting chain**

Using a recursive CTE, list **all employees who report (directly or indirectly) to employee id 1** (Alice Johnson, Engineering manager). Show each person's name and their depth level in the hierarchy.

```sql
-- your query here
```

---

**E2 — Window frame: 3-day moving average**

Calculate the **3-day moving average** of daily order revenue.  
For each day that has orders, show the date, that day's total revenue, and the average over the current day plus the two preceding days.

```sql
-- your query here
```

---

**E3 — EXPLAIN ANALYZE**

Run `EXPLAIN ANALYZE` on the query from **A5** (employees earning above department average).

Then answer in writing:
1. What does each node type mean? (`Seq Scan`, `Hash Join`, `Sort`)
2. What does `actual time` vs `estimated rows` tell you?
3. What index, if any, would improve this query?

```sql
EXPLAIN ANALYZE
-- paste your A5 query here
```

---

**E4 — Index design**

Part A: Create appropriate indexes for these two common query patterns on the `orders` table:
1. `WHERE customer_id = $1 AND status = 'delivered'`
2. `WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'`

Part B (written): Explain the difference between:
- B-tree index vs Hash index
- Composite index vs two separate single-column indexes
- Partial index — give a real example where one is better

```sql
-- your CREATE INDEX statements here
```

---

**E5 — Normalization**

Given this **denormalized** table that stores order information:

```
order_data (order_id, customer_name, customer_email, customer_city,
            product_name, product_category, product_price,
            quantity, order_date, order_status)
```

Part A: Identify which normal form violations exist.  
Part B: Decompose this into tables that satisfy **3NF**. Write the `CREATE TABLE` statements.  
Part C: What additional step would bring it to **BCNF**?

```sql
-- your CREATE TABLE statements for Part B
```

---

**E6 — Deadlock scenario**

Part A (written): What is a deadlock? How does PostgreSQL detect and resolve it automatically?

Part B: Write two transaction sequences (Transaction A and Transaction B) that would deadlock on the `employees` and `orders` tables.

Part C: Rewrite both transactions to **prevent** the deadlock.

```sql
-- Transaction A and B here
```

---

**E7 — JSON with JSONB**

The `products.metadata` column stores JSONB. Write four separate queries:

1. Select the `brand` field from metadata for all Electronics products.
2. Find all products where `metadata->>'color'` is `'black'`.
3. Find all products where the `features` JSON array contains `'SSD'`.
4. Update the `Laptop Pro 15` metadata to add a new key `"on_sale": true`.

```sql
-- Q1
-- Q2
-- Q3
-- Q4
```

---

**E8 — Table partitioning**

Part A: Create a **range-partitioned** version of the `orders` table, partitioned by `order_date` year (one partition per year: 2022, 2023, 2024, and a default).

Part B (written): Explain the difference between **range**, **list**, and **hash** partitioning. When would you choose each?

```sql
-- your CREATE TABLE ... PARTITION BY statements
```

---

**E9 — Query optimization walkthrough**

You are given this slow query on a 50-million-row `orders` table:

```sql
SELECT c.name, COUNT(o.id) AS order_count, SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'delivered'
  AND o.order_date >= '2023-01-01'
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 10;
```

The query takes 40 seconds. Walk through your **systematic optimization approach**:

1. What does `EXPLAIN ANALYZE` tell you to look for?
2. What indexes would you add and in what order?
3. Would a materialized view help here?
4. Are there any query rewrites that could help?

*(Written answer — no SQL required, but include any DDL you'd run)*

---

**E10 — Schema design: e-learning platform**

Design a PostgreSQL schema for an e-learning platform with these requirements:

- Instructors create **courses**, each with multiple **lessons** (ordered)
- **Students** enroll in courses
- Progress is tracked per student per lesson (not started / in progress / completed)
- Students can leave **reviews** on courses (rating 1–5 + comment)
- Queries to optimize for:
  - "Give me all lessons for course X in order"
  - "What % of a course has student Y completed?"
  - "What is the average rating for course X?"

Write:
1. All `CREATE TABLE` statements
2. All indexes you would create and why
3. The query for "completion percentage for student Y in course X"

```sql
-- your schema and queries here
```

---

> 📁 Full solutions are in `sql-interview-answers.md`
