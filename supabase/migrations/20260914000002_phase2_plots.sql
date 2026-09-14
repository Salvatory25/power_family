-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 2: PLOTS & PROJECTS INVENTORY
-- ============================================================================

-- 1. ENUMS FOR PLOTS & PROJECTS
DO $$ BEGIN
    CREATE TYPE plot_status_enum AS ENUM (
        'AVAILABLE',
        'RESERVED',
        'BOOKED',
        'SOLD',
        'INSTALLMENT',
        'FULLY_PAID',
        'TRANSFER_PENDING',
        'TITLE_PROCESSING',
        'TITLE_READY',
        'HANDED_OVER',
        'CANCELLED',
        'BLOCKED',
        'DISPUTED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE land_use_enum AS ENUM (
        'RESIDENTIAL',
        'COMMERCIAL',
        'INDUSTRIAL',
        'AGRICULTURAL',
        'MIXED_USE',
        'INSTITUTIONAL'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. PROJECTS TABLE
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id),
    branch_id UUID REFERENCES branches(id) NOT NULL,
    project_code VARCHAR(50) NOT NULL UNIQUE, -- e.g. PFI-PRJ-KIB-001
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

-- 3. PROJECT BLOCKS TABLE
CREATE TABLE IF NOT EXISTS project_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    block_name VARCHAR(50) NOT NULL, -- e.g. Block A, Block B
    description TEXT,
    total_plots INT DEFAULT 0,
    boundary_geojson JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(project_id, block_name)
);

-- 4. PLOTS / VIWANJA CORE TABLE
CREATE TABLE IF NOT EXISTS plots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plot_id VARCHAR(100) NOT NULL UNIQUE, -- e.g. PFI-KIB-000001
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
    boundary_coordinates JSONB, -- Polygon points array
    area_sqm NUMERIC(10, 2) NOT NULL,
    perimeter_meters NUMERIC(10, 2),
    land_use land_use_enum DEFAULT 'RESIDENTIAL',
    plot_type VARCHAR(50) DEFAULT 'STANDARD',
    
    -- Financial details
    list_price NUMERIC(15, 2) NOT NULL,
    discount_amount NUMERIC(15, 2) DEFAULT 0.0,
    selling_price NUMERIC(15, 2) GENERATED ALWAYS AS (list_price - discount_amount) STORED,
    required_deposit NUMERIC(15, 2) DEFAULT 0.0,
    installment_terms_months INT DEFAULT 12,
    
    -- Status trackers
    availability_status plot_status_enum DEFAULT 'AVAILABLE',
    survey_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    bitcon_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    halmashauri_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    title_status VARCHAR(50) DEFAULT 'NOT_STARTED',
    
    -- Entity linkages
    current_customer_id UUID,
    current_booking_id UUID,
    current_sale_id UUID,
    assigned_sales_agent_id UUID REFERENCES profiles(id),
    
    -- Metadata
    documents JSONB DEFAULT '[]'::jsonb,
    survey_data JSONB DEFAULT '{}'::jsonb,
    photos JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id)
);

-- Indexes for lightning fast searching and filtering
CREATE INDEX IF NOT EXISTS idx_plots_plot_id ON plots(plot_id);
CREATE INDEX IF NOT EXISTS idx_plots_branch ON plots(branch_id);
CREATE INDEX IF NOT EXISTS idx_plots_project ON plots(project_id);
CREATE INDEX IF NOT EXISTS idx_plots_status ON plots(availability_status);
CREATE INDEX IF NOT EXISTS idx_plots_customer ON plots(current_customer_id);

-- RLS POLICIES FOR PLOTS & PROJECTS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE plots ENABLE ROW LEVEL SECURITY;

CREATE POLICY projects_branch_policy ON projects
    FOR ALL USING (
        current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'CUSTOMER')
        OR branch_id = current_user_branch()
    );

CREATE POLICY plots_branch_policy ON plots
    FOR ALL USING (
        current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'CUSTOMER')
        OR branch_id = current_user_branch()
    );
