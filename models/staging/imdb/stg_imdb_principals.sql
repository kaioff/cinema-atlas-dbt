select
    tconst,
    ordering,
    nconst,
    category,
    job
from {{ source('imdb', 'imdb_principals_validated') }}