select
    tconst,
    snapshot_date,
    cast(averageRating as double) as average_rating,
    cast(numVotes as long) as num_votes
from {{ source('imdb', 'imdb_ratings_validated') }}