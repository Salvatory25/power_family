-- ============================================================================
-- POWER FAMILY INVESTMENT — CUSTOMER FAVOURITES MIGRATION
-- Copy and paste this script directly into Supabase Dashboard -> SQL Editor
-- ============================================================================

CREATE TABLE IF NOT EXISTS customer_favourites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(customer_id, plot_id)
);

-- Enable RLS
ALTER TABLE customer_favourites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own favourites
DROP POLICY IF EXISTS customer_favourites_select ON customer_favourites;
CREATE POLICY customer_favourites_select ON customer_favourites FOR SELECT USING (
    auth.uid() = customer_id
);

-- Policy: Users can insert their own favourites
DROP POLICY IF EXISTS customer_favourites_insert ON customer_favourites;
CREATE POLICY customer_favourites_insert ON customer_favourites FOR INSERT WITH CHECK (
    auth.uid() = customer_id
);

-- Policy: Users can delete their own favourites
DROP POLICY IF EXISTS customer_favourites_delete ON customer_favourites;
CREATE POLICY customer_favourites_delete ON customer_favourites FOR DELETE USING (
    auth.uid() = customer_id
);
