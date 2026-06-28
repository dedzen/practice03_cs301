This practice has 3 sql scripts.
- CreateDB.sql
    - Drops the previous schema
    - Creates tables up to specification
- Functions.sql
    - Declares functions, procedures
    - Adds needed ones as triggers
- Demo.sql
    - Creates a few customers and products
    - Creates an order for customer 1
    - Queries orders and order_log for checks
    - Adds products to order 1
    - Queries product table to see stock reduction
    - Add another product to order 1
    - Queries orders table to see total_amount increase

There isn't a lot of sense in explaining what functions and procedures do here, they are pretty easy.
They raise an error if conditions aren't met, e.g. stock is negative.
