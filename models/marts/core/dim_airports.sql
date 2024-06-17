{{ config(materialized="incremental",  unique_key=['airport_id'],
        tags=['incremental']) }}

select
    airport_id,
    airport_iata,
    airport_icao,
    airport_name,
    source,
    _fivetran_synced,
    _fivetran_deleted
from {{ ref("stg_airports") }}

{% if is_incremental() %}

  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}