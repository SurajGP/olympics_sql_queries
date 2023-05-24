-- Q1: Find out how many olympic games have been held.

select  count(distinct games) as Total_olympics from olympics_history;

-- Q2: List down all the olympic games and the cities held in  held so far.
-- (Date issue at 1956 olympics hence the query is returning an extra row)

select  distinct games as Olympic, city  from olympics_history
order by olympic;

-- Q3: Mention the total no. of countries who participated in each olympic game.

create view t1 as (
select Games, Count(games) as Countries_Participated from 
(select region, games from noc_regions 
join olympics_history on noc_regions.noc = olympics_history.noc
group by games,noc_regions.region
order by games) as abc
group by games
order by games
);
select * from t1;

-- Q4(1) : Which year saw the  highest no. of countries participating in olympics.

select concat(Games," - ",countries_participated) as Highest_Participation  from t1
order by Countries_participated desc
limit 1; 

-- Q4(2):  Which year saw the lowest no.of countries participating in Olympics.

select concat(Games," - ",countries_participated) as Lowest_Participation  from t1
order by Countries_participated asc
limit 1;


 -- Q5:  Find the countries that have participated in all olympic games.

with t1 as (select countries_participated,count(*) as total from  (select distinct(games), noc_regions.region as Countries_Participated from olympics_history
join noc_regions on noc_regions.noc = olympics_history.noc
order by games) as abc
group by countries_participated
order by total desc),
t2 as (select  count(distinct games) as Total_olympics from olympics_history)
select countries_participated,total from t2 join t1 on   t1.total = t2.total_olympics;


-- Q6: Find out  all sports that have been played in all summer Olympic games.
with temp1 as (select count(distinct games) as Total_games from olympics_history
where season = "summer"
order by games),

temp2 as (select distinct(sport), games from olympics_history
where season = "summer"
order by games
),
temp3 as (select sport, count(games) as no_games from temp2
group by sport)

select sport,no_games from temp1 join temp3 on temp1.total_games = temp3.no_games;

-- Q7: Find out sports that have been played only once in the history of olympic games.

with t1 as 
(select  sport,count(*) as total from (select distinct games,sport from olympics_history
order by games) as abc
group by sport)
select * from t1 where total= 1;

-- Q8: Find the total number of sports played in each olympic games.

select distinct games, count(sport) as total from  
(select distinct sport, games from olympics_history
order by games) as abc
group by games
order by games;

-- Q9: Find oldest athletes to win a gold medal. 

select * from (
select *, rank () over( order by age desc) as "rnk" from
(select name,team,games,
case when age = "NA" then 0 else age end as age 
from olympics_history
where medal = "gold" 
order by age desc) as abc)
 as bcd
 where rnk = 1;


-- Q10: Find the ratio of male and female athletes participated in all olympic games. 

with t1 as 
(select *, row_number() over(order by cnt) as rn from (
select sex,count(1) as cnt 
from olympics_history
group by sex) as abc),
min_c as ( select cnt from t1 where rn = 1),
max_c as (select cnt from t1 where rn = 2)
select concat( round( max_c.cnt / min_c.cnt,2),":1") as "Male : Female Ratio" from min_c,max_c;



-- Q11: Find the top 5 athletes who have won the most gold medals.

with temp1 as (select name, count(*) as total_medals  from olympics_history
where medal = "gold"
group by name
order by count(*) desc
),
temp2 as (select *, dense_rank()over(order by total_medals desc ) as D_rank  from temp1 )
select * from temp2 where d_rank<=5;

-- Q12: Find the athletes who have won the most medals (Gold + Silver + Bronze). 

with temp1 as (
select *, dense_rank() over(order by total desc) as rnk from (select name, team,count(1) as total from olympics_history
where medal in("gold","silver","bronze") !="na"
group by name
order by total desc) as abc)
select * from temp1 where rnk <=5;

-- Q13: Find the athletes who have won the most medals (Gold + Silver + Bronze).

with temp1 as (
select *, dense_rank() over(order by Total_Medals desc) as rnk from (select noc_regions.region,count(1) as Total_Medals from olympics_history
join noc_regions on noc_regions.noc = olympics_history.noc
where medal in("gold","silver","bronze") !="na"
group by noc_regions.region
order by Total_Medals desc) as abc)
select * from temp1 where rnk <=5;

-- Q14 : List down total Gold,Silver,Bronze medals won by each country.

with t1 as (select noc_regions.region as country , medal,count(*)  as total_medals
from noc_regions
join olympics_history on  noc_regions.noc = olympics_history.noc
where medal !="na"
group by country,medal
order by country) ,
t2 as 
(select distinct Country,
case 
when medal = "Gold" then total_medals
else 0
end as "Gold"
from t1),
t3 as 
(select Country,
case 
when medal = "Silver" then total_medals
else 0
end as "Silver"
from t1),

t4 as 
(select Country,
case 
when medal = "Bronze" then total_medals
else 0
end as "Bronze"
from t1),
t5 as 
(select distinct t3.country  ,silver,bronze from t4
left join t3 on t3.country = t4.country
group by  country),
t6 as (
select  t2.country,Gold,Silver,Bronze from t5 
 join t2 on t5.country = t2.country
group by country)
select * from t6
order by Gold desc;

-- Q15: In which sport or event India has won highest medals.

with t1 as (select *, dense_rank() over( order by medals_won desc) as rnk from 
(select sport,count(1) as Medals_won from olympics_history
where medal !="na" and team = "india"
group by sport
order by medals_won desc) as abc)
select sport,medals_won from t1 where rnk = 1;

-- Q16: Break down all Olympic games in which India has won medal for hockey and medals in each olympics.

select team,games , count(1) as medals_won from olympics_history
where medal !="na"and team = "india" and sport = "hockey"
group by games
order by medals_won desc

-- Q17: List all the countries that have won silver/bronzebut not gold.

with t1 as (select noc_regions.region as country , medal,count(*)  as total_medals
from noc_regions
join olympics_history on  noc_regions.noc = olympics_history.noc
where medal!="na"
group by country,medal
order by country) ,
t2 as 
(select distinct Country,
case 
when medal = "Gold" then total_medals
else 0
end as "Gold"
from t1),
t3 as 
(select Country,
case 
when medal = "Silver" then total_medals
else 0
end as "Silver"
from t1),

t4 as 
(select Country,
case 
when medal = "Bronze" then total_medals
else 0
end as "Bronze"
from t1),
t5 as 
(select distinct t3.country  ,silver,bronze from t4
left join t3 on t3.country = t4.country
group by  country),
t6 as (
select  t2.country,Gold,Silver,Bronze from t5 
 join t2 on t5.country = t2.country
group by country)
select * from t6
where gold = 0  and (silver > 0 or bronze > 0)
order by silver desc