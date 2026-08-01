select
    tconst,
    titleType,
    primaryTitle,
    originalTitle,
    cast(startYear as int) as start_year,
    cast(endYear as int) as end_year,
    cast(runtimeMinutes as int) as runtime_minutes,
    genres,
    cast(isAdult as boolean) as is_adult
from {{ source('imdb', 'imdb_basics_validated') }}