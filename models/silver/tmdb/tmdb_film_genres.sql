{{ config(materialized='table') }}

select
    film_id,
    genre_id,
    genre_name,
    cast('tmdb' as string)    as source_system,
    cast('movies' as string)  as source_endpoint,
    current_timestamp()       as loaded_at
from {{ ref('stg_tmdb_film_genres') }}