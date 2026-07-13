{{ config(materialized='table') }}

select
    person_id,
    imdb_id,
    name,
    gender,
    birthday,
    deathday,
    known_for_department,
    place_of_birth,
    popularity,
    biography,
    profile_path,
    {{ lineage_cols('people') }}
from {{ ref('stg_tmdb_people') }}