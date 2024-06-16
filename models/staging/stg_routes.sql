{{ config(materialized="table") }}

with
    source as (select * from {{ ref("base_routes") }}),

    renamed as (
        select
            route_id,
            source.airline_iata,
            source.origin_airport_iata as origin_airport_iata,
            source.dest_airport_iata as dest_airport_iata,
            aircraft_type,
            concat(source.origin_airport_iata, '-', source.dest_airport_iata) as directional_route,
            CONCAT(LEAST(origin_airport_iata, dest_airport_iata), '-', GREATEST(origin_airport_iata, dest_airport_iata)) AS non_directional_route,
            year,
            quarter,
            month,
            seats,
            passengers,
            distance,

            airline.airline_id,
            origin_airport.airport_id as origin_airport_id,
            dest_airport.airport_id as dest_airport_id,
            origin_country.country_id as origin_country_id,
            dest_country.country_id as dest_country_id,
            plane_model.plane_model_id,
            source._fivetran_synced,
            source._fivetran_deleted

        from source
        join
            {{ ref("base_airlines") }} airline
            on source.airline_iata = airline.airline_iata
        join
            {{ ref("base_airports") }} origin_airport
            on source.origin_airport_iata = origin_airport.airport_iata
        join
            {{ ref("base_airports") }} dest_airport
            on source.dest_airport_iata = dest_airport.airport_iata
        join
            {{ ref("base_countries") }} origin_country
            on source.origin_country_iata = origin_country.iata_country
        join
            {{ ref("base_countries") }} dest_country
            on source.dest_country_iata = dest_country.iata_country
        join
            {{ ref("base_plane_models") }} plane_model
            on source.aircraft_type = plane_model.code
        where source._fivetran_deleted = false
    ),

    deduplicated as (
        select 
            *,
            row_number() over (partition by route_id order by _fivetran_synced) as row_num
        from renamed
    )

select *
from deduplicated
where row_num = 1
order by route_id