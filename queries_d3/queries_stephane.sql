/* Query 4: Compute the safety index of each seating position as the fraction of total incidents where the victim
suffered no injury. The position with the highest safety index is the safest, while the one with the lowest
is the most unsafe. List the most safe and unsafe victim seating position along with its safety index */

/*SELECT DISTINCT VICTIMS.VICTIM_SEATING_POSITION
FROM VICTIMS;

SELECT DISTINCT V.VICTIM_DEGREE_OF_INJURY
FROM VICTIMS V;


SELECT v.victim_seating_position, COUNT(*)
FROM VICTIMS V
GROUP BY v.victim_seating_position
HAVING v.victim_degree_of_injury LIKE 'no injury';

SELECT COUNT(*) FROM (SELECT V.VICTIM_SEATING_POSITION
FROM VICTIMS V
WHERE V.VICTIM_SEATING_POSITION BETWEEN 2 AND 6);

WITH NON_PASSENGERS AS (SELECT table1.victim_seating_position, table2.non_injured_count / table1.seating_position_count as fraction
FROM (SELECT V.VICTIM_SEATING_POSITION, COUNT(*) AS SEATING_POSITION_COUNT
      FROM VICTIMS V
      WHERE V.VICTIM_SEATING_POSITION NOT BETWEEN 2 AND 6
      GROUP BY V.VICTIM_SEATING_POSITION) TABLE1, 
      (SELECT V.VICTIM_SEATING_POSITION, COUNT(*) AS NON_INJURED_COUNT
       FROM VICTIMS V
       WHERE V.VICTIM_DEGREE_OF_INJURY LIKE 'no injury' AND 
       V.VICTIM_SEATING_POSITION NOT BETWEEN 2 AND 6
       GROUP BY V.VICTIM_SEATING_POSITION) TABLE2
WHERE TABLE1.VICTIM_SEATING_POSITION = TABLE2.VICTIM_SEATING_POSITION)
SELECT fraction FROM NON_PASSENGERS;

SELECT 5, COUNT(V)
FROM VICTIMS V, 
    (SELECT COUNT(*) AS COUNT_NON_INJURED_PASSENGERS FROM (SELECT *
     FROM VICTIMS V
     WHERE v.victim_seating_position BETWEEN 2 AND 6 AND 
     v.victim_degree_of_injury LIKE 'no injury')) NON_INJURED_PASSENGERS,
WHERE V.VICTIM_SEATING_POSITION BETWEEN 2 AND 6;*/

-- TODO: Group all passengers together (2 to 6)? --
SELECT table1.victim_seating_position, ROUND(table2.non_injured_count / table1.seating_position_count, 3) as SAFETY_INDEX
FROM (SELECT V.VICTIM_SEATING_POSITION, COUNT(*) AS SEATING_POSITION_COUNT
      FROM VICTIMS V
      GROUP BY V.VICTIM_SEATING_POSITION) TABLE1, 
      (SELECT V.VICTIM_SEATING_POSITION, COUNT(*) AS NON_INJURED_COUNT
       FROM VICTIMS V
       WHERE V.VICTIM_DEGREE_OF_INJURY = 'no injury'
       GROUP BY V.VICTIM_SEATING_POSITION) TABLE2
WHERE TABLE1.VICTIM_SEATING_POSITION = TABLE2.VICTIM_SEATING_POSITION
ORDER BY SAFETY_INDEX;

CREATE INDEX VICTIM_SEATION_POSITION_IDX
    ON VICTIMS(VICTIM_SEATING_POSITION);
    
CREATE INDEX VICTIM_DEGREE_OF_INJURY_IDX
    ON VICTIMS(VICTIM_DEGREE_OF_INJURY);
    
CREATE INDEX VICTIM_DEGREE_INJ_SEATING_POS_IDX
    ON VICTIMS(VICTIM_DEGREE_OF_INJURY, VICTIM_SEATING_POSITION);
    
CREATE INDEX VICTIM_SEATING_POS_DEGREE_INJ_IDX
    ON VICTIMS(VICTIM_SEATING_POSITION, VICTIM_DEGREE_OF_INJURY);
    
