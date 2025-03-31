-----------------------1-----------------------------
SELECT 
    c.ID_customer, 
    c.name, 
    c.email, 
    c.phone, 
    COUNT(b.ID_booking) AS total_bookings,
    COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS hotel_list,
    ROUND(AVG(DATEDIFF(b.check_out_date, b.check_in_date)), 2) AS avg_stay_days
FROM Booking b
JOIN Customer c ON b.ID_customer = c.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer
HAVING total_bookings > 2 AND unique_hotels > 1
ORDER BY total_bookings DESC;
-----------------------2-----------------------------
WITH customer_spending AS (
    SELECT 
        b.ID_customer, 
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT r.ID_hotel) AS unique_hotels,
        SUM(DATEDIFF(b.check_out_date, b.check_in_date) * r.price) AS total_spent
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    GROUP BY b.ID_customer
),
filtered_customers AS (
    SELECT * FROM customer_spending
    WHERE total_bookings > 2 AND unique_hotels > 1
)
SELECT 
    fc.ID_customer, 
    fc.name, 
    fc.total_bookings, 
    fc.total_spent, 
    fc.unique_hotels
FROM filtered_customers fc
WHERE fc.total_spent > 500
ORDER BY fc.total_spent ASC;

-----------------------3-----------------------------
WITH hotel_categories AS (
    SELECT 
        h.ID_hotel, 
        h.name, 
        CASE 
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Room r
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY h.ID_hotel
),
customer_preferences AS (
    SELECT 
        b.ID_customer, 
        c.name,
        GROUP_CONCAT(DISTINCT hc.hotel_category ORDER BY hc.hotel_category DESC SEPARATOR ', ') AS category_list,
        GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS visited_hotels
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN hotel_categories hc ON h.ID_hotel = hc.ID_hotel
    GROUP BY b.ID_customer
)
SELECT 
    ID_customer, 
    name,
    CASE 
        WHEN category_list LIKE '%Дорогой%' THEN 'Дорогой'
        WHEN category_list LIKE '%Средний%' THEN 'Средний'
        ELSE 'Дешевый'
    END AS preferred_hotel_type,
    visited_hotels
FROM customer_preferences
ORDER BY 
    FIELD(preferred_hotel_type, 'Дешевый', 'Средний', 'Дорогой');
