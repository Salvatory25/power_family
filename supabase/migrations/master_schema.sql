-- ============================================================================
-- POWER FAMILY INVESTMENT — MASTER DATABASE SCHEMA & MIGRATION SCRIPT
-- Copy and paste this script directly into Supabase Dashboard -> SQL Editor
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. ENUMS & CONSTANTS
DO $$ BEGIN
    CREATE TYPE user_role_type AS ENUM (
        'SUPER_ADMIN', 'ADMIN', 'BRANCH_MANAGER', 'SALES_MANAGER', 'SALES_AGENT',
        'SECRETARY', 'SURVEYOR', 'SURVEY_ASSISTANT', 'ACCOUNTANT', 'FOLLOW_UP_OFFICER',
        'FIELD_OFFICER', 'DOCUMENT_OFFICER', 'MARKETING_MANAGER', 'SOCIAL_MEDIA_MANAGER',
        'CUSTOMER_SUPPORT', 'MANAGEMENT', 'CUSTOMER'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE record_status AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'ARCHIVED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE plot_status_enum AS ENUM (
        'AVAILABLE', 'RESERVED', 'BOOKED', 'SOLD', 'INSTALLMENT', 'FULLY_PAID',
        'TRANSFER_PENDING', 'TITLE_PROCESSING', 'TITLE_READY', 'HANDED_OVER',
        'CANCELLED', 'BLOCKED', 'DISPUTED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE land_use_enum AS ENUM (
        'RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL', 'MIXED_USE', 'INSTITUTIONAL'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 3. ORGANIZATIONS & BRANCHES
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    registration_number VARCHAR(100),
    tin_number VARCHAR(100),
    vrn_number VARCHAR(100),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address TEXT,
    logo_url TEXT,
    status record_status DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE, -- e.g. PFI-DAR, PFI-KIB, PFI-ARU
    region VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    ward VARCHAR(100),
    location TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    manager_id UUID,
    status record_status DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PROFILES / USERS & RBAC
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id),
    branch_id UUID REFERENCES branches(id),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50) UNIQUE,
    national_id VARCHAR(100),
    avatar_url TEXT,
    job_title VARCHAR(100),
    primary_role user_role_type DEFAULT 'SALES_AGENT',
    status record_status DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role user_role_type NOT NULL,
    permission_code VARCHAR(100) REFERENCES permissions(code) ON DELETE CASCADE,
    PRIMARY KEY (role, permission_code)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    role user_role_type NOT NULL,
    branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role, branch_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID,
    branch_id UUID,
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    old_data JSONB,
    new_data JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PROJECTS, BLOCKS & PLOTS
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id),
    branch_id UUID REFERENCES branches(id) NOT NULL,
    project_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    region VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    ward VARCHAR(100),
    village_street VARCHAR(100),
    gps_latitude NUMERIC(10, 8),
    gps_longitude NUMERIC(11, 8),
    boundary_geojson JSONB,
    total_area_sqm NUMERIC(12, 2) NOT NULL,
    total_plots INT DEFAULT 0,
    available_plots INT DEFAULT 0,
    booked_plots INT DEFAULT 0,
    sold_plots INT DEFAULT 0,
    min_price NUMERIC(15, 2),
    max_price NUMERIC(15, 2),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    launch_date DATE,
    project_manager_id UUID REFERENCES profiles(id),
    marketing_content JSONB,
    documents JSONB DEFAULT '[]'::jsonb,
    photos JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS project_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    block_name VARCHAR(50) NOT NULL,
    description TEXT,
    total_plots INT DEFAULT 0,
    boundary_geojson JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(project_id, block_name)
);

CREATE TABLE IF NOT EXISTS plots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plot_id VARCHAR(100) NOT NULL UNIQUE,
    plot_number VARCHAR(50) NOT NULL,
    block_id UUID REFERENCES project_blocks(id) ON DELETE SET NULL,
    block_name VARCHAR(50) NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    region VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    ward VARCHAR(100),
    village_street VARCHAR(100),
    location_description TEXT,
    gps_latitude NUMERIC(10, 8),
    gps_longitude NUMERIC(11, 8),
    boundary_coordinates JSONB,
    area_sqm NUMERIC(10, 2) NOT NULL,
    perimeter_meters NUMERIC(10, 2),
    land_use land_use_enum DEFAULT 'RESIDENTIAL',
    plot_type VARCHAR(50) DEFAULT 'STANDARD',
    list_price NUMERIC(15, 2) NOT NULL,
    discount_amount NUMERIC(15, 2) DEFAULT 0.0,
    selling_price NUMERIC(15, 2) GENERATED ALWAYS AS (list_price - discount_amount) STORED,
    required_deposit NUMERIC(15, 2) DEFAULT 0.0,
    installment_terms_months INT DEFAULT 12,
    availability_status plot_status_enum DEFAULT 'AVAILABLE',
    survey_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    bitcon_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    halmashauri_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    title_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    current_customer_id UUID,
    current_booking_id UUID,
    current_sale_id UUID,
    assigned_sales_agent_id UUID REFERENCES profiles(id),
    documents JSONB DEFAULT '[]'::jsonb,
    survey_data JSONB DEFAULT '{}'::jsonb,
    photos JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id)
);

