WITH busiest_airports AS (
  SELECT 
    airport_iata, 
    COUNT(*) AS flight_count
  FROM (
    SELECT 
      dim_airports.airport_iata, 
      fct_routes.city_pair_route_key
    FROM 
      {{ ref('fct_routes') }}
    JOIN 
      {{ ref('dim_city_pair_route') }} 
      ON fct_routes.city_pair_route_key = dim_city_pair_route.city_pair_id
    JOIN 
      {{ ref('dim_airports') }} 
      ON dim_city_pair_route.origin_airport_iata = dim_airports.airport_iata
    UNION ALL
    SELECT 
      dim_airports.airport_iata AS airport_iata, 
      fct_routes.city_pair_route_key
    FROM 
      {{ ref('fct_routes') }}
    JOIN 
      {{ ref('dim_city_pair_route') }} 
      ON fct_routes.city_pair_route_key = dim_city_pair_route.city_pair_id
    JOIN 
      {{ ref('dim_airports') }} 
      ON dim_city_pair_route.dest_airport_iata = dim_airports.airport_iata
  ) AS airport_routes
  GROUP BY 
    airport_iata
)
SELECT 
  dim_airports.airport_iata, 
  airport_name, 
  flight_count
FROM 
  busiest_airports
JOIN 
  {{ ref('dim_airports') }} 
  ON busiest_airports.airport_iata = dim_airports.airport_iata
WHERE 
  flight_count >= 100
ORDER BY 
  flight_count DESC