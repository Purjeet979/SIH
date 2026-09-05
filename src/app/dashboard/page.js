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
    totalScans: 1842,
    complianceRate: 76.4,
    violations: 438,
    categories: 20
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
    }
  }, [user, role]);

  const fetchDashboardData = async () => {
    try {
      // Try to fetch real inspections
      const { data, error } = await supabase
        .from('inspections')
        .select(`
          *,
          products ( product_name, category, brand ),
          profiles ( full_name )
        `)
        .order('captured_at', { ascending: false })
        .limit(6);

      if (!error && data && data.length > 0) {
        setInspections(data);
        // Calculate real stats
        const total = data.length;
        const passes = data.filter(d => d.overall_status === 'PASS').length;
        const fails = data.filter(d => d.overall_status === 'FAIL').length;
        setStats({
          totalScans: total,
          complianceRate: total > 0 ? ((passes / total) * 100).toFixed(1) : 0,
          violations: fails,
          categories: new Set(data.map(d => d.category).filter(Boolean)).size
        });
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

  // Demo data for when Supabase is not connected yet
  const demoInspections = [
    { id: 1, product: 'Herbal Face Wash, 100ml', category: 'Cosmetics & Toiletries', location: 'Nagpur, Maharashtra', officer: 'Inspector R. Deshmukh', time: '14 mins ago', status: 'FAIL', violations: 2 },
    { id: 2, product: 'Refined Sunflower Oil, 1L', category: 'Packaged Food & FMCG', location: 'Nagpur, Maharashtra', officer: 'Inspector R. Deshmukh', time: '26 mins ago', status: 'PASS', violations: 0 },
    { id: 3, product: 'Grade 53 OPC Cement, 50kg', category: 'Cement & Building Materials', location: 'Wardha, Maharashtra', officer: 'Inspector S. Kulkarni', time: '1 hour ago', status: 'PASS', violations: 0 },
    { id: 4, product: 'Synthetic Enamel Paint, 500ml', category: 'Paints & Varnishes', location: 'Wardha, Maharashtra', officer: 'Inspector S. Kulkarni', time: '1 hour ago', status: 'FAIL', violations: 1 },
    { id: 5, product: 'Insulated Copper Wire, 90m Coil', category: 'Electricals & Wires', location: 'Amravati, Maharashtra', officer: 'Inspector P. Joshi', time: '2 hours ago', status: 'PASS', violations: 0 },
    { id: 6, product: 'Smooth Talcum Powder, 200g', category: 'Cosmetics & Toiletries', location: 'Amravati, Maharashtra', officer: 'Inspector P. Joshi', time: '3 hours ago', status: 'FAIL', violations: 3 },
  ];

  const displayInspections = inspections.length > 0 ? inspections : demoInspections;

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
          <div style={{ display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
            <span className="demo-tag">
              {inspections.length > 0 ? '🟢 Live Data' : '🟡 Demo Data — Connect Supabase'}
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
            <div className="delta delta-up"><span>↑ +312</span> vs. last month</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(220,38,38,0.1)', color: '#16a34a' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div className="num">{stats.complianceRate}%</div>
            <div className="lbl">LMPC Compliance Rate</div>
            <div className="delta delta-up"><span>↑ +4.2%</span> improvement</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(220,38,38,0.1)', color: '#dc2626' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
            <div className="num">{stats.violations}</div>
            <div className="lbl">Violations Flagged</div>
            <div className="delta delta-down"><span>↓ -58</span> vs. last month</div>
          </div>
          <div className="stat-card stat-card-animated">
            <div className="stat-card-icon" style={{ backgroundColor: 'rgba(217,119,6,0.1)', color: '#d97706' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
            </div>
            <div className="num">{stats.categories}</div>
            <div className="lbl">Commodity Categories</div>
            <div className="delta delta-up"><span>↑ +2</span> new added</div>
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

            <div className="bar-row">
              <div className="bar-top"><span className="cat">Cosmetics & Toiletries</span><span className="val">31% (136)</span></div>
              <div className="bar-track"><div className="bar-fill alert" style={{ width: '31%' }}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Packaged Food & FMCG</span><span className="val">22% (96)</span></div>
              <div className="bar-track"><div className="bar-fill" style={{ width: '22%' }}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Cement & Construction</span><span className="val">18% (79)</span></div>
              <div className="bar-track"><div className="bar-fill" style={{ width: '18%' }}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Paints & Varnishes</span><span className="val">14% (61)</span></div>
              <div className="bar-track"><div className="bar-fill" style={{ width: '14%' }}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Electricals & Wires</span><span className="val">9% (39)</span></div>
              <div className="bar-track"><div className="bar-fill" style={{ width: '9%' }}></div></div>
            </div>
          </div>

          {/* TOP VIOLATED RULES */}
          <div className="panel panel-glass">
            <h3>Top Violated LMPC Clauses</h3>
            <div className="sub">Most frequent non-compliance issues</div>
            <ul className="rule-list">
              <li>
                <div><div className="rname">Numeral & Letter Height Defect</div><div className="rref">Rule 7 — Font Size vs Panel Area</div></div>
                <span className="rule-count">146</span>
              </li>
              <li>
                <div><div className="rname">Incomplete Consumer Care Info</div><div className="rref">Rule 6(2) — Email/Phone/Address</div></div>
                <span className="rule-count">98</span>
              </li>
              <li>
                <div><div className="rname">Missing Veg / Non-Veg Indicator</div><div className="rref">Rule 6(8) — Mandatory Dot</div></div>
                <span className="rule-count">71</span>
              </li>
              <li>
                <div><div className="rname">Unit Sale Price Omission</div><div className="rref">Rule 6(11) — Price per g/ml</div></div>
                <span className="rule-count">63</span>
              </li>
              <li>
                <div><div className="rname">Invalid Net Quantity</div><div className="rref">Rule 6(1)(c) — Standard Units</div></div>
                <span className="rule-count">60</span>
              </li>
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
                  <th>Product & Commodity</th>
                  <th>Location</th>
                  {(isAdmin || isUser) && <th>Inspecting Officer</th>}
                  <th>Timestamp</th>
                  <th>Compliance Verdict</th>
                  <th style={{ textAlign: 'center' }}>PDF Action</th>
                </tr>
              </thead>
              <tbody>
                {displayInspections.map((item, i) => (
                  <tr key={item.id || i}>
                    <td className="prod-cell">
                      <div className="pname">{item.product || item.products?.product_name || '—'}</div>
                      <div className="pcat">{item.category || item.products?.category || '—'}</div>
                    </td>
                    <td>{item.location || '—'}</td>
                    {(isAdmin || isUser) && (
                      <td>{item.officer || item.profiles?.full_name || '—'}</td>
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
                ))}
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

