{# ---------------------------------------------------------------------------
   empty_to_null: mirror of the notebook's empty_to_null — trims and nulls blanks
--------------------------------------------------------------------------- #}
{% macro empty_to_null(col) -%}
    nullif(trim({{ col }}), '')
{%- endmacro %}


{# ---------------------------------------------------------------------------
   to_date10: parse the first 10 chars of a string as yyyy-MM-dd (mirrors notebook)
--------------------------------------------------------------------------- #}
{% macro to_date10(col) -%}
    try_to_date(substring({{ col }}, 1, 10), 'yyyy-MM-dd')
{%- endmacro %}


{# ---------------------------------------------------------------------------
   lineage_cols: the standard lineage columns appended to every silver model
   (replaces the notebook's add_lineage helper)
--------------------------------------------------------------------------- #}
{% macro lineage_cols(endpoint) -%}
    cast('tmdb' as string)           as source_system,
    cast('{{ endpoint }}' as string) as source_endpoint,
    current_timestamp()              as loaded_at
{%- endmacro %}