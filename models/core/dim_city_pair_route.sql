{{ config(materialized="table") }}

with
    routes as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["directional_route", "non_directional_route"]
                )
            }} as city_pair_id,
            origin_airport_iata,
            dest_airport_iata,
            directional_route,
            non_directional_route,
            distance
        from {{ ref("stg_routes") }}
    ),

    city_pair_routes as (
        select
            city_pair_id,
            non_directional_route,
            origin_airport_iata,
            dest_airport_iata,
            directional_route,
            distance,
            row_number() over (
                partition by non_directional_route order by distance
            ) as row_num
        from routes
    )

select
    city_pair_id,
    non_directional_route,
    directional_route,
    origin_airport_iata,
    dest_airport_iata,
    distance
from city_pair_routes
where row_num = 1
