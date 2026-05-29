# SQL Interview Answers

> Each answer shows the query, explains the key concept, and flags common mistakes.  
> 🟢 Beginner · 🟡 Advanced · 🔴 Expert

---

## 🟢 Beginner

---

### B1 — Basic SELECT with ORDER BY

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    salary
FROM employees
ORDER BY salary DESC;
```

**Key concepts:**  
- `||` is PostgreSQL's string concatenation operator (`CONCAT()` also works).  
- `ORDER BY` defaults to `ASC`; always specify `DESC` explicitly for descending order.  
- Column aliases (`AS full_name`) apply *after* `SELECT` evaluates, so you cannot reference them in `WHERE` — but you *can* reference them in `ORDER BY` in PostgreSQL.

---

### B2 — Filtering with WHERE and a date condition

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    hire_date,
    salary
FROM employees
WHERE hire_date >= '2022-01-01'
ORDER BY hire_date;
```

**Key concepts:**  
- Date literals in PostgreSQL use ISO format `'YYYY-MM-DD'` — they are implicitly cast to `DATE`.  
- `>=` is inclusive; `> '2021-12-31'` is equivalent but less readable.  
- `BETWEEN '2022-01-01' AND '2023-12-31'` is inclusive on both ends.

---

### B3 — GROUP BY with COUNT

```sql
SELECT
    d.name       AS department,
    COUNT(e.id)  AS employee_count
FROM departments d
JOIN employees e ON e.department_id = d.id
GROUP BY d.name
ORDER BY employee_count DESC;
```

**Key concepts:**  
- Every non-aggregated column in `SELECT` **must** appear in `GROUP BY`.  
- `COUNT(e.id)` counts non-NULL values; `COUNT(*)` counts all rows including NULLs.  
- Using `JOIN` (not a subquery) is more readable and typically faster here.

---

### B4 — HAVING

```sql
SELECT
    d.name      AS department,
    COUNT(e.id) AS employee_count
FROM departments d
JOIN employees e ON e.department_id = d.id
GROUP BY d.name
HAVING COUNT(e.id) > 3
ORDER BY employee_count DESC;
```

**Key concept — WHERE vs HAVING:**  
- `WHERE` filters **rows before grouping** — it cannot reference aggregate functions.  
- `HAVING` filters **groups after aggregation** — it can use `COUNT()`, `SUM()`, etc.  
- Common mistake: `WHERE COUNT(e.id) > 3` → syntax error.

---

### B5 — INNER JOIN

```sql
SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    d.name                              AS department,
    d.location
FROM employees e
JOIN departments d ON d.id = e.department_id;
```

**Key concepts:**  
- `JOIN` (without a qualifier) means `INNER JOIN` — only rows with a match in **both** tables are returned.  
- Table aliases (`e`, `d`) are mandatory when column names are ambiguous across tables.  
- An employee without a `department_id` (NULL) would be **excluded** from the result.

---

### B6 — LEFT JOIN to find missing relationships

```sql
SELECT
    c.name,
    c.email,
    c.country
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;
```

**Key concept — anti-join pattern:**  
`LEFT JOIN ... WHERE right_table.id IS NULL` is the canonical "find rows with no match" pattern.  
After a LEFT JOIN, unmatched rows have NULL for all columns from the right table — filtering on `o.id IS NULL` keeps only those unmatched customers.

**Alternative using NOT EXISTS (often preferred by optimisers):**
```sql
SELECT c.name, c.email, c.country
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);
```

---

### B7 — Aggregate functions

```sql
SELECT
    MAX(salary)            AS highest_salary,
    MIN(salary)            AS lowest_salary,
    ROUND(AVG(salary), 2)  AS average_salary
FROM employees;
```

**Key concepts:**  
- `MAX`, `MIN`, `AVG`, `SUM`, `COUNT` are the five standard aggregates.  
- `ROUND(value, decimal_places)` controls precision.  
- All aggregates ignore `NULL` values (except `COUNT(*)` which counts everything).

---

### B8 — LIKE pattern matching

```sql
SELECT name, category, price
FROM products
WHERE name LIKE '%Pro%'
ORDER BY price DESC;
```

**Key concepts:**  
- `%` matches any sequence of characters (including empty).  
- `_` matches exactly one character.  
- `LIKE` is case-sensitive in PostgreSQL; use `ILIKE` for case-insensitive matching.  
- `WHERE name ILIKE '%pro%'` would also match "Laptop **pro**".  
- **Performance note:** Leading wildcard (`'%Pro'`) prevents index use — the database must scan every row.

---

### B9 — IN with a list of values

```sql
SELECT id, customer_id, order_date, total_amount, status
FROM orders
WHERE status IN ('shipped', 'delivered')
ORDER BY order_date;
```

**Key concepts:**  
- `IN ('a','b')` is shorthand for `status = 'a' OR status = 'b'`.  
- `NOT IN` is equivalent to `!= ALL(...)` — be careful: if the list contains a `NULL`, `NOT IN` returns no rows (because `x != NULL` is always UNKNOWN, not TRUE).

---

### B10 — BETWEEN

