{{ config(materialized="table") }}

with
    source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "countries") }}),

    renamed as (

        select
            {{ dbt_utils.generate_surrogate_key(["code","description"]) }} as country_id,
            code as iata_country,
            trim(description) as country_name,
            cast(_fivetran_synced as timestamp) as _fivetran_synced,
            cast(_fivetran_deleted as boolean) as _fivetran_deleted

        from source
        where _fivetran_deleted = false
    )

select *
from renamed
