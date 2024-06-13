{{ config(materialized='table') }}

with source as (

    select * from {{ source('SNOWFLAKE_DB_OPENFLIGHTS', 'routes') }}

),

renamed as (

    select
     {{ dbt_utils.generate_surrogate_key(['carrier_iata', 'origin_iata', 'dest_iata', 'year', 'quarter', 'month']) }} as route_id,
        seats,
        passengers,
        distance,
        carrier_iata as airline_iata,
        carrier_name as airline_name,
        origin_iata,
        origin_city_name,
        origin_country,
        origin_country_name,
        dest_iata,
        dest_city_name,
        dest_country,
        dest_country_name,
        aircraft_type,
        year,
        quarter,
        month,
        _fivetran_synced,
        _fivetran_deleted
 
    from source
   WHERE _fivetran_deleted = FALSE
)

select * from renamed
