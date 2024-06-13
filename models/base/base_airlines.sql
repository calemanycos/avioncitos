{{ config(materialized='table') }}

with source as (

    select * from {{ source('openflights', 'airline_iata') }}

),

renamed as (

    select
        code as airline_iata,
        description

    from source

)

select * from renamed