```sql
SELECT name, category, price
FROM products
WHERE price BETWEEN 20 AND 150
ORDER BY price ASC;
```

**Key concept:**  
`BETWEEN low AND high` is **inclusive** on both ends — equivalent to `price >= 20 AND price <= 150`.  
For date ranges, be careful: `BETWEEN '2023-01-01' AND '2023-12-31'` matches up to midnight on Dec 31, which misses the last day's records stored with timestamps. Prefer `>= '2023-01-01' AND < '2024-01-01'`.

---

### B11 — DISTINCT

```sql
SELECT DISTINCT country
FROM customers
ORDER BY country;
```

**Key concepts:**  
- `DISTINCT` deduplicates result rows — it applies to all selected columns together.  
- `SELECT DISTINCT country, city` deduplicates on the *combination* of country + city.  
- For counting unique values: `SELECT COUNT(DISTINCT country) FROM customers`.

---

### B12 — COUNT with a date filter

```sql
SELECT COUNT(*) AS orders_2023
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2024-01-01';
```

**Key concepts:**  
- `EXTRACT(YEAR FROM order_date) = 2023` also works but prevents index use on `order_date`.  
- The range approach (`>= start AND < next_year`) is index-friendly and handles all date/timestamp types correctly.

---

### B13 — SUM with a status filter

```sql
SELECT
    SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'delivered';
```

**Common interview follow-up:**  
*"What if total_amount can be NULL?"*  
`SUM` ignores NULLs — the result is still correct. But if you need to treat NULLs as zero: `SUM(COALESCE(total_amount, 0))`.

---

### B14 — COALESCE for NULL handling

```sql
SELECT
    first_name || ' ' || last_name      AS full_name,
    COALESCE(manager_id::TEXT, 'No Manager') AS manager
FROM employees;
```

**Key concepts:**  
- `COALESCE(a, b, c)` returns the first non-NULL argument.  
- `manager_id` is an `INT`; concatenating it into a string requires a cast (`::TEXT`) or use `CAST(manager_id AS TEXT)`.  
- `NULLIF(expr, value)` is the inverse: returns NULL when expr equals value (useful for "convert zero to NULL").

---

### B15 — Scalar subquery in WHERE

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    department_id,
    salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;
```

**Key concepts:**  
- A *scalar subquery* returns exactly one row and one column — it can appear anywhere a single value is expected.  
- The subquery here runs **once** and its result is reused for every row comparison (the planner materialises it).  
- If the subquery could return multiple rows, use `> ALL(subquery)` or `> ANY(subquery)`.

---

## 🟡 Advanced

---

### A1 — ROW_NUMBER window function

```sql
WITH ranked AS (
    SELECT
        d.name                                  AS department,
        e.first_name || ' ' || e.last_name      AS full_name,
        e.salary,
        ROW_NUMBER() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        )                                        AS rn
    FROM employees e
    JOIN departments d ON d.id = e.department_id
)
SELECT department, full_name, salary
FROM ranked
WHERE rn = 1
ORDER BY salary DESC;
```

**Key concepts:**  
- `OVER (PARTITION BY ... ORDER BY ...)` defines the window — rows are grouped by partition and ordered within each group.  
- `ROW_NUMBER()` assigns a unique integer even when salaries are tied (arbitrary tiebreak). Use `RANK()` or `DENSE_RANK()` if ties should share a rank.  
- Window functions are evaluated **after** `WHERE` and `GROUP BY`, so you **cannot** filter on the window result in the same `SELECT` — wrap it in a CTE or subquery first.

---

### A2 — RANK vs DENSE_RANK

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    salary,
    RANK()       OVER (ORDER BY salary DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
FROM employees
ORDER BY salary DESC;
```

**RANK vs DENSE_RANK explained:**

| Function       | Behaviour on ties                              | Gap after ties? |
|----------------|------------------------------------------------|-----------------|
| `RANK()`       | Tied rows get the same rank                    | **Yes** — next rank skips numbers |
| `DENSE_RANK()` | Tied rows get the same rank                    | **No** — ranks are always consecutive |

**Example with salaries $91k, $91k, $88k:**

| Name  | Salary | RANK | DENSE_RANK |
|-------|--------|------|------------|
| Hank  | 91000  | 1    | 1          |
| Steve | 91000  | 1    | 1          |
| Nathan| 88000  | **3**| **2**      |

`RANK` skips 2 because two rows tied for position 1. `DENSE_RANK` never skips.

**When to use which:**  
- Use `DENSE_RANK` when users expect "position 2" to always exist.  
- Use `RANK` when you need "how many rows ranked higher?"  
- Use `ROW_NUMBER` when you need a unique number regardless of ties.

---

### A3 — LAG for month-over-month comparison

```sql
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)  AS month,
        SUM(total_amount)                AS revenue
    FROM orders
    WHERE order_date >= '2023-01-01'
      AND order_date <  '2024-01-01'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                       AS month,
    ROUND(revenue, 2)                               AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2)    AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS change
FROM monthly
ORDER BY month;
```

