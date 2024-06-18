{{ config(materialized='incremental') }}
with airport_performance as
(
SELECT 
  a.airport_iata AS airport_iata,
  a.airport_name AS airport_name,
  COUNT(DISTINCT f.route_id) AS num_flights,
  AVG(f.seats) AS avg_seats,
  AVG(f.passengers) AS avg_passengers,
  AVG(f.distance) AS avg_distance,
  AVG(f.load_factor) AS avg_load_factor,
  AVG(f.distance_per_passenger) AS avg_distance_per_passenger,
  f._fivetran_synced,
  f._fivetran_deleted
FROM 
  {{ ref('fct_routes') }} f
  LEFT JOIN {{ ref('dim_airports') }} a ON f.origin_airport_key = a.airport_id
    where f._fivetran_deleted = null
GROUP BY 
  a.airport_iata, a.airport_name,f._fivetran_synced,f._fivetran_deleted

),

  max_fivetran as (select max(_fivetran_synced) as max_synced from airport_performance)

select *
from airport_performance

{% if is_incremental() %}
    where _fivetran_synced > (select max_synced from max_fivetran)
{% endif %}