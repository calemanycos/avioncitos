{% macro convert_ft_to_meters(ft) -%}
  {{ ft * 0.3048 }}
{%- endmacro %}