**Key concepts:**  
- `DATE_TRUNC('month', date)` truncates a date to the first of the month — all dates in the same month get the same truncated value, enabling `GROUP BY`.  
- `LAG(col, n, default)` returns the value `n` rows *before* the current row within the window. Default is 1 row back.  
- `LEAD(col)` looks *forward* instead of backward — useful for "next period" comparisons.  
- The first month's `prev_month_revenue` will be `NULL` because there is no preceding row.

---

### A4 — Running total with SUM OVER

```sql
SELECT
    id                                                    AS order_id,
    order_date,
    ROUND(total_amount, 2)                                AS amount,
    ROUND(
        SUM(total_amount) OVER (ORDER BY order_date, id),
    2)                                                    AS running_total
FROM orders
ORDER BY order_date, id;
```

**Key concepts:**  
- `SUM(...) OVER (ORDER BY ...)` without `PARTITION BY` computes a running total over **all** rows.  
- The default window frame when `ORDER BY` is present is `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` — exactly what a running total needs.  
- Including `id` in the `ORDER BY` ensures a deterministic order when multiple orders share the same date.  
- To reset the running total per customer: `SUM(...) OVER (PARTITION BY customer_id ORDER BY order_date)`.

---

### A5 — CTE (Common Table Expression)

```sql
WITH dept_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    d.name                             AS department,
    e.salary,
    ROUND(da.avg_salary, 2)            AS dept_avg_salary
FROM employees e
JOIN departments d  ON d.id = e.department_id
JOIN dept_avg    da ON da.department_id = e.department_id
WHERE e.salary > da.avg_salary
ORDER BY d.name, e.salary DESC;
```

**Key concepts:**  
- A CTE (`WITH name AS (...)`) is a named subquery scoped to the statement. It makes complex queries readable by naming intermediate results.  
- Unlike a subquery in `FROM`, a CTE can be **referenced multiple times** in the same query.  
- CTEs in PostgreSQL are **not** automatically materialised (pre-computed) — the planner may inline them. To force materialisation: `WITH dept_avg AS MATERIALIZED (...)`.  
- Multiple CTEs are chained with commas: `WITH a AS (...), b AS (...) SELECT ...`.

---

### A6 — Correlated subquery

```sql
SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department_id = e.department_id   -- ← references outer query's row
)
ORDER BY e.department_id;
```

**Key concept — correlated subquery:**  
The subquery references `e.department_id` from the **outer** query. This means it re-executes for **every row** in the outer query — it is *correlated*. For large tables this can be slow (O(n) subquery executions).  

**Performance comparison:**  
- Correlated subquery: O(n) executions of the inner query.  
- Window function (`ROW_NUMBER`) solution: single pass over the data — generally faster.  
- Use correlated subqueries when the logic cannot be expressed with a join or window function.

---

### A7 — EXISTS

```sql
SELECT c.name, c.email
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
      AND o.total_amount > 500
);
```

**EXISTS vs IN — critical difference:**  
- `EXISTS` **short-circuits** — as soon as one matching row is found, it stops scanning.  
- `IN (subquery)` materialises the full subquery result first, then checks membership.  
- `EXISTS` is generally faster when the subquery would return many rows.  
- `EXISTS` handles `NULL` correctly; `NOT IN` with NULLs in the subquery returns **no rows** (common trap).

**Rule of thumb:**  
- Use `EXISTS` / `NOT EXISTS` for existence checks.  
- Use `IN` only for small, fixed lists of literal values.

---

### A8 — CASE WHEN salary banding

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    salary,
    CASE
        WHEN salary < 60000                      THEN 'Junior'
        WHEN salary >= 60000 AND salary < 100000 THEN 'Mid'
        ELSE                                          'Senior'
    END AS band
FROM employees
ORDER BY salary;
```

**Key concepts:**  
- `CASE WHEN ... THEN ... ELSE ... END` is SQL's if/else. Conditions are evaluated top-to-bottom; the first `TRUE` wins.  
- The `ELSE` clause covers all unmatched rows. Without it, unmatched rows return `NULL`.  
- `CASE` can appear in `SELECT`, `WHERE`, `ORDER BY`, and inside aggregate functions.

**Aggregate use — count per band:**
```sql
SELECT
    CASE WHEN salary < 60000  THEN 'Junior'
         WHEN salary < 100000 THEN 'Mid'
         ELSE 'Senior'
    END            AS band,
    COUNT(*)       AS headcount
FROM employees
GROUP BY band
ORDER BY headcount DESC;
```

---

### A9 — UNION vs UNION ALL

**Part A — Query:**

```sql
SELECT name AS person_name, 'customer' AS source
FROM customers

UNION ALL

SELECT first_name || ' ' || last_name, 'employee'
FROM employees

