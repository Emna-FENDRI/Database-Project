-- MAPPING TO IMPLEMENT :
-- A - Violation 
-- E - Vision Obscurements 
-- F - Inattention 
-- G - Stop and Go Traffic 
-- H - Entering/Leaving Ramp 
-- I - Previous Collision 
-- J - Unfamiliar With Road 
-- K - Defective Vehicle Equipment 
-- L - Uninvolved Vehicle 
-- M - Other 
-- N - None Apparent 
-- O - Runaway Vehicle 
-- P - Inattention, Cell Phone  
-- Q - Inattention, Electronic Equip. 
-- R - Inattention, Radio/CD  
-- S - Inattention, Smoking  
-- T - Inattention, Eating  
-- U - Inattention, Children  
-- V - Inattention, Animal  
-- W - Inattention, Personal Hygiene  
-- X - Inattention, Reading  
-- Y - Inattention, Other


-- CREATE THE NEW COLUMN (EMPTY)
ALTER TABLE ASSOCIATED_FACTORS 
ADD associated_factor_1 VARCHAR(30);

ALTER TABLE ASSOCIATED_FACTORS
ADD associated_factor_2 VARCHAR(30);


-- FILL THE CREATED COLUMN WITH THE MAPPING
SELECT CASE WHEN AF.other_associated_factor_1 = 'A' THEN 'Violation'
            WHEN AF.other_associated_factor_1 = 'E' THEN 'Vision Obscurements'
            WHEN AF.other_associated_factor_1 = 'F' THEN 'Inattention'
            WHEN AF.other_associated_factor_1 = 'G' THEN 'Stop and Go Traffic'
            WHEN AF.other_associated_factor_1 = 'H' THEN 'Entering/Leaving Ramp'
            WHEN AF.other_associated_factor_1 = 'I' THEN 'Previous Collision'
            WHEN AF.other_associated_factor_1 = 'J' THEN 'Unfamiliar With Road'
            WHEN AF.other_associated_factor_1 = 'K' THEN 'Defective Vehicle Equipment'
            WHEN AF.other_associated_factor_1 = 'M' THEN 'Uninvolved Vehicle'
            WHEN AF.other_associated_factor_1 = 'N' THEN 'Other'
            WHEN AF.other_associated_factor_1 = 'O' THEN 'None Apparent'
            WHEN AF.other_associated_factor_1 = 'P' THEN 'Inattention, Cell Phone'
            WHEN AF.other_associated_factor_1 = 'Q' THEN 'Inattention, Electronic Equip.'
            WHEN AF.other_associated_factor_1 = 'R' THEN 'Inattention, Radio/CD'
            WHEN AF.other_associated_factor_1 = 'S' THEN 'Inattention, Smoking' 
            WHEN AF.other_associated_factor_1 = 'T' THEN 'Inattention, Eating'
            WHEN AF.other_associated_factor_1 = 'U' THEN 'Inattention, Children'
            WHEN AF.other_associated_factor_1 = 'V' THEN 'Inattention, Animal'
            WHEN AF.other_associated_factor_1 = 'W' THEN 'Inattention, Personal Hygiene'
            WHEN AF.other_associated_factor_1 = 'X' THEN 'Inattention, Reading'
            ELSE 'Inattention, Other' 
        INTO associated_factor_1
        FROM ASSOCIATED_FACTORS AF