ALTER INDEX VICTIM_SEATING_POS_DEGREE_INJ_IDX VISIBLE;
ALTER INDEX VICTIM_DEGREE_INJ_SEATING_POS_IDX INVISIBLE;
ALTER INDEX VICTIM_SEATING_POSITION_IDX VISIBLE;
ALTER INDEX VICTIM_DEGREE_OF_INJURY_IDX INVISIBLE;


/* Query 7: Find all collisions that satisfy the following: the collision was of type pedestrian and all victims were above
100 years old. For each of the qualifying collisions, show the collision id and the age of the eldest collision
victim
*/
/*SELECT DISTINCT C.TYPE_OF_COLLISION
FROM COLLISIONS C;

SELECT DISTINCT V.VICTIM_AGE
FROM VICTIMS V;

SELECT COUNT(C.CASE_ID)
FROM COLLISIONS C 
WHERE C.TYPE_OF_COLLISION LIKE 'pedestrian'
AND 100 < ALL (SELECT V.VICTIM_AGE FROM VICTIMS V WHERE V.VICTIM_AGE <= 125 AND V.CASE_ID = C.CASE_ID);*/

SELECT V.CASE_ID, MAX(V.VICTIM_AGE)
FROM VICTIMS V, COLLISIONS C
WHERE V.CASE_ID = C.CASE_ID AND C.TYPE_OF_COLLISION = 'pedestrian'
AND V.VICTIM_AGE IS NOT NULL
GROUP BY V.CASE_ID
HAVING MIN(V.VICTIM_AGE) > 100 AND MAX(V.VICTIM_AGE) <= 125;


-- Query above will not choose this index, because we're retrieving all victims anyway, the selection
-- predicates are done only after the group by. For a certain collision, we need to verify ALL its victims
-- are above 100, and for that we need to retrieve all the victims for that collision, and hence for all collisions
-- we need to retrieve all the victims.
CREATE INDEX VICTIM_AGE_IDX
   ON VICTIMS (VICTIM_AGE);

CREATE INDEX TYPE_OF_COLLISION_IDXS
    ON COLLISIONS (TYPE_OF_COLLISION);
    
CREATE INDEX victim_case_id_idx
        ON VICTIMS(case_id);
        
CREATE INDEX victim_age_case_id_idx
        ON VICTIMS(victim_age, case_id);
CREATE INDEX VICTIM_CASE_ID_AGE_IDX
        ON VICTIMS(CASE_ID, VICTIM_AGE);
    
ALTER INDEX victim_age_idx invisible;
ALTER INDEX type_of_collision_idx visible;
ALTER INDEX victim_case_id_age_idx visible;
ALTER INDEX victim_age_case_id_idx invisible;


/*
 Query 10: . Are there more accidents around dawn, dusk, during the day, or during the night? In case lighting
information is not available, assume the following: the dawn is between 06:00 and 07:59, and dusk
between 18:00 and 19:59 in the period September 1 - March 31; and dawn between 04:00 and 06:00,
and dusk between 20:00 and 21:59 in the period April 1 - August 31. The remaining corresponding times
are night and day. Display the number of accidents, and to which group it belongs, and make your
conclusion based on absolute number of accidents in the given 4 periods
*/
SELECT DISTINCT R.LIGHTING
FROM ROAD_STATES R;


/*SELECT EXTRACT(month FROM C.COLLISION_DATE) as m
FROM COLLISIONS C
WHERE m > 8;*/

SELECT 'DAY', COUNT(*)
FROM COLLISIONS C
WHERE C.ROAD_STATE_ID in (SELECT R.ROAD_STATE_ID FROM ROAD_STATES R WHERE R.LIGHTING = 'daylight');

SELECT 'DAY', COUNT(*)
FROM COLLISIONS C, ROAD_STATES R
WHERE C.ROAD_STATE_ID = R.ROAD_STATE_ID AND R.LIGHTING = 'daylight';

-- For date comparisons, we were only intersted in day and month, however collision date has a year as well.
-- For that we either had to transform it to extract only day and month and do the comparison, or reformat it here
-- using to_char as we did here. In any case the index we create on collision_date is lost unfortunately.
-- (Using between to do range search, we had to be careful of ranges like from "1st Septmber to 31st March", because there
-- is an overflow, so we just added 6 months to the dates so the comparison is between 1st of April to 31st of September, 
-- which still preserves the ordering).
SELECT 'DAWN', dawns.count_dawns, 'DAY', days.count_days,
        'DUSK', dusks.count_dusks, 'NIGHT', nights.count_nights
