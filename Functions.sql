CREATE OR REPLACE FUNCTION calculate_order_total(p_order_id int)
RETURNS numeric AS $$
    SELECT SUM(quantity*price) FROM order_items
    WHERE order_id = p_order_id;
$$ LANGUAGE sql;
---

CREATE OR REPLACE PROCEDURE create_order(p_customer_id int)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    INSERT INTO orders (customer_id, order_date, total_amount)
    VALUES (p_customer_id, NOW(), 0);
END;
$$;

CREATE OR REPLACE PROCEDURE add_product_to_order(p_order_id int,
                                                 p_product_id int,
                                                 p_quantity int
                                                 )
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_quantity int;
    v_price numeric;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity is leq 0';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM products
        WHERE product_id=p_product_id
    ) THEN
        RAISE EXCEPTION 'Product does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM orders
        WHERE order_id=p_order_id
    ) THEN
        RAISE EXCEPTION 'Order does not exist';
    END IF;


    SELECT stock_quantity, price
    INTO v_stock_quantity, v_price
    FROM products
    WHERE product_id = p_product_id;

    if v_stock_quantity<p_quantity THEN
        RAISE EXCEPTION 'Not enough stock';
    END IF;
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);
    UPDATE products
    SET stock_quantity = stock_quantity-p_quantity
    WHERE product_id = p_product_id;
END;
$$;



CREATE OR REPLACE FUNCTION update_order_total()
RETURNS trigger AS $$
DECLARE
    v_order_id int;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_order_id := OLD.order_id;
    ELSE
        v_order_id := NEW.order_id;
    END IF;

    UPDATE orders
    SET total_amount = calculate_order_total(v_order_id)
    WHERE order_id = v_order_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_order_log()
RETURNS trigger AS $$
BEGIN
    INSERT INTO order_log (order_id, customer_id, action, log_date)
    VALUES (NEW.order_id, NEW.customer_id, 'Created new order', NOW());
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trg_total_amount
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

CREATE OR REPLACE TRIGGER trg_order_created
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_log();
