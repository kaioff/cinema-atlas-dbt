with showtimes as (
    select * from {{ ref('stg_showtimes_movieglu') }}
),

films as (
    select distinct film_id, tconst
    from workspace.silver.matched_tconsts
),

joined as (
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
        s.load_ts,
        row_number() over (
            partition by f.film_id, s.cinema_id, s.show_date, s.start_time, s.version_type
            order by s.load_ts desc
        ) as _rn
    from showtimes s
    join films f on s.imdb_title_id = f.tconst
    where s.show_date = date(from_utc_timestamp(current_timestamp(), 'America/Los_Angeles'))
)

select
    film_id, movieglu_film_id, film_name, cinema_id, cinema_name,
    distance, version_type, start_time, end_time, show_date, load_ts
from joined
where _rn = 1