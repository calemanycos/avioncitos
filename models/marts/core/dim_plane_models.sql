{{ config(materialized="incremental",  unique_key=['plane_model_id'],
        tags=['incremental']

 ) }}
with
    dim_plane_model as (select * from {{ ref("base_plane_models") }}),
    stg_routes as (select * from {{ ref("stg_routes") }}), 
    routes_with_plane_model as (
        select 
            r.plane_model_id,
            sum(r.passengers) as total_passengers,
            sum(r.seats) as total_seats,
            r._fivetran_deleted,
            r._fivetran_synced
        from stg_routes r
        where r.passengers > 0 and r.seats > 0
        group by r.plane_model_id,_fivetran_synced,_fivetran_deleted
    )

select 
    p.code,
    r.plane_model_id,
    p.description,
    (r.total_passengers::float / r.total_seats)* 100 as avg_capacity_filled_pct,
    r._fivetran_deleted,
    r._fivetran_synced
from routes_with_plane_model r
inner join dim_plane_model p on r.plane_model_id = p.plane_model_id
where r._fivetran_deleted = false

{% if is_incremental() %}

  and r._fivetran_synced > (select max(r._fivetran_synced) from {{ this }})

{% endif %}