ORDER BY source, person_name;
```

**Part B — Written explanation:**

| Feature           | `UNION`                            | `UNION ALL`                          |
|-------------------|------------------------------------|--------------------------------------|
| Duplicates        | Removed (implicit `DISTINCT`)      | Kept — all rows included             |
| Performance       | Slower — requires sort + dedup     | Faster — no dedup step               |
| Use when          | You genuinely need distinct rows   | You know rows are unique, or you want all |

**Rules:**  
- Both queries must have the same number of columns.  
- Column types must be compatible (PostgreSQL will cast automatically in most cases).  
- `ORDER BY` at the end applies to the final combined result.

**Common mistake:** Using `UNION` (slower) when results are already distinct — always prefer `UNION ALL` unless deduplication is truly required.

---

### A10 — Detecting duplicates

```sql
SELECT
    email,
    COUNT(*) AS occurrences
FROM customers
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
```

**Key concept:**  
`HAVING COUNT(*) > 1` keeps only groups (emails) that appear more than once.  
To also see the full rows of duplicates:

```sql
SELECT *
FROM customers
WHERE email IN (
    SELECT email
    FROM customers
    GROUP BY email
    HAVING COUNT(*) > 1
)
ORDER BY email, id;
```

---

### A11 — PIVOT with CASE WHEN

```sql
SELECT
    COUNT(*) FILTER (WHERE status = 'pending')    AS pending,
    COUNT(*) FILTER (WHERE status = 'processing') AS processing,
    COUNT(*) FILTER (WHERE status = 'shipped')    AS shipped,
    COUNT(*) FILTER (WHERE status = 'delivered')  AS delivered,
    COUNT(*) FILTER (WHERE status = 'cancelled')  AS cancelled
FROM orders;
```

**Two approaches:**

**Option 1 — `FILTER` clause (PostgreSQL-specific, cleaner):**  
`COUNT(*) FILTER (WHERE condition)` counts only rows where the condition is true.

**Option 2 — `CASE WHEN` (ANSI SQL, portable):**
```sql
SELECT
    COUNT(CASE WHEN status = 'pending'    THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'processing' THEN 1 END) AS processing,
    COUNT(CASE WHEN status = 'shipped'    THEN 1 END) AS shipped,
    COUNT(CASE WHEN status = 'delivered'  THEN 1 END) AS delivered,
    COUNT(CASE WHEN status = 'cancelled'  THEN 1 END) AS cancelled
FROM orders;
```

`COUNT` ignores `NULL` — when the `CASE` condition is false it returns `NULL`, so only matching rows are counted.

---

### A12 — Self JOIN for hierarchy

```sql
SELECT
    e.first_name || ' ' || e.last_name          AS employee,
    COALESCE(m.first_name || ' ' || m.last_name,
             '— (no manager)')                  AS manager
FROM employees e
LEFT JOIN employees m ON m.id = e.manager_id
ORDER BY manager, employee;
```

**Key concept — self JOIN:**  
A table is joined to itself using two different aliases (`e` for employee, `m` for manager). The join condition `m.id = e.manager_id` links each employee to their manager row.  
`LEFT JOIN` is essential — without it, employees with `manager_id = NULL` would be excluded.

---

### A13 — Nth highest value without LIMIT

```sql
SELECT DISTINCT salary AS third_highest
FROM employees e1
WHERE 2 = (
    SELECT COUNT(DISTINCT salary)
    FROM employees e2
    WHERE e2.salary > e1.salary   -- how many salaries are strictly above e1.salary?
)
```

**How it works:**  
For the 3rd highest salary, we want rows where exactly **2** distinct salaries are greater.  
The correlated subquery counts how many distinct salaries are strictly higher than the current row's salary.  
When that count equals 2, the current row holds the 3rd highest value.

**Alternative — window function approach (cleaner):**
```sql
SELECT salary AS third_highest
FROM (
    SELECT DISTINCT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 3;
```

**`DENSE_RANK` is preferred over `RANK` here** because `RANK` would skip numbers on ties — `DENSE_RANK` ensures rank 3 is always the 3rd distinct salary.

---

### A14 — DELETE duplicates, keep one

```sql
DELETE FROM customers
WHERE id NOT IN (
    SELECT MIN(id)
    FROM customers
    GROUP BY email
);
```

**How it works:**  
`MIN(id)` per email group picks the keeper (lowest id). Any customer whose `id` is **not** the minimum for its email is deleted.

**Safer alternative using CTE (PostgreSQL):**
```sql
WITH keepers AS (
    SELECT MIN(id) AS keep_id
    FROM customers
    GROUP BY email
)
DELETE FROM customers
WHERE id NOT IN (SELECT keep_id FROM keepers);
```

**Always run a `SELECT` first to preview what will be deleted:**
```sql
SELECT * FROM customers
WHERE id NOT IN (SELECT MIN(id) FROM customers GROUP BY email);
```

---

### A15 — EXCEPT set operation

```sql
SELECT id AS product_id FROM products
EXCEPT
SELECT DISTINCT product_id FROM order_items
ORDER BY product_id;
```

**Set operation recap:**

| Operation   | Returns                                              |
|-------------|------------------------------------------------------|
| `UNION`     | Rows in A **or** B (deduped)                         |
| `INTERSECT` | Rows in A **and** B                                  |
| `EXCEPT`    | Rows in A that are **not** in B                      |

**Alternative using NOT EXISTS (often faster on large tables):**
```sql
SELECT p.id, p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.id
);
```

---

## 🔴 Expert

---

### E1 — Recursive CTE: full reporting chain

```sql
WITH RECURSIVE reports AS (
    -- Base case: the manager we start from
    SELECT id, first_name, last_name, manager_id, 0 AS depth
    FROM employees
    WHERE id = 1

    UNION ALL

    -- Recursive case: everyone who reports to someone already in the CTE
    SELECT e.id, e.first_name, e.last_name, e.manager_id, r.depth + 1
    FROM employees e
    JOIN reports r ON r.id = e.manager_id
)
SELECT
    depth,
    REPEAT('  ', depth) || first_name || ' ' || last_name AS name_indented,
    id
