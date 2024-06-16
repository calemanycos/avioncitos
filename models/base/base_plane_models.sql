{{ config(materialized="table") }}

with
    source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "plane_models") }}),

    renamed as (

        select
            {{ dbt_utils.generate_surrogate_key(["code","description"]) }} as plane_model_id,
            code,
            description,
            _fivetran_synced,
            _fivetran_deleted

        from source
        where _fivetran_deleted = false

    )

select *
from renamed
