/*DROP TABLE VICTIMS;
DROP TABLE PARTIES;
DROP TABLE COLLISIONS;
DROP TABLE LOCATIONS;
DROP TABLE PCF_VIOLATIONS;
DROP TABLE VEHICLES;
DROP TABLE SAFETY_EQUIPMENTS;
DROP TABLE WEATHERS;
DROP TABLE ROAD_STATES;
DROP TABLE ASSOCIATED_FACTORS;*/

-- Vehicles Table --
CREATE TABLE VEHICLES(
    vehicle_id INTEGER NOT NULL,
    -- Stored as plain text
    statewide_vehicle_type VARCHAR2(48),
    vehicle_make VARCHAR2(32),
    vehicle_year INTEGER,
    PRIMARY KEY(vehicle_id)
);

ALTER TABLE VEHICLES
   ADD CONSTRAINT vh_uniq UNIQUE (statewide_vehicle_type,
                                  vehicle_make,
                                  vehicle_year);

-- Locations Table --
CREATE TABLE LOCATIONS(
    location_id INTEGER NOT NULL,
    county_city_location INTEGER,
    jurisdiction INTEGER, 
    -- stored as plain text
    location_type VARCHAR2(16),
        CONSTRAINT check_location_type CHECK 
            (location_type IN ('highway', 'intersection', 'ramp')),
    location_population INTEGER 
        CONSTRAINT check_population CHECK (location_population BETWEEN 0 and 9),
    PRIMARY KEY(location_id)
);

ALTER TABLE LOCATIONS
   ADD CONSTRAINT lc_uniq UNIQUE (county_city_location,
                                  jurisdiction,
                                  location_type);

-- Table for pcf (primary_collision_factor) violation --
CREATE TABLE PCF_VIOLATIONS(
    pcf_id INTEGER NOT NULL,
    pcf_violation INTEGER,
    -- stored as plain text 
    primary_collision_factor VARCHAR2(32),
    -- stored as plain text
    pcf_violation_category VARCHAR2(48),
    pcf_violation_subsection CHAR(1),
    PRIMARY KEY(pcf_id)
);

-- Weathers Table --
CREATE TABLE WEATHERS(
    weather_id INTEGER NOT NULL,
    weather VARCHAR2(8) NOT NULL,
    PRIMARY KEY(weather_id)
);

-- Table of combinations of safety equipments
CREATE TABLE SAFETY_EQUIPMENTS(
    seid INTEGER NOT NULL,
    safety_equipment_1 CHAR(1),
    safety_equipment_2 CHAR(1),
    PRIMARY KEY(seid)
);

ALTER TABLE SAFETY_EQUIPMENTS
   ADD CONSTRAINT se_uniq UNIQUE (seid,
                                  safety_equipment_1,
                                  safety_equipment_2);

-- Table of combinations of associated factors
CREATE TABLE ASSOCIATED_FACTORS(
    afid INTEGER NOT NULL,
    associated_factor_1 CHAR(1),
    associated_factor_2 CHAR(1),
    PRIMARY KEY(afid)
);

ALTER TABLE ASSOCIATED_FACTORS
   ADD CONSTRAINT af_uniq UNIQUE (afid,
                                  associated_factor_1,
                                  associated_factor_2);

-- Table for road conditions --
CREATE TABLE ROAD_STATES(
    road_state_id INTEGER NOT NULL,
    -- stored as plain text
    lighting VARCHAR2(48),
    -- stored as plaintext
    road_condition_1 VARCHAR2(32),
    road_condition_2 VARCHAR2(32),
    -- stored as plaintext
    -- CAUTION: watch out for outlier value 'H'
    road_surface VARCHAR2(10),
    PRIMARY KEY (road_state_id)
);

ALTER TABLE ROAD_STATES
    ADD CONSTRAINT rc_uniq UNIQUE (lighting, road_condition_1, road_condition_2, road_surface);

-- Collisions Table --
CREATE TABLE COLLISIONS(
    case_id VARCHAR2(19) NOT NULL, 
    -- location
    location_id INTEGER,  
    -- Maybe merge date and time into single attribute?
    -- All collision date have standard 'yyyy-mm-dd' format.
    collision_date DATE, 
    -- All collision time have standara 'hh-mm-ss' format or just nan 
    -- CAUTION: TIME or DATE?
    collision_time CHAR(8), 
    -- stored as plaintext
    collision_severity VARCHAR2(32)
        CONSTRAINT check_collision_severity CHECK (collision_severity in (
            'property damage only', 'severe injury', 'pain', 'fatal', 'other injury'
        )), 
    -- stored as plain text
    -- CAUTION: outlier value 'D' in data
    hit_and_run VARCHAR2(16) 
        CONSTRAINT check_hit_and_run 
            CHECK (hit_and_run IN ('not hit and run', 'misdemeanor', 'felony')),
    officer_id VARCHAR2(8), 
    pcf_id INTEGER, 
    -- All process date have standard 'yyyy-mm-dd' format.
    process_date DATE, 
    -- Already stored as integer
    ramp_intersection INTEGER 
        CONSTRAINT check_ramp_intersection CHECK (ramp_intersection BETWEEN 1 AND 8),
    road_state_id INTEGER, 
    
    -- tow_away stored as 0,1 or nan --
    tow_away NUMBER(1), 
    -- stored as plaintext
    type_of_collision VARCHAR2(16), 
    weather_id_1 INTEGER, 
    weather_id_2 INTEGER, 
    PRIMARY KEY(case_id),
    FOREIGN KEY(weather_id_1) REFERENCES WEATHERS(weather_id),
    FOREIGN KEY(weather_id_2) REFERENCES WEATHERS(weather_id),
    FOREIGN KEY(road_state_id) REFERENCES ROAD_STATES,
    FOREIGN KEY(pcf_id) REFERENCES PCF_VIOLATIONS,
    FOREIGN KEY(location_id) REFERENCES LOCATIONS
);

