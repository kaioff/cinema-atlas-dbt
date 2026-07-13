{{ config(materialized='table') }}

with reviews as (
    select
        cast(id as bigint) as film_id,
        results,
        source_file
    from {{ source('tmdb_bronze', 'tmdb_reviews_validated') }}
),

exploded as (
    select
        film_id,
        explode(results) as r,
        source_file
    from reviews
)

select distinct
    r.id                                            as review_id,
    film_id,
    r.author                                        as author,
    r.author_details.username                       as author_username,
    cast(r.author_details.rating as double)         as author_rating,
    r.content                                       as content,
    to_timestamp(r.created_at)                      as created_at,
    to_timestamp(r.updated_at)                      as updated_at,
    r.url                                           as url,
    {{ lineage_cols('reviews') }}
from exploded