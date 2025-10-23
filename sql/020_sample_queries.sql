-- Sample query: cheapest in radius with recency filter (14 days)
-- Inputs: user_lat, user_lng, product_id, radius_km
WITH params AS (
  SELECT
    CAST(:user_lat AS DOUBLE PRECISION) AS lat,
    CAST(:user_lng AS DOUBLE PRECISION) AS lng,
    CAST(:product_id AS BIGINT) AS pid,
    CAST(:radius_km AS DOUBLE PRECISION) AS radius
),
stores_in_radius AS (
  SELECT s.*, ST_DistanceSphere(s.point, ST_MakePoint((SELECT lng FROM params),(SELECT lat FROM params))) AS dist_m
  FROM stores s, params
  WHERE ST_DWithin(s.point, ST_MakePoint((SELECT lng FROM params),(SELECT lat FROM params)), (SELECT radius FROM params) * 1000)
),
recent_reports AS (
  SELECT pr.*
  FROM price_reports pr
  WHERE pr.product_id = (SELECT pid FROM params)
    AND pr.reported_at >= now() - INTERVAL '14 days'
),
agg AS (
  SELECT
    r.store_id,
    AVG(r.price) FILTER (WHERE r.quality_score IS NOT NULL) AS avg_price,
    MAX(r.reported_at) AS last_seen,
    AVG(COALESCE(r.quality_score,0.5)) AS avg_quality
  FROM recent_reports r
  GROUP BY r.store_id
)
SELECT
  s.id AS store_id,
  s.name,
  s.address,
  (a.avg_price) AS price,
  ROUND((dist_m/1000.0)::numeric, 2) AS distance_km,
  a.last_seen,
  a.avg_quality
FROM stores_in_radius s
JOIN agg a ON a.store_id = s.id
ORDER BY price ASC, distance_km ASC
LIMIT 10;
