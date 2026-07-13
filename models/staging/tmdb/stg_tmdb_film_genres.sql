{#
  One row per (film, genre). Explodes movies.genres[].
  Feeds both the delimited-string rollup on silver.tmdb_films AND the thin
  exploded silver.tmdb_film_genres table used for analytics aggregations.
#}

with movies as (
    select
        cast(id as bigint) as film_id,
        genres
    from {{ source('tmdb_bronze', 'tmdb_movies_validated') }}
),

exploded as (
    select
        film_id,
        explode(genres) as g
    from movies
)

select distinct
    film_id,
    cast(g.id as int)   as genre_id,
    g.name              as genre_name
from exploded
where g.id is not null