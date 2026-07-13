{{ config(materialized='table') }}

with snapshots as (
    select distinct
        cast(id as bigint)          as film_id,
        cast(popularity as double)  as popularity,
        cast(vote_average as double) as vote_average,
        cast(vote_count as int)     as vote_count,
        cast(revenue as bigint)     as revenue,
        cast(budget as bigint)      as budget,
        load_ts                     as snapshot_ts
    from {{ source('tmdb_bronze', 'tmdb_movies_raw') }}
)

select
    film_id,
    popularity,
    vote_average,
    vote_count,
    revenue,
    budget,
    snapshot_ts,
    row_number() over (partition by film_id order by snapshot_ts desc) = 1 as is_current,
    current_timestamp() as loaded_at
from snapshots