{{ config(materialized="incremental") }}

SELECT
  dim_airlines.airline_id,
  dim_airlines.airline_iata,
  dim_airlines.airline_name,
  dim_plane_models.code AS plane_model_code,
  dim_plane_models.description AS plane_model_description,
  COUNT(DISTINCT fct_routes.route_id) OVER (PARTITION BY dim_airlines.airline_id) AS num_unique_routes_by_airline,
  COUNT(DISTINCT fct_routes.route_id) AS num_unique_routes_by_airline_model,
  SUM(fct_routes.seats) AS total_seats,
  AVG(fct_routes.load_factor) AS avg_load_factor,
  fct_routes._fivetran_synced,
  fct_routes._fivetran_deleted
FROM
  {{ ref('fct_routes') }} AS fct_routes
JOIN
  {{ ref('dim_airlines') }} AS dim_airlines
ON
  fct_routes.airline_key = dim_airlines.airline_id
JOIN
  {{ ref('dim_plane_models') }} AS dim_plane_models
ON
  fct_routes.plane_model_key = dim_plane_models.plane_model_id
GROUP BY
  dim_airlines.airline_id,
  dim_airlines.airline_iata,
  dim_airlines.airline_name,
  dim_plane_models.code,
  fct_routes.route_id,
  dim_plane_models.description,
  fct_routes._fivetran_synced,
  fct_routes._fivetran_deleted
{% if is_incremental() %}
    where _fivetran_synced > (select fct_routes._fivetran_synced from {{ this }} )
{% endif %}