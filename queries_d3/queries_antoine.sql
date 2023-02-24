--1. for drivers of the following groups :
-- - underaged : [0, 18]
-- - young I : [19, 21]
-- - young II : [22, 24]
-- - adult : [24, 60]
-- - elder II : [61, 65]
-- - elder II : [66, +inf]
-- find the ratio of cases where the party was at fault
-- show the ratio as percentage and display it for every
-- group 

-- with CLASSES as (SELECT P.at_fault, P.party_id, 
--     CASE WHEN P.party_age BETWEEN 16 AND 18 THEN 'underaged'
--          WHEN P.party_age BETWEEN 19 AND 21 THEN 'young I'
--          WHEN P.party_age BETWEEN 22 AND 24 THEN 'young II'
--          WHEN P.party_age BETWEEN 25 AND 60 THEN 'adult'
--          WHEN P.party_age BETWEEN 61 AND 65 THEN 'elder I'
--          ELSE 'elder II' 
--     END AS range
--     FROM PARTIES P),

-- AT_FAULT as (SELECT C.range, COUNT(C.party_id) as at_fault_cases
-- FROM CLASSES C
-- WHERE C.at_fault == 1
-- GROUP BY C.range),

-- TOTALS as (SELECT C.range, COUNT(C.party_id) as total_cases
-- FROM CLASSES C
-- GROUP BY C.range),

with ATFAULT as (SELECT CLASSES.range, COUNT(*) as at_fault_cases
FROM (SELECT CASE
    WHEN P.party_age BETWEEN 16 AND 18 THEN 'underaged'
    WHEN P.party_age BETWEEN 19 AND 21 THEN 'young I'
    WHEN P.party_age BETWEEN 22 AND 24 THEN 'young II'
    WHEN P.party_age BETWEEN 25 AND 60 THEN 'adult'
    WHEN P.party_age BETWEEN 61 AND 65 THEN 'elder I'
    ELSE 'elder II' 
    END 
    AS range
    FROM PARTIES P
    WHERE P.at_fault = 1) CLASSES
GROUP BY CLASSES.range),

TOTALS as (SELECT TCLASSES.range, COUNT(*) as total_cases
FROM (SELECT CASE
    WHEN P.party_age BETWEEN 16 AND 18 THEN 'underaged'
    WHEN P.party_age BETWEEN 19 AND 21 THEN 'young I'
    WHEN P.party_age BETWEEN 22 AND 24 THEN 'young II'
    WHEN P.party_age BETWEEN 25 AND 60 THEN 'adult'
    WHEN P.party_age BETWEEN 61 AND 65 THEN 'elder I'
    ELSE 'elder II' 
    END 
    AS range
    FROM PARTIES P) TCLASSES
GROUP BY TCLASSES.range)

SELECT AF.range, ROUND(AF.at_fault_cases * 100 / T.total_cases, 2) as ratio
FROM ATFAULT AF, TOTALS T
WHERE AF.range = T.range

-- conclusion : if you are an insurance company don't cover underaged drivers



-- 2. we want the top 5 vehicle types that have collisions
-- on road with holes 

-- initial benchmark : 3.581 secondes

WITH COLLISIONS_HOLES as (
SELECT C.case_id, P.vehicle_id
FROM Collisions C, ROAD_STATES RS, PARTIES P
WHERE  C.road_state_id = RS.road_state_id AND 
(RS.road_condition_1 = 'holes' OR RS.road_condition_2 = 'holes')
AND P.case_id = C.case_id
), 

VTYPES as (
SELECT V.vehicle_id, V.statewide_vehicle_type as vehicle_type
FROM VEHICLES V)

SELECT VT.vehicle_type, COUNT(*) AS collision_total
FROM VTYPES VT, COLLISIONS_HOLES CH 
WHERE VT.vehicle_id = CH.vehicle_id AND VT.vehicle_type IS NOT NULL
GROUP BY vehicle_type
ORDER BY collision_total DESC
FETCH FIRST 5 ROWS ONLY; 


-- 3. How many vehicle types have participated in at least 
-- 10 collisions in at least half of the cities? 

-- we want the total collision count and the location count


WITH COLLISION_V AS (
SELECT COUNT(C.case_id) as nb_collisions, L.county_city_location AS city, V.statewide_vehicle_type as vehicle_type
FROM COLLISIONS C, PARTIES P, VEHICLES V, LOCATIONS L
WHERE C.case_id = P.case_id AND V.vehicle_id = P.vehicle_id AND L.location_id = C.location_id
GROUP BY V.statewide_vehicle_type, L.county_city_location
),

STAT as (SELECT CV.vehicle_type, COUNT(CV.city) as nb_cities 
FROM COLLISION_V CV
WHERE CV.nb_collisions > 10
GROUP BY CV.vehicle_type),

TOTAL_CITIES AS (
SELECT COUNT(DISTINCT L.county_city_location) as total_cities
FROM LOCATIONS L)

SELECT S.vehicle_type
FROM STAT S, TOTAL_CITIES TOTAL
WHERE S.nb_cities >= TOTAL.total_cities / 2 AND vehicle_type IS NOT NULL

-- 8. Find the vehicles that have participated in at least 10 collisions.
-- Show the vehicle id and number of collisions the vehicle has participated in, 
-- sorted according to number of collisions (descending order). What do you observe? 

WITH TEMP AS (SELECT V.vehicle_id as id, V.vehicle_make as make, V.vehicle_year as year, COUNT(C.case_id) as nb_collisions
FROM COLLISIONS C, VEHICLES V, PARTIES P 
WHERE C.case_id = P.case_id AND V.vehicle_id = P.vehicle_id
GROUP BY V.vehicle_make, V.vehicle_year, V.vehicle_id
)

SELECT T.id, T.make, T.year, T.nb_collisions
FROM TEMP T
WHERE T.nb_collisions > 10
ORDER BY T.nb_collisions DESC
FETCH FIRST 50 ROWS ONLY;


-- conclusion: a lot of HONDA, FORD, TOYOTA









