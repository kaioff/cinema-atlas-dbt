select
    tconst,
    primaryTitle as title,
    originalTitle as original_title,
    start_year,
    end_year,
    runtime_minutes,
    genres,
    is_adult
from {{ ref('stg_imdb_titles') }}
where titleType = 'movie'