SELECT CASE WHEN AF.other_associated_factor_2 = 'A' THEN 'Violation'
            WHEN AF.other_associated_factor_2 = 'E' THEN 'Vision Obscurements'
            WHEN AF.other_associated_factor_2 = 'F' THEN 'Inattention'
            WHEN AF.other_associated_factor_2 = 'G' THEN 'Stop and Go Traffic'
            WHEN AF.other_associated_factor_2 = 'H' THEN 'Entering/Leaving Ramp'
            WHEN AF.other_associated_factor_2 = 'I' THEN 'Previous Collision'
            WHEN AF.other_associated_factor_2 = 'J' THEN 'Unfamiliar With Road'
            WHEN AF.other_associated_factor_2 = 'K' THEN 'Defective Vehicle Equipment'
            WHEN AF.other_associated_factor_2 = 'M' THEN 'Uninvolved Vehicle'
            WHEN AF.other_associated_factor_2 = 'N' THEN 'Other'
            WHEN AF.other_associated_factor_2 = 'O' THEN 'None Apparent'
            WHEN AF.other_associated_factor_2 = 'P' THEN 'Inattention, Cell Phone'
            WHEN AF.other_associated_factor_2 = 'Q' THEN 'Inattention, Electronic Equip.'
            WHEN AF.other_associated_factor_2 = 'R' THEN 'Inattention, Radio/CD'
            WHEN AF.other_associated_factor_2 = 'S' THEN 'Inattention, Smoking' 
            WHEN AF.other_associated_factor_2 = 'T' THEN 'Inattention, Eating'
            WHEN AF.other_associated_factor_2 = 'U' THEN 'Inattention, Children'
            WHEN AF.other_associated_factor_2 = 'V' THEN 'Inattention, Animal'
            WHEN AF.other_associated_factor_2 = 'W' THEN 'Inattention, Personal Hygiene'
            WHEN AF.other_associated_factor_2 = 'X' THEN 'Inattention, Reading'
            ELSE 'Inattention, Other' 
        INTO associated_factor_2
        FROM ASSOCIATED_FACTORS AF


-- MAPPING TO IMPLEMENT
-- A - None in Vehicle 
-- B - Unknown 
-- C - Lap Belt Used 
-- D - Lap Belt Not Used 
-- E - Shoulder Harness Used 
-- F - Shoulder Harness Not Used
-- G - Lap/Shoulder Harness Used 
-- H - Lap/Shoulder Harness Not Used 
-- J - Passive Restraint Used 
-- K - Passive Restraint Not Used 
-- L - Air Bag Deployed 
-- M - Air Bag Not Deployed 
-- N - Other 
-- P - Not Required 
-- Q - Child Restraint in Vehicle Used 
-- R - Child Restraint in Vehicle Not Used 
-- S - Child Restraint in Vehicle, Use Unknown 
-- T - Child Restraint in Vehicle, Improper Use 
-- U - No Child Restraint in Vehicle 
-- V - Driver, Motorcycle Helmet Not Used 
-- W - Driver, Motorcycle Helmet Used 
-- X - Passenger, Motorcycle Helmet Not Used 
-- Y - Passenger, Motorcycle Helmet Used


-- CREATE THE NEW COLUMNS (EMPTY)
ALTER TABLE SAFETY_EQUIPMENTS 
ADD safety_equipment_1_desc VARCHAR(40);

ALTER TABLE SAFETY_EQUIPMENTS
ADD safety_equipment_2_desc VARCHAR(40);


-- FILL THE CREATED COLUMN WITH THE MAPPING
SELECT CASE WHEN SE.safety_equipment_1  = 'A' THEN 'None in Vehicle'
            WHEN SE.safety_equipment_1  = 'B' THEN 'Unknown'
            WHEN SE.safety_equipment_1  = 'C' THEN 'Lap Belt Used'
            WHEN SE.safety_equipment_1  = 'D' THEN 'Lap Belt Not Used'
            WHEN SE.safety_equipment_1  = 'E' THEN 'Shoulder Harness Used'
            WHEN SE.safety_equipment_1  = 'F' THEN 'Shoulder Harness Not Used'
            WHEN SE.safety_equipment_1  = 'G' THEN 'Lap/Shoulder Harness Used'
            WHEN SE.safety_equipment_1  = 'H' THEN 'Lap/Shoulder Harness Not Used'
            WHEN SE.safety_equipment_1  = 'J' THEN 'Passive Restraint Used'
            WHEN SE.safety_equipment_1  = 'K' THEN 'Passive Restraint Not Used'
            WHEN SE.safety_equipment_1  = 'L' THEN 'Air Bag Deployed'
            WHEN SE.safety_equipment_1  = 'M' THEN 'Air Bag Not Deployed'
            WHEN SE.safety_equipment_1  = 'N' THEN 'Other'
            WHEN SE.safety_equipment_1  = 'P' THEN 'Not required'
            WHEN SE.safety_equipment_1  = 'Q' THEN 'Child Restraint in Vehicle Used' 
            WHEN SE.safety_equipment_1  = 'R' THEN 'Child Restraint in Vehicle Not Used'
            WHEN SE.safety_equipment_1  = 'S' THEN 'Child Restraint in Vehicle, Use Unknown'
            WHEN SE.safety_equipment_1  = 'T' THEN 'Child Restraint in Vehicle, Improper Use'
            WHEN SE.safety_equipment_1  = 'U' THEN 'No Child Restraint in Vehicle'
            WHEN SE.safety_equipment_1  = 'V' THEN 'Driver, Motorcycle Helmet Not Used'
            WHEN SE.safety_equipment_1  = 'W' THEN 'Driver, Motorcycle Helmet Used'
            WHEN SE.safety_equipment_1  = 'X' THEN 'Passenger, Motorcycle Helmet Not Used'
            ELSE 'Passenger, Motorcycle Helmet Used' 
        INTO associated_factor_1_desc
        FROM SAFETY_EQUIPMENTS SE


