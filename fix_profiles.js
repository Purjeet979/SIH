const { Client } = require('pg');

const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function fixProfiles() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        
        // Find the user from auth.users and insert into public.profiles
        const sql = `
            INSERT INTO public.profiles (id, full_name, role)
            SELECT id, 'Field Officer', 'OFFICER'
            FROM auth.users
            WHERE email = 'officer@rulescan.com'
            ON CONFLICT (id) DO NOTHING;
        `;
        
        const result = await client.query(sql);
        console.log("Inserted profiles! Rows affected:", result.rowCount);
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}

fixProfiles();
