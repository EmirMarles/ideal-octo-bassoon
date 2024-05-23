-- how many drama films are there
with Drama as(
select title, genres
from movie_dataset
where genres like 'Drama'
)
select count(genres)
from Drama;

with languages as(
select title, original_language
from movie_dataset
order by original_language desc
), 
-- how many movies are in particular language
language_rank as(
select *, dense_rank()over(
partition by original_language and title order by original_language desc) as language_code
from languages)
-- how many movies with a particular language code as above 
select original_language, count(language_code)
from language_rank
where language_code = 1
group by original_language;

-- top 10 movies according to vote counts
with top_movies as
(select title, vote_count
from movie_dataset
order by vote_count desc 
), ranking_top as(
select *, dense_rank()over(
partition by vote_count and title order by vote_count desc) as ranking
from top_movies)
-- final top 10 movies according to votes
select *
from ranking_top
where ranking <11;
-- How many movies from the 20th century are liked by people
with year_of as(
select title, year(release_date) as date_of_release
from movie_dataset
where year(release_date) <2000
order by year(release_date) desc)

select count(title)
from year_of;
-- popularity of the war films before the 20th ct and after 
select title, year(release_date) as years, genres, popularity
from movie_dataset
where genres like '%War%'
order by years asc;
-- popularity of war movies 
select sum(popularity) as popularity_war_movies
from movie_dataset
where genres like "%War%" and release_date <1950
;
-- rolling total of popularity of movies by months
with popularity_CTE as(
select title, substring(release_date, 6, 2) as month_, popularity
from movie_dataset
order by month_
), rolling_tot_pop as(
select *, sum(popularity) over(partition by month_ order by popularity) as rolling_total_popularity
from popularity_CTE)
-- maximum popularity for the given month
select month_, max(rolling_total_popularity) as final_popularity
from rolling_tot_pop
group by month_
order by final_popularity desc
;
-- how many are there non-enlish movies
select count(original_language) as movies_not_in_english
from movie_dataset
where original_language != 'en'
;
-- average vote of all the comedies from 2000
with comedy as(
select title, year(release_date), genres, vote_average
from movie_dataset
where genres like "%Comedy%" and year(release_date) > 2000
order by year(release_date) asc
)
select avg(vote_average) as average_score
from comedy