-- Party Table --
-- (Weak entity of COLLISIONS) --
CREATE TABLE PARTIES(
    case_id VARCHAR2(19) NOT NULL, 
    party_number INTEGER NOT NULL, 
    -- CAUTION: Named other_associate_factor in the data
    afid INTEGER, 
    at_fault NUMBER(1), 
    -- CAUTION: Can also be one of '1', '2' or '3' 
    cellphone_use CHAR(1) CONSTRAINT check_cellphone_use CHECK (cellphone_use in ('B', 'C', 'D')),
    
    financial_responsibility CHAR(1) CONSTRAINT check_financial_responsibility CHECK(financial_responsibility in ('N', 'Y', 'O', 'E')),
    -- Can be 'A' or blank, need to transform into boolean (0 or 1)
    hazardous_materials NUMBER(1), 
    -- Stored as plain word 
    movement_preceding_collision VARCHAR2(32), 
    party_age INTEGER, 
    -- stored as plain word(TODO: convert to 'M' or 'F')
    party_sex CHAR(1) CONSTRAINT check_party_sex CHECK(party_sex in ('M', 'F')), 
    /* The following two are similar */
    -- CAUTION: outlier value 'G' in data
    party_drug_physical CHAR(1)  
        CONSTRAINT check_party_drug_physical CHECK (party_drug_physical in ('E', 'F', 'H', 'I')),
    party_sobriety CHAR(1) 
        CONSTRAINT check_party_sobriety CHECK (party_sobriety in ('A', 'B', 'C', 'D', 'G', 'H')),
    -- Stored as plain text
    party_type VARCHAR2(16)
        CONSTRAINT check_party_type CHECK (party_type IN (
            'driver', 'parked vehicle', 'other', 'bicyclist', 'pedestrian' 
        )), 
    seid INTEGER, 
    -- CAUTION: school_bus_related Is either 'E' or blank in the dataset, stored in parties
    school_bus_related NUMBER(1), 
    vehicle_id INTEGER, 
    PRIMARY KEY(case_id, party_number),
    FOREIGN KEY(afid) REFERENCES ASSOCIATED_FACTORS,
    FOREIGN KEY(seid) REFERENCES SAFETY_EQUIPMENTS,
    FOREIGN KEY(vehicle_id) REFERENCES VEHICLES,
    FOREIGN KEY(case_id) REFERENCES COLLISIONS ON DELETE CASCADE 
);

-- Victims Table --
-- (Weak entity of Parties)
CREATE TABLE VICTIMS(
    id INTEGER NOT NULL, 
    case_id VARCHAR2(19) NOT NULL, 
    party_number INTEGER NOT NULL, 
    seid INTEGER, 
    victim_age INTEGER, 
        CONSTRAINT check_victim_age CHECK (victim_age BETWEEN 0 AND 999),
    -- stored as plaintext
    -- CAUTION: value '7' should be mapped to 'possible injury'
    victim_degree_of_injury VARCHAR2(32) 
        CONSTRAINT check_victim_degree_of_injury CHECK (victim_degree_of_injury
             IN('no injury', 'severe injury', 'complaint of pain', 'other visible injury', 'killed', 
                'suspected minor injury', 'suspected serious injury', 'possible injury')),
    -- CAUTION: watch out for outlier value 4 --
    victim_ejected INTEGER 
        CONSTRAINT check_victim_ejected CHECK (victim_ejected BETWEEN 0 AND 3),
    victim_role INTEGER 
        CONSTRAINT check_victim_role CHECK (victim_role BETWEEN 1 AND 6),
    victim_seating_position INTEGER 
        CONSTRAINT check_victim_seating_position CHECK (victim_seating_position BETWEEN 0 AND 9), 
    -- stored as plain word(TODO: convert to 'M' or 'F')
    victim_sex CHAR(1) 
        CONSTRAINT check_victim_sex CHECK (victim_sex IN ('M', 'F')),
    PRIMARY KEY (id),
    FOREIGN KEY(seid) REFERENCES SAFETY_EQUIPMENTS,
    FOREIGN KEY(case_id, party_number) REFERENCES PARTIES ON DELETE CASCADE
);
