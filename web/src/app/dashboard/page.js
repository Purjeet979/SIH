'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://ganoupqtsujbtrikhiia.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhbm91cHF0c3VqYnRyaWtoaWlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MjQyMDQsImV4cCI6MjEwNDIwMDIwNH0.tySQFHOj3VMOcEAU469yca_5nYNok0286yYmnC1j6aY'
);

export default function DashboardPage() {
  const [inspections, setInspections] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchInspections = async () => {
    try {
      const { data, error } = await supabase
        .from('inspections')
        .select(`
          id,
          category,
          overall_status,
          remarks,
          latitude,
          longitude,
          officer_id,
          created_at,
          products ( barcode ),
          evidence ( storage_path )
        `)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      if (data) {
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
                ? Math.round((inspections.filter(i => i.overall_status === 'PASS').length / inspections.length) * 100) 
                : 0}%
            </div>
            <div className="lbl">Overall compliance rate</div>
            <div className="delta delta-up">Of synced records</div>
          </div>
          <div className="stat-card">
            <div className="num">
                {inspections.filter(i => i.overall_status === 'FAIL').length}
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
                  const violationsList = (insp.remarks && insp.remarks.trim() !== '') ? insp.remarks.split(',') : [];
                  const isCompliant = insp.overall_status === 'PASS';
                  const storagePath = insp.evidence && insp.evidence.length > 0 ? insp.evidence[0].storage_path : null;
                  const imageUrl = storagePath ? `https://ganoupqtsujbtrikhiia.supabase.co/storage/v1/object/public/inspection-evidence/${storagePath}` : null;
                  const barcode = insp.products && insp.products.barcode ? insp.products.barcode : '';
                  
                  return (
                    <tr key={insp.id}>
                      <td>
                        {imageUrl ? (
                           <a href={imageUrl} target="_blank" rel="noreferrer" title="Click to view full image">
                               <img src={imageUrl} alt="Evidence" style={{width: '60px', height: '60px', objectFit: 'cover', borderRadius: '4px', border: '1px solid #ddd'}} />
                           </a>
                        ) : (
                           <div style={{width: '60px', height: '60px', backgroundColor: '#eee', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', color: '#888', border: '1px solid #ddd', textAlign: 'center'}}>No<br/>Photo</div>
                        )}
                      </td>
                      <td className="prod-cell">
                        <div className="pname">Inspection</div>
                        <div className="pcat">{insp.category}</div>
                        {barcode.trim() !== '' && (
                          <div className="pcat" style={{color: '#6366f1', marginTop: '4px', fontSize: '11px'}}>
                            <span style={{fontWeight: 'bold'}}>Barcode:</span> {barcode}
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
                      <td style={{fontSize: '11px', maxWidth: '100px', overflow: 'hidden', textOverflow: 'ellipsis'}}>{insp.officer_id}</td>
                      <td>{new Date(insp.created_at).toLocaleString()}</td>
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
