-- Migration script to update leads table from model_name to model_id

-- Step 1: Add the model_id column (if it doesn't exist)
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

-- Step 2: Migrate existing data from model_name to model_id
-- For each lead with a model_name, find the corresponding model and set model_id
UPDATE leads
SET model_id = (
  SELECT m.id
  FROM models m
  WHERE m.name = leads.model_name
    AND m.category_id = leads.category_id
  LIMIT 1
)
WHERE model_name IS NOT NULL
  AND model_id IS NULL;

-- Step 3: Drop the old model_name column
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'leads'
      AND column_name = 'model_name'
  ) THEN
    ALTER TABLE leads DROP COLUMN model_name;
    RAISE NOTICE 'Dropped model_name column from leads table';
  ELSE
    RAISE NOTICE 'model_name column does not exist';
  END IF;
END $$;

-- Step 4: Force PostgREST to reload the schema
SELECT pg_notify('pgrst', 'reload schema');
SELECT pg_notify('pgrst', 'reload config');
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- Step 5: Verify the changes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'leads'
ORDER BY ordinal_position;
