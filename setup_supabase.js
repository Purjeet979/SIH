const { Client } = require('pg');
const { createClient } = require('@supabase/supabase-js');

const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';
const SUPABASE_URL = 'https://ganoupqtsujbtrikhiia.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhbm91cHF0c3VqYnRyaWtoaWlhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODYyNDIwNCwiZXhwIjoyMTA0MjAwMjA0fQ.odMsG3fm-sjOfdjxobZMDRRzKNsS7R4hEoZKhnZ1WVs';

async function setup() {
    console.log("--- Starting Automated Supabase Setup ---");

    // 1. DDL Execution via pg
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log("[DB] Connected to PostgreSQL.");

        const sql = `
            create extension if not exists pgcrypto;

            create table if not exists public.profiles (
                id uuid primary key references auth.users(id) on delete cascade,
                full_name text,
                role text not null default 'OFFICER' check (role in ('OFFICER', 'ADMIN', 'REGULATOR')),
                department text,
                created_at timestamptz not null default now(),
                updated_at timestamptz not null default now()
            );

            create table if not exists public.products (
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

            create table if not exists public.inspections (
                id uuid primary key default gen_random_uuid(),
                officer_id uuid references public.profiles(id),
                product_id uuid references public.products(id),
                source_type text not null check (source_type in ('CAMERA', 'GALLERY', 'ECOMMERCE_SCREENSHOT', 'ECOMMERCE_URL', 'BARCODE')),
                category text,
                overall_status text not null default 'MANUAL_REVIEW' check (overall_status in ('PASS', 'FAIL', 'MANUAL_REVIEW', 'UNCERTAIN')),
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

            create table if not exists public.ocr_results (
                id uuid primary key default gen_random_uuid(),
                inspection_id uuid not null references public.inspections(id) on delete cascade,
                text_content text not null,
                confidence numeric check (confidence >= 0 and confidence <= 1),
                source text,
                bbox jsonb,
                language text,
                created_at timestamptz not null default now()
            );

            create table if not exists public.declarations (
                id uuid primary key default gen_random_uuid(),
                inspection_id uuid not null references public.inspections(id) on delete cascade,
                declaration_type text not null,
                value_text text,
                normalized_value text,
                confidence numeric check (confidence >= 0 and confidence <= 1),
                bbox jsonb,
                created_at timestamptz not null default now()
            );

            create table if not exists public.rule_results (
                id uuid primary key default gen_random_uuid(),
                inspection_id uuid not null references public.inspections(id) on delete cascade,
                rule_id text not null,
                rule_number text not null,
                rule_title text,
                status text not null check (status in ('PASS', 'FAIL', 'UNCERTAIN', 'NOT_APPLICABLE', 'MANUAL_REVIEW')),
                confidence numeric check (confidence >= 0 and confidence <= 1),
                message text,
                evidence_data jsonb,
                officer_override boolean default false,
                officer_decision text,
                remarks text,
                created_at timestamptz not null default now()
            );

            create table if not exists public.evidence (
                id uuid primary key default gen_random_uuid(),
                inspection_id uuid not null references public.inspections(id) on delete cascade,
                evidence_type text not null check (evidence_type in ('ORIGINAL_IMAGE', 'CROP', 'OCR_REGION', 'PDP_REGION')),
                storage_path text,
                image_hash text,
                metadata jsonb,
                created_at timestamptz not null default now()
            );

            create table if not exists public.rule_bundles (
                id uuid primary key default gen_random_uuid(),
                bundle_version text not null unique,
                effective_from timestamptz,
                source_reference text,
                checksum text,
                rules jsonb not null,
                is_active boolean default false,
                created_at timestamptz not null default now()
            );

            create table if not exists public.sync_logs (
                id uuid primary key default gen_random_uuid(),
                entity_type text not null,
                entity_id uuid not null,
                operation text not null check (operation in ('CREATE', 'UPDATE')),
                status text not null default 'PENDING' check (status in ('PENDING', 'SYNCED', 'FAILED')),
                retry_count integer default 0,
                last_error text,
                created_at timestamptz not null default now(),
                synced_at timestamptz
            );

            -- Drop RLS policies if they exist so we can re-run
            drop policy if exists "Users can view own profile" on public.profiles;
            drop policy if exists "Officers can create inspections" on public.inspections;
            drop policy if exists "Officers can view own inspections" on public.inspections;
            drop policy if exists "Officers can manage OCR results" on public.ocr_results;
            drop policy if exists "Officers can manage declarations" on public.declarations;
            drop policy if exists "Officers can view rule results" on public.rule_results;
            drop policy if exists "Authenticated users can read rule bundles" on public.rule_bundles;

            -- Enable RLS
            alter table public.profiles enable row level security;
            alter table public.products enable row level security;
            alter table public.inspections enable row level security;
            alter table public.ocr_results enable row level security;
            alter table public.declarations enable row level security;
            alter table public.rule_results enable row level security;
            alter table public.evidence enable row level security;
            alter table public.rule_bundles enable row level security;
            alter table public.sync_logs enable row level security;

            create policy "Users can view own profile" on public.profiles for select to authenticated using (id = auth.uid());
            
            create policy "Officers can create inspections" on public.inspections for insert to authenticated with check (officer_id = auth.uid());
            create policy "Officers can view own inspections" on public.inspections for select to authenticated using (officer_id = auth.uid());
            
            create policy "Officers can manage OCR results" on public.ocr_results for all to authenticated using (exists (select 1 from public.inspections i where i.id = inspection_id and i.officer_id = auth.uid())) with check (exists (select 1 from public.inspections i where i.id = inspection_id and i.officer_id = auth.uid()));
            
            create policy "Officers can manage declarations" on public.declarations for all to authenticated using (exists (select 1 from public.inspections i where i.id = inspection_id and i.officer_id = auth.uid())) with check (exists (select 1 from public.inspections i where i.id = inspection_id and i.officer_id = auth.uid()));
            
            create policy "Officers can view rule results" on public.rule_results for select to authenticated using (exists (select 1 from public.inspections i where i.id = inspection_id and i.officer_id = auth.uid()));
            
            create policy "Authenticated users can read rule bundles" on public.rule_bundles for select to authenticated using (true);
        `;
        
        await client.query(sql);
        console.log("[DB] Schema and RLS Policies successfully executed!");

        // 2. Storage and Auth via supabase-js
        const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

        console.log("[STORAGE] Creating inspection-evidence bucket...");
        const { error: bucketError } = await supabase.storage.createBucket('inspection-evidence', {
            public: true,
            fileSizeLimit: 10485760, // 10MB
        });
        if (bucketError && !bucketError.message.includes('already exists')) {
            console.error("[STORAGE] Error:", bucketError.message);
        } else {
            console.log("[STORAGE] Bucket ready.");
        }

        console.log("[AUTH] Creating test officer account...");
        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
            email: 'officer@rulescan.com',
            password: 'Purjeet@9506',
            email_confirm: true,
            user_metadata: { role: 'OFFICER', department: 'Legal Metrology' }
        });
        if (authError && !authError.message.includes('already registered')) {
            console.error("[AUTH] Error:", authError.message);
        } else {
            console.log("[AUTH] Test user ready (officer@rulescan.com / Purjeet@9506).");
            
            // Note: Since profiles table has a trigger (usually) or we insert manually:
            if (authData?.user) {
                const { error: profileError } = await supabase.from('profiles').insert({
                    id: authData.user.id,
                    full_name: 'Test Officer',
                    role: 'OFFICER',
                    department: 'Legal Metrology'
                });
                if (profileError && profileError.code !== '23505') { // 23505 is unique violation
                    console.log("[DB] Could not insert profile:", profileError.message);
                }
            }
        }

        console.log("--- Setup Complete! ---");

    } catch (e) {
        console.error("FATAL ERROR:", e);
    } finally {
        await client.end();
    }
}

setup();
