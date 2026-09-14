-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 3: CUSTOMERS, LEADS, VISITS, BOOKINGS & SALES
-- ============================================================================

-- 1. CUSTOMERS TABLE (CUSTOMER 360)
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-CUST-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || COALESCE(middle_name || ' ', '') || last_name) STORED,
    phone VARCHAR(50) NOT NULL,
    phone_normalized VARCHAR(50) NOT NULL,
    alt_phone VARCHAR(50),
    email VARCHAR(255),
    email_normalized VARCHAR(255),
    national_id VARCHAR(100),
    tin_number VARCHAR(100),
    passport_number VARCHAR(100),
    address TEXT,
    region VARCHAR(100),
    district VARCHAR(100),
    lead_source VARCHAR(100) DEFAULT 'WALK_IN',
    assigned_staff_id UUID REFERENCES profiles(id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES profiles(id)
);

CREATE INDEX IF NOT EXISTS idx_customers_phone_norm ON customers(phone_normalized);
CREATE INDEX IF NOT EXISTS idx_customers_email_norm ON customers(email_normalized);
CREATE INDEX IF NOT EXISTS idx_customers_national_id ON customers(national_id);

-- 2. LEADS & SALES PIPELINE TABLE
CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-LEAD-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    source VARCHAR(100) NOT NULL, -- Facebook, Instagram, TikTok, WhatsApp, Website, etc.
    campaign_id UUID,
    assigned_agent_id UUID REFERENCES profiles(id),
    status VARCHAR(50) DEFAULT 'NEW', -- NEW, CONTACTED, QUALIFIED, SITE_VISIT, NEGOTIATION, BOOKED, SOLD, LOST, INACTIVE
    pipeline_stage VARCHAR(50) DEFAULT 'NEW_LEAD',
    interested_project_id UUID REFERENCES projects(id),
    interested_plot_type VARCHAR(50),
    budget_max NUMERIC(15, 2),
    notes TEXT,
    converted_customer_id UUID REFERENCES customers(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SITE VISITS TABLE
CREATE TABLE IF NOT EXISTS site_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-VST-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id),
    lead_id UUID REFERENCES leads(id),
    project_id UUID REFERENCES projects(id) NOT NULL,
    plot_id UUID REFERENCES plots(id),
    scheduled_datetime TIMESTAMPTZ NOT NULL,
    pickup_point VARCHAR(255),
    sales_agent_id UUID REFERENCES profiles(id),
    driver_id UUID REFERENCES profiles(id),
    field_officer_id UUID REFERENCES profiles(id),
    status VARCHAR(50) DEFAULT 'SCHEDULED', -- SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW
    gps_latitude NUMERIC(10, 8),
    gps_longitude NUMERIC(11, 8),
    feedback_notes TEXT,
    photos JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BOOKINGS TABLE (WITH STRICT DOUBLE-BOOKING PREVENTION)
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-BKG-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    plot_id UUID REFERENCES plots(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    sales_agent_id UUID REFERENCES profiles(id),
    booking_date TIMESTAMPTZ DEFAULT NOW(),
    expiry_date TIMESTAMPTZ NOT NULL,
    fee_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    fee_paid BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, EXPIRED, CONVERTED_TO_SALE, CANCELLED, EXTENDED
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Database function to enforce atomic double-booking protection
CREATE OR REPLACE FUNCTION check_and_create_booking(
    p_customer_id UUID,
    p_plot_id UUID,
    p_project_id UUID,
    p_branch_id UUID,
    p_agent_id UUID,
    p_expiry_days INT,
    p_fee NUMERIC
) RETURNS UUID AS $$
DECLARE
    v_plot_status plot_status_enum;
    v_booking_id UUID;
    v_booking_code VARCHAR(50);
BEGIN
    -- Lock target plot row for update to prevent concurrent double-booking
    SELECT availability_status INTO v_plot_status
    FROM plots
    WHERE id = p_plot_id
    FOR UPDATE;

    IF v_plot_status NOT IN ('AVAILABLE', 'RESERVED') THEN
        RAISE EXCEPTION 'Plot is not available for booking. Current status: %', v_plot_status;
    END IF;

    -- Check if active booking already exists
    IF EXISTS (
        SELECT 1 FROM bookings
        WHERE plot_id = p_plot_id AND status = 'ACTIVE' AND expiry_date > NOW()
    ) THEN
        RAISE EXCEPTION 'Plot currently has an active booking.';
    END IF;

    v_booking_code := 'PFI-BKG-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || SUBSTRING(uuid_generate_v4()::text FROM 1 FOR 6);

    INSERT INTO bookings (
        booking_id, branch_id, customer_id, plot_id, project_id,
        sales_agent_id, expiry_date, fee_amount, status
    ) VALUES (
        v_booking_code, p_branch_id, p_customer_id, p_plot_id, p_project_id,
        p_agent_id, NOW() + (p_expiry_days || ' days')::INTERVAL, p_fee, 'ACTIVE'
    ) RETURNING id INTO v_booking_id;

    -- Update plot status to BOOKED
    UPDATE plots
    SET availability_status = 'BOOKED',
        current_booking_id = v_booking_id,
        current_customer_id = p_customer_id,
        updated_at = NOW()
    WHERE id = p_plot_id;

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. SALES TABLE & AGREEMENTS
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-SLE-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    plot_id UUID REFERENCES plots(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    booking_id UUID REFERENCES bookings(id),
    sales_agent_id UUID REFERENCES profiles(id),
    
    agreed_price NUMERIC(15, 2) NOT NULL,
    deposit_amount NUMERIC(15, 2) NOT NULL,
    balance_amount NUMERIC(15, 2) NOT NULL,
    payment_terms_months INT DEFAULT 12,
    payment_plan_type VARCHAR(50) DEFAULT 'INSTALLMENT', -- CASH, INSTALLMENT
    
    sale_date DATE DEFAULT CURRENT_DATE,
    agreement_url TEXT,
    agreement_status VARCHAR(50) DEFAULT 'DRAFT', -- DRAFT, PENDING_SIGNATURE, SIGNED, APPROVED, CANCELLED
    sale_status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, CANCELLED, DEFAULTED
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS POLICIES FOR PHASE 3
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY customers_branch_policy ON customers FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
CREATE POLICY leads_branch_policy ON leads FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
CREATE POLICY visits_branch_policy ON site_visits FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
CREATE POLICY bookings_branch_policy ON bookings FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
CREATE POLICY sales_branch_policy ON sales FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
