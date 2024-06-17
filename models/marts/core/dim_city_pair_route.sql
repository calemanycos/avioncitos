{{ config(materialized="incremental",  unique_key=['city_pair_id'],
        tags=['incremental']) }}


      with  city_pair as (
        select
            city_pair_id,
            non_directional_route,
            directional_route,
            origin_airport_iata,
            dest_airport_iata,
            distance,
            _fivetran_synced,
            _fivetran_deleted,

        from {{ ref('int_city_pair_route') }}


    ),
    max_fivetran as (select max(_fivetran_synced) from city_pair)

select *
from city_pair
{% if is_incremental() %}
    where _fivetran_synced > (select _fivetran_synced from max_fivetran)
{% endif %}