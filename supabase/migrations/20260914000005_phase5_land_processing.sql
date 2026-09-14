-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 5: SURVEY, BITCON, HALMASHAURI & TITLE DEEDS
-- ============================================================================

-- 1. SURVEY / UPIMAJI TABLES
CREATE TABLE IF NOT EXISTS survey_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_number VARCHAR(50) NOT NULL UNIQUE, -- e.g. SUR-2026-000001
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE,
    surveyor_id UUID REFERENCES profiles(id) NOT NULL,
    assistant_id UUID REFERENCES profiles(id),
    survey_date DATE NOT NULL,
    positioning_mode VARCHAR(50) DEFAULT 'SMARTPHONE_GPS', -- SMARTPHONE_GPS, DGPS, RTK_FLOAT, RTK_FIX
    
    total_points_captured INT DEFAULT 0,
    calculated_area_sqm NUMERIC(12, 2),
    calculated_perimeter_m NUMERIC(12, 2),
    accuracy_meters NUMERIC(6, 3),
    
    survey_device_info JSONB,
    nmea_log_url TEXT,
    survey_report_pdf_url TEXT,
    status VARCHAR(50) DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, COMPLETED, APPROVED, REJECTED
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS survey_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    survey_job_id UUID REFERENCES survey_jobs(id) ON DELETE CASCADE NOT NULL,
    point_code VARCHAR(50) NOT NULL,
    latitude NUMERIC(12, 9) NOT NULL,
    longitude NUMERIC(12, 9) NOT NULL,
    altitude NUMERIC(8, 2),
    accuracy NUMERIC(6, 3),
    satellites_count INT,
    hdop NUMERIC(5, 2),
    vdop NUMERIC(5, 2),
    positioning_status VARCHAR(50), -- FIX, FLOAT, SINGLE
    captured_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BITCON WORKFLOW TABLE
CREATE TABLE IF NOT EXISTS bitcon_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bitcon_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. BIT-2026-000001
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    
    application_reference VARCHAR(100),
    responsible_staff_id UUID REFERENCES profiles(id),
    submission_date DATE,
    fee_amount NUMERIC(15, 2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, SUBMITTED, PROCESSING, COMPLETED, REJECTED, RETURNED
    
    documents JSONB DEFAULT '[]'::jsonb,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. HALMASHAURI TRACKING TABLE
CREATE TABLE IF NOT EXISTS halmashauri_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. HAL-2026-000001
    halmashauri_name VARCHAR(150) NOT NULL, -- e.g. Halmashauri ya Wilaya ya Kibaha
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
    status VARCHAR(50) DEFAULT 'PROCESSING', -- PROCESSING, WAITING_DOCUMENT, FOLLOW_UP_REQUIRED, READY, COMPLETED
    
    remarks TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TITLE DEED / HATI MILIKI TABLE
CREATE TABLE IF NOT EXISTS title_deeds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_number VARCHAR(100) NOT NULL UNIQUE, -- e.g. HT-2026-000001
    plot_id UUID REFERENCES plots(id) ON DELETE CASCADE NOT NULL UNIQUE,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    project_id UUID REFERENCES projects(id) NOT NULL,
    branch_id UUID REFERENCES branches(id) NOT NULL,
    
    issuing_authority VARCHAR(150) DEFAULT 'Wizara ya Ardhi, Nyumba na Maendeleo ya Makazi',
    application_file_ref VARCHAR(100),
    issue_date DATE,
    title_deed_pdf_url TEXT,
    
    workflow_stage VARCHAR(50) DEFAULT 'APPLICATION', -- APPLICATION, PROCESSING, WAITING, TITLE_READY, CUSTOMER_NOTIFIED, TITLE_COLLECTED, HANDOVER, COMPLETED
    notification_sent_at TIMESTAMPTZ,
    collected_at TIMESTAMPTZ,
    receiver_name VARCHAR(200),
    receiver_national_id VARCHAR(100),
    handover_officer_id UUID REFERENCES profiles(id),
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS POLICIES FOR PHASE 5
ALTER TABLE survey_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bitcon_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE halmashauri_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE title_deeds ENABLE ROW LEVEL SECURITY;

CREATE POLICY survey_access_policy ON survey_jobs FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'SURVEYOR', 'SURVEY_ASSISTANT')
);
CREATE POLICY bitcon_access_policy ON bitcon_cases FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'DOCUMENT_OFFICER', 'BRANCH_MANAGER') OR branch_id = current_user_branch()
);
CREATE POLICY halmashauri_access_policy ON halmashauri_applications FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'DOCUMENT_OFFICER', 'FOLLOW_UP_OFFICER')
);
CREATE POLICY title_deeds_access_policy ON title_deeds FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'DOCUMENT_OFFICER') OR branch_id = current_user_branch()
);
