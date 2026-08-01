select
    tconst,
    snapshot_date,
    average_rating,
    num_votes
from {{ ref('stg_imdb_ratings') }}