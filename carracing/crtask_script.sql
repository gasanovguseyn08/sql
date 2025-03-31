-------------------1--------------------------
SELECT c1.name AS car_name, 
       c1.class, 
       AVG(r.position) AS avg_position, 
       COUNT(r.race) AS race_count
FROM Cars c1
JOIN Results r ON c1.name = r.car
GROUP BY c1.name, c1.class
HAVING AVG(r.position) = (
    SELECT MIN(avg_position)
    FROM (
        SELECT c2.class, AVG(r2.position) AS avg_position
        FROM Cars c2
        JOIN Results r2 ON c2.name = r2.car
        GROUP BY c2.name, c2.class
    ) AS ClassAvg
    WHERE ClassAvg.class = c1.class
)
ORDER BY avg_position;

-------------------2--------------------------
SELECT c.name AS car_name, 
       c.class, 
       cl.country,
       AVG(r.position) AS avg_position, 
       COUNT(r.race) AS race_count
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
GROUP BY c.name, c.class, cl.country
ORDER BY avg_position ASC, c.name ASC
LIMIT 1;
-------------------3--------------------------
SELECT c.name AS car_name, 
       c.class, 
       cl.country, 
       AVG(r.position) AS avg_position, 
       COUNT(r.race) AS race_count,
       (SELECT COUNT(*) FROM Results r2 JOIN Cars c2 ON r2.car = c2.name WHERE c2.class = c.class) AS total_races
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
GROUP BY c.name, c.class, cl.country
HAVING (SELECT AVG(position) FROM Results r2 JOIN Cars c2 ON r2.car = c2.name WHERE c2.class = c.class) = 
       (SELECT MIN(class_avg_position) 
        FROM (SELECT c3.class, AVG(r3.position) AS class_avg_position 
              FROM Cars c3 
              JOIN Results r3 ON c3.name = r3.car 
              GROUP BY c3.class) AS MinClass)
ORDER BY avg_position;
-------------------4--------------------------
SELECT c1.name AS car_name, 
       c1.class, 
       cl.country, 
       AVG(r1.position) AS avg_position, 
       COUNT(r1.race) AS race_count
FROM Cars c1
JOIN Results r1 ON c1.name = r1.car
JOIN Classes cl ON c1.class = cl.class
WHERE (SELECT COUNT(DISTINCT c2.name) FROM Cars c2 WHERE c2.class = c1.class) >= 2
GROUP BY c1.name, c1.class, cl.country
HAVING avg_position < (
    SELECT AVG(r2.position) 
    FROM Cars c2
    JOIN Results r2 ON c2.name = r2.car
    WHERE c2.class = c1.class
)
ORDER BY c1.class, avg_position;
-------------------5--------------------------
SELECT c.name AS car_name, 
       c.class, 
       cl.country, 
       AVG(r.position) AS avg_position, 
       COUNT(r.race) AS race_count,
       (SELECT COUNT(*) FROM Cars c2 
        WHERE c2.class = c.class 
        AND (SELECT AVG(r2.position) FROM Results r2 WHERE r2.car = c2.name) > 3.0) AS num_low_rank_cars,
       (SELECT COUNT(*) FROM Results r3 
        JOIN Cars c3 ON r3.car = c3.name 
        WHERE c3.class = c.class) AS total_races
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
GROUP BY c.name, c.class, cl.country
HAVING avg_position > 3.0
ORDER BY num_low_rank_cars DESC;
