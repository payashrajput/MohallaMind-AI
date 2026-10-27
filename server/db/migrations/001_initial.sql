CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'resident' CHECK (role IN ('resident','reviewer','admin')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  email_verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS incidents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  public_id BIGSERIAL UNIQUE,
  title VARCHAR(120) NOT NULL,
  category VARCHAR(40) NOT NULL CHECK (category IN ('Road damage','Drainage','Waste','Streetlight','Water supply','Other')),
  location VARCHAR(220) NOT NULL,
  ward VARCHAR(80) NOT NULL DEFAULT '',
  description VARCHAR(2000) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'Under review' CHECK (status IN ('Under review','Assigned','In progress','Resolved','Rejected')),
  severity VARCHAR(12) NOT NULL DEFAULT 'Medium' CHECK (severity IN ('Critical','High','Medium','Low')),
  priority_score SMALLINT NOT NULL DEFAULT 50 CHECK (priority_score BETWEEN 0 AND 100),
  report_count INTEGER NOT NULL DEFAULT 1 CHECK (report_count >= 1),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
  resolution_note VARCHAR(2000),
  resolved_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS incidents_status_created_idx ON incidents(status, created_at DESC);
CREATE INDEX IF NOT EXISTS incidents_category_status_idx ON incidents(category, status);
CREATE INDEX IF NOT EXISTS incidents_ward_idx ON incidents(ward);
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
  reporter_name VARCHAR(100) NOT NULL DEFAULT 'Community member',
  description VARCHAR(2000) NOT NULL,
  severity VARCHAR(12) NOT NULL DEFAULT 'Medium' CHECK (severity IN ('Critical','High','Medium','Low')),
  evidence_key TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS reports_incident_created_idx ON reports(incident_id, created_at DESC);
CREATE TABLE IF NOT EXISTS incident_events (
  id BIGSERIAL PRIMARY KEY,
  incident_id UUID REFERENCES incidents(id) ON DELETE SET NULL,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  event_type VARCHAR(50) NOT NULL,
  message VARCHAR(1000) NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS incident_events_created_idx ON incident_events(created_at DESC);
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS refresh_tokens_user_idx ON refresh_tokens(user_id);
CREATE TABLE IF NOT EXISTS schema_migrations (
  version TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
