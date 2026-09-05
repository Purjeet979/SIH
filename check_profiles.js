const { Client } = require('pg');
const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function checkProfiles() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        const res = await client.query('SELECT * FROM public.profiles');
        console.log("Profiles:", res.rows);
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}
checkProfiles();
