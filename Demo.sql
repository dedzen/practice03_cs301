
INSERT INTO customers (full_name, email, balance)
VALUES
('John', 'email', 25),
('Bob', 'bmal', 35),
('Sob', 'zmail', 45),
('Lob', 'snail', 15),
('Snob', 'vail', 65),
('Mor', 'mail', 75);

INSERT INTO products (product_id, product_name, price, stock_quantity)
VALUES 
(1, 'Keyboard', 50, 10),
(2, 'Mouse', 20, 5);

CALL create_order(1);
SELECT * FROM orders;
SELECT * FROM order_log;

\echo ===============;

CALL add_product_to_order(1, 1, 2); 
CALL add_product_to_order(1, 2, 1);
SELECT * FROM order_items;
SELECT * FROM orders;
\echo stock is less now;
SELECT * FROM products;
CALL add_product_to_order(1, 1, 1);
\echo amount just increased
SELECT total_amount FROM orders WHERE order_id = 1;

