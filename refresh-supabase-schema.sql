-- First, verify tables exist
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('models', 'leads', 'categories')
ORDER BY table_name, ordinal_position;

-- Force reload the PostgREST schema cache
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';
