-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 1: FOUNDATION, ORGANIZATIONS & RBAC
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. ENUMS & CONSTANTS
DO $$ BEGIN
    CREATE TYPE user_role_type AS ENUM (
        'SUPER_ADMIN',
        'ADMIN',
        'BRANCH_MANAGER',
        'SALES_MANAGER',
        'SALES_AGENT',
        'SECRETARY',
        'SURVEYOR',
        'SURVEY_ASSISTANT',
        'ACCOUNTANT',
        'FOLLOW_UP_OFFICER',
        'FIELD_OFFICER',
        'DOCUMENT_OFFICER',
        'MARKETING_MANAGER',
        'SOCIAL_MEDIA_MANAGER',
        'CUSTOMER_SUPPORT',
        'MANAGEMENT',
        'CUSTOMER'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE record_status AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'ARCHIVED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. ORGANIZATIONS TABLE
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

-- 4. BRANCHES TABLE
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
    monthly_target NUMERIC DEFAULT 50000000.0,
    status record_status DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PROFILES / USERS
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

-- 6. PERMISSIONS & ROLES SYSTEM
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

-- 7. AUDIT LOGS TABLE
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

-- 8. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Base RLS Helper Functions
CREATE OR REPLACE FUNCTION current_user_role()
RETURNS user_role_type AS $$
    SELECT primary_role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_branch()
RETURNS UUID AS $$
    SELECT branch_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Profiles Policy: Staff sees profiles in their branch; Super Admin/Admin/Management sees all
CREATE POLICY profiles_isolation_policy ON profiles
    FOR ALL USING (
        current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT')
        OR branch_id = current_user_branch()
        OR id = auth.uid()
    );

-- Branches Policy: Staff sees their branch; Admin/Management sees all
CREATE POLICY branches_access_policy ON branches
    FOR SELECT USING (
        current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT')
        OR id = current_user_branch()
    );

-- Audit Logs Policy: Super Admin / Admin / Management read-only
CREATE POLICY audit_logs_access_policy ON audit_logs
    FOR SELECT USING (
        current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT')
    );
