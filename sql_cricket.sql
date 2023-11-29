-- 1. Import the csv file to a table in the database.

create database ICC_Test_Batting_Figures;
use ICC_Test_Batting_Figures;
desc `icc test batting figures (1)`;
select * from `icc test batting figures (1)`;

-- 2.	Remove the column 'Player Profile' from the table.

alter table `icc test batting figures (1)` drop column `Player Profile`;
select * from `icc test batting figures (1)`;

-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.

alter table `icc test batting figures (1)` add column Player_Name text after Player ;
update `icc test batting figures (1)` set Player_Name = substring_index(Player, '(', 1);

alter table `icc test batting figures (1)` add column Country text after Player_Name;
update `icc test batting figures (1)` set 
Country = substring_index(substring_index(player,'(',-1),')',1);

-- 4. From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.

alter table `icc test batting figures (1)` add column start_year text after Span;
update `icc test batting figures (1)` set start_year = substr(Span,1,4);

alter table `icc test batting figures (1)` add column end_year text after start_year;
update `icc test batting figures (1)` set end_year = substr(Span,6);

-- 5.	The column 'HS' has the highest score scored by the player so far in any given match. 
-- The column also has details if the player had completed the match in a NOT OUT status.
 -- Extract the data and store the highest runs and the NOT OUT status in different columns.
 
alter table `icc test batting figures (1)` add column High_score text ;
update `icc test batting figures (1)` set High_score = trim(trailing '*' from hs) ;

alter table `icc test batting figures (1)` add column out_status text ;
update `icc test batting figures (1)` set out_status = if(instr(HS,'*') = 0,'out','not out');

-- 6. Using the data given, considering the players who were active in the year of 2019,
-- create a set of batting order of best 6 players using the selection criteria 
-- of those who have a good average score across all matches for India.

select *,dense_rank()over(order by avg desc) as highest_avg_rank from `icc test batting figures (1)`
where country like '%india%' and end_year= '2019'
limit 6;

-- 7.Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria of those
-- who have the highest number of 100s across all matches for India.

select * from `icc test batting figures (1)` where Country like '%india%' 
and end_year= 2019 order by `100` desc limit 6;

-- 8.Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players
-- using 2 selection criteria of your own for India.

select * from `icc test batting figures (1)` where Country like '%india%' 
and end_year= 2019 order by avg desc,runs desc limit 6;
 
 -- 9.Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given,
 -- considering the players who were active in the year of 2019,
 -- create a set of batting order of best 6 players using the selection criteria
 -- of those who have a good average score across all matches for South Africa.
 
 create view Batting_Order_GoodAvgScorers_SA as
 (select * from `icc test batting figures (1)` where Country like '%SA%' 
and end_year= 2019 order by Avg desc limit 6);

select * from Batting_Order_GoodAvgScorers_SA;

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ 
-- Using the data given, considering the players who were active in the year of 2019, 
-- create a set of batting order of best 6 players using the selection criteria 
-- of those who have highest number of 100s across all matches for South Africa.
 
 create view Batting_Order_HighestCenturyScorers_SA as
 (select * from `icc test batting figures (1)` where Country like '%SA%' 
and end_year= 2019 order by `100` desc limit 6);

select * from Batting_Order_HighestCenturyScorers_SA;

-- 11.Using the data given, Give the number of player_played for each country.

select Country_name,count(Country_name) as Number_of_Players from
(select case 
when country like "%/ICC" then substring_index(country,'/',1)
when country like "ICC/%" then substring_index(country,'/',-1)
else country
end as Country_name, country , player_name
from `icc test batting figures (1)`) temp group by Country_name ;


-- 12.Using the data given, Give the number of player_played for Asian and Non-Asian continent

 select count(*) as 'number of players',case
when Country in ('india','icc/india','sl','pak','icc/pak','bdesh','india/pak','afg','eng/india','icc/sl') then 'asian' 
when Country in ('aus','eng','eng/icc','icc/sa','icc/wi','wi','sa','nz','zim','icc/nz','aus/sa','aus/eng','ire','nz/wi','sa/zim','eng/sa','eng/ire') then 'non_asian'
end continent  from  `icc test batting figures (1)`
group by continent;
 
 ## EXTRA QUESTIONS
 
-- 1.List the players who played for more than one country. 

select  *  from
(select *, case 
when country like "%/ICC" then substring_index(country,'/',1)
when country like "ICC/%" then substring_index(country,'/',-1)
else country
end as Countries from `icc test batting figures (1)`)temp  where countries like '%/%';

-- 2. create a view for the Vintage era players who played for India whose term ended before the year 2000.

create view vintage_indian_players as
(select * from `icc test batting figures (1)` where  Country like '%ind%' and end_year < 2000);

-- 3. List all the Australian players who played for more than 20 years.

select Player_Name,Country,Span,(end_year-start_year) as years from `icc test batting figures (1)`
where country like '%aus%' and (end_year-start_year)>10;

-- 4. List all the players who scored maximum number of runs from each country.

select Player_Name,Country,Span,Runs from
(select *,dense_rank()over( partition by Country order by Runs desc) as run_rank 
from `icc test batting figures (1)`)temp where run_rank<2  
and Country not like '%/%'order by Runs desc;

-- 5. List all the players who played most no.of innings and not out by the end of atleast 20 matches.

select Player_Name,Country,Span,Inn,NO
from`icc test batting figures (1)` where NO>=20 
order by Inn desc limit 10;
