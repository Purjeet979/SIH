'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function DashboardPage() {
  const [inspections, setInspections] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchInspections = async () => {
    try {
      const res = await fetch('https://zbkphvdtxwydfihgcbnv.supabase.co/rest/v1/inspections?select=*&order=id.desc', {
        headers: {
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpia3BodmR0eHd5ZGZpaGdjYm52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MDcyMzksImV4cCI6MjEwNDE4MzIzOX0.B-iPMWxV3CrFq1vnkWWedXQk31KCf33paD5kDctoIu0',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpia3BodmR0eHd5ZGZpaGdjYm52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MDcyMzksImV4cCI6MjEwNDE4MzIzOX0.B-iPMWxV3CrFq1vnkWWedXQk31KCf33paD5kDctoIu0'
        }
      });
      const data = await res.json();
      if (Array.isArray(data)) {
        setInspections(data);
      }
    } catch (err) {
      console.error("Failed to fetch inspections:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchInspections();
    // Poll every 5 seconds for new syncs
    const interval = setInterval(fetchInspections, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="dashboard-body">
      <div className="topbar">
        <div className="brand"><span className="dot"></span>RuleScan</div>
        <nav>
          <Link href="/">Landing page</Link>
          <Link className="active" href="/dashboard">Dashboard</Link>
        </nav>
        <Link className="back" href="/">&larr; Back to site</Link>
      </div>

      <div className="shell">
        <div className="page-head">
          <div>
            <h1>Compliance overview</h1>
            <p>State Legal Metrology cell &middot; All categories &middot; Live Data</p>
          </div>
          <div style={{display: 'flex', alignItems: 'center', gap: '12px'}}>
            <button onClick={() => window.print()} className="demo-tag" style={{background: '#e0e7ff', color: '#4338ca', border: '1px solid #c7d2fe', cursor: 'pointer'}}>
              📄 EXPORT AS PDF
            </button>
            <span className="demo-tag" style={{background: '#dcfce7', color: '#166534', border: '1px solid #bbf7d0'}}>LIVE SYNC ENABLED</span>
          </div>
        </div>

        <div className="stat-row">
          <div className="stat-card">
            <div className="num">{inspections.length}</div>
            <div className="lbl">Total Scans Synced</div>
            <div className="delta delta-up">From mobile app</div>
          </div>
          <div className="stat-card">
            <div className="num">
              {inspections.length > 0 
                ? Math.round((inspections.filter(i => !i.violations || i.violations.trim() === '').length / inspections.length) * 100) 
                : 0}%
            </div>
            <div className="lbl">Overall compliance rate</div>
            <div className="delta delta-up">Of synced records</div>
          </div>
          <div className="stat-card">
            <div className="num">
                {inspections.filter(i => i.violations && i.violations.trim() !== '').length}
            </div>
            <div className="lbl">Scans with Violations</div>
            <div className="delta delta-down">Need action</div>
          </div>
          <div className="stat-card">
            <div className="num">{new Set(inspections.map(i => i.category)).size}</div>
            <div className="lbl">Categories scanned</div>
            <div className="delta delta-up">Unique types</div>
          </div>
        </div>

        <div className="panel">
          <h3>Recent scans</h3>
          <div className="sub">Latest inspections synced from field officers via Supabase Cloud</div>
          <table>
            <thead>
              <tr><th>Evidence</th><th>Category</th><th>Coordinates</th><th>Officer</th><th>Time</th><th>Status</th></tr>
            </thead>
            <tbody>
              {loading && <tr><td colSpan="6" style={{textAlign: 'center', padding: '20px'}}>Loading live data...</td></tr>}
              {!loading && inspections.length === 0 && <tr><td colSpan="6" style={{textAlign: 'center', padding: '20px'}}>No inspections synced yet. Run a scan on the mobile app and tap SYNC DATA.</td></tr>}
              {inspections.map((insp) => {
                  const violationsList = (insp.violations && insp.violations.trim() !== '') ? insp.violations.split(',') : [];
                  const isCompliant = violationsList.length === 0;
                  
                  return (
                    <tr key={insp.id}>
                      <td>
                        {insp.image_data ? (
                           <a href={`data:image/jpeg;base64,${insp.image_data}`} target="_blank" rel="noreferrer" title="Click to view full image">
                               <img src={`data:image/jpeg;base64,${insp.image_data}`} alt="Evidence" style={{width: '60px', height: '60px', objectFit: 'cover', borderRadius: '4px', border: '1px solid #ddd'}} />
                           </a>
                        ) : (
                           <div style={{width: '60px', height: '60px', backgroundColor: '#eee', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', color: '#888', border: '1px solid #ddd'}}>No Photo</div>
                        )}
                      </td>
                      <td className="prod-cell">
                        <div className="pname">Inspection #{insp.mobile_id}</div>
                        <div className="pcat">{insp.category}</div>
                        {insp.barcode && insp.barcode.trim() !== '' && (
                          <div className="pcat" style={{color: '#6366f1', marginTop: '4px', fontSize: '11px'}}>
                            <span style={{fontWeight: 'bold'}}>Barcode:</span> {insp.barcode}
                          </div>
                        )}
                      </td>
                      <td>
                        {insp.latitude && insp.longitude 
                            ? <a href={`https://maps.google.com/?q=${insp.latitude},${insp.longitude}`} target="_blank" rel="noreferrer" style={{color: '#2563eb', textDecoration: 'underline'}}>
                                {insp.latitude.toFixed(4)}, {insp.longitude.toFixed(4)}
                              </a> 
                            : 'No GPS'}
                      </td>
                      <td>{insp.officer_id}</td>
                      <td>{new Date(insp.timestamp).toLocaleString()}</td>
                      <td>
                        {isCompliant ? (
                          <span className="chip chip-ok">Compliant</span>
                        ) : (
                          <span className="chip chip-flag">{violationsList.length} flagged</span>
                        )}
                      </td>
                    </tr>
                  )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
