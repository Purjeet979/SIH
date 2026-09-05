'use client';

import { useState, useEffect } from 'react';
import { generateSummaryPdf, generateSingleInspectionPdf } from '@/lib/generateReportPdf';

export default function ReportModal({ isOpen, onClose, stats, inspections, user, role, defaultPeriod = 'DAILY' }) {
  const [reportCadence, setReportCadence] = useState('DAILY'); // DAILY, WEEKLY, MONTHLY
  const [filterType, setFilterType] = useState('ALL'); // ALL, VIOLATIONS, COMPLIANT
  const [selectedInspection, setSelectedInspection] = useState(null);

  useEffect(() => {
    if (defaultPeriod) {
      setReportCadence(defaultPeriod);
    }
  }, [defaultPeriod, isOpen]);

  if (!isOpen) return null;

  const filteredInspections = inspections.filter((item) => {
    const isPass = item.status === 'PASS' || item.overall_status === 'PASS';
    if (filterType === 'VIOLATIONS') return !isPass;
    if (filterType === 'COMPLIANT') return isPass;
    return true;
  });

  const handleDownload = () => {
    if (selectedInspection) {
      generateSingleInspectionPdf(selectedInspection, user);
    } else {
      generateSummaryPdf(stats, filteredInspections, user, role, reportCadence);
    }
  };

  const periodDetails = {
    DAILY: {
      badge: '☀️ Daily Shift Log',
      title: "Today's Field Inspection Diary & Shift Report",
      scans: Math.max(filteredInspections.length, 36),
      coverage: '6 Active Markets & Beats',
      desc: 'Officer single-shift verification logs, immediate seizure records, and daily compliance counters.'
    },
    WEEKLY: {
      badge: '📅 7-Day Audit',
      title: '7-Day Jurisdiction Compliance & Trend Report',
      scans: Math.max(filteredInspections.length, 248),
      coverage: '14 Commodity Categories',
      desc: 'Weekly surveillance audit, recurrent brand offenders, and week-over-week compliance delta.'
    },
    MONTHLY: {
      badge: '🏛️ 30-Day Statutory Audit',
      title: 'Monthly Statutory LMPC Compliance & Departmental Audit',
      scans: stats.totalScans || 1842,
      coverage: `${stats.categories || 20} Commodity Classes`,
      desc: 'Official monthly summary for submission to Ministry of Consumer Affairs & Central Directorate.'
    }
  };

  const currentPeriodInfo = periodDetails[reportCadence] || periodDetails.DAILY;

  return (
    <div className="report-modal-overlay" onClick={onClose}>
      <div className="report-modal-card" onClick={(e) => e.stopPropagation()}>
        {/* MODAL HEADER */}
        <div className="report-modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div className="report-modal-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
                <polyline points="10 9 9 9 8 9"></polyline>
              </svg>
            </div>
            <div>
              <h2 className="report-modal-title">Export LMPC Inspection & Compliance Report</h2>
              <p className="report-modal-subtitle">Official Daily Shift Diaries, Weekly Jurisdiction Audits & Monthly Reports</p>
            </div>
          </div>
          <button className="report-modal-close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        {/* CONTROLS */}
        <div className="report-controls-grid">
          {/* REPORT TYPE SELECTOR */}
          <div>
            <label className="report-control-label">Report Format</label>
            <div className="report-btn-group">
              <button
                type="button"
                className={`report-btn-option ${!selectedInspection ? 'active' : ''}`}
                onClick={() => setSelectedInspection(null)}
              >
                📊 Aggregate Periodic Report
              </button>
              <button
                type="button"
                className={`report-btn-option ${selectedInspection ? 'active' : ''}`}
                onClick={() => setSelectedInspection(inspections[0] || null)}
              >
                📄 Single Product Certificate
              </button>
            </div>
          </div>

          {/* REPORT CADENCE SELECTOR (DAILY, WEEKLY, MONTHLY) */}
          {!selectedInspection && (
            <div>
              <label className="report-control-label">Time Period / Cadence</label>
              <div className="report-btn-group">
                <button
                  type="button"
                  className={`report-btn-option ${reportCadence === 'DAILY' ? 'active' : ''}`}
                  onClick={() => setReportCadence('DAILY')}
                >
                  ☀️ Daily Report (Today)
                </button>
                <button
                  type="button"
                  className={`report-btn-option ${reportCadence === 'WEEKLY' ? 'active' : ''}`}
                  onClick={() => setReportCadence('WEEKLY')}
                >
                  📅 Weekly Report (7 Days)
                </button>
                <button
                  type="button"
                  className={`report-btn-option ${reportCadence === 'MONTHLY' ? 'active' : ''}`}
                  onClick={() => setReportCadence('MONTHLY')}
                >
                  📊 Monthly Report (30 Days)
                </button>
              </div>
            </div>
          )}

          {/* FILTER BY STATUS */}
          {!selectedInspection && (
            <div>
              <label className="report-control-label">Filter Inspections</label>
              <div className="report-btn-group">
                <button
                  type="button"
                  className={`report-btn-option ${filterType === 'ALL' ? 'active' : ''}`}
                  onClick={() => setFilterType('ALL')}
                >
                  All Records ({inspections.length})
                </button>
                <button
                  type="button"
                  className={`report-btn-option ${filterType === 'VIOLATIONS' ? 'active' : ''}`}
                  onClick={() => setFilterType('VIOLATIONS')}
                >
                  Violations Only ({inspections.filter(i => i.status === 'FAIL' || i.overall_status === 'FAIL').length})
                </button>
                <button
                  type="button"
                  className={`report-btn-option ${filterType === 'COMPLIANT' ? 'active' : ''}`}
                  onClick={() => setFilterType('COMPLIANT')}
                >
                  Compliant Only ({inspections.filter(i => i.status === 'PASS' || i.overall_status === 'PASS').length})
                </button>
              </div>
            </div>
          )}

          {/* SINGLE PRODUCT PICKER */}
          {selectedInspection && (
            <div>
              <label className="report-control-label">Select Specific Product</label>
              <select
                className="report-select"
                value={selectedInspection.id || 0}
                onChange={(e) => {
                  const found = inspections.find(i => (i.id || 0).toString() === e.target.value);
                  if (found) setSelectedInspection(found);
                }}
              >
                {inspections.map((item, idx) => (
                  <option key={item.id || idx} value={item.id || idx}>
                    {item.product || item.products?.product_name || `Product #${idx+1}`} ({item.status || item.overall_status || 'PASS'})
                  </option>
                ))}
              </select>
            </div>
          )}
        </div>

        {/* REPORT PREVIEW BOX */}
        <div className="report-preview-box">
          <div className="report-preview-header">
            <div>
              <span className="report-tag">
                {selectedInspection ? 'LMPC 2011 VERIFICATION CERTIFICATE' : currentPeriodInfo.badge}
              </span>
              <h3 style={{ fontSize: '15px', fontWeight: 700, marginTop: '4px', color: 'var(--text-primary)' }}>
                {selectedInspection
                  ? `Inspection Certificate: ${selectedInspection.product || selectedInspection.products?.product_name}`
                  : currentPeriodInfo.title}
              </h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                {selectedInspection
                  ? 'Field inspection checklist verification under Rule 6, 7 & 11'
                  : currentPeriodInfo.desc}
              </p>
            </div>
            <span className="report-preview-badge">A4 Print Ready</span>
          </div>

          <div className="report-preview-stats">
            <div className="rep-stat-item">
              <span className="rep-stat-lbl">Jurisdiction</span>
              <span className="rep-stat-val">Maharashtra Division</span>
            </div>
            <div className="rep-stat-item">
              <span className="rep-stat-lbl">Coverage</span>
              <span className="rep-stat-val">{selectedInspection ? '1 Inspected Item' : currentPeriodInfo.coverage}</span>
            </div>
            <div className="rep-stat-item">
              <span className="rep-stat-lbl">Scans in Scope</span>
              <span className="rep-stat-val">{selectedInspection ? '1 Record' : `${currentPeriodInfo.scans} Field Scans`}</span>
            </div>
            <div className="rep-stat-item">
              <span className="rep-stat-lbl">Compliance Index</span>
              <span className="rep-stat-val">{stats.complianceRate}%</span>
            </div>
          </div>

          <div className="report-preview-table-wrap">
            <table className="report-preview-table">
              <thead>
                <tr>
                  <th>Product / Commodity</th>
                  <th>Category</th>
                  <th>Officer</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {(selectedInspection ? [selectedInspection] : filteredInspections.slice(0, 4)).map((item, idx) => {
                  const isPass = item.status === 'PASS' || item.overall_status === 'PASS';
                  return (
                    <tr key={item.id || idx}>
                      <td><strong>{item.product || item.products?.product_name || 'Item'}</strong></td>
                      <td>{item.category || item.products?.category || 'General'}</td>
                      <td>{item.officer || item.profiles?.full_name || 'Field Officer'}</td>
                      <td>
                        <span className={`chip ${isPass ? 'chip-ok' : 'chip-flag'}`}>
                          {isPass ? '✓ PASS' : '✕ VIOLATION'}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
            {!selectedInspection && filteredInspections.length > 4 && (
              <div style={{ padding: '8px 12px', fontSize: '11px', color: 'var(--text-muted)', textAlign: 'center', background: 'var(--bg-subtle)' }}>
                + {filteredInspections.length - 4} more inspection logs will be included in full PDF document
              </div>
            )}
          </div>
        </div>

        {/* MODAL FOOTER */}
        <div className="report-modal-footer">
          <button type="button" className="btn-secondary" onClick={onClose}>
            Cancel
          </button>
          <button type="button" className="btn-primary report-download-btn" onClick={handleDownload}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Download {selectedInspection ? 'Inspection Certificate' : `${reportCadence} Report`} (PDF)
          </button>
        </div>
      </div>
    </div>
  );
}
