{{ config(materialized="table") }}

with
    source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "countries") }}),

    renamed as (

        select
            {{ dbt_utils.generate_surrogate_key(["code"]) }} as country_id,
            code as iata_country,
            description,
            _fivetran_synced,
            _fivetran_deleted

        from source
        where _fivetran_deleted = false
    )

select *
from renamed
