{#
  Long/tall staging of the multi-valued movie attributes we fold into
  delimited columns on silver.tmdb_films: production companies, production
  countries, and spoken languages. One row per (film, attribute_type, value).
  Kept as a single tall model so the rollup in tmdb_films is one group-by.
#}

with movies as (
    select
        cast(id as bigint)      as film_id,
        production_companies,
        production_countries,
        spoken_languages
    from {{ source('tmdb_bronze', 'tmdb_movies_validated') }}
),

companies as (
    select film_id, 'company' as attr_type,
           c.name as attr_value
    from movies
    lateral view explode(production_companies) t as c
    where c.name is not null
),

countries as (
    select film_id, 'country' as attr_type,
           c.iso_3166_1 as attr_value
    from movies
    lateral view explode(production_countries) t as c
    where c.iso_3166_1 is not null
),

languages as (
    select film_id, 'language' as attr_type,
           l.english_name as attr_value
    from movies
    lateral view explode(spoken_languages) t as l
    where l.english_name is not null
)

select * from companies
union all
select * from countries
union all
select * from languages