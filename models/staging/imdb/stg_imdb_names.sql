select
    nconst,
    primaryName,
    birthYear,
    deathYear
from {{ source('imdb', 'imdb_names_validated') }}