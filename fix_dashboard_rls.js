const { Client } = require('pg');
const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function fixDashboardRLS() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        const sql = `
            -- Allow public to view everything so the unauthenticated Next.js Dashboard can fetch data
            drop policy if exists "Public can view inspections" on public.inspections;
            create policy "Public can view inspections" 
            on public.inspections for select to anon using (true);
            create policy "Public auth view inspections" 
            on public.inspections for select to authenticated using (true);

            drop policy if exists "Public can view products" on public.products;
            create policy "Public can view products" 
            on public.products for select to anon using (true);

            drop policy if exists "Public can view evidence" on public.evidence;
            create policy "Public can view evidence" 
            on public.evidence for select to anon using (true);
            create policy "Public auth view evidence" 
            on public.evidence for select to authenticated using (true);
        `;
        await client.query(sql);
        console.log("Dashboard Public Read Policies added successfully!");
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}
fixDashboardRLS();