-- 6. CUSTOMERS, LEADS & BOOKINGS
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id VARCHAR(50) NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || COALESCE(middle_name || ' ', '') || last_name) STORED,
    phone VARCHAR(50) NOT NULL,
    phone_normalized VARCHAR(50) NOT NULL,
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

CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id VARCHAR(50) NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    source VARCHAR(100) NOT NULL,
    campaign_id UUID,
    assigned_agent_id UUID REFERENCES profiles(id),
    status VARCHAR(50) DEFAULT 'NEW',
    pipeline_stage VARCHAR(50) DEFAULT 'NEW_LEAD',
    interested_project_id UUID REFERENCES projects(id),
    interested_plot_type VARCHAR(50),
    budget_max NUMERIC(15, 2),
    notes TEXT,
    converted_customer_id UUID REFERENCES customers(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id VARCHAR(50) NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    plot_id UUID REFERENCES plots(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    sales_agent_id UUID REFERENCES profiles(id),
    booking_date TIMESTAMPTZ DEFAULT NOW(),
    expiry_date TIMESTAMPTZ NOT NULL,
    fee_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    fee_paid BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Double booking prevention function
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
    SELECT availability_status INTO v_plot_status FROM plots WHERE id = p_plot_id FOR UPDATE;
    IF v_plot_status NOT IN ('AVAILABLE', 'RESERVED') THEN
        RAISE EXCEPTION 'Plot is not available for booking. Current status: %', v_plot_status;
    END IF;
    IF EXISTS (SELECT 1 FROM bookings WHERE plot_id = p_plot_id AND status = 'ACTIVE' AND expiry_date > NOW()) THEN
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

    UPDATE plots
    SET availability_status = 'BOOKED', current_booking_id = v_booking_id, current_customer_id = p_customer_id, updated_at = NOW()
    WHERE id = p_plot_id;

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. SALES, INVOICES, PAYMENTS & RECEIPTS
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id VARCHAR(50) NOT NULL UNIQUE,
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
    payment_plan_type VARCHAR(50) DEFAULT 'INSTALLMENT',
    sale_date DATE DEFAULT CURRENT_DATE,
    agreement_url TEXT,
    agreement_status VARCHAR(50) DEFAULT 'DRAFT',
    sale_status VARCHAR(50) DEFAULT 'ACTIVE',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    sale_id UUID REFERENCES sales(id),
    plot_id UUID REFERENCES plots(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    invoice_date DATE DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    subtotal NUMERIC(15, 2) NOT NULL,
    discount_amount NUMERIC(15, 2) DEFAULT 0.0,
    tax_amount NUMERIC(15, 2) DEFAULT 0.0,
    total_amount NUMERIC(15, 2) GENERATED ALWAYS AS (subtotal - discount_amount + tax_amount) STORED,
    paid_amount NUMERIC(15, 2) DEFAULT 0.0,
    balance_due NUMERIC(15, 2) GENERATED ALWAYS AS (subtotal - discount_amount + tax_amount - paid_amount) STORED,
    status VARCHAR(50) DEFAULT 'UNPAID',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_number VARCHAR(50) NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    invoice_id UUID REFERENCES invoices(id),
    sale_id UUID REFERENCES sales(id),
    plot_id UUID REFERENCES plots(id) NOT NULL,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(100) UNIQUE,
    control_number VARCHAR(100),
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'PENDING',
    received_by UUID REFERENCES profiles(id),
    confirmed_by UUID REFERENCES profiles(id),
    confirmed_at TIMESTAMPTZ,
    reversal_reason TEXT,
    original_payment_id UUID REFERENCES payments(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_number VARCHAR(50) NOT NULL UNIQUE,
    payment_id UUID REFERENCES payments(id) ON DELETE RESTRICT NOT NULL UNIQUE,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    plot_id UUID REFERENCES plots(id) NOT NULL,
    amount_paid NUMERIC(15, 2) NOT NULL,
    balance_remaining NUMERIC(15, 2) NOT NULL,
    receipt_pdf_url TEXT,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    issued_by UUID REFERENCES profiles(id)
);

-- Financial Integrity Trigger
CREATE OR REPLACE FUNCTION prevent_confirmed_payment_modification()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'CONFIRMED' AND (NEW.amount <> OLD.amount OR NEW.payment_method <> OLD.payment_method) THEN
        RAISE EXCEPTION 'Confirmed financial records cannot be directly edited. Issue a VOID or REVERSAL transaction instead.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_payment_safety ON payments;
CREATE TRIGGER trg_payment_safety
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION prevent_confirmed_payment_modification();

-- 8. SURVEY, BITCON, HALMASHAURI & TITLE DEEDS
CREATE TABLE IF NOT EXISTS survey_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_number VARCHAR(50) NOT NULL UNIQUE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE,
    surveyor_id UUID REFERENCES profiles(id) NOT NULL,
    assistant_id UUID REFERENCES profiles(id),
    survey_date DATE NOT NULL,
    positioning_mode VARCHAR(50) DEFAULT 'SMARTPHONE_GPS',
    total_points_captured INT DEFAULT 0,
    calculated_area_sqm NUMERIC(12, 2),
    calculated_perimeter_m NUMERIC(12, 2),
    accuracy_meters NUMERIC(6, 3),
    survey_device_info JSONB,
    nmea_log_url TEXT,
    survey_report_pdf_url TEXT,
    status VARCHAR(50) DEFAULT 'IN_PROGRESS',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bitcon_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bitcon_id VARCHAR(50) NOT NULL UNIQUE,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    application_reference VARCHAR(100),
    responsible_staff_id UUID REFERENCES profiles(id),
    submission_date DATE,
    fee_amount NUMERIC(15, 2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'PENDING',
    documents JSONB DEFAULT '[]'::jsonb,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS halmashauri_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id VARCHAR(50) NOT NULL UNIQUE,
    halmashauri_name VARCHAR(150) NOT NULL,
    department VARCHAR(150) DEFAULT 'Idara ya Ardhi na Mipango Miji',
    file_number VARCHAR(100) NOT NULL,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    submission_date DATE NOT NULL,
    officer_in_charge VARCHAR(150),
    officer_phone VARCHAR(50),
    current_stage VARCHAR(150) DEFAULT 'Uhakiki wa Nyaraka',
    next_follow_up_date DATE,
    pending_fee NUMERIC(15, 2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'PROCESSING',
    remarks TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS title_deeds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_number VARCHAR(100) NOT NULL UNIQUE,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE NOT NULL UNIQUE,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    issuing_authority VARCHAR(150) DEFAULT 'Wizara ya Ardhi, Nyumba na Maendeleo ya Makazi',
    application_file_ref VARCHAR(100),
    issue_date DATE,
    title_deed_pdf_url TEXT,
    workflow_stage VARCHAR(50) DEFAULT 'APPLICATION',
    notification_sent_at TIMESTAMPTZ,
    collected_at TIMESTAMPTZ,
    receiver_name VARCHAR(200),
    receiver_national_id VARCHAR(100),
    handover_officer_id UUID REFERENCES profiles(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE plots ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE survey_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bitcon_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE halmashauri_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE title_deeds ENABLE ROW LEVEL SECURITY;

-- Helper RLS Functions
CREATE OR REPLACE FUNCTION current_user_role() RETURNS user_role_type AS $$
    SELECT primary_role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_branch() RETURNS UUID AS $$
    SELECT branch_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Master Policies
DROP POLICY IF EXISTS profiles_isolation ON profiles;
CREATE POLICY profiles_isolation ON profiles FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch() OR id = auth.uid()
);

DROP POLICY IF EXISTS branches_access ON branches;
CREATE POLICY branches_access ON branches FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR id = current_user_branch()
);

DROP POLICY IF EXISTS plots_access ON plots;
CREATE POLICY plots_access ON plots FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'CUSTOMER') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS customers_access ON customers;
CREATE POLICY customers_access ON customers FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS sales_access ON sales;
CREATE POLICY sales_access ON sales FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS payments_access ON payments;
CREATE POLICY payments_access ON payments FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS organizations_access ON organizations;
CREATE POLICY organizations_access ON organizations FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT')
);

DROP POLICY IF EXISTS projects_access ON projects;
CREATE POLICY projects_access ON projects FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS leads_access ON leads;
CREATE POLICY leads_access ON leads FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS bookings_access ON bookings;
CREATE POLICY bookings_access ON bookings FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS invoices_access ON invoices;
CREATE POLICY invoices_access ON invoices FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS receipts_access ON receipts;
CREATE POLICY receipts_access ON receipts FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS audit_logs_access ON audit_logs;
CREATE POLICY audit_logs_access ON audit_logs FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT')
);

DROP POLICY IF EXISTS survey_jobs_access ON survey_jobs;
CREATE POLICY survey_jobs_access ON survey_jobs FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'SURVEYOR', 'SURVEY_ASSISTANT') OR project_id IN (SELECT id FROM projects WHERE branch_id = current_user_branch())
);

DROP POLICY IF EXISTS bitcon_cases_access ON bitcon_cases;
CREATE POLICY bitcon_cases_access ON bitcon_cases FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);

DROP POLICY IF EXISTS halmashauri_access ON halmashauri_applications;
CREATE POLICY halmashauri_access ON halmashauri_applications FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR project_id IN (SELECT id FROM projects WHERE branch_id = current_user_branch())
);

DROP POLICY IF EXISTS title_deeds_access ON title_deeds;
CREATE POLICY title_deeds_access ON title_deeds FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT') OR branch_id = current_user_branch()
);
