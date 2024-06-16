{{ config(materialized="table") }}

with
    base as (select * from {{ ref("base_airports") }}),

    transformed as (
        select
            airport_id,
            airport_name,
            city,
            country_name,
            airport_iata,
            airport_icao,
            latitude,
            longitude,
            altitude_ft,
            hours_utc_offset,
            zona_horaria,
            tz_timezone,
            type,
            source,
            _fivetran_synced,
            _fivetran_deleted

        from base
    )

select *
from transformed
