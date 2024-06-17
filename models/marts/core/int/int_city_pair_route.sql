{{ config(materialized="incremental") }}

with
    routes as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["directional_route", "non_directional_route", "distance"]
                )
            }} as city_pair_id,
            origin_airport_iata,
            dest_airport_iata,
            directional_route,
            non_directional_route,
            distance,
            _fivetran_deleted,
            _fivetran_synced
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
            _fivetran_synced,
            _fivetran_deleted,
            row_number() over (
                partition by non_directional_route order by distance
            ) as row_num
        from routes
    ),

    filtro_city as (
        select
            city_pair_id,
            non_directional_route,
            directional_route,
            origin_airport_iata,
            dest_airport_iata,
            distance,
            _fivetran_synced,
            _fivetran_deleted
        from city_pair_routes
        having row_num = 1
    ),
    max_fivetran as (select max(_fivetran_synced) from city_pair_routes)

select *
from filtro_city
{% if is_incremental() %}
    where _fivetran_synced > (select _fivetran_synced from max_fivetran)
{% endif %}
