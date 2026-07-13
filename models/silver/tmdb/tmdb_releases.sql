{{ config(materialized='table') }}

with releases as (
    select
        cast(id as bigint) as film_id,
        countries,
        source_file
    from {{ source('tmdb_bronze', 'tmdb_releases_validated') }}
),

exploded as (
    select
        film_id,
        explode(countries) as c,
        source_file
    from releases
)

select distinct
    film_id,
    c.iso_3166_1                            as country_iso,
    {{ empty_to_null('c.certification') }}  as certification,
    {{ to_date10('c.release_date') }}       as release_date,
    cast(c.primary as boolean)              as is_primary,
    c.descriptors                           as descriptors,
    {{ lineage_cols('releases') }}
from exploded