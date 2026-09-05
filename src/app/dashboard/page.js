import Link from 'next/link';
import ThemeToggle from '../ThemeToggle';

export default function DashboardPage() {
  return (
    <div className="dashboard-body">
      <div className="topbar">
        <div className="brand">
          <img src="/logo.svg" alt="RuleScan Logo" className="brand-logo" />
          <span className="brand-badge">Dashboard</span>
        </div>
        <nav>
          <Link href="/">Landing Page</Link>
          <Link className="active" href="/dashboard">
            Compliance Analytics
          </Link>
        </nav>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <ThemeToggle />
          <Link className="back" href="/">
            ← Back to Main Site
          </Link>
        </div>
      </div>

      <div className="shell">
        <div className="page-head">
          <div>
            <h1>State Compliance Overview</h1>
            <p>State Legal Metrology Department &middot; All Commodity Categories &middot; Last 30 Days</p>
          </div>
          <span className="demo-tag">Live Prototype — Synced Evidence Data</span>
        </div>

        {/* STATS OVERVIEW */}
        <div className="stat-row">
          <div className="stat-card">
            <div className="num">1,842</div>
            <div className="lbl">Total Field Scans Completed</div>
            <div className="delta delta-up">
              <span>↑ +312</span> vs. last month
            </div>
          </div>
          <div className="stat-card">
            <div className="num">76.4%</div>
            <div className="lbl">Overall LMPC Compliance Rate</div>
            <div className="delta delta-up">
              <span>↑ +4.2%</span> improvement
            </div>
          </div>
          <div className="stat-card">
            <div className="num">438</div>
            <div className="lbl">Legal Violations Flagged</div>
            <div className="delta delta-down">
              <span>↓ -58</span> vs. last month
            </div>
          </div>
          <div className="stat-card">
            <div className="num">20</div>
            <div className="lbl">Active Commodity Categories</div>
            <div className="delta delta-up">
              <span>↑ +2</span> new categories added
            </div>
          </div>
        </div>

        {/* ANALYTICS GRID */}
        <div className="grid-2">
          {/* CATEGORY VIOLATION SHARES */}
          <div className="panel">
            <h3>Violations by Commodity Category</h3>
            <div className="sub">Share of non-compliant scans across major product classes</div>

            <div className="bar-row">
              <div className="bar-top">
                <span className="cat">Cosmetics &amp; Toiletries</span>
                <span className="val">31% (136 violations)</span>
              </div>
              <div className="bar-track">
                <div className="bar-fill alert" style={{ width: '31%' }}></div>
              </div>
            </div>

            <div className="bar-row">
              <div className="bar-top">
                <span className="cat">Packaged Food &amp; FMCG</span>
                <span className="val">22% (96 violations)</span>
              </div>
              <div className="bar-track">
                <div className="bar-fill" style={{ width: '22%' }}></div>
              </div>
            </div>

            <div className="bar-row">
              <div className="bar-top">
                <span className="cat">Cement &amp; Construction</span>
                <span className="val">18% (79 violations)</span>
              </div>
              <div className="bar-track">
                <div className="bar-fill" style={{ width: '18%' }}></div>
              </div>
            </div>

            <div className="bar-row">
              <div className="bar-top">
                <span className="cat">Paints &amp; Varnishes</span>
                <span className="val">14% (61 violations)</span>
              </div>
              <div className="bar-track">
                <div className="bar-fill" style={{ width: '14%' }}></div>
              </div>
            </div>

            <div className="bar-row">
              <div className="bar-top">
                <span className="cat">Electricals &amp; Wires</span>
                <span className="val">9% (39 violations)</span>
              </div>
              <div className="bar-track">
                <div className="bar-fill" style={{ width: '9%' }}></div>
              </div>
            </div>
          </div>

          {/* TOP VIOLATED RULES */}
          <div className="panel">
            <h3>Top Violated LMPC Clauses</h3>
            <div className="sub">Most frequent non-compliance issues found on labels</div>

            <ul className="rule-list">
              <li>
                <div>
                  <div className="rname">Numeral &amp; Letter Height Defect</div>
                  <div className="rref">Rule 7 — Font Size vs Panel Area</div>
                </div>
                <span className="rule-count">146 cases</span>
              </li>
              <li>
                <div>
                  <div className="rname">Incomplete Consumer Care Info</div>
                  <div className="rref">Rule 6(2) — Email/Phone/Address</div>
                </div>
                <span className="rule-count">98 cases</span>
              </li>
              <li>
                <div>
                  <div className="rname">Missing Veg / Non-Veg Indicator</div>
                  <div className="rref">Rule 6(8) — Mandatory Dot Standard</div>
                </div>
                <span className="rule-count">71 cases</span>
              </li>
              <li>
                <div>
                  <div className="rname">Unit Sale Price Omission</div>
                  <div className="rref">Rule 6(11) — Price per g/ml</div>
                </div>
                <span className="rule-count">63 cases</span>
              </li>
              <li>
                <div>
                  <div className="rname">Invalid Net Quantity Declaration</div>
                  <div className="rref">Rule 6(1)(c) — Standard Units</div>
                </div>
                <span className="rule-count">60 cases</span>
              </li>
            </ul>
          </div>
        </div>

        {/* RECENT INSPECTIONS TABLE */}
        <div className="panel">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div>
              <h3 style={{ margin: 0 }}>Recent Field Inspection Logs</h3>
              <div className="sub" style={{ margin: 0 }}>Synced in real-time from field officer mobile devices</div>
            </div>
            <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--primary)' }}>Geotagged &amp; Verified</span>
          </div>

          <table>
            <thead>
              <tr>
                <th>Product &amp; Commodity</th>
                <th>Location</th>
                <th>Inspecting Officer</th>
                <th>Timestamp</th>
                <th>Compliance Verdict</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Herbal Face Wash, 100ml</div>
                  <div className="pcat">Cosmetics &amp; Toiletries</div>
                </td>
                <td>Nagpur, Maharashtra</td>
                <td>Inspector R. Deshmukh</td>
                <td>14 mins ago</td>
                <td>
                  <span className="chip chip-flag">✕ 2 Violations Flagged</span>
                </td>
              </tr>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Refined Sunflower Oil, 1L</div>
                  <div className="pcat">Packaged Food &amp; FMCG</div>
                </td>
                <td>Nagpur, Maharashtra</td>
                <td>Inspector R. Deshmukh</td>
                <td>26 mins ago</td>
                <td>
                  <span className="chip chip-ok">✓ Fully Compliant</span>
                </td>
              </tr>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Grade 53 OPC Cement, 50kg</div>
                  <div className="pcat">Cement &amp; Building Materials</div>
                </td>
                <td>Wardha, Maharashtra</td>
                <td>Inspector S. Kulkarni</td>
                <td>1 hour ago</td>
                <td>
                  <span className="chip chip-ok">✓ Fully Compliant</span>
                </td>
              </tr>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Synthetic Enamel Paint, 500ml</div>
                  <div className="pcat">Paints &amp; Varnishes</div>
                </td>
                <td>Wardha, Maharashtra</td>
                <td>Inspector S. Kulkarni</td>
                <td>1 hour ago</td>
                <td>
                  <span className="chip chip-flag">✕ 1 Violation Flagged</span>
                </td>
              </tr>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Insulated Copper Wire, 90m Coil</div>
                  <div className="pcat">Electricals &amp; Wires</div>
                </td>
                <td>Amravati, Maharashtra</td>
                <td>Inspector P. Joshi</td>
                <td>2 hours ago</td>
                <td>
                  <span className="chip chip-ok">✓ Fully Compliant</span>
                </td>
              </tr>
              <tr>
                <td className="prod-cell">
                  <div className="pname">Smooth Talcum Powder, 200g</div>
                  <div className="pcat">Cosmetics &amp; Toiletries</div>
                </td>
                <td>Amravati, Maharashtra</td>
                <td>Inspector P. Joshi</td>
                <td>3 hours ago</td>
                <td>
                  <span className="chip chip-flag">✕ 3 Violations Flagged</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
