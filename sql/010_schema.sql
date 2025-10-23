-- Schema for BuyBetter (PostgreSQL + PostGIS)
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  ean TEXT,
  brand TEXT,
  name TEXT NOT NULL,
  category TEXT
);

CREATE TABLE IF NOT EXISTS stores (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  point GEOGRAPHY(POINT, 4326) NOT NULL, -- (lng, lat)
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stores_point ON stores USING GIST (point);

CREATE TABLE IF NOT EXISTS users_bb (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  reputation NUMERIC DEFAULT 0.5
);

CREATE TABLE IF NOT EXISTS price_reports (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  price NUMERIC(12,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'BRL',
  reported_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID,
  source TEXT DEFAULT 'user',
  quality_score NUMERIC DEFAULT 0.5,
  CONSTRAINT chk_price_positive CHECK (price > 0)
);

CREATE INDEX IF NOT EXISTS idx_price_reports_product_time ON price_reports (product_id, reported_at DESC);
CREATE INDEX IF NOT EXISTS idx_price_reports_store ON price_reports (store_id);
