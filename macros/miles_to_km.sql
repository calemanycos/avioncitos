{% macro convert_miles_to_km(miles) -%}
  {{ miles * 1.60934 }}
{%- endmacro %}