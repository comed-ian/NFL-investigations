USE devenvironment;

DROP TABLE DVOA_2_16;


CREATE TABLE DVOA_2_16 (
	Season INT,
    Week INT,
    Rank INT,
    Team VARCHAR (20),
    Total_DVOA decimal(4,2),
    Last_Week INT,
	DAVE decimal(4,2),
    DAVE_Rank INT,
    Record VARCHAR (5),
	Off_DVOA decimal(4,2),
    OFF_Rank INT,
	DEF_DVOA decimal(4,2),
    DEF_Rank INT,
	ST_DVOA decimal(4,2),
    ST_Rank INT
    )
;

/*For Uploading weeks 2-16*/
LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/To Upload/DVOA_2_16.csv" INTO TABLE DVOA_2_16
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

/*For uploading week 17*/
LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/To Upload/DVOA_17.csv" INTO TABLE DVOA_2_16
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

