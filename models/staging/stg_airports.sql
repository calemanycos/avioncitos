{{ config(materialized="incremental",  unique_key=['airport_id'],
        tags=['incremental']
) }}

with
    base as (select * from {{ ref("base_airports") }}),

    transformed as (
        select
            airport_id,
            airport_name,
            airport_city,
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
{% if is_incremental() %}

  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}