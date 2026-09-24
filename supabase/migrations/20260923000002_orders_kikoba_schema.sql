-- ==========================================
-- 0. CLEANUP (IN CASE OF PARTIAL MIGRATION)
-- ==========================================
DROP TABLE IF EXISTS public.kikoba_memberships CASCADE;
DROP TABLE IF EXISTS public.kikoba_packages CASCADE;
DROP TABLE IF EXISTS public.payments CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;

-- ==========================================
-- 1. ORDERS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    customer_name TEXT NOT NULL,
    property_id UUID NOT NULL REFERENCES public.plots(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    acquisition_plan TEXT NOT NULL, -- FULL_PAYMENT, INSTALLMENT, KIKOBA
    total_payable NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    amount_paid NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING, ACTIVE, FULLY_PAID, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 2. PAYMENTS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id TEXT NOT NULL, -- Order ID or Membership ID
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    amount NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    method TEXT NOT NULL DEFAULT 'CASH', -- BANK, MOBILE_MONEY, CASH
    transaction_ref TEXT NOT NULL, -- e.g. Receipt Number or MPESA code
    status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING, VERIFIED, REJECTED
    verified_by UUID REFERENCES public.profiles(id), -- Admin/Manager who verified
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 3. KIKOBA PACKAGES TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.kikoba_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    weekly_contribution NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    duration_weeks INT NOT NULL DEFAULT 0,
    target_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    member_limit INT NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE, COMPLETED
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 4. KIKOBA MEMBERSHIPS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.kikoba_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    package_id UUID NOT NULL REFERENCES public.kikoba_packages(id),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    customer_name TEXT NOT NULL,
    property_id UUID REFERENCES public.plots(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    total_contributed NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING, ACTIVE, COMPLETED, CANCELLED, DEFAULTED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- 5. RLS POLICIES
-- ==========================================
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kikoba_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kikoba_memberships ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read and insert (for prototype speed)
CREATE POLICY "Allow all authenticated to read orders" ON public.orders FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to insert orders" ON public.orders FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to update orders" ON public.orders FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all authenticated to read payments" ON public.payments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to insert payments" ON public.payments FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to update payments" ON public.payments FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all authenticated to read kikoba packages" ON public.kikoba_packages FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to insert kikoba packages" ON public.kikoba_packages FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to update kikoba packages" ON public.kikoba_packages FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all authenticated to read kikoba memberships" ON public.kikoba_memberships FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to insert kikoba memberships" ON public.kikoba_memberships FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow all authenticated to update kikoba memberships" ON public.kikoba_memberships FOR UPDATE USING (auth.role() = 'authenticated');