FROM reports
ORDER BY depth, id;
```

**How recursive CTEs work:**

```
WITH RECURSIVE name AS (
    base_case          ← runs once, seeds the result set
    UNION ALL
    recursive_case     ← runs repeatedly, joining result set to itself
                       ← stops when recursive_case returns 0 rows
)
```

**Infinite loop guard:** PostgreSQL stops recursion when the recursive term returns no new rows, but always ensure your join condition eventually terminates. Add `WHERE depth < 10` as a safety net during development.

**Inverse query — find all managers above a given employee:**
```sql
WITH RECURSIVE chain AS (
    SELECT id, first_name, last_name, manager_id, 0 AS level
    FROM employees WHERE id = 4   -- start from David Brown

    UNION ALL

    SELECT e.id, e.first_name, e.last_name, e.manager_id, c.level + 1
    FROM employees e
    JOIN chain c ON c.manager_id = e.id
)
SELECT level, first_name || ' ' || last_name AS name FROM chain ORDER BY level;
```

---

### E2 — Window frame: 3-day moving average

```sql
WITH daily AS (
    SELECT
        order_date,
        SUM(total_amount) AS daily_revenue
    FROM orders
    GROUP BY order_date
)
SELECT
    order_date,
    ROUND(daily_revenue, 2)                        AS daily_revenue,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
    2)                                              AS moving_avg_3d
FROM daily
ORDER BY order_date;
```

**Window frame syntax:**

```
ROWS BETWEEN <start> AND <end>

start / end can be:
  UNBOUNDED PRECEDING   — from the very first row in the partition
  N PRECEDING           — N rows before the current row
  CURRENT ROW           — the current row
  N FOLLOWING           — N rows after the current row
  UNBOUNDED FOLLOWING   — to the very last row in the partition
```

**`ROWS` vs `RANGE`:**  
- `ROWS` counts physical rows.  
- `RANGE` counts rows with the same `ORDER BY` value — e.g., `RANGE BETWEEN 1 PRECEDING AND CURRENT ROW` with dates would include all rows with the same or previous date, which can be unexpected. Use `ROWS` for moving averages.

---

### E3 — EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    d.name AS department,
    e.salary,
    ROUND(da.avg_salary, 2) AS dept_avg_salary
FROM employees e
JOIN departments d  ON d.id = e.department_id
JOIN dept_avg    da ON da.department_id = e.department_id
WHERE e.salary > da.avg_salary
ORDER BY d.name, e.salary DESC;
```

**Reading a query plan:**

```
Seq Scan on employees  (cost=0.00..1.19 rows=19 width=...)
                        (actual time=0.012..0.025 rows=19 loops=1)
```

| Field              | Meaning |
|--------------------|---------|
| `cost=start..total`| Planner's estimate: start-up cost and total cost in arbitrary units |
| `rows=N`           | Planner's **estimated** row count |
| `actual time`      | Real execution time in milliseconds |
| `actual rows`      | Real row count — compare to `rows=` estimate |
| `loops=N`          | How many times this node executed (>1 for nested loops) |

**Node types:**  
- `Seq Scan` — reads the entire table. Fine for small tables or when selecting most rows.  
- `Index Scan` — uses an index to find rows; follows heap pointers for each. Good for selective queries.  
- `Index Only Scan` — all needed columns are in the index; no heap access. Fastest.  
- `Hash Join` — builds a hash table from the smaller side, probes with the larger side. O(n+m).  
- `Nested Loop` — for each outer row, scans the inner. Fast when inner is indexed and outer is small.  
- `Sort` — required before `ORDER BY`, `MERGE JOIN`, or `DISTINCT`.

**Red flags to look for:**  
1. `estimated rows=5` but `actual rows=50000` — stale statistics, run `ANALYZE`.  
2. `Seq Scan` on a large table with a selective `WHERE` — missing index.  
3. `loops=10000` on a nested loop — likely a cartesian product or a correlated subquery running N times.

**Index that would help A5:**
```sql
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
```
This is a *covering index* for the `dept_avg` CTE join: Postgres can satisfy the query without hitting the table heap.

---

### E4 — Index design

**Part A — Indexes for the two query patterns:**

```sql
-- Pattern 1: WHERE customer_id = $1 AND status = 'delivered'
-- Composite index — put the equality column first, range/low-cardinality second
CREATE INDEX idx_orders_customer_status
    ON orders (customer_id, status);

-- Pattern 2: WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'
CREATE INDEX idx_orders_date
    ON orders (order_date);

-- Even better for pattern 1 if you only ever query delivered orders — partial index:
CREATE INDEX idx_orders_customer_delivered
    ON orders (customer_id)
    WHERE status = 'delivered';
```

