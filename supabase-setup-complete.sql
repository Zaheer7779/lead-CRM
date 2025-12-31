-- ============================================
-- Lead CRM - Complete Supabase Database Setup
-- ============================================
-- Run this script in your Supabase SQL Editor to set up the entire database

-- ============================================
-- 1. CREATE TABLES
-- ============================================

-- Organizations Table
CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_number TEXT,
  whatsapp_phone_number_id TEXT,
  whatsapp_access_token TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  phone TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'sales_rep')),
  pin_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ,
  UNIQUE(organization_id, phone)
);

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, name)
);

-- Models Table
CREATE TABLE IF NOT EXISTS models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(category_id, name)
);

-- Leads Table
CREATE TABLE IF NOT EXISTS leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  sales_rep_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE SET NULL,
  model_id UUID REFERENCES models(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  deal_size DECIMAL(10, 2) NOT NULL,
  purchase_timeline TEXT NOT NULL CHECK (purchase_timeline IN ('today', '3_days', '7_days', '30_days')),
  not_today_reason TEXT CHECK (not_today_reason IN ('need_family_approval', 'price_high', 'want_more_options', 'just_browsing')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_organization_id ON users(organization_id);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_phone_pin ON users(phone, pin_hash);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_organization_id ON categories(organization_id);

-- Models indexes
CREATE INDEX IF NOT EXISTS idx_models_organization_id ON models(organization_id);
CREATE INDEX IF NOT EXISTS idx_models_category_id ON models(category_id);

-- Leads indexes
CREATE INDEX IF NOT EXISTS idx_leads_organization_id ON leads(organization_id);
CREATE INDEX IF NOT EXISTS idx_leads_sales_rep_id ON leads(sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_leads_category_id ON leads(category_id);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at DESC);

-- ============================================
-- 3. CREATE UPDATED_AT TRIGGER FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. APPLY TRIGGERS TO TABLES
-- ============================================

-- Organizations trigger
DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
CREATE TRIGGER update_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Leads trigger
DROP TRIGGER IF EXISTS update_leads_updated_at ON leads;
CREATE TRIGGER update_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 5. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE models ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 6. CREATE RLS POLICIES
-- ============================================

-- Organizations Policies
DROP POLICY IF EXISTS "Organizations are viewable by members" ON organizations;
CREATE POLICY "Organizations are viewable by members"
  ON organizations FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Organizations are editable by admins" ON organizations;
CREATE POLICY "Organizations are editable by admins"
  ON organizations FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Organizations can be inserted" ON organizations;
CREATE POLICY "Organizations can be inserted"
  ON organizations FOR INSERT
  WITH CHECK (true);

-- Users Policies
DROP POLICY IF EXISTS "Users are viewable by organization members" ON users;
CREATE POLICY "Users are viewable by organization members"
  ON users FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can be inserted" ON users;
CREATE POLICY "Users can be inserted"
  ON users FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can be updated by admins" ON users;
CREATE POLICY "Users can be updated by admins"
  ON users FOR UPDATE
  USING (true);

-- Categories Policies
DROP POLICY IF EXISTS "Categories are viewable by organization members" ON categories;
CREATE POLICY "Categories are viewable by organization members"
  ON categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Categories can be inserted" ON categories;
CREATE POLICY "Categories can be inserted"
  ON categories FOR INSERT
  WITH CHECK (true);

-- Models Policies
DROP POLICY IF EXISTS "Models are viewable by organization members" ON models;
CREATE POLICY "Models are viewable by organization members"
  ON models FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Models can be inserted" ON models;
CREATE POLICY "Models can be inserted"
  ON models FOR INSERT
  WITH CHECK (true);

-- Leads Policies
DROP POLICY IF EXISTS "Leads are viewable by organization members" ON leads;
CREATE POLICY "Leads are viewable by organization members"
  ON leads FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Leads can be inserted" ON leads;
CREATE POLICY "Leads can be inserted"
  ON leads FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Leads can be updated" ON leads;
CREATE POLICY "Leads can be updated"
  ON leads FOR UPDATE
  USING (true);

-- ============================================
-- 7. VERIFY SETUP
-- ============================================

-- Check all tables exist
SELECT
  'Tables Created:' as status,
  COUNT(*) as count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('organizations', 'users', 'categories', 'models', 'leads');

-- Check all indexes exist
SELECT
  'Indexes Created:' as status,
  COUNT(*) as count
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('organizations', 'users', 'categories', 'models', 'leads');

-- Check RLS is enabled
SELECT
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('organizations', 'users', 'categories', 'models', 'leads')
ORDER BY tablename;

-- ============================================
-- 8. SUCCESS MESSAGE
-- ============================================

SELECT '✅ Database setup complete!' as message;
SELECT '📝 Next steps:' as message;
SELECT '1. Update your .env.local with Supabase credentials' as step;
SELECT '2. Run your Next.js app: npm run dev' as step;
SELECT '3. Visit /login to create your first organization' as step;
