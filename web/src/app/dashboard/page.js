import Link from 'next/link';

export default function DashboardPage() {
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
            <p>State Legal Metrology cell &middot; All categories &middot; Last 30 days</p>
          </div>
          <span className="demo-tag">Prototype data — for demo purposes</span>
        </div>

        <div className="stat-row">
          <div className="stat-card">
            <div className="num">1,842</div>
            <div className="lbl">Scans completed</div>
            <div className="delta delta-up">+312 vs. last month</div>
          </div>
          <div className="stat-card">
            <div className="num">76%</div>
            <div className="lbl">Overall compliance rate</div>
            <div className="delta delta-up">+4pts vs. last month</div>
          </div>
          <div className="stat-card">
            <div className="num">438</div>
            <div className="lbl">Violations flagged</div>
            <div className="delta delta-down">-58 vs. last month</div>
          </div>
          <div className="stat-card">
            <div className="num">9</div>
            <div className="lbl">Commodity categories scanned</div>
            <div className="delta delta-up">+2 new this month</div>
          </div>
        </div>

        <div className="grid-2">
          <div className="panel">
            <h3>Violations by category</h3>
            <div className="sub">Share of flagged scans within each commodity category</div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Cosmetics &amp; toiletries</span><span className="val">31%</span></div>
              <div className="bar-track"><div className="bar-fill alert" style={{width: '31%'}}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Packaged food</span><span className="val">22%</span></div>
              <div className="bar-track"><div className="bar-fill" style={{width: '22%'}}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Cement &amp; construction</span><span className="val">18%</span></div>
              <div className="bar-track"><div className="bar-fill" style={{width: '18%'}}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Paints &amp; varnishes</span><span className="val">14%</span></div>
              <div className="bar-track"><div className="bar-fill" style={{width: '14%'}}></div></div>
            </div>
            <div className="bar-row">
              <div className="bar-top"><span className="cat">Electricals &amp; wire</span><span className="val">9%</span></div>
              <div className="bar-track"><div className="bar-fill" style={{width: '9%'}}></div></div>
            </div>
          </div>

          <div className="panel">
            <h3>Top violated rules</h3>
            <div className="sub">Which clause is most often missing or wrong</div>
            <ul className="rule-list">
              <li>
                <div><span className="rname">Letter/numeral height</span><span className="rref">Rule 7</span></div>
                <span className="rule-count">146</span>
              </li>
              <li>
                <div><span className="rname">Consumer care details</span><span className="rref">Rule 6(2)</span></div>
                <span className="rule-count">98</span>
              </li>
              <li>
                <div><span className="rname">Veg / non-veg dot</span><span className="rref">Rule 6(8)</span></div>
                <span className="rule-count">71</span>
              </li>
              <li>
                <div><span className="rname">Unit sale price</span><span className="rref">Rule 6(11)</span></div>
                <span className="rule-count">63</span>
              </li>
              <li>
                <div><span className="rname">Net quantity declaration</span><span className="rref">Rule 6(1)(c)</span></div>
                <span className="rule-count">60</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="panel">
          <h3>Recent scans</h3>
          <div className="sub">Latest inspections synced from field officers</div>
          <table>
            <thead>
              <tr><th>Product</th><th>Location</th><th>Officer</th><th>Time</th><th>Status</th></tr>
            </thead>
            <tbody>
              <tr>
                <td className="prod-cell"><div className="pname">Herbal Face Wash, 100ml</div><div className="pcat">Cosmetics</div></td>
                <td>Nagpur, MH</td><td>R. Deshmukh</td><td>14 min ago</td>
                <td><span className="chip chip-flag">2 flagged</span></td>
              </tr>
              <tr>
                <td className="prod-cell"><div className="pname">Refined Sunflower Oil, 1L</div><div className="pcat">Packaged food</div></td>
                <td>Nagpur, MH</td><td>R. Deshmukh</td><td>26 min ago</td>
                <td><span className="chip chip-ok">Compliant</span></td>
              </tr>
              <tr>
                <td className="prod-cell"><div className="pname">OPC Cement, 50kg</div><div className="pcat">Cement</div></td>
                <td>Wardha, MH</td><td>S. Kulkarni</td><td>1 hr ago</td>
                <td><span className="chip chip-ok">Compliant</span></td>
              </tr>
              <tr>
                <td className="prod-cell"><div className="pname">Enamel Paint, 500ml</div><div className="pcat">Paints</div></td>
                <td>Wardha, MH</td><td>S. Kulkarni</td><td>1 hr ago</td>
                <td><span className="chip chip-flag">1 flagged</span></td>
              </tr>
              <tr>
                <td className="prod-cell"><div className="pname">Copper Wire, 90m coil</div><div className="pcat">Electricals</div></td>
                <td>Amravati, MH</td><td>P. Joshi</td><td>2 hr ago</td>
                <td><span className="chip chip-ok">Compliant</span></td>
              </tr>
              <tr>
                <td className="prod-cell"><div className="pname">Talcum Powder, 200g</div><div className="pcat">Cosmetics</div></td>
                <td>Amravati, MH</td><td>P. Joshi</td><td>3 hr ago</td>
                <td><span className="chip chip-flag">3 flagged</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
