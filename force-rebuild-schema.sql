-- Step 1: Verify the leads table has model_id column
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'leads'
ORDER BY ordinal_position;

-- Step 2: If model_id is missing, add it
-- (This should NOT be needed if you ran the setup script correctly)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'leads'
      AND column_name = 'model_id'
  ) THEN
    ALTER TABLE leads ADD COLUMN model_id UUID REFERENCES models(id) ON DELETE SET NULL;
    RAISE NOTICE 'Added model_id column to leads table';
  ELSE
    RAISE NOTICE 'model_id column already exists';
  END IF;
END $$;

-- Step 3: Force PostgREST to reload schema
-- Multiple notification methods to ensure it takes effect
SELECT pg_notify('pgrst', 'reload schema');
SELECT pg_notify('pgrst', 'reload config');
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- Step 4: Verify the schema after changes
SELECT
  t.table_name,
  c.column_name,
  c.data_type
FROM information_schema.tables t
LEFT JOIN information_schema.columns c
  ON t.table_name = c.table_name
  AND t.table_schema = c.table_schema
WHERE t.table_schema = 'public'
  AND t.table_name IN ('models', 'leads', 'categories')
ORDER BY t.table_name, c.ordinal_position;
