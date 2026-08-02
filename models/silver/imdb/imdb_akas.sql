select
    tconst,
    ordering,
    title,
    region,
    language,
    is_original_title
from {{ ref('stg_imdb_akas') }}