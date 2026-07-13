{% docs __overview__ %}

# Cinema Atlas — dbt

Denormalized Silver layer for **Cinema Atlas**, a multi-source film knowledge
graph and analytics platform built as a graduate project at the University of
San Francisco.

## What this project owns

Databricks notebooks handle ingestion (TMDB API, IMDb TSV, Wikidata SPARQL) and
land raw data into the **bronze** layer, including the `*_validated`
data-quality tables. **dbt takes over from there** — every model in this project
reads from validated bronze and builds the denormalized **silver** layer that
the web application queries.

## Design principle: denormalized, join-light

The original notebook-built silver exploded the TMDB source into 16 normalized
tables that required joins at read time. This project collapses TMDB into
**7 flat models**, trading storage for query simplicity:

- **`tmdb_films`** — one row per film, with genres / companies / countries /
  languages folded into pipe-delimited columns. No joins to display a film.
- **`tmdb_credits`** — cast and crew unioned into one table, with each person's
  name and headshot folded in. No join to show a film's cast with photos.
- **`tmdb_film_genres`** — the one thin bridge kept, purely for genre
  aggregation charts.
- **`tmdb_people`**, **`tmdb_reviews`**, **`tmdb_releases`** — standalone flat tables.
- **`tmdb_audience_trends`** — SCD2 time series of metric snapshots, read from
  the full append-only movie history.

## Layers

- **staging** (`staging_cinema_atlas`) — thin views that type and unnest the
  validated bronze once. No storage.
- **silver** (`silver_cinema_atlas`) — physical denormalized tables the app reads.

## Data quality

Every model carries schema tests — primary-key `unique` + `not_null`,
`accepted_values` on enums like `credit_type`. The denormalized output has been
validated row-for-row against the legacy notebook tables; remaining differences
trace to the notebook tables holding stale TMDB classifications and deleted
reviews, which the dbt full-rebuild correctly self-corrects.

## Running

```bash
dbt run                       # build staging views then silver tables
dbt test                      # run all schema tests
dbt docs generate && dbt docs serve   # browse this documentation
```

Set the source catalog via the `tmdb_catalog` var in `dbt_project.yml`.

{% enddocs %}