{#
  Scalar movie fields, typed and cleaned. One row per film.
  Nested arrays (genres, companies, countries, languages) are handled in
  their own staging models so this stays one-row-per-film.
#}

with src as (
    select * from {{ source('tmdb_bronze', 'tmdb_movies_validated') }}
)

select
    cast(id as bigint)                              as film_id,
    {{ empty_to_null('imdb_id') }}                  as imdb_id,
    title,
    original_title,
    original_language,
    status,
    {{ to_date10('release_date') }}                 as release_date,
    cast(runtime as int)                            as runtime,
    cast(budget as bigint)                          as budget,
    cast(revenue as bigint)                         as revenue,
    cast(popularity as double)                      as popularity,
    cast(vote_average as double)                    as vote_average,
    cast(vote_count as int)                         as vote_count,
    cast(adult as boolean)                          as adult,
    cast(video as boolean)                          as video,
    {{ empty_to_null('homepage') }}                 as homepage,
    {{ empty_to_null('tagline') }}                  as tagline,
    overview,
    cast(get_json_object(belongs_to_collection, '$.id') as bigint)   as collection_id,
    get_json_object(belongs_to_collection, '$.name')                 as collection_name,
    poster_path,
    backdrop_path,
    source_file
from src
qualify row_number() over (partition by cast(id as bigint) order by 1) = 1