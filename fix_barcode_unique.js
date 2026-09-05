const { Client } = require('pg');

const DB_URL = 'postgresql://postgres:Purjeet%409506@db.ganoupqtsujbtrikhiia.supabase.co:5432/postgres';

async function fixDB() {
    const client = new Client({
        connectionString: DB_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        
        // Find the constraint name and drop it
        const sql = `
            ALTER TABLE products DROP CONSTRAINT IF EXISTS products_barcode_key;
        `;
        
        await client.query(sql);
        console.log("Barcode unique constraint dropped!");
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await client.end();
    }
}

fixDB();
