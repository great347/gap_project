{% macro clean_fullname (column_name) %}

{% set cleaned_name_expression %}
    -- First, define the expression to clean the name
    TRIM(REGEXP_REPLACE(
        {{ column_name }}, 
        r'^(Mr\.?|Mrs\.?|Miss\.?|Ms\.?|Dr\.?|Sir\.?)\s*', 
        ''
    ))
{% endset %}

{{ return(cleaned_name_expression) }}

{% endmacro %}