SELECT CASE WHEN SE.safety_equipment_2  = 'A' THEN 'None in Vehicle'
            WHEN SE.safety_equipment_2  = 'B' THEN 'Unknown'
            WHEN SE.safety_equipment_2  = 'C' THEN 'Lap Belt Used'
            WHEN SE.safety_equipment_2  = 'D' THEN 'Lap Belt Not Used'
            WHEN SE.safety_equipment_2  = 'E' THEN 'Shoulder Harness Used'
            WHEN SE.safety_equipment_2  = 'F' THEN 'Shoulder Harness Not Used'
            WHEN SE.safety_equipment_2  = 'G' THEN 'Lap/Shoulder Harness Used'
            WHEN SE.safety_equipment_2  = 'H' THEN 'Lap/Shoulder Harness Not Used'
            WHEN SE.safety_equipment_2  = 'J' THEN 'Passive Restraint Used'
            WHEN SE.safety_equipment_2  = 'K' THEN 'Passive Restraint Not Used'
            WHEN SE.safety_equipment_2  = 'L' THEN 'Air Bag Deployed'
            WHEN SE.safety_equipment_2  = 'M' THEN 'Air Bag Not Deployed'
            WHEN SE.safety_equipment_2  = 'N' THEN 'Other'
            WHEN SE.safety_equipment_2  = 'P' THEN 'Not required'
            WHEN SE.safety_equipment_2  = 'Q' THEN 'Child Restraint in Vehicle Used' 
            WHEN SE.safety_equipment_2  = 'R' THEN 'Child Restraint in Vehicle Not Used'
            WHEN SE.safety_equipment_2  = 'S' THEN 'Child Restraint in Vehicle, Use Unknown'
            WHEN SE.safety_equipment_2  = 'T' THEN 'Child Restraint in Vehicle, Improper Use'
            WHEN SE.safety_equipment_2  = 'U' THEN 'No Child Restraint in Vehicle'
            WHEN SE.safety_equipment_2  = 'V' THEN 'Driver, Motorcycle Helmet Not Used'
            WHEN SE.safety_equipment_2  = 'W' THEN 'Driver, Motorcycle Helmet Used'
            WHEN SE.safety_equipment_2  = 'X' THEN 'Passenger, Motorcycle Helmet Not Used'
            ELSE 'Passenger, Motorcycle Helmet Used' 
        INTO associated_factor_2_desc
        FROM SAFETY_EQUIPMENTS SE


-- DROP ORIGINAL COLUMNS
ALTER TABLE SAFETY_EQUIPMENTS DROP COLUMN safety_equipment_2;
ALTER TABLE SAFETY_EQUIPMENTS DROP COLUMN safety_equipment_1;

ALTER TABLE ASSOCIATED_FACTORS DROP COLUMN other_associated_factor_1;
ALTER TABLE ASSOCIATED_FACTORS DROP COLUMN other_associated_factor_2;

-- GIVE THE NEW COLUMN THE NAME OF THE ORIGINAL ONES    
ALTER TABLE ASSOCIATED_FACTORS RENAME COLUMN associated_factor_1 TO other_associated_factor_1;
ALTER TABLE ASSOCIATED_FACTORS RENAME COLUMN associated_factor_2 TO other_associated_factor_2;

ALTER TABLE SAFETY_EQUIPMENTS RENAME COLUMN safety_equipment_1_desc TO safety_equipement_1;
ALTER TABLE SAFETY_EQUIPMENTS RENAME COLUMN safety_equipment_2_desc TO safety_equipement_2;
