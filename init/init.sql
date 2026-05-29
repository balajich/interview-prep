-- =============================================================================
-- SQL Interview Practice Schema
-- Database: interviewdb
-- =============================================================================
-- Tables:
--   departments   — company departments
--   employees     — staff with salaries and manager relationships
--   customers     — people who buy products
--   products      — catalogue items
--   orders        — customer purchase orders
--   order_items   — individual line items within an order
-- =============================================================================

-- ── Schema ────────────────────────────────────────────────────────────────────

CREATE TABLE departments (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    budget   DECIMAL(15,2),
    location VARCHAR(100)
);

CREATE TABLE employees (
    id            SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)    NOT NULL,
    last_name     VARCHAR(50)    NOT NULL,
    department_id INT            REFERENCES departments(id),
    salary        DECIMAL(10,2),
    hire_date     DATE,
    manager_id    INT            REFERENCES employees(id)   -- self-referencing for hierarchy
);

CREATE TABLE customers (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150),
    city       VARCHAR(100),
    country    VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    category       VARCHAR(100),
    price          DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    metadata       JSONB          -- used in expert JSON questions
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INT  REFERENCES customers(id),
    order_date   DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(12,2),
    status       VARCHAR(50) DEFAULT 'pending'
    -- status values: pending | processing | shipped | delivered | cancelled
);

CREATE TABLE order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INT REFERENCES orders(id),
    product_id INT REFERENCES products(id),
    quantity   INT,
    unit_price DECIMAL(10,2)
);

-- ── Seed data ─────────────────────────────────────────────────────────────────

-- Departments
INSERT INTO departments (name, budget, location) VALUES
    ('Engineering',  1500000.00, 'New York'),
    ('Marketing',     800000.00, 'Los Angeles'),
    ('Sales',        1200000.00, 'Chicago'),
    ('HR',            400000.00, 'New York'),
    ('Finance',       600000.00, 'Chicago'),
    ('Operations',    900000.00, 'Austin');

-- Employees (manager_id set afterwards for circular reference)
INSERT INTO employees (first_name, last_name, department_id, salary, hire_date) VALUES
    ('Alice',   'Johnson',   1, 120000.00, '2019-03-15'),   -- id 1  (Engineering manager)
    ('Bob',     'Smith',     1,  95000.00, '2020-06-01'),   -- id 2
    ('Carol',   'Williams',  1,  87000.00, '2021-01-10'),   -- id 3
    ('David',   'Brown',     1,  72000.00, '2022-08-22'),   -- id 4
    ('Eve',     'Davis',     2, 105000.00, '2018-11-30'),   -- id 5  (Marketing manager)
    ('Frank',   'Miller',    2,  68000.00, '2021-04-18'),   -- id 6
    ('Grace',   'Wilson',    3, 130000.00, '2017-07-05'),   -- id 7  (Sales manager)
    ('Hank',    'Moore',     3,  91000.00, '2020-02-14'),   -- id 8
    ('Ivy',     'Taylor',    3,  78000.00, '2021-09-01'),   -- id 9
    ('Jack',    'Anderson',  3,  65000.00, '2022-11-15'),   -- id 10
    ('Karen',   'Thomas',    4,  55000.00, '2020-05-20'),   -- id 11
    ('Leo',     'Jackson',   4,  48000.00, '2021-07-07'),   -- id 12
    ('Mia',     'White',     5, 115000.00, '2019-01-08'),   -- id 13 (Finance manager)
    ('Nathan',  'Harris',    5,  88000.00, '2020-10-12'),   -- id 14
    ('Olivia',  'Martin',    6,  77000.00, '2021-03-25'),   -- id 15
    ('Paul',    'Garcia',    6,  61000.00, '2022-06-30'),   -- id 16
    ('Quinn',   'Martinez',  1,  43000.00, '2023-02-01'),   -- id 17 (junior engineer)
    ('Rachel',  'Robinson',  2,  43000.00, '2023-03-15'),   -- id 18 (duplicate salary for RANK demo)
    ('Steve',   'Clark',     3,  91000.00, '2023-04-01');   -- id 19 (same salary as Hank)

