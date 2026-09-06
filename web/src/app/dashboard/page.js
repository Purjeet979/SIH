'use client';

import Link from 'next/link';
import { useAuth } from '@/context/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import ThemeToggle from '../ThemeToggle';
import ReportModal from './ReportModal';
import { generateSingleInspectionPdf } from '@/lib/generateReportPdf';

export default function DashboardPage() {
  const { user, profile, role, loading, signOut, isAdmin, isEmployee, isUser } = useAuth();
  const router = useRouter();
  const [stats, setStats] = useState({
    totalScans: 0,
    complianceRate: 0,
    violations: 0,
    categories: 0
  });
  const [analytics, setAnalytics] = useState({
    categoryShares: [],
    topRules: []
  });
  const [inspections, setInspections] = useState([]);
  const [isReportModalOpen, setIsReportModalOpen] = useState(false);
  const [reportPeriod, setReportPeriod] = useState('DAILY'); // DAILY, WEEKLY, MONTHLY

  const openReportWithPeriod = (period) => {
    setReportPeriod(period);
    setIsReportModalOpen(true);
  };

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login');
    }
  }, [loading, user, router]);

  useEffect(() => {
    if (user) {
      fetchDashboardData();
      const interval = setInterval(fetchDashboardData, 4000);
      return () => clearInterval(interval);
    }
  }, [user, role]);

  const fetchDashboardData = async () => {
    try {
      let realInspections = [];

      // 1. Fetch from Central SQLite Sync Bridge (Backend Server on port 3001)
      try {
        const syncRes = await fetch('http://localhost:3001/api/inspections');
        if (syncRes.ok) {
          const syncJson = await syncRes.json();
          if (syncJson?.data && Array.isArray(syncJson.data)) {
            let syncData = syncJson.data;
            if (isEmployee && user?.id) {
              syncData = syncData.filter(insp => insp.officer_id === user.id);
            }
            realInspections = syncData.map((insp) => {
              const violationsList = (insp.violations && insp.violations.trim() !== '')
                ? insp.violations.split(',').map(v => v.trim()).filter(Boolean)
                : [];
              const isPass = violationsList.length === 0;
              const formattedCat = insp.category
                ? insp.category.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                : 'Packaged Commodity';

              return {
                id: insp.id,
                mobile_id: insp.mobile_id,
                product: insp.barcode ? `Barcode: ${insp.barcode}` : `${formattedCat} Sample #${insp.id}`,
                category: formattedCat,
                location: (insp.latitude && insp.longitude)
                  ? `${Number(insp.latitude).toFixed(4)}, ${Number(insp.longitude).toFixed(4)}`
                  : 'Field Beat #04, Delhi',
                latitude: insp.latitude,
                longitude: insp.longitude,
                officer: insp.officer_id || 'Insp. Rajesh Kumar (DL-OFF-01)',
                time: new Date(insp.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }),
                captured_at: insp.timestamp,
                status: isPass ? 'PASS' : 'FAIL',
                overall_status: isPass ? 'PASS' : 'FAIL',
                violations: violationsList.length,
                violationsList: violationsList,
                image_data: insp.image_data,
                barcode: insp.barcode,
              };
            });
          }
        }
      } catch (syncErr) {
        console.warn('Central sync bridge on port 3001 not reachable:', syncErr);
      }

      // 2. Also check Supabase if connected
      try {
        let query = supabase
          .from('inspections')
          .select(`
            *,
            products ( product_name, category, brand ),
            profiles ( full_name ),
            evidence ( storage_path, evidence_type )
          `)
          .order('captured_at', { ascending: false })
          .limit(10);

        if (isEmployee && user?.id) {
          query = query.eq('officer_id', user.id);
        }

        const { data, error } = await query;

        if (!error && data && data.length > 0) {
          const formattedSupabaseData = data.map(insp => {
            // Location
            const loc = (insp.latitude !== null && insp.longitude !== null && insp.latitude !== undefined)
              ? `${Number(insp.latitude).toFixed(4)}, ${Number(insp.longitude).toFixed(4)}`
              : '—';
              
            // Evidence URL
            let evidenceUrl = null;
            if (insp.evidence && insp.evidence.length > 0) {
                const ev = insp.evidence.find(e => e.evidence_type === 'ORIGINAL_IMAGE') || insp.evidence[0];
                if (ev.storage_path) {
                   if (ev.storage_path.startsWith('http')) {
                      evidenceUrl = ev.storage_path;
                   } else {
                      const { data: publicUrlData } = supabase.storage.from('inspection-evidence').getPublicUrl(ev.storage_path);
                      evidenceUrl = publicUrlData?.publicUrl;
                   }
                }
            }
            
            // Violations count
            let violationCount = 0;
            if (insp.remarks && insp.overall_status === 'FAIL') {
                violationCount = insp.remarks.split(',').filter(r => r.trim().length > 0).length;
            } else if (insp.overall_status === 'FAIL') {
                violationCount = 1;
            }

            return {
              ...insp,
              location: loc,
              evidence_url: evidenceUrl,
              violations: violationCount
            };
          });
          realInspections = [...realInspections, ...formattedSupabaseData];
        }
      } catch (_) {}

      if (realInspections.length > 0) {
        setInspections(realInspections);
        const total = realInspections.length;
        const passes = realInspections.filter(d => d.overall_status === 'PASS' || d.status === 'PASS').length;
        const fails = total - passes;
        setStats({
          totalScans: total,
          complianceRate: total > 0 ? Number(((passes / total) * 100).toFixed(1)) : 0,
          violations: fails,
          categories: new Set(realInspections.map(d => d.category).filter(Boolean)).size,
        });

        // Dynamic Analytics Calculation
        const catCounts = {};
        const ruleCounts = {};

        realInspections.forEach(insp => {
          // Categories
          if (insp.category) {
             catCounts[insp.category] = (catCounts[insp.category] || 0) + 1;
          }
          // Violations
          if (insp.remarks && insp.overall_status === 'FAIL') {
             // remarks string from SQLite/mobile
             const rules = insp.remarks.split(',').map(r => r.trim()).filter(Boolean);
             rules.forEach(r => {
                 ruleCounts[r] = (ruleCounts[r] || 0) + 1;
             });
          }
          if (insp.rule_results) {
             insp.rule_results.filter(r => !r.is_compliant).forEach(r => {
                 ruleCounts[r.rule_id || 'General Violation'] = (ruleCounts[r.rule_id || 'General Violation'] || 0) + 1;
             });
          }
        });

        // If no explicit rules logged, but there are fails, add a generic one
        if (Object.keys(ruleCounts).length === 0 && fails > 0) {
           ruleCounts['General Packaging Violation'] = fails;
        }

        const categoryShares = Object.entries(catCounts)
          .map(([cat, count]) => ({ cat, count, pct: Math.round((count / total) * 100) }))
          .sort((a, b) => b.count - a.count);

        const topRules = Object.entries(ruleCounts)
          .map(([rname, count]) => ({ rname, count }))
          .sort((a, b) => b.count - a.count)
          .slice(0, 5);

        setAnalytics({ categoryShares, topRules });
      } else {
        // Reset if 0
        setStats({ totalScans: 0, complianceRate: 0, violations: 0, categories: 0 });
        setAnalytics({ categoryShares: [], topRules: [] });
      }
    } catch (err) {
      console.error('Dashboard data fetch error:', err);
    }
  };

  const handleSignOut = async () => {
    await signOut();
    router.push('/');
  };

  if (loading) {
    return (
      <div className="dashboard-body">
        <div className="dash-loading">
          <div className="dash-loading-spinner"></div>
          <p>Loading dashboard...</p>
        </div>
      </div>
    );
  }

  if (!user) return null;

  const roleConfig = {
    ADMIN: { label: 'Administrator', color: '#8b5cf6', bg: 'rgba(139,92,246,0.12)', border: '#7c3aed' },
    EMPLOYEE: { label: 'Field Officer', color: '#2563eb', bg: 'rgba(37,99,235,0.12)', border: '#1d4ed8' },
    USER: { label: 'Viewer', color: '#0d9488', bg: 'rgba(13,148,136,0.12)', border: '#0f766e' },
  };

  const currentRole = roleConfig[role] || roleConfig.USER;

  const displayInspections = inspections;

  return (
    <div className="dashboard-body">
      {/* TOP BAR */}
      <div className="topbar">
        <div className="brand">
          <img src="/logo.svg" alt="RuleScan Logo" className="brand-logo" />
          <span className="brand-badge" style={{ backgroundColor: currentRole.bg, color: currentRole.color, borderColor: currentRole.border }}>
            {currentRole.label}
          </span>
        </div>
        <nav>
          <Link href="/">Home</Link>
          <Link className="active" href="/dashboard">Dashboard</Link>
          {isAdmin && <Link href="/dashboard/admin">Admin Panel</Link>}
        </nav>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <ThemeToggle />
          <div className="dash-user-pill">
            <div className="dash-avatar" style={{ backgroundColor: currentRole.color }}>
              {(profile?.full_name || user.email || '?')[0].toUpperCase()}
            </div>
            <div className="dash-user-info">
              <span className="dash-user-name">{profile?.full_name || user.email}</span>
              <span className="dash-user-role" style={{ color: currentRole.color }}>{currentRole.label}</span>
            </div>
          </div>
          <button className="dash-signout-btn" onClick={handleSignOut}>
            Sign Out
          </button>
        </div>
      </div>

      <div className="shell">
        {/* PAGE HEADER */}
        <div className="page-head">
          <div>
            <h1>
              {isAdmin ? 'Admin Dashboard' : isEmployee ? 'Officer Dashboard' : 'Compliance Overview'}
            </h1>
            <p>
              {isAdmin
                ? 'Full system overview — all officers, inspections & analytics'
                : isEmployee
                ? 'Your field inspections, scan results & sync status'
                : 'Public compliance reports & category analytics'}
              {' · '}Last 30 Days
            </p>
          </div>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'center', flexWrap: 'wrap' }}>
            <button
              onClick={fetchDashboardData}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '6px',
                padding: '8px 14px',
                borderRadius: '8px',
                border: '1px solid var(--line, #cbd5e1)',
                background: 'var(--surface, #fff)',
                color: 'var(--text-dark, #1e293b)',
                fontSize: '12.5px',
                fontWeight: '600',
                cursor: 'pointer',
                boxShadow: '0 1px 2px rgba(0,0,0,0.05)'
              }}
              title="Click to refresh synced mobile scans from port 3001"
            >
              🔄 Refresh Synced Data
            </button>
            <span
              className="demo-tag"
              style={{
                backgroundColor: inspections.length > 0 ? '#dcfce7' : '#fef3c7',
                color: inspections.length > 0 ? '#166534' : '#92400e',
                border: '1px solid ' + (inspections.length > 0 ? '#bbf7d0' : '#fde68a')
              }}
            >
              {inspections.length > 0 ? `🟢 Live Synced (${inspections.length} Records)` : '🟡 Awaiting Mobile Sync'}
            </span>
            <button className="btn-export-pdf" onClick={() => openReportWithPeriod('DAILY')}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                <polyline points="14 2 14 8 20 8" />
                <line x1="16" y1="13" x2="8" y2="13" />
                <line x1="16" y1="17" x2="8" y2="17" />
              </svg>
              Export PDF Report
            </button>
          </div>
        </div>

        {/* OFFICER REPORT CADENCE BAR */}
        <div className="officer-report-bar">
          <div className="report-bar-left">
            <span className="report-bar-badge">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                <polyline points="14 2 14 8 20 8" />
                <line x1="16" y1="13" x2="8" y2="13" />
                <line x1="16" y1="17" x2="8" y2="17" />
              </svg>
              {isEmployee ? 'Officer Duty Reports' : 'Jurisdiction LMPC Reports'}
            </span>
            <span className="report-bar-sub">Download one-click statutory PDF reports for your beat, shift or division</span>
          </div>
          <div className="report-bar-actions">
            <button
              className="btn-report-quick daily"
              title="Download Today's Shift Diary and Inspection Log"
              onClick={() => openReportWithPeriod('DAILY')}
            >
              ☀️ Daily Report (Today)
            </button>
            <button
              className="btn-report-quick weekly"
              title="Download 7-Day Surveillance and Trend Audit"
              onClick={() => openReportWithPeriod('WEEKLY')}
            >
              📅 Weekly Report (7D)
            </button>
            <button
              className="btn-report-quick monthly"
              title="Download 30-Day Executive Statutory Audit"
              onClick={() => openReportWithPeriod('MONTHLY')}
            >
              📊 Monthly Report (30D)
            </button>
          </div>
        </div>

        {/* STAT CARDS */}
        <div className="stat-row">
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(37,99,235,0.1)', color: '#2563eb' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg>
            </div>
            <div className="num">{stats.totalScans.toLocaleString()}</div>
            <div className="lbl">{isEmployee ? 'Your Scans' : 'Total Field Scans'}</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(220,38,38,0.1)', color: '#16a34a' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div className="num">{stats.complianceRate}%</div>
            <div className="lbl">LMPC Compliance Rate</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(220,38,38,0.1)', color: '#dc2626' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
            <div className="num">{stats.violations}</div>
            <div className="lbl">Violations Flagged</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(217,119,6,0.1)', color: '#d97706' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
            </div>
            <div className="num">{stats.categories}</div>
            <div className="lbl">Commodity Categories</div>
          </div>
        </div>

        {/* ANALYTICS GRID */}
        <div className="grid-2">
          {/* CATEGORY VIOLATION SHARES */}
          <div className="panel panel-glass">
            <div className="panel-header-row">
              <div>
                <h3>Violations by Commodity Category</h3>
                <div className="sub">Share of non-compliant scans across major product classes</div>
              </div>
            </div>

            {analytics.categoryShares.length > 0 ? analytics.categoryShares.map((item, idx) => (
              <div className="bar-row" key={idx}>
                <div className="bar-top">
                  <span className="cat">{item.cat}</span>
                  <span className="val">{item.pct}% ({item.count})</span>
                </div>
                <div className="bar-track">
                  <div className={`bar-fill ${item.pct > 25 ? 'alert' : ''}`} style={{ width: `${item.pct}%` }}></div>
                </div>
              </div>
            )) : (
              <div style={{ padding: '20px', color: '#94a3b8' }}>No category data yet.</div>
            )}
          </div>

          {/* TOP VIOLATED RULES */}
          <div className="panel panel-glass">
            <h3>Top Violated LMPC Clauses</h3>
            <div className="sub">Most frequent non-compliance issues</div>
            <ul className="rule-list">
              {analytics.topRules.length > 0 ? analytics.topRules.map((rule, idx) => (
                <li key={idx}>
                  <div>
                    <div className="rname">{rule.rname}</div>
                    <div className="rref">Flagged in field</div>
                  </div>
                  <span className="rule-count">{rule.count}</span>
                </li>
              )) : (
                <li style={{ color: '#94a3b8', borderBottom: 'none' }}>No violations flagged yet.</li>
              )}
            </ul>
          </div>
        </div>

        {/* RECENT INSPECTIONS TABLE */}
        <div className="panel panel-glass">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '8px' }}>
            <div>
              <h3 style={{ margin: 0 }}>
                {isEmployee ? 'Your Recent Inspections' : 'Recent Field Inspection Logs'}
              </h3>
              <div className="sub" style={{ margin: 0 }}>
                {isAdmin ? 'All officers — synced in real-time' : isEmployee ? 'Your mobile synced scans' : 'Public compliance records'}
              </div>
            </div>
            <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--primary)' }}>
              Geotagged & Verified
            </span>
          </div>

          <div className="table-responsive">
            <table>
              <thead>
                <tr>
                  <th style={{ width: '60px' }}>Evidence</th>
                  <th>Product & Commodity</th>
                  <th>Location</th>
                  {(isAdmin || isUser) && <th>Inspecting Officer</th>}
                  <th>Timestamp</th>
                  <th>Compliance Verdict</th>
                  <th style={{ textAlign: 'center' }}>PDF Action</th>
                </tr>
              </thead>
              <tbody>
                {displayInspections.length > 0 ? displayInspections.map((item, i) => (
                  <tr key={item.id || i}>
                    <td>
                      {item.image_data || item.evidence_url ? (
                        <a
                          href={item.image_data ? `data:image/jpeg;base64,${item.image_data}` : item.evidence_url}
                          target="_blank"
                          rel="noreferrer"
                          title="Click to view full photo evidence"
                        >
                          <img
                            src={item.image_data ? `data:image/jpeg;base64,${item.image_data}` : item.evidence_url}
                            alt="Evidence"
                            style={{
                              width: '46px',
                              height: '46px',
                              objectFit: 'cover',
                              borderRadius: '6px',
                              border: '1px solid var(--line, #cbd5e1)',
                              cursor: 'pointer'
                            }}
                          />
                        </a>
                      ) : (
                        <div
                          style={{
                            width: '46px',
                            height: '46px',
                            borderRadius: '6px',
                            background: 'var(--card-bg, #f1f5f9)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '18px',
                            border: '1px solid var(--line, #e2e8f0)'
                          }}
                        >
                          📦
                        </div>
                      )}
                    </td>
                    <td className="prod-cell">
                      <div className="pname">{item.product || item.products?.product_name || `Inspection #${item.id}`}</div>
                      <div className="pcat">{item.category || item.products?.category || '—'}</div>
                      {item.barcode && (
                        <div style={{ fontSize: '10.5px', color: '#6366f1', fontWeight: 600, marginTop: '2px' }}>
                          Barcode: {item.barcode}
                        </div>
                      )}
                    </td>
                    <td>
                      {item.latitude && item.longitude ? (
                        <a
                          href={`https://maps.google.com/?q=${item.latitude},${item.longitude}`}
                          target="_blank"
                          rel="noreferrer"
                          style={{ color: '#2563eb', textDecoration: 'underline' }}
                        >
                          {item.location}
                        </a>
                      ) : (
                        item.location || '—'
                      )}
                    </td>
                    {(isAdmin || isUser) && (
                      <td><strong>{item.officer || item.profiles?.full_name || '—'}</strong></td>
                    )}
                    <td>{item.time || (item.captured_at ? new Date(item.captured_at).toLocaleString() : '—')}</td>
                    <td>
                      {(item.status === 'PASS' || item.overall_status === 'PASS') ? (
                        <span className="chip chip-ok">✓ Fully Compliant</span>
                      ) : (item.status === 'FAIL' || item.overall_status === 'FAIL') ? (
                        <span className="chip chip-flag">✕ {item.violations || '?'} Violation{(item.violations !== 1) ? 's' : ''} Flagged</span>
                      ) : (
                        <span className="chip chip-review">⏳ Manual Review</span>
                      )}
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <button
                        className="btn-table-pdf"
                        title="Download official single inspection certificate PDF"
                        onClick={() => generateSingleInspectionPdf(item, user)}
                      >
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                          <polyline points="14 2 14 8 20 8" />
                          <line x1="12" y1="18" x2="12" y2="12" />
                          <line x1="9" y1="15" x2="12" y2="18" />
                          <line x1="15" y1="15" x2="12" y2="18" />
                        </svg>
                        PDF
                      </button>
                    </td>
                  </tr>
                )) : (
                  <tr>
                    <td colSpan={(isAdmin || isUser) ? 7 : 6} style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                      No inspections found. Awaiting mobile sync...
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* ADMIN-ONLY: Quick Links */}
        {isAdmin && (
          <div className="dash-admin-shortcuts">
            <Link href="/dashboard/admin" className="dash-shortcut-card">
              <div className="dash-shortcut-icon" style={{ backgroundColor: 'rgba(139,92,246,0.12)', color: '#8b5cf6' }}>⚙️</div>
              <div>
                <strong>Admin Panel</strong>
                <span>Manage users, roles & rule bundles</span>
              </div>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg>
            </Link>
          </div>
        )}
      </div>

      {/* REPORT EXPORT MODAL */}
      <ReportModal
        isOpen={isReportModalOpen}
        onClose={() => setIsReportModalOpen(false)}
        stats={stats}
        inspections={displayInspections}
        user={user}
        role={role}
        defaultPeriod={reportPeriod}
      />
    </div>
  );
}

