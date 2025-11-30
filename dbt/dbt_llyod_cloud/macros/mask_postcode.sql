{% macro mask_postcode(column_name) -%}

    REGEXP_REPLACE(
        {{ column_name }}, 
        r'(^[^ ]+)(.*)$', 
        r'\1 ***'
    )

{%- endmacro -%}
