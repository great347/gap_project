{% macro hash_column_name(column_name) %}

{% set hash_expression %}

  TO_HEX(SHA256({{ column_name }} ))

{% endset %}

{{ return(hash_expression) }}

{% endmacro %}




