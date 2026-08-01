select
    p.tconst,
    p.ordering,
    p.nconst,
    n.primaryName as person_name,
    p.category,
    p.job
from {{ ref('stg_imdb_principals') }} p
left join {{ ref('stg_imdb_names') }} n on p.nconst = n.nconst