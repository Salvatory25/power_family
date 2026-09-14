-- ============================================================================
-- POWER FAMILY INVESTMENT - PHASE 4: FINANCE, PAYMENTS & INSTALLMENTS
-- ============================================================================

-- 1. INVOICES TABLE
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE, -- e.g. INV-2026-000001
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
    
    status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PARTIAL, PAID, OVERDUE, VOIDED, REVERSED
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. INVOICE ITEMS
CREATE TABLE IF NOT EXISTS invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE NOT NULL,
    description TEXT NOT NULL,
    quantity INT DEFAULT 1,
    unit_price NUMERIC(15, 2) NOT NULL,
    total_price NUMERIC(15, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PAYMENTS TABLE (STRICT NON-MUTABILITY TRIGGER)
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_number VARCHAR(50) NOT NULL UNIQUE, -- e.g. PAY-2026-000001
    branch_id UUID REFERENCES branches(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    invoice_id UUID REFERENCES invoices(id),
    sale_id UUID REFERENCES sales(id),
    plot_id UUID REFERENCES plots(id) NOT NULL,
    
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) NOT NULL, -- CASH, BANK_TRANSFER, MOBILE_MONEY, CONTROL_NUMBER, CLICKPESA
    payment_reference VARCHAR(100) UNIQUE, -- Transaction ID / Control No ref
    control_number VARCHAR(100),
    
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, CONFIRMED, FAILED, VOIDED, REVERSED
    
    received_by UUID REFERENCES profiles(id),
    confirmed_by UUID REFERENCES profiles(id),
    confirmed_at TIMESTAMPTZ,
    
    reversal_reason TEXT,
    original_payment_id UUID REFERENCES payments(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. RECEIPTS TABLE
CREATE TABLE IF NOT EXISTS receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_number VARCHAR(50) NOT NULL UNIQUE, -- e.g. REC-2026-000001
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

-- 5. INSTALLMENT PLANS & SCHEDULE TABLE
CREATE TABLE IF NOT EXISTS installment_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE NOT NULL UNIQUE,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    plot_id UUID REFERENCES plots(id) NOT NULL,
    
    total_price NUMERIC(15, 2) NOT NULL,
    deposit_paid NUMERIC(15, 2) NOT NULL,
    remaining_balance NUMERIC(15, 2) NOT NULL,
    duration_months INT NOT NULL,
    monthly_installment NUMERIC(15, 2) NOT NULL,
    frequency VARCHAR(50) DEFAULT 'MONTHLY',
    
    next_due_date DATE,
    overdue_amount NUMERIC(15, 2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, COMPLETED, OVERDUE, DEFAULTED
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS installments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    installment_plan_id UUID REFERENCES installment_plans(id) ON DELETE CASCADE NOT NULL,
    installment_number INT NOT NULL,
    due_date DATE NOT NULL,
    amount_due NUMERIC(15, 2) NOT NULL,
    amount_paid NUMERIC(15, 2) DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PARTIAL, PAID, OVERDUE
    payment_id UUID REFERENCES payments(id),
    paid_at TIMESTAMPTZ
);

-- Financial Integrity Trigger: Block direct edits on CONFIRMED payments
CREATE OR REPLACE FUNCTION prevent_confirmed_payment_modification()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'CONFIRMED' AND (NEW.amount <> OLD.amount OR NEW.payment_method <> OLD.payment_method) THEN
        RAISE EXCEPTION 'Confirmed financial records cannot be directly edited. Issue a VOID or REVERSAL transaction instead.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_safety
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION prevent_confirmed_payment_modification();

-- RLS POLICIES FOR FINANCE
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE installment_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY invoices_branch_policy ON invoices FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);
CREATE POLICY payments_branch_policy ON payments FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);
CREATE POLICY receipts_branch_policy ON receipts FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);
CREATE POLICY installments_branch_policy ON installment_plans FOR ALL USING (
    current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'MANAGEMENT', 'ACCOUNTANT') OR branch_id = current_user_branch()
);
