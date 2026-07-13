{#
  Unifies cast[] and crew[] from the credits endpoint into one long table
  with a credit_type discriminator. Cast-only fields (character, cast_order)
  are null for crew rows; crew-only fields (department, job) are null for cast.
  Person name/profile_path are folded in at the silver layer.
#}

with credits as (
    select
        cast(id as bigint) as film_id,
        cast,
        crew,
        source_file
    from {{ source('tmdb_bronze', 'tmdb_credits_validated') }}
),

cast_rows as (
    select
        c.credit_id                     as credit_id,
        film_id,
        cast(c.id as bigint)            as person_id,
        'cast'                          as credit_type,
        c.character                     as character,
        cast(c.order as int)            as cast_order,
        cast(c.cast_id as int)          as cast_id,
        cast(null as string)            as department,
        cast(null as string)            as job,
        source_file
    from credits
    lateral view explode(cast) t as c
),

crew_rows as (
    select
        c.credit_id                     as credit_id,
        film_id,
        cast(c.id as bigint)            as person_id,
        'crew'                          as credit_type,
        cast(null as string)            as character,
        cast(null as int)               as cast_order,
        cast(null as int)               as cast_id,
        c.department                    as department,
        c.job                           as job,
        source_file
    from credits
    lateral view explode(crew) t as c
),

unioned as (
    select * from cast_rows
    union all
    select * from crew_rows
)

select * from unioned
qualify row_number() over (partition by credit_id order by 1) = 1