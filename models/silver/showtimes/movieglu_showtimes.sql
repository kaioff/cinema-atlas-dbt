with showtimes as (
    select * from {{ ref('stg_showtimes_movieglu') }}
),

films as (
    select film_id, tconst
    from {{ source('workspace_silver', 'matched_tconsts') }}
)

select
    f.film_id,
    s.movieglu_film_id,
    s.film_name,
    s.cinema_id,
    s.cinema_name,
    s.distance,
    s.version_type,
    s.start_time,
    s.end_time,
    s.show_date,
    s.load_ts
from showtimes s
join films f on s.imdb_title_id = f.tconst