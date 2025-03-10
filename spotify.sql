-- ADVANCE SQL PROJECT -- SPOTIFY DATASET
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
	);


-- EDA

select count(*) from spotify;

select count(distinct artist) from spotify;

select count(distinct album) from spotify;

select distinct album_type from spotify;

select duration_min from spotify;

select max(duration_min) from spotify;
select min(duration_min) from spotify;

select count(distinct channel) from spotify;

select distinct most_played_on from spotify;

-- DATA ANALYSIS 

-- 1] RETERIVE THE NAMES OF ALL TRACKS THAT HAVE MORE THAN 1 BILLION STREAMS.

select * from spotify where stream>1000000000;


-- 2] LIST ALL THE ALBUMS ALONG THERE RESPECTIVE ARTIST
select album,artist from spotify;

-- 3] GET THE TOTAL NUMBER OF COMMENTS FOR TRACKS WHERE LICENSED = TRUE
select sum(comments) as total_comments
from spotify 
where licensed = 'true';

-- 4] FIND ALL THE TRACK THAT BELONGS TO THE ALBUM TYPE SINGLE
select * from spotify
where album_type = 'single';

-- 5] count the total number of tracks by each artist
select artist,count(*) as total_no_songs
from spotify
group by artist
order by 5 desc;

-- 6] CALCULATE THE AVERAGE DENCIBILITY OF TRACK IN EACH ALBUM
select album,
avg(danceability) as avg_danceability from spotify
group by 1
order by 2 desc;

-- 7] FIND THE TOP 5 TRACKS WITH THE HIGHEST ENERGY VALUES
select track, max(energy)
from spotify
group by 1
order by 2 desc 
limit 5;

-- 8] LIST ALL THE TRACK ALONG WITH THERE VIEWS AND LIKES WHERE OFFICIAL_VIDEO = TRUE
select track,
sum(views) as total_view,
sum(likes) as total_likes
from spotify
group by 1
order by 2 desc
limit 5;

-- 9] FOR EACH ALBUM CALCULATE THE TOTAL VIEW OF ALL ASSOCIATED TRACKS.
select album,
track, sum(views)
from spotify
group by 1,2
order by 3 desc;

-- 10] RETERIVE THE TRACK NAMES THAT HAVE BEEN STREAMED ON SPOTIFY MORE THAN YOUTUBE
select * from
(select 
track,
sum(case when most_played_on = 'Youtube' then stream end) as streamed_on_youtube,
sum(case when most_played_on = 'Spotify' then stream end) as streamed_on_spotify
from spotify
group by 1) as t1
where streamed_on_spotify > streamed_on_youtube
and 
streamed_on_youtube <> 0;

-- 11] FIND THE TOP 3 MOST -VIEWED TRACKS FOR EACH ARTIST USING WINDOW FUNCTION

-- EACH ARTIST AND TOTAL VIEW FOR EACH TRACK
-- TRACK WITH HIGHEST VIEW FOR EACH ARTIST (WE NEED TOP)
-- DENSE RANK
-- CTE FILTER RANK <=3

with ranking_artist
as 
(
select
artist,
track, 
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1,2
order by 1, 3 desc
)
select * from ranking_artist
where rank <= 3;

-- 12] WRITE QUERY TO FIND TRACKS WHERE THE LIVENESS SCORE IS ABOVE THE AVERAGE

select track , artist , liveness
from spotify
where liveness > (select avg(liveness) from spotify);

-- 13] WITH CLAUSE TO CALCULATE THE DIFFERENCE BETWEEN THE 
--HIGHEST AND LOWEST ENERGY VALUE TRACK IM EACH.
with cte
as(
select album,
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1
)
select 
album,
highest_energy - lowest_energy as energy_diff
from cte
order by 2 desc;

-- 14] FIND TRACKS WHERE THE ENERGY TO LIVENESS RATION IS GREATER THAN 1.2
select
track ,
energy / nullif(liveness , 0) as energy_liveness
from spotify
where liveness <> 0 and (energy / nullif(liveness ,0)) > 1.2;


-- 15] CALCULATE THE CUMULATIVE SUM OF LIKES FOR TRACKS ORDERED BY THE NUMBER OF VIEWS
-- WINDOWS FUNCTION

with cte 
as
(
select 
track,
sum(likes) over (order by views desc) as cumalative_sum
from spotify
)
select * from cte;

