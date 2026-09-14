-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 7, 8 & 9: MARKETING, COMMUNICATION, AI & AUTOMATION
-- ============================================================================

-- 1. MARKETING CAMPAIGNS & ADVERTISEMENTS
CREATE TABLE IF NOT EXISTS marketing_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. CMP-2026-000001
    name VARCHAR(255) NOT NULL,
    objective VARCHAR(50) NOT NULL, -- LEADS, SITE_VISITS, BOOKINGS, SALES, AWARENESS, PROJECT_LAUNCH
    project_id UUID REFERENCES projects(id),
    target_audience TEXT,
    budget_tsh NUMERIC(15, 2) DEFAULT 0.0,
    start_date DATE,
    end_date DATE,
    platforms JSONB DEFAULT '["FACEBOOK", "INSTAGRAM", "WHATSAPP"]'::jsonb,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS advertisements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ad_id VARCHAR(50) NOT NULL UNIQUE, -- e.g. AD-2026-000001
    campaign_id UUID REFERENCES marketing_campaigns(id) ON DELETE CASCADE,
    template_type VARCHAR(100) NOT NULL, -- New Project, Plot For Sale, Special Offer, Weekend Offer, Site Visit, etc.
    headline VARCHAR(255) NOT NULL,
    description TEXT,
    price_tsh NUMERIC(15, 2),
    project_id UUID REFERENCES projects(id) NOT NULL,
    location VARCHAR(255),
    plot_type VARCHAR(50),
    contact_phone VARCHAR(50),
    whatsapp_number VARCHAR(50),
    cta_text VARCHAR(100),
    media_urls JSONB DEFAULT '[]'::jsonb,
    social_caption TEXT,
    hashtags TEXT,
    status VARCHAR(50) DEFAULT 'DRAFT', -- DRAFT, PENDING_APPROVAL, APPROVED, SCHEDULED, PUBLISHED
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. COMMUNICATION LOGS & REMINDERS
CREATE TABLE IF NOT EXISTS communication_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    channel VARCHAR(50) NOT NULL, -- PUSH, SMS, EMAIL, WHATSAPP
    message_type VARCHAR(50) NOT NULL, -- SYSTEM, MANUAL, BULK, PAYMENT_RECEIPT, REMINDER
    sender_id UUID REFERENCES profiles(id),
    recipient_customer_id UUID REFERENCES customers(id),
    recipient_phone VARCHAR(50),
    recipient_email VARCHAR(255),
    content TEXT NOT NULL,
    provider_reference VARCHAR(100),
    delivery_status VARCHAR(50) DEFAULT 'SENT', -- PENDING, SENT, DELIVERED, FAILED
    sent_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS followups_and_reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL, -- CALL, SMS, WHATSAPP, VISIT, APPOINTMENT, PAYMENT, BOOKING, TITLE
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
    assigned_to_id UUID REFERENCES profiles(id) NOT NULL,
    due_date TIMESTAMPTZ NOT NULL,
    title VARCHAR(255) NOT NULL,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, COMPLETED, OVERDUE, CANCELLED
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CONTROLLED AI ASSISTANT & AUTOMATION ENGINE
CREATE TABLE IF NOT EXISTS ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    session_title VARCHAR(255) DEFAULT 'AI Session',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES ai_conversations(id) ON DELETE CASCADE NOT NULL,
    sender_role VARCHAR(50) NOT NULL, -- USER, ASSISTANT, TOOL
    content TEXT NOT NULL,
    tool_calls JSONB,
    tool_results JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS automations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    event_trigger VARCHAR(100) NOT NULL, -- BOOKING_CREATED, PAYMENT_CONFIRMED, TITLE_READY, NEW_LEAD
    conditions JSONB DEFAULT '{}'::jsonb,
    action_type VARCHAR(100) NOT NULL, -- SEND_SMS, SEND_WHATSAPP, CREATE_FOLLOWUP, NOTIFY_STAFF
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS automation_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    automation_id UUID REFERENCES automations(id) ON DELETE CASCADE NOT NULL,
    trigger_payload JSONB,
    status VARCHAR(50) DEFAULT 'SUCCESS',
    log_output TEXT,
    executed_at TIMESTAMPTZ DEFAULT NOW()
);
