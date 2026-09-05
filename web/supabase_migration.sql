-- ============================================================
-- RULESCAN — SUPABASE DATABASE MIGRATION
-- Run this entire script in Supabase SQL Editor
-- ============================================================

-- 1. EXTENSIONS
create extension if not exists pgcrypto;

-- ============================================================
-- 2. TABLES
-- ============================================================

-- PROFILES — Officer/Admin/User information
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text,
    role text not null default 'USER'
        check (role in ('ADMIN', 'EMPLOYEE', 'USER')),
    department text,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- PRODUCTS — Product basic information
create table public.products (
    id uuid primary key default gen_random_uuid(),
    brand text,
    product_name text,
    manufacturer text,
    category text,
    quantity_value numeric,
    quantity_unit text,
    mrp numeric,
    country_of_origin text,
    barcode text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- INSPECTIONS — Complete scan record
create table public.inspections (
    id uuid primary key default gen_random_uuid(),
    officer_id uuid references public.profiles(id),
    product_id uuid references public.products(id),
    source_type text not null
        check (
            source_type in (
                'CAMERA',
                'GALLERY',
                'ECOMMERCE_SCREENSHOT',
                'ECOMMERCE_URL',
                'BARCODE'
            )
        ),
    category text,
    overall_status text not null default 'MANUAL_REVIEW'
        check (
            overall_status in (
                'PASS',
                'FAIL',
                'MANUAL_REVIEW',
                'UNCERTAIN'
            )
        ),
    officer_decision text,
    remarks text,
    latitude double precision,
    longitude double precision,
    captured_at timestamptz not null default now(),
    rule_bundle_version text,
    app_version text,
    model_version text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- OCR RESULTS — Extracted text from OCR
create table public.ocr_results (
    id uuid primary key default gen_random_uuid(),
    inspection_id uuid not null
        references public.inspections(id)
        on delete cascade,
    text_content text not null,
    confidence numeric
        check (confidence >= 0 and confidence <= 1),
    source text,
    bbox jsonb,
    language text,
    created_at timestamptz not null default now()
);

-- DECLARATIONS — Parsed label declarations
create table public.declarations (
    id uuid primary key default gen_random_uuid(),
    inspection_id uuid not null
        references public.inspections(id)
        on delete cascade,
    declaration_type text not null,
    value_text text,
    normalized_value text,
    confidence numeric
        check (confidence >= 0 and confidence <= 1),
    bbox jsonb,
    created_at timestamptz not null default now()
);

-- RULE RESULTS — Individual rule evaluation results
create table public.rule_results (
    id uuid primary key default gen_random_uuid(),
    inspection_id uuid not null
        references public.inspections(id)
        on delete cascade,
    rule_id text not null,
    rule_number text not null,
    rule_title text,
    status text not null
        check (
            status in (
                'PASS',
                'FAIL',
                'UNCERTAIN',
                'NOT_APPLICABLE',
                'MANUAL_REVIEW'
            )
        ),
    confidence numeric
        check (confidence >= 0 and confidence <= 1),
    message text,
    evidence_data jsonb,
    officer_override boolean default false,
    officer_decision text,
    remarks text,
    created_at timestamptz not null default now()
);

-- EVIDENCE — Image/crop metadata
create table public.evidence (
    id uuid primary key default gen_random_uuid(),
    inspection_id uuid not null
        references public.inspections(id)
        on delete cascade,
    evidence_type text not null
        check (
            evidence_type in (
                'ORIGINAL_IMAGE',
                'CROP',
                'OCR_REGION',
                'PDP_REGION'
            )
        ),
    storage_path text,
    image_hash text,
    metadata jsonb,
    created_at timestamptz not null default now()
);

-- RULE BUNDLES — Versioned LMPC rule sets
create table public.rule_bundles (
    id uuid primary key default gen_random_uuid(),
    bundle_version text not null unique,
    effective_from timestamptz,
    source_reference text,
    checksum text,
    rules jsonb not null,
    is_active boolean default false,
    created_at timestamptz not null default now()
);

-- SYNC LOGS — Offline sync tracking
create table public.sync_logs (
    id uuid primary key default gen_random_uuid(),
    entity_type text not null,
    entity_id uuid not null,
    operation text not null
        check (operation in ('CREATE', 'UPDATE')),
    status text not null default 'PENDING'
        check (status in ('PENDING', 'SYNCED', 'FAILED')),
    retry_count integer default 0,
    last_error text,
    created_at timestamptz not null default now(),
    synced_at timestamptz
);

-- ============================================================
-- 3. INDEXES
-- ============================================================

create index idx_inspections_officer on public.inspections(officer_id);
create index idx_inspections_product on public.inspections(product_id);
create index idx_inspections_status on public.inspections(overall_status);
create index idx_inspections_captured_at on public.inspections(captured_at);
create index idx_rule_results_inspection on public.rule_results(inspection_id);
create index idx_rule_results_rule_number on public.rule_results(rule_number);
create index idx_declarations_inspection on public.declarations(inspection_id);
create index idx_ocr_results_inspection on public.ocr_results(inspection_id);
create index idx_evidence_inspection on public.evidence(inspection_id);
create index idx_sync_logs_status on public.sync_logs(status);
create index idx_profiles_role on public.profiles(role);

-- ============================================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.inspections enable row level security;
alter table public.ocr_results enable row level security;
alter table public.declarations enable row level security;
alter table public.rule_results enable row level security;
alter table public.evidence enable row level security;
alter table public.rule_bundles enable row level security;
alter table public.sync_logs enable row level security;

-- ============================================================
-- 5. RLS POLICIES
-- ============================================================

-- Helper function to get current user's role
create or replace function public.get_user_role()
returns text as $$
  select role from public.profiles where id = auth.uid();
$$ language sql security definer stable;

-- ── PROFILES ──

-- Users can view their own profile
create policy "Users can view own profile"
on public.profiles for select to authenticated
using (id = auth.uid());

-- Users can update their own profile
create policy "Users can update own profile"
on public.profiles for update to authenticated
using (id = auth.uid());

-- Admins can view all profiles
create policy "Admins can view all profiles"
on public.profiles for select to authenticated
using (public.get_user_role() = 'ADMIN');

-- Admins can update any profile
create policy "Admins can update any profile"
on public.profiles for update to authenticated
using (public.get_user_role() = 'ADMIN');

-- Allow insert for new signups (via trigger)
create policy "Allow profile insert on signup"
on public.profiles for insert to authenticated
with check (id = auth.uid());

-- ── PRODUCTS ──

-- Authenticated users can read products
create policy "Authenticated users can read products"
on public.products for select to authenticated
using (true);

-- Employees and Admins can create products
create policy "Employees and Admins can create products"
on public.products for insert to authenticated
with check (public.get_user_role() in ('EMPLOYEE', 'ADMIN'));

-- Admins can update/delete products
create policy "Admins can manage products"
on public.products for update to authenticated
using (public.get_user_role() = 'ADMIN');

-- ── INSPECTIONS ──

-- Employees can create inspections
create policy "Employees can create inspections"
on public.inspections for insert to authenticated
with check (officer_id = auth.uid());

-- Employees can view own inspections
create policy "Employees can view own inspections"
on public.inspections for select to authenticated
using (officer_id = auth.uid());

-- Admins can view all inspections
create policy "Admins can view all inspections"
on public.inspections for select to authenticated
using (public.get_user_role() = 'ADMIN');

-- Users (public) can view inspections (read-only analytics)
create policy "Users can view inspections for analytics"
on public.inspections for select to authenticated
using (public.get_user_role() = 'USER');

-- ── OCR RESULTS ──

create policy "Officers can manage own OCR results"
on public.ocr_results for all to authenticated
using (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
)
with check (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
);

create policy "Admins can manage all OCR results"
on public.ocr_results for all to authenticated
using (public.get_user_role() = 'ADMIN')
with check (public.get_user_role() = 'ADMIN');

-- ── DECLARATIONS ──

create policy "Officers can manage own declarations"
on public.declarations for all to authenticated
using (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
)
with check (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
);

create policy "Admins can manage all declarations"
on public.declarations for all to authenticated
using (public.get_user_role() = 'ADMIN')
with check (public.get_user_role() = 'ADMIN');

-- ── RULE RESULTS ──

create policy "Officers can view own rule results"
on public.rule_results for select to authenticated
using (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
);

create policy "Officers can insert rule results"
on public.rule_results for insert to authenticated
with check (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
);

create policy "Admins can manage all rule results"
on public.rule_results for all to authenticated
using (public.get_user_role() = 'ADMIN')
with check (public.get_user_role() = 'ADMIN');

create policy "Users can view rule results"
on public.rule_results for select to authenticated
using (public.get_user_role() = 'USER');

-- ── EVIDENCE ──

create policy "Officers can manage own evidence"
on public.evidence for all to authenticated
using (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
)
with check (
    exists (
        select 1 from public.inspections i
        where i.id = inspection_id and i.officer_id = auth.uid()
    )
);

create policy "Admins can manage all evidence"
on public.evidence for all to authenticated
using (public.get_user_role() = 'ADMIN')
with check (public.get_user_role() = 'ADMIN');

-- ── RULE BUNDLES ──

create policy "Authenticated users can read rule bundles"
on public.rule_bundles for select to authenticated
using (true);

create policy "Admins can manage rule bundles"
on public.rule_bundles for all to authenticated
using (public.get_user_role() = 'ADMIN')
with check (public.get_user_role() = 'ADMIN');

-- ── SYNC LOGS ──

create policy "Officers can manage own sync logs"
on public.sync_logs for all to authenticated
using (true)
with check (true);

-- ============================================================
-- 6. AUTO-CREATE PROFILE ON SIGNUP TRIGGER
-- ============================================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, full_name, role)
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', ''),
        coalesce(new.raw_user_meta_data->>'role', 'USER')
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ============================================================
-- 7. UPDATED_AT TRIGGER
-- ============================================================

create or replace function public.update_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at before update on public.profiles
    for each row execute function public.update_updated_at();

create trigger products_updated_at before update on public.products
    for each row execute function public.update_updated_at();

create trigger inspections_updated_at before update on public.inspections
    for each row execute function public.update_updated_at();

-- ============================================================
-- 8. SEED DATA — Default Rule Bundle (LMPC 2026.01)
-- ============================================================

insert into public.rule_bundles (bundle_version, effective_from, source_reference, is_active, rules)
values (
    '2026.01',
    now(),
    'Legal Metrology (Packaged Commodities) Rules, 2011',
    true,
    '[
        {"rule_id": "R6", "rule_number": "6", "title": "Mandatory Declarations", "description": "Name, address, net quantity, MRP, date, customer care, country of origin"},
        {"rule_id": "R6_8", "rule_number": "6(8)", "title": "Veg/Non-Veg Indicator", "description": "Green/brown dot on food products"},
        {"rule_id": "R7", "rule_number": "7", "title": "Numeral & Letter Height", "description": "Minimum height based on principal display panel area"},
        {"rule_id": "R8", "rule_number": "8", "title": "Net Quantity Declaration", "description": "Correct standard units of weight/volume/length/number"},
        {"rule_id": "R9", "rule_number": "9", "title": "Combined Package Rules", "description": "Multi-piece / combo pack declarations"},
        {"rule_id": "R11", "rule_number": "11", "title": "Unit Sale Price", "description": "Price per standard unit (g/ml/cm)"},
        {"rule_id": "R12", "rule_number": "12", "title": "Best Before / Use By", "description": "Date marking requirements for perishable goods"},
        {"rule_id": "R13", "rule_number": "13", "title": "MRP Declaration", "description": "Maximum retail price including all taxes"},
        {"rule_id": "R26", "rule_number": "26", "title": "Exemptions", "description": "Categories and conditions for exemption from certain rules"}
    ]'::jsonb
);

-- ============================================================
-- 9. STORAGE BUCKET (Run separately if needed)
-- NOTE: Create a bucket called "inspection-evidence" in
--       Supabase Dashboard > Storage > New Bucket
-- ============================================================

-- insert into storage.buckets (id, name, public)
-- values ('inspection-evidence', 'inspection-evidence', false);

-- ============================================================
-- DONE! Your RuleScan database is ready.
-- ============================================================
