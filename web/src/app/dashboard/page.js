'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function DashboardPage() {
  const [inspections, setInspections] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchInspections = async () => {
    try {
      const res = await fetch('http://localhost:3001/api/inspections');
      const data = await res.json();
      if (data.data) {
        setInspections(data.data);
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

  const [selectedZone, setSelectedZone] = useState('All');
  const [officerLimit, setOfficerLimit] = useState(5);
  const [scansLimit, setScansLimit] = useState(5);

  const zones = [
    { id: 'z1', name: 'Central Commercial Hub', code: 'DL-CENTRAL-01', officers: 6, scans: 486, violations: 68, topRisk: 'Packaged Food & Dairy', compliance: 86.0, target: 550, risk: 'Moderate' },
    { id: 'z2', name: 'South District Retail Corridor', code: 'DL-SOUTH-04', officers: 5, scans: 374, violations: 32, topRisk: 'Cosmetics & Personal Care', compliance: 91.4, target: 400, risk: 'Low' },
    { id: 'z3', name: 'West Industrial & Logistics Hub', code: 'DL-WEST-07', officers: 5, scans: 312, violations: 54, topRisk: 'Edible Oils & Commodities', compliance: 82.7, target: 380, risk: 'High' },
    { id: 'z4', name: 'North Wholesale Mandi Zone', code: 'DL-NORTH-02', officers: 4, scans: 256, violations: 14, topRisk: 'Grains, Pulses & Spices', compliance: 94.5, target: 300, risk: 'Low' },
    { id: 'z5', name: 'East E-Commerce Belt', code: 'DL-EAST-09', officers: 4, scans: 218, violations: 39, topRisk: 'Imported Electronics', compliance: 82.1, target: 260, risk: 'High' },
  ];

  const officers = [
    { id: 'off_001', name: 'Insp. Rajesh Sharma', badge: 'LM-DL-104', zone: 'Central Commercial Hub', scans: 142, today: 16, violations: 19, status: 'Active on Field' },
    { id: 'off_002', name: 'Insp. Anita Desai', badge: 'LM-DL-219', zone: 'West Industrial & Logistics Hub', scans: 128, today: 14, violations: 23, status: 'Active on Field' },
    { id: 'off_003', name: 'Insp. Vikram Malhotra', badge: 'LM-DL-308', zone: 'Central Commercial Hub', scans: 116, today: 11, violations: 15, status: 'Active on Field' },
    { id: 'off_004', name: 'Insp. Priya Nair', badge: 'LM-DL-412', zone: 'South District Retail Corridor', scans: 104, today: 9, violations: 8, status: 'Reporting' },
    { id: 'off_005', name: 'Insp. Amit Patel', badge: 'LM-DL-515', zone: 'East E-Commerce Belt', scans: 98, today: 13, violations: 18, status: 'Active on Field' },
    { id: 'off_006', name: 'Insp. Sunita Rao', badge: 'LM-DL-620', zone: 'North Wholesale Mandi Zone', scans: 92, today: 7, violations: 6, status: 'Active on Field' },
  ];

  const totalAreaScans = zones.reduce((a, b) => a + b.scans, 0) + inspections.length;
  const totalOfficersCount = 24;
  const activeOfficersCount = 19;

  return (
    <div className="dashboard-body">
      <div className="topbar">
        <div className="brand"><span className="dot"></span>RuleScan <small style={{color: '#94a3b8', fontSize: '12px', marginLeft: '6px'}}>Admin Command</small></div>
        <nav>
          <Link href="/">Landing page</Link>
          <Link className="active" href="/dashboard">Admin Dashboard</Link>
        </nav>
        <Link className="back" href="/">&larr; Back to site</Link>
      </div>

      <div className="shell">
        <div className="page-head">
          <div>
            <h1>Admin Command & Surveillance Oversight</h1>
            <p>State Legal Metrology Authority &middot; Field Force & Area-Wise Enforcement Tracking</p>
          </div>
          <div style={{display: 'flex', alignItems: 'center', gap: '12px'}}>
            <button onClick={() => window.print()} className="demo-tag" style={{background: '#e0e7ff', color: '#4338ca', border: '1px solid #c7d2fe', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px'}}>
              <span>📄</span> EXPORT DOSSIER (PDF)
            </button>
            <span className="demo-tag" style={{background: '#dcfce7', color: '#166534', border: '1px solid #bbf7d0', display: 'flex', alignItems: 'center', gap: '6px'}}>
              <span style={{width: '6px', height: '6px', borderRadius: '50%', background: '#16a34a'}}></span> LIVE SYNC ACTIVE
            </span>
          </div>
        </div>

        {/* 4 Stat Cards */}
        <div className="stat-row">
          <div className="stat-card">
            <div className="num">{totalOfficersCount}</div>
            <div className="lbl">Enrolled Field Officers</div>
            <div className="delta delta-up">{activeOfficersCount} active on duty today</div>
          </div>
          <div className="stat-card">
            <div className="num">{totalAreaScans}</div>
            <div className="lbl">Total Area Scans Done</div>
            <div className="delta delta-up">Across 5 monitoring zones</div>
          </div>
          <div className="stat-card">
            <div className="num">
              {zones.reduce((a, b) => a + b.violations, 0) + inspections.filter(i => i.violations && i.violations.trim() !== '').length}
            </div>
            <div className="lbl">Violations Flagged</div>
            <div className="delta delta-down">11.8% Non-compliance rate</div>
          </div>
          <div className="stat-card">
            <div className="num">{zones.length} Zones</div>
            <div className="lbl">Surveillance Coverage</div>
            <div className="delta delta-up">100% jurisdiction mapped</div>
          </div>
        </div>

        {/* AREA-WISE SURVEILLANCE BREAKDOWN */}
        <div className="panel" style={{marginBottom: '24px'}}>
          <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px', marginBottom: '16px'}}>
            <div>
              <h3>Area-Wise Scans & Zonal Surveillance</h3>
              <div className="sub" style={{marginBottom: 0}}>Enforcement metrics, inspection counts, and violation risk across all designated zones</div>
            </div>
            <div style={{display: 'flex', gap: '8px', alignItems: 'center'}}>
              <span style={{fontSize: '13px', color: 'var(--text-muted)'}}>Filter Zone:</span>
              <select 
                value={selectedZone} 
                onChange={(e) => setSelectedZone(e.target.value)}
                style={{padding: '6px 12px', borderRadius: '6px', border: '1px solid var(--line)', background: '#fff', fontSize: '13px', cursor: 'pointer'}}
              >
                <option value="All">All Zones ({zones.length})</option>
                {zones.map(z => <option key={z.id} value={z.name}>{z.name}</option>)}
              </select>
            </div>
          </div>

          <table>
            <thead>
              <tr>
                <th>Surveillance Zone</th>
                <th>District Code</th>
                <th>Officers Deployed</th>
                <th>Total Scans</th>
                <th>Violations</th>
                <th>Compliance Rate</th>
                <th>Hotspot Category</th>
                <th>Risk Level</th>
              </tr>
            </thead>
            <tbody>
              {zones
                .filter(z => selectedZone === 'All' || z.name === selectedZone)
                .map((z) => (
                  <tr key={z.id}>
                    <td style={{fontWeight: '600', color: 'var(--text-dark)'}}>{z.name}</td>
                    <td><span style={{fontFamily: 'monospace', fontSize: '12px', background: '#e2e8f0', padding: '2px 6px', borderRadius: '4px'}}>{z.code}</span></td>
                    <td><strong>{z.officers}</strong> Officers</td>
                    <td><strong>{z.scans}</strong> scans</td>
                    <td style={{color: z.violations > 40 ? 'var(--alert)' : 'var(--text-dark)', fontWeight: '600'}}>{z.violations} flagged</td>
                    <td>
                      <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                        <div style={{width: '60px', height: '6px', background: '#e2e8f0', borderRadius: '3px', overflow: 'hidden'}}>
                          <div style={{width: `${z.compliance}%`, height: '100%', background: z.compliance >= 90 ? 'var(--ok)' : (z.compliance >= 85 ? 'var(--brass)' : 'var(--alert)')}}></div>
                        </div>
                        <span style={{fontSize: '12.5px', fontWeight: '500'}}>{z.compliance}%</span>
                      </div>
                    </td>
                    <td style={{fontSize: '12.5px', color: 'var(--text-muted)'}}>{z.topRisk}</td>
                    <td>
                      <span className={`chip ${z.risk === 'Low' ? 'chip-ok' : 'chip-flag'}`} style={{fontSize: '11px'}}>
                        {z.risk} Risk
                      </span>
                    </td>
                  </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* FIELD FORCE OFFICERS DIRECTORY */}
        <div className="panel" style={{marginBottom: '24px'}}>
          <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px', flexWrap: 'wrap', gap: '8px'}}>
            <div>
              <h3>Field Force Officers & Scan Performance</h3>
              <div className="sub" style={{marginBottom: 0}}>Roster of deployed officers, individual scan volume, and enforcement activity</div>
            </div>
            <div style={{display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap'}}>
              <span style={{fontSize: '12px', color: 'var(--text-muted)'}}>Show:</span>
              {[5, 10, -1].map((lim) => (
                <button
                  key={lim}
                  onClick={() => setOfficerLimit(lim)}
                  style={{
                    padding: '3px 9px',
                    borderRadius: '5px',
                    border: '1px solid ' + (officerLimit === lim ? '#2563eb' : 'var(--line)'),
                    background: officerLimit === lim ? '#2563eb' : '#fff',
                    color: officerLimit === lim ? '#fff' : 'var(--text-dark)',
                    fontSize: '11.5px',
                    fontWeight: '600',
                    cursor: 'pointer'
                  }}
                >
                  {lim === -1 ? 'All' : lim}
                </button>
              ))}
              <span style={{fontSize: '12px', background: '#eff6ff', color: '#1d4ed8', padding: '3px 8px', borderRadius: '10px', fontWeight: '600', marginLeft: '6px'}}>
                24 Total
              </span>
            </div>
          </div>

          <table>
            <thead>
              <tr>
                <th>Officer Name</th>
                <th>Badge #</th>
                <th>Assigned Zone</th>
                <th>Scans Completed</th>
                <th>Today's Scans</th>
                <th>Violations Found</th>
                <th>Field Status</th>
              </tr>
            </thead>
            <tbody>
              {(officerLimit === -1 ? officers : officers.slice(0, officerLimit)).map((off) => (
                <tr key={off.id}>
                  <td style={{fontWeight: '600', color: 'var(--text-dark)'}}>
                    <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                      <div style={{width: '26px', height: '26px', borderRadius: '50%', background: '#2563eb', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', fontWeight: 'bold'}}>
                        {off.name.split(' ').slice(-1)[0][0]}
                      </div>
                      {off.name}
                    </div>
                  </td>
                  <td><span style={{fontFamily: 'monospace', fontSize: '12px'}}>{off.badge}</span></td>
                  <td>{off.zone}</td>
                  <td><strong>{off.scans}</strong> scans</td>
                  <td style={{color: 'var(--ok)', fontWeight: '600'}}>+{off.today} today</td>
                  <td style={{color: off.violations > 15 ? 'var(--alert)' : 'var(--text-dark)', fontWeight: '600'}}>{off.violations} flagged</td>
                  <td>
                    <span style={{
                      display: 'inline-flex', alignItems: 'center', gap: '5px',
                      fontSize: '11.5px', fontWeight: '500', padding: '3px 8px', borderRadius: '12px',
                      background: off.status === 'Active on Field' ? '#dcfce7' : '#f1f5f9',
                      color: off.status === 'Active on Field' ? '#166534' : '#475569'
                    }}>
                      <span style={{width: '6px', height: '6px', borderRadius: '50%', background: off.status === 'Active on Field' ? '#16a34a' : '#94a3b8'}}></span>
                      {off.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* RECENT SCANS TABLE */}
        <div className="panel">
          <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px', flexWrap: 'wrap', gap: '8px'}}>
            <div>
              <h3>Recent Synced Evidence & Audits</h3>
              <div className="sub" style={{marginBottom: 0}}>Live inspections synced from mobile field force devices via SQLite Central Bridge</div>
            </div>
            <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
              <span style={{fontSize: '12px', color: 'var(--text-muted)'}}>Show:</span>
              {[5, 10, -1].map((lim) => (
                <button
                  key={lim}
                  onClick={() => setScansLimit(lim)}
                  style={{
                    padding: '3px 9px',
                    borderRadius: '5px',
                    border: '1px solid ' + (scansLimit === lim ? '#2563eb' : 'var(--line)'),
                    background: scansLimit === lim ? '#2563eb' : '#fff',
                    color: scansLimit === lim ? '#fff' : 'var(--text-dark)',
                    fontSize: '11.5px',
                    fontWeight: '600',
                    cursor: 'pointer'
                  }}
                >
                  {lim === -1 ? 'All' : lim}
                </button>
              ))}
            </div>
          </div>
          <table>
            <thead>
              <tr><th>Evidence</th><th>Category</th><th>Coordinates</th><th>Officer</th><th>Time</th><th>Status</th></tr>
            </thead>
            <tbody>
              {loading && <tr><td colSpan="6" style={{textAlign: 'center', padding: '20px'}}>Loading live data...</td></tr>}
              {!loading && inspections.length === 0 && <tr><td colSpan="6" style={{textAlign: 'center', padding: '20px'}}>No inspections synced yet. Run a scan on the mobile app and tap SYNC DATA.</td></tr>}
              {(scansLimit === -1 ? inspections : inspections.slice(0, scansLimit)).map((insp) => {
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
                      <td><strong>{insp.officer_id}</strong></td>
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

