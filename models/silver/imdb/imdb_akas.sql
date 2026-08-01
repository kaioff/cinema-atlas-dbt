select
    tconst,
    ordering,
    title,
    region,
    language,
    is_original_language
from {{ ref('stg_imdb_akas') }}