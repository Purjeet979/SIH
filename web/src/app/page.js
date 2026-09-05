import Link from 'next/link';

export default function LandingPage() {
  return (
    <>
      <nav className="landing-nav">
        <div className="wrap">
          <div className="brand">RuleScan <small>Team Kamchalau Coders</small></div>
          <div className="navlinks">
            <Link href="#how">How it works</Link>
            <Link href="#categories">Coverage</Link>
            <Link href="#research">Research</Link>
            <Link href="/dashboard">Dashboard</Link>
            <a className="nav-cta" href="/rulescan.apk" download>Download APK</a>
          </div>
        </div>
      </nav>

      <section className="hero">
        <div className="wrap">
          <div>
            <div className="kicker">Smart India Hackathon · SIH26034 · Legal Metrology (Packaged Commodities) Rules, 2011</div>
            <h1>Check any packaged product's compliance in one photo.</h1>
            <p className="lede">RuleScan reads a product label on-device, works out which commodity category it belongs to, and checks it against the exact Legal Metrology rules for that category — offline, in seconds, in Hindi or English.</p>
            <div className="hero-ctas">
              <a className="btn btn-primary" href="/rulescan.apk" download>Download APK<small>v0.1 prototype</small></a>
              <Link className="btn btn-ghost" href="/dashboard">View live dashboard</Link>
            </div>
          </div>
          <div className="scan-panel">
            <div className="label-title">Scan result</div>
            <div className="product-name">Herbal Face Wash, 100ml</div>
            <div className="field-row"><span className="field-name">Category detected</span><span>Cosmetics</span></div>
            <div className="field-row"><span className="field-name">MRP declaration</span><span className="chip chip-ok">Present</span></div>
            <div className="field-row"><span className="field-name">Net quantity</span><span className="chip chip-ok">Present</span></div>
            <div className="field-row"><span className="field-name">Veg / non-veg dot</span><span className="chip chip-flag">Missing</span></div>
            <div className="field-row"><span className="field-name">Letter height (panel: 68cm²)</span><span className="chip chip-flag">1.2mm &lt; 1.5mm req.</span></div>
            <div className="scan-summary">
              <span className="verdict">2 issues flagged</span>
              <span className="rule-ref">Rule 6(8), Rule 7</span>
            </div>
          </div>
        </div>
      </section>

      <div className="statbar">
        <div className="wrap">
          <div>
            <div className="stat-num">20+</div>
            <div className="stat-label">Commodity categories covered — not just food</div>
          </div>
          <div>
            <div className="stat-num">0</div>
            <div className="stat-label">Internet connection required to scan and check</div>
          </div>
          <div>
            <div className="stat-num">2</div>
            <div className="stat-label">Languages checked for every declaration: Hindi &amp; English</div>
          </div>
          <div>
            <div className="stat-num">&lt;10s</div>
            <div className="stat-label">From photo to pass / flagged result</div>
          </div>
        </div>
      </div>

      <section id="how">
        <div className="wrap">
          <div className="section-head">
            <div className="eyebrow">How it works</div>
            <h2>One photo runs the full compliance pipeline</h2>
            <p>Every step below happens on the officer's device — no signal needed until the result is ready to sync.</p>
          </div>
          <div className="steps">
            <div className="step">
              <div className="step-num">1</div>
              <h3>Capture + script detection</h3>
              <p>Photograph any packaged product. The app detects which script is printed — English, Devanagari, or a regional language.</p>
            </div>
            <div className="step">
              <div className="step-num">2</div>
              <h3>AI category classification</h3>
              <p>A classifier reads the label text and packaging shape to place the product into one of the law's commodity categories.</p>
            </div>
            <div className="step">
              <div className="step-num">3</div>
              <h3>Category rule match</h3>
              <p>The right rule bundle loads — universal declarations plus that category's standard sizes and unit-type requirements.</p>
            </div>
            <div className="step">
              <div className="step-num">4</div>
              <h3>Officer review</h3>
              <p>Every flag is confidence-scored, never automatic. The officer confirms before anything is recorded as a violation.</p>
            </div>
          </div>
        </div>
      </section>

      <section className="cat-band" id="categories">
        <div className="wrap">
          <div className="section-head">
            <div className="eyebrow">Built for every packaged commodity</div>
            <h2>The 2011 Rules were never just about food</h2>
            <p>RuleScan's rule engine is built category-first, matching the Second and Fourth Schedules of the Act.</p>
          </div>
          <div className="cat-grid">
            <div className="cat-tile">Packaged food &amp; FMCG<span className="rule-tag">Second Schedule sizes</span></div>
            <div className="cat-tile">Cosmetics &amp; toiletries<span className="rule-tag">Veg / non-veg dot, Rule 6(8)</span></div>
            <div className="cat-tile">Cement &amp; construction<span className="rule-tag">Bag-size declarations</span></div>
            <div className="cat-tile">Paints &amp; varnishes<span className="rule-tag">Volume-based units</span></div>
            <div className="cat-tile">Textiles &amp; garments<span className="rule-tag">Dimension declarations, Rule 14</span></div>
            <div className="cat-tile">Electricals &amp; wire<span className="rule-tag">Length or weight, Fourth Schedule</span></div>
            <div className="cat-tile">LPG cylinders<span className="rule-tag">Weight-checking equipment rule</span></div>
            <div className="cat-tile">Chemicals &amp; liquids<span className="rule-tag">Weight or volume declarations</span></div>
          </div>
        </div>
      </section>

      <section className="download-section" id="download">
        <div className="wrap">
          <div className="download-card">
            <div>
              <h2>Get the prototype on your phone.</h2>
              <p>Android APK, built for field officers. Requires camera permission only — no account, no network needed to run a scan.</p>
              <div className="download-meta">
                <div><span>Android 8+</span>APK, ~24MB</div>
                <div><span>v0.1</span>Hackathon prototype build</div>
                <div><span>Offline</span>No sign-in required</div>
              </div>
            </div>
            <a className="btn btn-primary" href="/rulescan.apk" download>Download APK</a>
          </div>
        </div>
      </section>

      <footer id="research">
        <div className="wrap">
          <div className="foot-grid">
            <div>
              <h4>RuleScan</h4>
              <p style={{fontSize: '13.5px', maxWidth: '34ch'}}>An offline-first compliance scanner for the Legal Metrology (Packaged Commodities) Rules, 2011 — built for SIH26034.</p>
            </div>
            <div>
              <h4>Research &amp; references</h4>
              <ul>
                <li><a href="https://consumeraffairs.nic.in" target="_blank" rel="noreferrer">Legal Metrology (Packaged Commodities) Rules, 2011 — full text</a></li>
                <li><a href="https://github.com/JaidedAI/EasyOCR" target="_blank" rel="noreferrer">EasyOCR — multi-script OCR</a></li>
                <li><a href="https://github.com/MariosVisos/retail-product-classifier" target="_blank" rel="noreferrer">Retail product image classification</a></li>
                <li><a href="https://github.com/CacheControl/json-rules-engine" target="_blank" rel="noreferrer">JSON rules engine</a></li>
                <li><a href="https://github.com/Practical-CV/Measuring-Size-of-Objects-with-OpenCV" target="_blank" rel="noreferrer">Reference-object size measurement</a></li>
              </ul>
            </div>
            <div>
              <h4>Project</h4>
              <ul>
                <li><Link href="/dashboard">Live dashboard demo</Link></li>
                <li><Link href="#how">How it works</Link></li>
                <li><Link href="#categories">Category coverage</Link></li>
              </ul>
            </div>
          </div>
          <div className="foot-bottom">
            <span>Team Kamchalau Coders — Smart India Hackathon 2026</span>
            <span>SIH26034 · Software</span>
          </div>
        </div>
      </footer>
    </>
  );
}
