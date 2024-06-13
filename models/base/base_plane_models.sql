{{ config(materialized='table') }}

with source as (

    select * from {{ source('openflights', 'plane_models') }}

),

renamed as (

    select
    {{ dbt_utils.generate_surrogate_key(["code"]) }} as plane_model_id,
        code,
        description

    from source

)

select * from renamed
