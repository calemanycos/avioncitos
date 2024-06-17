{{ config(materialized="incremental", unique_key=["route_id"], tags=["incremental"]) }}

with
    source as (select * from {{ ref("stg_routes") }}),

    fact_routes as (
        select
            route_id,
            airline_id as airline_key,
            origin_airport_id as origin_airport_key,
            dest_airport_id as dest_airport_key,
            origin_country_id as origin_country_key,
            dest_country_id as dest_country_key,
            plane_model_id as plane_model_key,
            city_pair_id as city_pair_route_key,
            year,
            quarter,
            month,
            seats,
            passengers,
            source.distance,
            source._fivetran_deleted,
            source._fivetran_synced,
            case when seats = 0 then 0 else passengers / seats end as load_factor,
            case
                when passengers = 0 then 0 else source.distance / passengers
            end as distance_per_passenger
        from source
        join
            {{ ref("int_city_pair_route") }} cpr
            on source.non_directional_route = cpr.non_directional_route
    )

select *
from fact_routes

{% if is_incremental() %}

    where _fivetran_synced > (select max(_fivetran_synced) from fct_routes)

{% endif %}
