select
    id as film_id,
    keywords
from {{ source('tmdb_bronze', 'tmdb_keywords_validated') }}