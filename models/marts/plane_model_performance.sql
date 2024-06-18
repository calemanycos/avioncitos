{{ config(materialized="incremental") }}

With plane_performance as 
(select
    pm.plane_model_id,
    pm.code as plane_model_code,
    pm.description as plane_model_description,
    count(distinct f.route_id) as num_flights,
    avg(f.seats) as avg_seats,
    avg(f.passengers) as avg_passengers,
    avg(f.distance) as avg_distance,
    avg(f.load_factor) as avg_load_factor,
    avg(f.distance_per_passenger) as avg_distance_per_passenger,
    f._fivetran_synced,
    f._fivetran_deleted
from {{ ref("fct_routes") }} f
inner join {{ ref("dim_plane_models") }} pm on f.plane_model_key = pm.plane_model_id
where f._fivetran_deleted = false
group by pm.code, pm.description, pm.plane_model_id,f._fivetran_synced,f._fivetran_deleted
),

max_fivetran as (select max(_fivetran_synced) as max_synced from plane_performance)

select *
from plane_performance

{% if is_incremental() %}
    where f._fivetran_synced > (select max_synced from max_fivetran)
{% endif %}