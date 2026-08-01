select
    titleId as tconst,
    ordering,
    title,
    region,
    language,
    isOriginalLanguage as is_original_language
from {{ source('imdb', 'imdb_akas_validated') }}