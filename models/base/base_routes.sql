 {{ config(materialized="table") }}

with source as (select * from {{ source("SNOWFLAKE_DB_OPENFLIGHTS", "routes") }}),
renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(["_fivetran_id"]) }} as route_id,
        seats,
        passengers,
        distance,
        carrier_iata as airline_iata,
        carrier_name as airline_name,
        coalesce(origin_iata,'Unknown') as origin_airport_iata,
        coalesce(origin_city_name,'Unknown') as origin_city_name,
        coalesce(origin_country,'Unknown') as origin_country_iata,
        coalesce(origin_country_name,'Unknown') as origin_country_name,
        coalesce(dest_iata,'Unknown') as dest_airport_iata,
        dest_city_name,
        dest_country as dest_country_iata,
        dest_country_name,
        aircraft_type,
        year,
        quarter,
        month,
        _fivetran_synced,
        _fivetran_deleted

    from source
    where _fivetran_deleted = false
)
select * from renamed
