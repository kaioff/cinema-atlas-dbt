select
    titleId as tconst,
    ordering,
    title,
    region,
    language,
    isOriginalTitle as is_original_title
from {{ source('imdb', 'imdb_akas_validated') }}