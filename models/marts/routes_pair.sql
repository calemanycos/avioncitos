WITH route_pairs AS (
  SELECT 
    dim_city_pair_route.non_directional_route,
    COUNT(*) AS flight_count
  FROM 
    {{ ref('fct_routes') }}
  JOIN 
    {{ ref('dim_city_pair_route') }} 
    ON fct_routes.city_pair_route_key = dim_city_pair_route.city_pair_id
  GROUP BY 
    dim_city_pair_route.non_directional_route
)
SELECT 
  dim_city_pair_route.directional_route,
  route_pairs.flight_count AS directional_flight_count,
  route_pairs.non_directional_route,
  route_pairs.flight_count * 2 AS non_directional_flight_count
FROM 
  route_pairs
JOIN 
  {{ ref('dim_city_pair_route') }} 
  ON route_pairs.non_directional_route = dim_city_pair_route.non_directional_route
ORDER BY 
  route_pairs.flight_count DESC