-- Set manager relationships
UPDATE employees SET manager_id = 1  WHERE id IN (2, 3, 4, 17);   -- Alice manages Engineering
UPDATE employees SET manager_id = 5  WHERE id IN (6, 18);          -- Eve manages Marketing
UPDATE employees SET manager_id = 7  WHERE id IN (8, 9, 10, 19);  -- Grace manages Sales
UPDATE employees SET manager_id = 13 WHERE id IN (14);             -- Mia manages Finance

-- Customers
INSERT INTO customers (name, email, city, country) VALUES
    ('Liam Walker',    'liam@example.com',   'New York',    'USA'),
    ('Emma Brown',     'emma@example.com',   'London',      'UK'),
    ('Noah Chen',      'noah@example.com',   'Toronto',     'Canada'),
    ('Ava Patel',      'ava@example.com',    'Mumbai',      'India'),
    ('Oliver Scott',   'oliver@example.com', 'Sydney',      'Australia'),
    ('Sophia Kim',     'sophia@example.com', 'Seoul',       'South Korea'),
    ('James Lee',      'james@example.com',  'New York',    'USA'),
    ('Isabella Cruz',  'isabella@example.com','Mexico City','Mexico'),
    ('William Nguyen', 'william@example.com','Houston',     'USA'),
    ('Mia Rossi',      'mia@example.com',    'Rome',        'Italy'),
    ('Ghost User',     'emma@example.com',   'London',      'UK'),   -- duplicate email for Q10
    ('No Orders',      'noorders@example.com','Paris',      'France');-- customer with no orders

-- Products
INSERT INTO products (name, category, price, stock_quantity, metadata) VALUES
    ('Laptop Pro 15',      'Electronics',  1299.99,  45, '{"brand":"TechCo","warranty_years":2,"features":["SSD","16GB RAM"]}'),
    ('Wireless Mouse',     'Electronics',    29.99, 200, '{"brand":"PeriphCo","color":"black"}'),
    ('Mechanical Keyboard','Electronics',   149.99,  80, '{"brand":"TypePro","color":"white","switches":"blue"}'),
    ('USB-C Hub',          'Electronics',    49.99, 120, '{"brand":"ConnectCo","ports":7}'),
    ('Standing Desk',      'Furniture',     499.99,  15, '{"brand":"ErgoDesk","adjustable":true,"weight_kg":35}'),
    ('Ergonomic Chair',    'Furniture',     349.99,  20, '{"brand":"ComfortSit","lumbar_support":true}'),
    ('Notebook A5',        'Stationery',      4.99, 500, '{"brand":"PaperCo","pages":120,"lined":true}'),
    ('Ballpoint Pen Set',  'Stationery',      9.99, 800, '{"brand":"InkCo","count":12,"colors":["blue","red","black"]}'),
    ('Coffee Maker',       'Appliances',    129.99,  35, '{"brand":"BrewMaster","cups":12}'),
    ('Water Bottle',       'Accessories',    24.99, 300, '{"brand":"HydroFlask","capacity_ml":750,"color":"blue"}'),
    ('Monitor 27"',        'Electronics',   399.99,  30, '{"brand":"ViewCo","resolution":"4K","hz":144}'),
    ('Out of Stock Item',  'Electronics',    99.99,   0, '{"brand":"SoldOut"}');  -- for stock queries

