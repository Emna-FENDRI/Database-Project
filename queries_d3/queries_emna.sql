--DELIV 3
 --3.Find the top-10 vehicle makes based on the number of victims who suffered either a severe injury or were killed. 
--List both the vehicle make and their corresponding number of victims.

SELECT  c.vehicle_make, COUNT(*) AS victims 
FROM parties P , victims V, vehicles C
WHERE P.case_id = V.case_id AND P.party_number = V.party_number 
        AND   C.vehicle_id = P.vehicle_id 
        AND c.vehicle_make is not null
        AND (V.victim_degree_of_injury = 'severe injury'  OR V.victim_degree_of_injury = 'killed' )
GROUP BY  c.vehicle_make
ORDER BY victims DESC
FETCH FIRST 10 ROWS ONLY;



-- 6 .For each of the top-3 most populated cities, show the city location, population, and the bottom-10
--collisions in terms of average victim age (show collision id and average victim age).


WITH cities AS 
(SELECT DISTINCT L.county_city_location AS city_location , l.location_population AS population
FROM collisions C , locations L 
WHERE C.location_id = L.location_id  AND L.location_population BETWEEN 1 AND 7
ORDER BY L.location_population DESC
FETCH FIRST 3 ROWS ONLY),

B AS (
SELECT  T.city_location AS city_location , C.case_id AS case_id , AVG(victim_age) AS average_victim_age 
FROM victims V, collisions C , locations L , cities T
WHERE V.case_id = C.case_id AND C.location_id = L.location_id AND  L.county_city_location = T.city_location AND V.victim_age is not null
group by T.city_location , C.case_id
ORDER BY T.city_location, average_victim_age
),

rws AS (
SELECT B.city_location, B.case_id , B.average_victim_age, 
        rank() over (
        partition by B.city_location
        order by  B.average_victim_age, B.case_id) rn
FROM  B
),

rws_selected AS (
SELECT * 
FROM rws
WHERE  rn <= 10) 

SELECT C.city_location, C.population , R.case_id , R.average_victim_age
FROM rws_selected R , cities C
WHERE R.city_location = C.city_location;


-- 9. Find the top-10 (with respect to number of collisions) cities. For each of these cities, show the city
--location and number of collisions.
SELECT L.county_city_location  AS city_location , count(*) AS number_of_collisions
FROM collisions C, Locations L 
WHERE C.location_id = L.location_id
GROUP BY L.county_city_location 
ORDER BY number_of_collisions DESC
FETCH FIRST 10 ROWS ONLY;