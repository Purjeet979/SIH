const { Client } = require('pg');
const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function checkPolicies() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        const res = await client.query(`
            SELECT polname, polcmd, polroles, polqual, polwithcheck 
            FROM pg_policy 
            WHERE polrelid = 'products'::regclass;
        `);
        console.log("Products Policies:", res.rows);
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}
checkPolicies();
