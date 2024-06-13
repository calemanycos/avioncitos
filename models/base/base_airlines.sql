{{ config(materialized='table') }}

with source as (

    select * from {{ source('SNOWFLAKE_DB_OPENFLIGHTS', 'airline_iata') }}

),

renamed as (

    select
        code as airline_iata,
        description,
        _fivetran_synced,
        _fivetran_deleted
 
    from source
   WHERE _fivetran_deleted = FALSE

)

select * from renamed