**Part B — Written explanation:**

**B-tree vs Hash index:**

| Feature          | B-tree (default)            | Hash                           |
|------------------|-----------------------------|--------------------------------|
| Supports         | `=`, `<`, `>`, `BETWEEN`, `LIKE 'abc%'` | `=` only |
| WAL-logged       | Yes                         | Yes (since PG 10)              |
| When to use      | Almost always               | Only for pure equality on very high-cardinality columns |

**Composite index vs two single-column indexes:**  
A composite index `(customer_id, status)` satisfies `WHERE customer_id = 5 AND status = 'delivered'` with one index scan.  
Two separate indexes would require a *bitmap AND* of two index scans, which is less efficient.  
**Rule:** Create a composite index when queries consistently filter on both columns together. Put the **most selective** (or equality) column first.

**Partial index:**  
A partial index includes only rows matching a `WHERE` condition:
```sql
CREATE INDEX idx_orders_pending ON orders(order_date) WHERE status = 'pending';
```
If 90% of orders are `'delivered'` and only 10% are `'pending'`, this index is 10× smaller than a full index on `order_date`, fits in cache better, and updates are only triggered on rows that match the condition — significantly faster writes.

---

### E5 — Normalization

**Part A — Violations in `order_data`:**

- **1NF violation:** All columns are atomic, so 1NF is satisfied — but if `product_category` or `product_name` is a list, that would violate 1NF.  
- **2NF violation:** Non-key attributes depend on *part* of a composite key. Customer details (`customer_name`, `customer_email`, `customer_city`) depend only on `customer_id`, not on the full `(order_id, product_name)` composite key.  
- **3NF violation:** Transitive dependencies. `product_category` and `product_price` depend on `product_name`, not directly on `order_id`.

**Part B — Decomposed into 3NF:**

```sql
CREATE TABLE customers_3nf (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) UNIQUE,
    customer_city  VARCHAR(100)
);

CREATE TABLE products_3nf (
    product_id       SERIAL PRIMARY KEY,
    product_name     VARCHAR(150) NOT NULL,
    product_category VARCHAR(100),
    product_price    DECIMAL(10,2)
);

CREATE TABLE orders_3nf (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT REFERENCES customers_3nf(customer_id),
    order_date   DATE,
    order_status VARCHAR(50)
);

CREATE TABLE order_lines_3nf (
    order_id   INT REFERENCES orders_3nf(order_id),
    product_id INT REFERENCES products_3nf(product_id),
    quantity   INT,
    PRIMARY KEY (order_id, product_id)
);
```

**Why 3NF?**  
- Every non-key attribute depends on **the whole key** (2NF).  
- Every non-key attribute depends **only on the key** — no transitive dependencies (3NF).

