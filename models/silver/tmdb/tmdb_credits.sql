{{ config(materialized='table') }}

with credits as (
    select * from {{ ref('stg_tmdb_credits') }}
),

people as (
    select person_id, name, profile_path, known_for_department
    from {{ ref('stg_tmdb_people') }}
)

select
    c.credit_id,
    c.film_id,
    c.person_id,
    c.credit_type,
    p.name                  as person_name,
    p.profile_path,
    p.known_for_department,
    c.character,
    c.cast_order,
    c.cast_id,
    c.department,
    c.job,
    {{ lineage_cols('credits') }}
from credits c
left join people p on c.person_id = p.person_id