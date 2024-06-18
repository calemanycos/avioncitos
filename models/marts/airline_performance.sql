{{ config(materialized='incremental',
tags=['incremental','datamart']) }}

with airline_performance as 
(
SELECT 
  a.airline_iata AS airline_iata,
  a.airline_name AS airline_name,
  COUNT(DISTINCT f.route_id) AS num_flights,
  AVG(f.seats) AS avg_seats,
  AVG(f.passengers) AS avg_passengers,
  AVG(f.distance) AS avg_distance,
  AVG(f.load_factor) AS avg_load_factor,
  AVG(f.distance_per_passenger) AS avg_distance_per_passenger,
  f._fivetran_deleted,
  f._fivetran_synced
FROM 
  {{ ref('fct_routes') }} f
  inner JOIN {{ ref('dim_airlines') }} a ON f.airline_key = a.airline_id
  where f._fivetran_deleted = null
GROUP BY 
  a.airline_iata, a.airline_name,f._fivetran_synced,f._fivetran_deleted
),

  max_fivetran as (select max(_fivetran_synced) as max_synced from airline_performance)

select *
from airline_performance

{% if is_incremental() %}
    where _fivetran_synced > (select max_synced from max_fivetran)
{% endif %}