-- Accelerate candidate lookup while keeping similarity matches reviewable.
CREATE INDEX IF NOT EXISTS incidents_title_trgm_idx ON incidents USING GIN (LOWER(title) gin_trgm_ops);
CREATE INDEX IF NOT EXISTS incidents_location_lower_idx ON incidents (LOWER(location));
CREATE INDEX IF NOT EXISTS incidents_open_category_created_idx ON incidents(category, created_at DESC) WHERE status NOT IN ('Resolved','Rejected');
