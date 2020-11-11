USE devenvironment;

DROP TABLE DVOA_1;


CREATE TABLE DVOA_1 (
	Season INT,
    Week INT,
    Rank INT,
    Team VARCHAR (20),
    Total_DVOA decimal(5,2),
	DAVE decimal(5,2),
    DAVE_Rank INT,
	Record VARCHAR(5),
	Off_DVOA decimal(5,2),
    OFF_Rank INT,
	DEF_DVOA decimal(5,2),
    DEF_Rank INT,
	ST_DVOA decimal(5,2),
    ST_Rank INT
    )
;

LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/To Upload/DVOA_1.csv" INTO TABLE DVOA_1
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;