FROM (
    -- DAWN INSTANCES
    SELECT 'DAWN', COUNT(*) as count_dawns
        FROM COLLISIONS C
        WHERE (TO_CHAR(C.COLLISION_DATE, 'MM-DD') BETWEEN '04-01' AND '08-31'
        AND C.COLLISION_TIME BETWEEN '04:00:00' AND '05:59:59') OR
        (TO_CHAR(ADD_MONTHS(C.COLLISION_DATE, 6), 'MM-DD') BETWEEN '03-01' AND '09-31'
        AND C.COLLISION_TIME BETWEEN '06:00:00' AND '07:59:59')) dawns,
    -- DAY INSTANCES
    (SELECT 'DAY', COUNT(*) as count_days
        FROM COLLISIONS C
        WHERE (TO_CHAR(C.COLLISION_DATE, 'MM-DD') BETWEEN '04-01' AND '08-31'
        AND C.COLLISION_TIME BETWEEN '06:00:00' AND '19:59:59') OR
        (TO_CHAR(ADD_MONTHS(C.COLLISION_DATE, 6), 'MM-DD') BETWEEN '03-01' AND '09-31'
        AND C.COLLISION_TIME BETWEEN '08:00:00' AND '17:59:59') OR
        C.ROAD_STATE_ID in (SELECT R.ROAD_STATE_ID FROM ROAD_STATES R WHERE R.LIGHTING = 'daylight')) days,
    -- DUSK INSTANCES
    (SELECT 'DUSK', COUNT(*) as count_dusks
        FROM COLLISIONS C 
        WHERE (TO_CHAR(C.COLLISION_DATE, 'MM-DD') BETWEEN '04-01' AND '08-31'
        AND C.COLLISION_TIME BETWEEN '20:00:00' AND '21:59:59') OR
        (TO_CHAR(ADD_MONTHS(C.COLLISION_DATE, 6), 'MM-DD') BETWEEN '03-01' AND '09-31'
        AND C.COLLISION_TIME BETWEEN '18:00:00' AND '19:59:59')) dusks,
    -- -- NIGHT INSTANCES
    (SELECT 'NIGHT', COUNT(*) as count_nights
        FROM COLLISIONS C
        WHERE (TO_CHAR(C.COLLISION_DATE, 'MM-DD') BETWEEN '04-01' AND '08-31'
        AND ((C.COLLISION_TIME BETWEEN '22:00:00' AND '23:59:59') OR (C.COLLISION_TIME BETWEEN '00:00:00' AND '03:59:59'))) OR
        (TO_CHAR(ADD_MONTHS(C.COLLISION_DATE, 6), 'MM-DD') BETWEEN '03-01' AND '09-31'
        AND ((C.COLLISION_TIME BETWEEN '20:00:00' AND '23:59:59') OR (C.COLLISION_TIME BETWEEN '00:00:00' AND '05:59:59'))) OR 
        (C.ROAD_STATE_ID IN (SELECT R.ROAD_STATE_ID FROM ROAD_STATES R WHERE R.LIGHTING LIKE 'dark%'))) nights;
    
CREATE INDEX collision_date_idx
    ON COLLISIONS(COLLISION_DATE);

CREATE INDEX collision_time_idx
    ON COLLISIONS(COLLISION_TIME);
    
    
-- SKETCH --
    
SELECT COUNT(*)
FROM COLLISIONS;
    
SELECT C.OFFICER_ID
FROM COLLISIONS C
WHERE C.CASE_ID <= '0000011';

ALTER INDEX SYS_C00200542 VISIBLE;

SELECT C.CASE_ID, C.COLLISION_DATE
FROM COLLISIONS C
WHERE C.CASE_ID = 0000001;

SELECT P.CASE_ID, P.PARTY_NUMBER, P.AT_FAULT
FROM PARTIES P
WHERE P.CASE_ID = 0000001 AND P.PARTY_NUMBER = 1;

ALTER INDEX SYS_C00200542 VISIBLE;






