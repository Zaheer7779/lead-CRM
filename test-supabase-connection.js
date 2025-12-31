// Test Supabase connection and schema
require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('Testing Supabase connection...');
console.log('URL:', supabaseUrl);
console.log('Service Key:', supabaseServiceKey ? `${supabaseServiceKey.substring(0, 20)}...` : 'MISSING');

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function testConnection() {
  try {
    // Test 1: Check if we can query the database
    console.log('\n1. Testing basic connection...');
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .in('table_name', ['models', 'leads', 'categories']);

    if (tablesError) {
      console.error('❌ Error querying tables:', tablesError);
    } else {
      console.log('✅ Tables found:', tables?.map(t => t.table_name));
    }

    // Test 2: Try to query models table directly
    console.log('\n2. Testing models table...');
    const { data: models, error: modelsError } = await supabase
      .from('models')
      .select('*')
      .limit(1);

    if (modelsError) {
      console.error('❌ Error querying models:', modelsError);
    } else {
      console.log('✅ Models table accessible, rows:', models?.length || 0);
    }

    // Test 3: Try to query leads table
    console.log('\n3. Testing leads table...');
    const { data: leads, error: leadsError } = await supabase
      .from('leads')
      .select('*')
      .limit(1);

    if (leadsError) {
      console.error('❌ Error querying leads:', leadsError);
    } else {
      console.log('✅ Leads table accessible, rows:', leads?.length || 0);
    }

    // Test 4: Check columns in leads table
    console.log('\n4. Checking leads table schema...');
    const { data: columns, error: columnsError } = await supabase.rpc('exec_sql', {
      sql: `
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'leads'
        ORDER BY ordinal_position;
      `
    });

    if (columnsError) {
      console.error('❌ Error checking schema:', columnsError);
      console.log('Note: RPC method might not be available. Run the SQL query manually in Supabase dashboard.');
    } else {
      console.log('✅ Leads columns:', columns);
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

testConnection();