**Part C — BCNF:**  
BCNF requires that every *determinant* is a candidate key. If `customer_email` uniquely identifies a customer (it's a candidate key), then `customer_email → customer_city` could violate BCNF unless `customer_email` is promoted to a candidate key. The schema above handles this with the `UNIQUE` constraint on `customer_email`.

---

### E6 — Deadlock scenario

**Part A — What is a deadlock?**

A deadlock occurs when two (or more) transactions each hold a lock that the other needs, creating a circular wait. Neither can proceed.

PostgreSQL detects deadlocks automatically by periodically checking for cycles in the lock wait graph (default check interval: `deadlock_timeout = 1s`). When detected, PostgreSQL **aborts one transaction** (the one that is cheapest to roll back) and returns error `ERROR: deadlock detected`.

**Part B — Example deadlock:**

```sql
-- Transaction A
BEGIN;
UPDATE employees SET salary = salary * 1.1 WHERE id = 1;  -- locks employee 1
-- ... waits ...
UPDATE orders    SET status = 'processing' WHERE id = 1;  -- needs orders lock
COMMIT;

-- Transaction B (runs concurrently)
BEGIN;
UPDATE orders    SET status = 'processing' WHERE id = 1;  -- locks order 1
-- ... waits ...
UPDATE employees SET salary = salary * 1.1 WHERE id = 1;  -- needs employee lock → DEADLOCK
COMMIT;
```

**Part C — Prevention: always acquire locks in the same order:**

```sql
-- Transaction A — lock employees first, then orders
BEGIN;
UPDATE employees SET salary = salary * 1.1 WHERE id = 1;
UPDATE orders    SET status = 'processing' WHERE id = 1;
COMMIT;

-- Transaction B — SAME ORDER: employees first, then orders
BEGIN;
UPDATE employees SET salary = salary * 1.1 WHERE id = 1;  -- will wait for A, not deadlock
UPDATE orders    SET status = 'processing' WHERE id = 1;
COMMIT;
```

**Other prevention strategies:**  
- Keep transactions short — the shorter the transaction, the less time locks are held.  
- Use `SELECT ... FOR UPDATE` at the start to take locks upfront in a deterministic order.  
- Use `LOCK TABLE` with the same table order across all transactions.  
- Retry logic in application code (deadlocks will still occasionally occur under high concurrency).

---

### E7 — JSON with JSONB

```sql
-- 1. Extract the 'brand' field from metadata for all Electronics products
SELECT
    name,
    metadata ->> 'brand'    AS brand
FROM products
WHERE category = 'Electronics';

-- 2. Find products where metadata color is 'black'
SELECT name, category, price
FROM products
WHERE metadata ->> 'color' = 'black';

-- 3. Find products where the features array contains 'SSD'
SELECT name, metadata
FROM products
WHERE metadata -> 'features' ? 'SSD';

-- 4. Update Laptop Pro 15 to add "on_sale": true to metadata
UPDATE products
SET metadata = metadata || '{"on_sale": true}'::jsonb
WHERE name = 'Laptop Pro 15';

-- Verify:
SELECT name, metadata -> 'on_sale' AS on_sale FROM products WHERE name = 'Laptop Pro 15';
```

**JSONB operator cheatsheet:**

| Operator        | Returns  | Meaning                                              |
|-----------------|----------|------------------------------------------------------|
| `->  'key'`     | `jsonb`  | Get value as JSON (use for nested JSON)              |
| `->> 'key'`     | `text`   | Get value as text (use for comparison/display)       |
| `-> 2`          | `jsonb`  | Get array element by index                           |
| `? 'key'`       | `boolean`| Does the key exist? / Does array contain value?      |
| `@> '{"k":"v"}'`| `boolean`| Does left JSON contain right JSON (containment)?     |
| `\|\|`          | `jsonb`  | Merge two JSON objects (right wins on key conflict)  |
| `- 'key'`       | `jsonb`  | Delete a key                                         |

**Why JSONB over JSON?**  
`JSONB` is stored in a decomposed binary format — it supports indexing (GIN, GiST) and operators like `?` and `@>`. `JSON` stores raw text and must be re-parsed on every access. Always use `JSONB` unless you need to preserve key ordering or duplicate keys.

**GIN index for fast JSONB queries:**
```sql
CREATE INDEX idx_products_metadata ON products USING GIN (metadata);
-- Speeds up operators: ?, ?|, ?&, @>
```

---

### E8 — Table partitioning

**Part A — Range-partitioned orders table:**

```sql
-- Parent table — no data is stored here directly
CREATE TABLE orders_partitioned (
    id           SERIAL,
    customer_id  INT,
    order_date   DATE NOT NULL,
    total_amount DECIMAL(12,2),
    status       VARCHAR(50)
) PARTITION BY RANGE (order_date);

-- Year partitions
CREATE TABLE orders_2022 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE orders_2023 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Default partition catches any rows outside defined ranges
CREATE TABLE orders_default PARTITION OF orders_partitioned DEFAULT;

-- Index on each partition (or use a global index on the parent)
CREATE INDEX ON orders_2023 (customer_id);
CREATE INDEX ON orders_2023 (order_date);
```

**Query against the partitioned table (looks identical):**
```sql
SELECT * FROM orders_partitioned
WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
-- PostgreSQL reads ONLY the orders_2023 partition — "partition pruning"
```

**Part B — Partitioning strategies:**

| Strategy | Key type         | Use when                                              |
|----------|------------------|-------------------------------------------------------|
| `RANGE`  | Continuous values (dates, integers) | Time-series data, log archives, billing by period |
| `LIST`   | Discrete values  | Status codes, region names, fixed categories         |
| `HASH`   | Any type         | Evenly distributing rows when no natural range/list exists |

**When partitioning helps:**  
- Tables > ~100M rows where queries consistently filter on the partition key.  
- Enables fast `DROP PARTITION` for archiving old data (vs slow `DELETE`).  
- Partition-wise joins and aggregates can parallelise work across partitions.

**When partitioning does NOT help:**  
- Queries that do not filter on the partition key (no pruning → full scan of all partitions).  
- Small tables — overhead exceeds benefits.  
- Heavy write workloads with random partition key values.

---

### E9 — Query optimization walkthrough

**Step 1 — Run EXPLAIN ANALYZE, look for:**
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT c.name, COUNT(o.id) AS order_count, SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'delivered'
  AND o.order_date >= '2023-01-01'
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 10;
```

Look for:
- `Seq Scan` on `orders` (50M rows) — the likely culprit at 40s.
- `actual rows` >> `estimated rows` — stale statistics.
- High `Buffers: shared hit/read` — data not in cache.

**Step 2 — Add indexes in priority order:**

```sql
-- Most impactful: composite index covering the WHERE clause
-- status first (equality = low cardinality, good selectivity)
-- order_date second (range scan)
CREATE INDEX idx_orders_status_date
    ON orders (status, order_date)
    WHERE status = 'delivered';   -- partial index — only 'delivered' rows (~30% of table)

-- If GROUP BY c.name creates a slow hash aggregate, help the join:
CREATE INDEX idx_orders_customer_id ON orders (customer_id);
-- (customers.id is already a PK, so it's indexed)
```

**Step 3 — Would a materialized view help?**  
Yes, if this is a dashboard query run frequently with the same `order_date` range:

```sql
CREATE MATERIALIZED VIEW mv_delivered_revenue AS
SELECT
    c.name,
    COUNT(o.id)         AS order_count,
    SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.name;

CREATE INDEX ON mv_delivered_revenue (revenue DESC);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_delivered_revenue;
-- Query time drops from 40s to <1ms — reads pre-aggregated data
```

**Step 4 — Query rewrites:**

```sql
-- Rewrite: push filtering into a CTE to reduce join size
WITH delivered AS (
    SELECT customer_id, SUM(total_amount) AS revenue, COUNT(*) AS cnt
    FROM orders
    WHERE status = 'delivered'
      AND order_date >= '2023-01-01'
    GROUP BY customer_id
)
SELECT c.name, d.cnt AS order_count, d.revenue
FROM delivered d
JOIN customers c ON c.id = d.customer_id
ORDER BY d.revenue DESC
LIMIT 10;
-- Aggregation happens before the join → smaller hash table → faster join
```

**Also run:**
```sql
ANALYZE orders;   -- refresh planner statistics
VACUUM orders;    -- reclaim dead tuples, update visibility map
```

---

### E10 — Schema design: e-learning platform

**Part 1 — CREATE TABLE statements:**

```sql
CREATE TABLE instructors (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) UNIQUE NOT NULL,
    bio        TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE courses (
    id            SERIAL PRIMARY KEY,
    instructor_id INT REFERENCES instructors(id),
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    published     BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT NOW()
);

CREATE TABLE lessons (
    id          SERIAL PRIMARY KEY,
    course_id   INT REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    content_url TEXT,
    position    INT NOT NULL,               -- lesson order within the course
    duration_s  INT,                        -- duration in seconds
    UNIQUE (course_id, position)            -- no two lessons share the same position in a course
);

CREATE TABLE students (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE enrollments (
    student_id  INT REFERENCES students(id),
    course_id   INT REFERENCES courses(id),
    enrolled_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lesson_progress (
    student_id   INT REFERENCES students(id),
    lesson_id    INT REFERENCES lessons(id),
    status       VARCHAR(20) DEFAULT 'not_started',  -- not_started | in_progress | completed
    completed_at TIMESTAMP,
    PRIMARY KEY (student_id, lesson_id)
);

CREATE TABLE reviews (
    id          SERIAL PRIMARY KEY,
    student_id  INT REFERENCES students(id),
    course_id   INT REFERENCES courses(id),
    rating      SMALLINT CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE (student_id, course_id)          -- one review per student per course
);
```

**Part 2 — Indexes and rationale:**

```sql
-- "All lessons for course X in order" — primary access pattern
CREATE INDEX idx_lessons_course_position ON lessons (course_id, position);

-- "Completion % for student Y in course X" — join lessons → lesson_progress
CREATE INDEX idx_lesson_progress_student ON lesson_progress (student_id, lesson_id);
CREATE INDEX idx_lesson_progress_status  ON lesson_progress (lesson_id, status);

-- "Average rating for course X" — frequent aggregate
CREATE INDEX idx_reviews_course ON reviews (course_id);

-- Dashboard: all courses a student is enrolled in
CREATE INDEX idx_enrollments_student ON enrollments (student_id);

-- Find all students in a course (admin queries)
CREATE INDEX idx_enrollments_course ON enrollments (course_id);
```

**Part 3 — Completion percentage query:**

```sql
-- Completion % for student 3 in course 2
SELECT
    s.name                                              AS student,
    c.title                                             AS course,
    COUNT(l.id)                                         AS total_lessons,
    COUNT(lp.lesson_id) FILTER (WHERE lp.status = 'completed')
                                                        AS completed_lessons,
    ROUND(
        100.0 * COUNT(lp.lesson_id) FILTER (WHERE lp.status = 'completed')
              / NULLIF(COUNT(l.id), 0),
    1)                                                  AS completion_pct
FROM enrollments e
JOIN students s  ON s.id = e.student_id
JOIN courses  c  ON c.id = e.course_id
JOIN lessons  l  ON l.course_id = e.course_id
LEFT JOIN lesson_progress lp
       ON lp.lesson_id = l.id AND lp.student_id = e.student_id
WHERE e.student_id = 3
  AND e.course_id  = 2
GROUP BY s.name, c.title;
```

**Key design decisions explained:**

| Decision | Why |
|---|---|
| `lessons.position` + `UNIQUE(course_id, position)` | Enforces lesson ordering at DB level; no gaps handled by app |
| `PRIMARY KEY (student_id, course_id)` on enrollments | Prevents double-enrollment without application-level check |
| `UNIQUE (student_id, course_id)` on reviews | One review per student per course enforced at DB level |
| `ON DELETE CASCADE` on lessons | Deleting a course automatically removes its lessons |
| `NULLIF(COUNT(l.id), 0)` | Prevents division-by-zero if a course has no lessons |
| `FILTER (WHERE status = 'completed')` | Counts only completed lessons without a separate subquery |

---

> 📁 Questions are in `sql-interview-questions.md`
