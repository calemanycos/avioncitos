{{ config(materialized="table") }}

select
    base_airports.airport_id,
    base_airports.airport_iata as airport_iata,
    base_airports.airport_icao as airport_icao,
    base_airports.airport_name,
    base_airports.city as airport_city,
    base_countries.country_id as country_id,
    base_countries.iata_country as country_iata,
    base_countries.country_name as country_name

from {{ ref("base_airports") }} as base_airports
join {{ ref("base_countries") }} as base_countries
on base_airports.country_name = base_countries.country_name