{{ config(materialized='table') }}

with films as (
    select * from {{ ref('stg_tmdb_movies') }}
),

genres_rollup as (
    select
        film_id,
        concat_ws('|', sort_array(collect_set(genre_name))) as genres,
        concat_ws('|', sort_array(collect_set(cast(genre_id as string)))) as genre_ids
    from {{ ref('stg_tmdb_film_genres') }}
    group by film_id
),

attributes_rollup as (
    select
        film_id,
        concat_ws('|', sort_array(collect_set(case when attr_type = 'company'  then attr_value end))) as production_companies,
        concat_ws('|', sort_array(collect_set(case when attr_type = 'country'  then attr_value end))) as production_countries,
        concat_ws('|', sort_array(collect_set(case when attr_type = 'language' then attr_value end))) as spoken_languages
    from {{ ref('stg_tmdb_film_attributes') }}
    group by film_id
),

keywords_rollup as (
    select
        film_id,
        concat_ws('|', sort_array(collect_set(kw.name))) as keywords
    from {{ ref('stg_tmdb_keywords') }}
    lateral view explode(keywords) as kw
    group by film_id
)

select
    f.film_id,
    f.imdb_id,
    f.title,
    f.original_title,
    f.original_language,
    f.status,
    f.release_date,
    f.runtime,
    f.budget,
    f.revenue,
    f.popularity,
    f.vote_average,
    f.vote_count,
    f.adult,
    f.video,
    f.homepage,
    f.tagline,
    f.overview,
    f.collection_id,
    f.collection_name,
    f.poster_path,
    f.backdrop_path,
    g.genres,
    g.genre_ids,
    a.production_companies,
    a.production_countries,
    a.spoken_languages,
    k.keywords,
    {{ lineage_cols('movies') }}
from films f
left join genres_rollup     g on f.film_id = g.film_id
left join attributes_rollup a on f.film_id = a.film_id
left join keywords_rollup   k on f.film_id = k.film_id