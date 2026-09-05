const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
app.use(cors());
app.use(express.json());

// 1. Sync Endpoint for Mobile App
app.post('/api/sync', (req, res) => {
    const inspections = req.body.inspections;
    if (!inspections || !Array.isArray(inspections)) {
        return res.status(400).json({ error: 'Invalid payload, expected array of inspections' });
    }

    let insertedCount = 0;
    const stmt = db.prepare(`
        INSERT OR IGNORE INTO inspections (mobile_id, category, timestamp, latitude, longitude, violations, officer_id)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    db.serialize(() => {
        db.run('BEGIN TRANSACTION');
        inspections.forEach(item => {
            stmt.run(
                item.id,
                item.category,
                item.timestamp,
                item.latitude,
                item.longitude,
                item.violations,
                item.officer_id || 'OFFICER_001',
                function(err) {
                    if (!err && this.changes > 0) insertedCount++;
                }
            );
        });
        db.run('COMMIT', (err) => {
            stmt.finalize();
            if (err) {
                console.error("Transaction Error:", err);
                return res.status(500).json({ error: 'Database transaction failed' });
            }
            res.status(200).json({ success: true, inserted: insertedCount });
        });
    });
});

// 2. Dashboard Endpoint for Web App
app.get('/api/inspections', (req, res) => {
    db.all('SELECT * FROM inspections ORDER BY timestamp DESC', [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ data: rows });
    });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Sync Server running on http://0.0.0.0:${PORT}`);
});
