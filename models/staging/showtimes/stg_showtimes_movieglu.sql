with source as (
    select * from {{ source('movieglu', 'movieglu_showtimes_raw') }}
),

deduped as (
    select *,
        row_number() over (
            partition by movieglu_film_id, cinema_id, show_date, start_time
            order by load_ts desc
        ) as _rn
    from source
)

select
    movieglu_film_id,
    imdb_title_id,
    film_name,
    cinema_id,
    cinema_name,
    distance,
    version_type,
    start_time,
    end_time,
    show_date,
    query_lat,
    query_lng,
    load_ts
from deduped
where _rn = 1