-- Orders
INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
    (1, '2023-01-15', 1329.98, 'delivered'),
    (1, '2023-03-22',  179.98, 'delivered'),
    (2, '2023-02-10',  499.99, 'delivered'),
    (3, '2023-02-28',  549.98, 'shipped'),
    (3, '2023-05-10',   34.98, 'delivered'),
    (4, '2023-04-05', 1649.98, 'delivered'),
    (5, '2023-04-18',   79.98, 'processing'),
    (6, '2023-05-30',  399.99, 'shipped'),
    (7, '2023-06-12',  149.99, 'delivered'),
    (8, '2023-06-25',  524.98, 'cancelled'),
    (1, '2023-07-04',   49.99, 'delivered'),
    (2, '2023-07-20', 1299.99, 'delivered'),
    (9, '2023-08-01',  474.98, 'delivered'),
    (10,'2023-08-15',  129.99, 'shipped'),
    (3, '2023-09-03',  349.99, 'pending'),
    (4, '2023-09-19',   24.99, 'delivered'),
    (5, '2023-10-07',  499.99, 'delivered'),
    (6, '2023-10-22',  159.98, 'processing'),
    (7, '2023-11-05',  399.99, 'delivered'),
    (1, '2023-11-20', 1799.97, 'delivered'),
    (2, '2023-12-01',  174.98, 'shipped'),
    (9, '2023-12-10',  649.98, 'delivered'),
    (10,'2024-01-05',  299.99, 'delivered'),
    (1, '2024-01-18',   54.98, 'delivered'),
    (3, '2024-02-02',  899.98, 'shipped');

-- Order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1,  1, 1, 1299.99), (1,  2, 1,   29.99),
    (2,  3, 1,  149.99), (2,  2, 1,   29.99),
    (3,  5, 1,  499.99),
    (4,  4, 1,   49.99), (4,  9, 1,  129.99), (4, 11, 1, 399.99),
    (5,  7, 2,    4.99), (5,  8, 1,    9.99), (5,  2, 1,  29.99),
    (6,  1, 1, 1299.99), (6,  6, 1,  349.99),
    (7,  2, 1,   29.99), (7, 10, 2,   24.99),
    (8, 11, 1,  399.99),
    (9,  3, 1,  149.99),
    (10, 5, 1,  499.99), (10, 2, 1,   29.99),
    (11, 4, 1,   49.99),
    (12, 1, 1, 1299.99),
    (13, 6, 1,  349.99), (13, 2, 1,   29.99), (13, 4, 1,  49.99),  (13,10,1,24.99),
    (14, 9, 1,  129.99),
    (15, 6, 1,  349.99),
    (16,10, 1,   24.99),
    (17, 5, 1,  499.99),
    (18, 3, 1,  149.99), (18, 2, 1,    9.99),
    (19,11, 1,  399.99),
    (20, 1, 1, 1299.99), (20, 4, 1,   49.99), (20, 6, 1, 349.99), (20,10,1,24.99), (20,2,1,29.99),
    (21, 3, 1,  149.99), (21, 2, 1,   24.99),
    (22, 1, 1, 1299.99), (22, 4, 1,   49.99), (22,10,1,24.99),    (22,7,1,4.99),   (22,8,1,9.99),
    (23,11, 1,  399.99), (23, 9, 1,  129.99),  (23,10,1,24.99),
    (24, 7, 3,    4.99), (24, 8, 1,   9.99),   (24, 2, 1, 29.99),
    (25, 1, 1, 1299.99), (25, 2, 1,   29.99);

-- ── Useful views for reference ─────────────────────────────────────────────────

CREATE VIEW employee_details AS
SELECT
    e.id,
    e.first_name || ' ' || e.last_name        AS full_name,
    d.name                                     AS department,
    e.salary,
    e.hire_date,
    m.first_name || ' ' || m.last_name        AS manager_name
FROM employees e
JOIN departments d ON d.id = e.department_id
LEFT JOIN employees m ON m.id = e.manager_id;

-- ── Verification ──────────────────────────────────────────────────────────────
-- Run this to confirm seed data loaded:
-- SELECT 'departments' AS tbl, COUNT(*) FROM departments
-- UNION ALL SELECT 'employees',  COUNT(*) FROM employees
-- UNION ALL SELECT 'customers',  COUNT(*) FROM customers
-- UNION ALL SELECT 'products',   COUNT(*) FROM products
-- UNION ALL SELECT 'orders',     COUNT(*) FROM orders
-- UNION ALL SELECT 'order_items',COUNT(*) FROM order_items;
