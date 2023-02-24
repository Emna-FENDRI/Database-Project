--1.List the year and the number of collisions per year. 
SELECT extract(year FROM collision_date) AS year,count(*) AS col_per_year
FROM collisions 
GROUP BY extract(year FROM collision_date);

--2.Find the most popular vehicle make in the database. 
--Also list the number of vehicles of that particular make.

WITH Temp AS 
(   SELECT V.vehicle_make AS vehicle_make ,COUNT(*) AS vehicle_make_count
    FROM parties P, VEHICLES V
    where P.vehicle_id = V.vehicle_id
    GROUP BY V.vehicle_make )

SELECT Temp.vehicle_make, Temp.vehicle_make_count
FROM  Temp
WHERE Temp.vehicle_make_count = (SELECT MAX(Temp.vehicle_make_count) FROM Temp);



--3.Find the fraction of total collisions that happened under dark lighting conditions.
-- dark lighting = {'dark with no street lights' ,'dark with street lights' ,'dark with street lights not functioning'}
WITH total AS 
(SELECT COUNT(*) AS tot
FROM collisions )

SELECT    (SELECT COUNT(*) AS res
            FROM COLLISIONS C , ROAD_STATES R
            WHERE   (C.road_state_id = R.road_state_id) 
                    AND (R.lighting = 'dark with no street lights' 
                    OR R.lighting ='dark with street lights' 
                    OR R.lighting = 'dark with street lights not functioning' ))/total.tot as fraction_dark_light_col
                    
FROM total;

--4.Find the number of collisions that have occurred under snowy weather conditions.
SELECT COUNT(DISTINCT c.case_id) AS number_of_snowy_weather_col
FROM COLLISIONS C , WEATHERS W1 , WEATHERS W2 
WHERE  (C.weather_id_1 = W1.weather_id AND W1.weather = 'snowing' )
        OR (C.weather_id_2 = W2.weather_id AND W2.weather = 'snowing' ) ;

--5.Compute the number of collisions per day of the week
-- and find the day that witnessed the highest number of collisions. 

--Computes the number of collisions per day of the week
SELECT to_char(COLLISION_DATE, 'DAY') AS day ,COUNT(*) AS col_per_day 
FROM COLLISIONS C
GROUP BY to_char(COLLISION_DATE, 'DAY')

--Finds the day that witnessed the highest number of collisions
WITH Temp AS 
( SELECT to_char(COLLISION_DATE, 'DAY') AS day ,COUNT(*) AS col_per_day
          FROM COLLISIONS C
          GROUP BY to_char(COLLISION_DATE, 'DAY'))
          
SELECT Temp.day, Temp.col_per_day
FROM Temp
WHERE Temp.col_per_day=(SELECT MAX(Temp.col_per_day) 
                        FROM Temp );

--6. List all weather types and their corresponding number of collisions in descending order of the number of collisions.
with weather1 as (select count(*) as count_w1  , weather as w1
from collisions C , weathers W 
where  C.weather_id_1 = W.weather_id
group by weather ),

weather2 as (select count(*) as count_w2  , weather as w2
from collisions C , weathers W 
where  C.weather_id_2 = W.weather_id
group by weather )

select  weather1.w1 as weathertype ,weather1.count_w1 + weather2.count_w2 as tot
from weather1 , weather2
where (Weather1.w1 = Weather2.w2) 
UNION
select weather1.w1 , weather1.count_w1
from weather1
where weather1.w1 = 'clear'
ORDER BY TOT DESC;


--7. Find the number of at-fault collision parties with financial responsibility and loose material road conditions.
SELECT COUNT(*) AS number_of_parties
FROM PARTIES P ,COLLISIONS C , ROAD_STATES R 
WHERE   P.case_id = C.case_id 
        AND C.road_state_id = R.road_state_id
        AND P.at_fault = 1 
        AND P.financial_responsibility = 'Y'
        AND (R.road_condition_1 = 'loose material' OR R.road_condition_2 = 'loose material');
--8.Find the median victim age and the most common victim seating position.

--Find the most common victim seating position
with temp as (select victim_seating_position as seat , COUNT(*) as count_per_seat
                from victims
                group by victim_seating_position)
                
select temp.seat as most_common_seating_pos
from temp 
where temp.count_per_seat = (select max(temp.count_per_seat)  
                            from temp );   
--Find the median victim age

select median(V.victim_age) as median_age 
from victims V;

--9.What is the fraction of all participants that have been victims of collisions while using a belt?

with total as 
(select count(*) as tot
from victims )
                
select ( SELECT COUNT(*)
        FROM VICTIMS V, SAFETY_EQUIPMENTS S
        WHERE   V.seid = S.seid
                AND (S.safety_equipment_1 = 'C' OR S.safety_equipment_2 = 'C'))/total.tot as fraction

FROM total;

--10. Compute and the fraction of the collisions happening for each hour of the day (for example, x% at 13,
--where 13 means period from 13:00 to 13:59). Display the ratio as percentage for all the hours of the day.

with total as 
(select count(*) as tot
from collisions)

select hour,(count_per_hour/ total.tot)*100 as percentage_per_hour
from total , 
    (select extract( hour from  cast(collision_time as time) ) as hour , count(*) as count_per_hour
    from collisions 
    group by extract(hour from cast(collision_time as time) ));

