const { Client } = require('pg');

const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function fixStorage() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        
        const sql = `
            -- Enable RLS on storage objects
            -- Note: By default, Supabase might already have RLS on storage.objects

            -- Create policy to allow authenticated users to upload files to inspection-evidence bucket
            drop policy if exists "Allow authenticated uploads" on storage.objects;
            create policy "Allow authenticated uploads"
            on storage.objects for insert to authenticated
            with check ( bucket_id = 'inspection-evidence' );

            -- Create policy to allow public reads (just in case 'public: true' isn't enough)
            drop policy if exists "Allow public read" on storage.objects;
            create policy "Allow public read"
            on storage.objects for select to public
            using ( bucket_id = 'inspection-evidence' );
            
            -- Create policy to allow update/delete just in case
            drop policy if exists "Allow authenticated update" on storage.objects;
            create policy "Allow authenticated update"
            on storage.objects for update to authenticated
            using ( bucket_id = 'inspection-evidence' );
        `;
        
        await client.query(sql);
        console.log("Storage RLS fixed!");
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}

fixStorage();
