{{ config(materialized='table') }}

with source as (

    select * from {{ source('openflights', 'countries') }}

),

renamed as (

    select
    {{ dbt_utils.generate_surrogate_key(['code']) }} as country_id,
    code as IATA_COUNTRY,
    description

    from source

)

select * from renamed
