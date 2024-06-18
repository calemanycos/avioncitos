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
where _fivetran_deleted = false
{% if is_incremental() %}

 and _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}