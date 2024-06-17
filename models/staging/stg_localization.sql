{{ config(materialized="incremental",  unique_key=['localization_id'],
        tags=['incremental']
) }}

with max_synced as (
  select 
    a.airport_id,
    a.airport_iata,
    a.airport_icao,
    a.airport_name,
    a.airport_city,
    l.country_id,
    l.country_iata,
    l.country_name,
    a._fivetran_synced,
    a._fivetran_deleted,
    max(a._fivetran_synced) over () as max_synced
  from {{ ref("base_airports") }} a
  inner join {{ ref("base_countries") }} l
  on a.country_name = l.country_name
)
select 
  {{      dbt_utils.generate_surrogate_key(["airport_id", "airport_iata","airport_icao","country_iata","country_id","airport_city"])}} as localization_id,
  airport_id,
  airport_iata,
  airport_icao,
  airport_name,
  airport_city,
  country_id,
  country_iata,
  country_name,
  _fivetran_synced,
  _fivetran_deleted
from max_synced
{% if is_incremental() %}
  where _fivetran_synced > max_synced
{% endif %}