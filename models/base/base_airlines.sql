{{ config(materialized="incremental",  unique_key=['airline_id'],
        tags=['incremental'] ) }}

with
    source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "airline_iata") }}),

    renamed as (
        select
            {{ dbt_utils.generate_surrogate_key(["code", "description"]) }} as airline_id,
            upper(code) as airline_iata,
            trim(description) as airline_name,
            cast(_fivetran_synced as timestamp) as _fivetran_synced,
            cast(_fivetran_deleted as boolean) as _fivetran_deleted

        from source
        where _fivetran_deleted = false

    
    )

select *
from renamed


{% if is_incremental() %}

  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})

{% endif %}