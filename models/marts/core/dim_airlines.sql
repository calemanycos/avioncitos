{{ config(materialized="incremental",  unique_key=['airline_id'],
        tags=['incremental']) }}

select
    airline_id,
    airline_iata,
    airline_name,
    _fivetran_synced,
    _fivetran_deleted
from {{ ref("stg_airlines") }}

{% if is_incremental() %}

  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}