{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {# 
      If a custom_schema_name is provided in the YAML config 
      (e.g., +schema: bronze), use ONLY that name, completely 
      ignoring the default_schema provided in profiles.yml.
    #}
    {%- if custom_schema_name is not none -%}

      {{ custom_schema_name | trim }}

    {# Otherwise, fall back to the default behavior for nodes without a specific layer config #}
    {%- else -%}

      {{ default_schema }}

    {%- endif -%}

{%- endmacro -%}
