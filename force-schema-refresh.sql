-- Step 1: Verify the schema exists
SELECT
  t.table_name,
  c.column_name,
  c.data_type,
  c.is_nullable
FROM information_schema.tables t
LEFT JOIN information_schema.columns c
  ON t.table_name = c.table_name
  AND t.table_schema = c.table_schema
WHERE t.table_schema = 'public'
  AND t.table_name IN ('models', 'leads', 'categories')
ORDER BY t.table_name, c.ordinal_position;

-- Step 2: Drop and recreate PostgREST schema cache
-- This forces a complete reload
SELECT pg_notify('pgrst', 'reload schema');
SELECT pg_notify('pgrst', 'reload config');

-- Step 3: Verify PostgREST can see the tables
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('models', 'leads', 'categories');
