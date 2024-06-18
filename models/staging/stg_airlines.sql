{{ config(materialized="incremental",  unique_key=['airline_id'],
        tags=['incremental']
) }}

with
    base as (select * from {{ ref("base_airlines") }}),

    transformed as (
        select
            airline_id,
            airline_iata,
            airline_name,
            _fivetran_synced,
            _fivetran_deleted

        from base
        where _fivetran_deleted = false
    )

select *
from transformed

{% if is_incremental() %}

  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}