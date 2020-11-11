USE devenvironment;

drop table DVOA;

/*append DVOA tables*/ 
create table DVOA
select Season, Week, Rank, Team, Total_DVOA, Record, DAVE, DAVE_Rank, OFF_Rank, DEF_DVOA, DEF_Rank, ST_DVOA, ST_Rank from DVOA_2_16
union all
select Season, Week, Rank, Team, Total_DVOA, Record, DAVE, DAVE_Rank, OFF_Rank, DEF_DVOA, DEF_Rank, ST_DVOA, ST_Rank from DVOA_1 
;

SELECT season, week, rank, record, DAVE_Rank from DVOA where Team = "GB" AND season = 2011;