const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'central_sync.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Error opening database', err.message);
    } else {
        console.log('Connected to the central SQLite database.');
        
        // Create table for synced inspections
        db.run(`
            CREATE TABLE IF NOT EXISTS inspections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                mobile_id INTEGER UNIQUE,
                category TEXT,
                timestamp TEXT,
                latitude REAL,
                longitude REAL,
                violations TEXT,
                officer_id TEXT
            )
        `);
    }
});

module.exports = db;
