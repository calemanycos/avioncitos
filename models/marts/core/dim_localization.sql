{{ config(materialized="incremental",  unique_key=['localization_id'],
        tags=['incremental']) }}

with localization as (
    select
        localization_id,
        a.airport_id,
        a.airport_iata,
        a.airport_icao,
        a.airport_name,
        l.airport_city,
        l.country_iata,
        l.country_name,
        l.country_id,
        a.latitude,
        a.longitude,
        a.altitude_ft,
        a.hours_utc_offset,
        a.zona_horaria,
        a.tz_timezone,
        a.type,
        a.source,
        a._fivetran_synced,
        a._fivetran_deleted
    from {{ ref("stg_airports") }} a
    inner join {{ ref("stg_localization") }} l
        on a.airport_id = l.airport_id
)

select *
from localization
{% if is_incremental() %}
  where _fivetran_synced > (select max(_fivetran_synced) from localization)
{% endif %}