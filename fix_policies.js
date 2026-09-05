const { Client } = require('pg');
const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function fixPolicies() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        const sql = `
            -- Products Policies
            drop policy if exists "Anyone can view products" on public.products;
            drop policy if exists "Officers can insert products" on public.products;
            
            create policy "Anyone can view products" 
            on public.products for select to authenticated using (true);
            
            create policy "Officers can insert products" 
            on public.products for insert to authenticated with check (true);

            -- Evidence Policies
            drop policy if exists "Officers can insert evidence" on public.evidence;
            drop policy if exists "Officers can view own evidence" on public.evidence;

            create policy "Officers can insert evidence" 
            on public.evidence for insert to authenticated with check (true);
            
            create policy "Officers can view own evidence" 
            on public.evidence for select to authenticated using (
                exists (
                    select 1 from public.inspections i 
                    where i.id = inspection_id and i.officer_id = auth.uid()
                )
            );
        `;
        await client.query(sql);
        console.log("Missing Policies added successfully!");
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}
fixPolicies();
