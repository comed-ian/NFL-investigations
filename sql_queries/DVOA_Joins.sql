USE devenvironment;

/*create DVOA table with team names instead of abbreviations, calculate next_week column (since DVOA is published after week results)*/
DROP TABLE DVOA_teams;
create table DVOA_teams(
SELECT Season, Week,  Week+1 as Next_Week, Rank, Total_DVOA, Record, DAVE, DAVE_Rank, OFF_Rank, DEF_DVOA, DEF_Rank, ST_DVOA, ST_Rank, l.team as team from DVOA as d
left JOIN lookup AS l 
ON d.Team= l.abbreviationalt
)
;
select * from DVOA_teams;


/*Add home DVOA rankings to seasons_spreads table*/
DROP TABLE DVOA_seasons_spreads_prelim;
create table DVOA_seasons_spreads_prelim(
SELECT s.gamedatetext, s.season, s.week, d.week as dWeek, d.Next_Week, d.rank as HomeRank, d.DAVE_rank as HomeDAVE, s.away, s.home, s.winner, s.RoadOpen, s.roadclose, s.ptswin, s.ptsloss, s.Margin_of_V, s.spread_error FROM  seasons_spreads AS s
left JOIN dvoa_teams as d
ON (s.Season = d.Season AND s.Week = d.Next_Week AND s.Home = d.team)
)
;

Select * from dvoa_seasons_spreads_prelim;

/*Add away DVOA rankings to seasons_spreads table*/
DROP TABLE DVOA_seasons_spreads;
create table DVOA_seasons_spreads(
SELECT s.gamedatetext as gamedate, s.season, s.week, s.Next_Week, s.HomeRank, s.HomeDAVE, d.rank as AwayRank, d.DAVE_rank as AwayDAVE, s.away, s.home, s.winner, s.roadopen, s.roadclose, s.ptswin, s.ptsloss, s.Margin_of_V, s.spread_error FROM dvoa_seasons_spreads_prelim as s
left JOIN  dvoa_teams as d
ON (s.Season = d.Season AND s.Week = d.Next_Week AND s.away = d.team)
)
;

SELECT * FROM DVOA_seasons_spreads WHERE abs(spread_error) >1.5;

/* testing validation */
DROP TABLE DVOA_seasons_spreads_dev;
create table DVOA_seasons_spreads_dev(
SELECT AwayRank-HomeRank as RankDiff, season, week, HomeRank, HomeDAVE, AwayRank, AwayDAVE, away, home, winner, roadclose, ptswin, ptsloss, Margin_of_V, spread_error FROM dvoa_seasons_spreads
)
;

SELECT * from DVOA_seasons_spreads_dev WHERE RankDiff = 30 OR RankDiff = 17 OR RankDiff = 10 OR RankDiff = 8;
SELECT * from DVOA_seasons_spreads_dev WHERE abs(spread_error) >0 AND roadclose = 3;