-- Retrieve the first 10 films with their IDs, titles, and release years
SELECT film_id, title, release_year
FROM film
LIMIT 10;

-- Count the total number of customers
SELECT COUNT(*) AS total_customers
FROM customer;

-- Get titles of films released in 2006
SELECT title
FROM film
WHERE release_year = 2006;

-- Retrieve customers whose last names start with 'S'
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name LIKE 'S%';

-- Get the top 5 longest films
SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 5;

-- Retrieve the 5 most recent rentals
SELECT rental_id, rental_date, customer_id
FROM rental
ORDER BY rental_date DESC
LIMIT 5;

-- Find actors in the film 'Academy Dinosaur'
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Academy Dinosaur';

-- Get customer and rented film details
SELECT c.customer_id, c.first_name, c.last_name, f.title
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;

-- Calculate total revenue from payments
SELECT SUM(p.amount) AS total_revenue
FROM payment p;

-- Count films in each category
SELECT c.name AS category_name, COUNT(f.film_id) AS film_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY c.name;

-- Retrieve customers with more than 30 rentals
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.customer_id IN (
    SELECT r.customer_id
    FROM rental r
    GROUP BY r.customer_id
    HAVING COUNT(r.rental_id) > 30
);

-- Get films not rented
SELECT f.title
FROM film f
WHERE f.film_id NOT IN (
    SELECT i.film_id
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
);

-- Categorize films based on length
SELECT title, length,
    CASE
        WHEN length < 60 THEN 'Short'
        WHEN length BETWEEN 60 AND 120 THEN 'Medium'
        ELSE 'Long'
    END AS length_category
FROM film;

-- Insert a new customer
INSERT INTO customer (
    store_id, 
    first_name, 
    last_name, 
    email, 
    address_id, 
    active, 
    create_date, 
    last_update
) VALUES (
    1, 'John', 'Doe', 'johndoe@example.com', 123, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

-- Insert a new film
INSERT INTO film (
    title, 
    description, 
    release_year, 
    language_id, 
    rental_duration, 
    rental_rate, 
    length, 
    replacement_cost, 
    rating, 
    special_features, 
    last_update
) VALUES (
    'Adventures of Space', 
    'A thrilling journey through the galaxy.', 
    2023, 1, 7, 4.99, 120, 19.99, 'PG', 'Behind the Scenes, Trailers', CURRENT_TIMESTAMP
);

-- Update a customer's email
UPDATE customer
SET email = 'mary.newmail@gmail.com', 
    last_update = CURRENT_TIMESTAMP
WHERE first_name = 'MARY' 
  AND last_name = 'SMITH';

-- Update rental rates for long films
SET SQL_SAFE_UPDATES = 0;
UPDATE film
SET rental_rate = 4.99, 
    last_update = CURRENT_TIMESTAMP
WHERE length > 120;
SET SQL_SAFE_UPDATES = 1;

-- Delete customers without rentals
SET SQL_SAFE_UPDATES = 0;
DELETE FROM customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM rental
);
SET SQL_SAFE_UPDATES = 1;

-- Delete films released before 2000
SET SQL_SAFE_UPDATES = 0;
DELETE FROM film
WHERE release_year < 2000;
SET SQL_SAFE_UPDATES = 1;

-- Get the top 10 customers by number of rentals
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS numberOfRented
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY numberOfRented DESC
LIMIT 10;

-- Calculate total revenue by category
SELECT c.name AS category_name, SUM(p.amount) AS total_revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.category_id
ORDER BY c.name;

-- Identify the busiest rental month
SELECT 
    MONTHNAME(rental_date) AS busiest_month, 
    COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY MONTHNAME(rental_date)
ORDER BY COUNT(rental_id) DESC;

-- Create a view for customer rentals
CREATE VIEW customer_rentals AS
SELECT
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    f.title AS film_title, 
    r.rental_date
FROM
    customer c
JOIN
    rental r ON c.customer_id = r.customer_id
JOIN
    inventory i ON r.inventory_id = i.inventory_id
JOIN
    film f ON i.film_id = f.film_id;

-- Create a view for revenue by category
CREATE VIEW category_revenue AS
SELECT
    cat.name AS category_name,
    SUM(p.amount) AS total_revenue
FROM
    category cat
JOIN
    film_category fc ON cat.category_id = fc.category_id
JOIN
    film f ON fc.film_id = f.film_id
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
JOIN
    payment p ON r.rental_id = p.rental_id
GROUP BY
    cat.name;

-- Create indexes for optimization
CREATE INDEX idx_film_title ON film (title);
CREATE INDEX idx_rental_date ON rental (rental_date);

-- Create a stored procedure for retrieving customer rentals
DELIMITER $$
CREATE PROCEDURE get_customer_rentals (IN p_customer_id INT)
BEGIN
    SELECT 
        f.title AS movie_title,
        r.rental_date,
        r.return_date,
        r.inventory_id
    FROM 
        rental r
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        film f ON i.film_id = f.film_id
    WHERE 
        r.customer_id = p_customer_id
    ORDER BY 
        r.rental_date DESC;
END$$
DELIMITER;
