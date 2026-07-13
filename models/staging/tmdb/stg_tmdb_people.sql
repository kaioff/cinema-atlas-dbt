{#
  Scalar person fields, typed and cleaned. One row per person.
  profile_path and name are folded into tmdb_credits downstream so the app
  can render cast/crew without joining back to people.
#}

with src as (
    select * from {{ source('tmdb_bronze', 'tmdb_people_validated') }}
)

select
    cast(id as bigint)                  as person_id,
    {{ empty_to_null('imdb_id') }}      as imdb_id,
    name,
    cast(gender as int)                 as gender,
    {{ to_date10('birthday') }}         as birthday,
    {{ to_date10('deathday') }}         as deathday,
    known_for_department,
    {{ empty_to_null('place_of_birth') }} as place_of_birth,
    cast(popularity as double)          as popularity,
    biography,
    profile_path,
    source_file
from src
qualify row_number() over (partition by cast(id as bigint) order by 1) = 1