# Cinema Atlas — dbt

Denormalized Silver layer for Cinema Atlas, built with dbt on Databricks.

## Split of responsibilities

- **Databricks notebooks (unchanged):** API/TSV/SPARQL pulls → raw Bronze → `*_validated` data-quality tables.
- **dbt (this project):** everything from `*_validated` onward — denormalized Silver models.

## Design: denormalized, join-light

The old Databricks silver exploded 5 validated tables into 16 normalized tables that required joins at read time. This project collapses TMDB to **7 flat models**, folding multi-valued attributes into delimited columns and person names into the credits table so the web app reads its hot paths with zero joins.

| Model | Grain | Denormalization |
|---|---|---|
| `tmdb_films` | film | genres / companies / countries / languages → pipe-delimited columns |
| `tmdb_credits` | credit | cast + crew unioned; person name + profile_path folded in |
| `tmdb_film_genres` | film×genre | thin bridge, kept only for genre aggregation |
| `tmdb_people` | person | standalone (person profile pages) |
| `tmdb_reviews` | review | standalone |
| `tmdb_releases` | film×country | standalone |
| `tmdb_audience_trends` | film×snapshot | SCD2 time series from raw history |

## Layout

```
models/
  overview.md       docs site landing page (doc block)
  staging/tmdb/     thin views: type + unnest the validated bronze once
  silver/tmdb/      physical denormalized tables the app queries
macros/             helpers (empty_to_null, to_date10, lineage_cols)
                    + generate_schema_name (clean schema names, no dev prefix)
```

Staging models are views (cheap, no storage); silver models are tables.
Schemas materialize as `staging_cinema_atlas` and `silver_cinema_atlas`.

## Setup

```bash
pip install dbt-databricks
cp profiles.yml.example profiles.yml     # fill in host/http_path
export DATABRICKS_TOKEN=dapi...
```

Source catalog is set via the `tmdb_catalog` var in `dbt_project.yml` (currently `workspace`). In dbt Cloud, set the connection Catalog to `workspace` as well.

## Run

```bash
dbt deps
dbt run --select staging.tmdb        # build staging views first
dbt run --select silver.tmdb         # then the denormalized tables
dbt test --select silver.tmdb        # unique/not_null/accepted_values
```

Or everything at once: `dbt build --select tmdb`.

## Documentation

Every model and column is documented in the `_*.yml` schema files, with a project overview in `models/overview.md`. Browse it as a searchable site with an interactive lineage graph:

```bash
dbt docs generate     # compiles docs + lineage
dbt docs serve        # serves at http://localhost:8080
```

In **dbt Cloud**, docs generate automatically on each production run and appear under the **Documentation** link. The site includes every model with its columns and tests, source docs, compiled SQL, and an interactive **source → staging → silver** lineage graph.

## Notes

- `tmdb_audience_trends` is a full rebuild each run (reads raw history) — idempotent.
- Delimited columns split in the app with `.split('|')`. Genre *aggregation* uses `tmdb_film_genres`, not the delimited column.
- Validated row-for-row against the legacy notebook tables; small count differences trace to stale classifications / deleted reviews the dbt rebuild self-corrects.
- IMDb and Wikidata models are added next, following the same denormalized pattern.