'use client';

import Link from 'next/link';
import ThemeToggle from './ThemeToggle';
import { useAuth } from '@/context/AuthContext';

export default function LandingPage() {
  const { user, profile, role, isAuthenticated, signOut } = useAuth();

  return (
    <>
      <nav className="landing-nav">
        <div className="wrap">
          <div className="brand">
            <img src="/logo.svg" alt="RuleScan Logo" className="brand-logo" />
            <span className="brand-badge">SIH 2026</span>
          </div>
          <div className="navlinks">
            <Link href="#how">How it works</Link>
            <Link href="#categories">Coverage</Link>
            <Link href="#research">Research</Link>
            <Link href="/dashboard">Dashboard</Link>
            <ThemeToggle />
            {isAuthenticated ? (
              <div className="nav-auth-group">
                <Link href="/dashboard" className="nav-user-pill">
                  <span className="nav-user-avatar">
                    {(profile?.full_name || user?.email || '?')[0].toUpperCase()}
                  </span>
                  <span>{profile?.full_name || 'Dashboard'}</span>
                </Link>
                <button className="nav-signout-btn" onClick={() => signOut()}>
                  Sign Out
                </button>
              </div>
            ) : (
              <div className="nav-auth-group">
                <Link className="nav-login-btn" href="/login">
                  Sign In
                </Link>
                <Link className="nav-cta" href="/signup">
                  Get Started
                </Link>
              </div>
            )}
          </div>
        </div>
      </nav>

      <section className="hero">
        <div className="wrap">
          <div className="hero-grid">
            {/* HERO LEFT CONTENT */}
            <div>
              <div className="sih-badge">
                SMART INDIA HACKATHON 2026 • SIH26034
              </div>
              
              <h1>
                Legal Metrology Compliance,<br />
                <span className="blue-text">Simplified.</span>
              </h1>
              
              <p className="lede">
                RuleScan turns packaged commodity labels into explainable, evidence-backed regulatory verdicts in under 3 seconds — operating with zero cloud latency on standard edge hardware.
              </p>

              <div className="hero-ctas">
                <a className="btn-hero-dark" href="https://github.com/Purjeet979/SIH/releases/download/v1.0.0/app-release.apk" download>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M17.523 15.3414C17.054 15.3414 16.674 14.9614 16.674 14.4924C16.674 14.0234 17.054 13.6434 17.523 13.6434C17.992 13.6434 18.372 14.0234 18.372 14.4924C18.372 14.9614 17.992 15.3414 17.523 15.3414ZM6.477 15.3414C6.008 15.3414 5.628 14.9614 5.628 14.4924C5.628 14.0234 6.008 13.6434 6.477 13.6434C6.946 13.6434 7.326 14.0234 7.326 14.4924C7.326 14.9614 6.946 15.3414 6.477 15.3414ZM17.885 10.3954L19.824 7.03642C19.963 6.79542 19.88 6.48842 19.639 6.34942C19.398 6.21042 19.091 6.29342 18.952 6.53442L16.98 9.94942C15.474 9.26442 13.788 8.87442 12 8.87442C10.212 8.87442 8.526 9.26442 7.02 9.94942L5.048 6.53442C4.909 6.29342 4.602 6.21042 4.361 6.34942C4.12 6.48842 4.037 6.79542 4.176 7.03642L6.115 10.3954C2.716 12.2474 0.428 15.7194 0 19.8164H24C23.572 15.7194 21.284 12.2474 17.885 10.3954Z"/>
                  </svg>
                  <div>
                    <span>Download Android App</span>
                    <span className="btn-sub">v1.0.0 (Offline Build • 48MB)</span>
                  </div>
                </a>

                {isAuthenticated ? (
                  <Link className="btn-hero-light" href="/dashboard">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <line x1="18" y1="20" x2="18" y2="10"></line>
                      <line x1="12" y1="20" x2="12" y2="4"></line>
                      <line x1="6" y1="20" x2="6" y2="14"></line>
                    </svg>
                    <span>Open Dashboard</span>
                  </Link>
                ) : (
                  <Link className="btn-hero-light" href="/signup">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                      <circle cx="8.5" cy="7" r="4"></circle>
                      <line x1="20" y1="8" x2="20" y2="14"></line>
                      <line x1="23" y1="11" x2="17" y2="11"></line>
                    </svg>
                    <span>Create Account — Free</span>
                  </Link>
                )}
              </div>

              {/* FEATURE PILLS */}
              <div className="feature-pills-row">
                <span className="feature-pill">📶 100% Offline Core</span>
                <span className="feature-pill">💡 Edge ML Kit + TFLite</span>
                <span className="feature-pill">🔬 PCR 2011 Codified</span>
                <span className="feature-pill">🛡️ Court-Ready Hashing</span>
              </div>
            </div>

            {/* HERO RIGHT PHONE MOCKUP */}
            <div className="phone-mockup-wrapper">
              {/* Floating OCR Certainty Badge */}
              <div className="floating-badge-ocr">
                <div style={{ background: '#eff6ff', color: '#2563eb', padding: '8px', borderRadius: '8px', fontSize: '18px' }}>
                  🔍
                </div>
                <div>
                  <div className="ocr-lbl">OCR Certainty</div>
                  <div className="ocr-val">98.4%</div>
                  <div className="ocr-lbl">Google ML Kit On-Device</div>
                </div>
              </div>

              {/* Smartphone Frame */}
              <div className="phone-bezel">
                <div className="phone-screen">
                  {/* Status Bar */}
                  <div className="phone-status-bar">
                    <span>12:42</span>
                    <span>📶 ⚡ 100%</span>
                  </div>

                  {/* Header */}
                  <div className="phone-top-bar">
                    <span>● Heritage Ghee 1L Tin</span>
                    <span className="phone-pass-pill">88% PASS</span>
                  </div>

                  {/* Camera Scanner View with REAL Product Label Image */}
                  <div className="phone-content">
                    <div className="phone-content-overlay"></div>

                    {/* Real-time Inspection Overlay Cards over the actual scanned image */}
                    <div className="phone-overlay-card ok">
                      <div>
                        <div className="phone-overlay-lbl">MRP ₹495.00</div>
                        <span className="phone-overlay-sub">Rule 6(1)(e) • Valid</span>
                      </div>
                      <span style={{ color: '#22c55e', fontWeight: 800 }}>✓</span>
                    </div>

                    <div className="phone-overlay-card ok">
                      <div>
                        <div className="phone-overlay-lbl">Net Qty: 1000 ml (1 L)</div>
                        <span className="phone-overlay-sub">Rule 6(1)(d) • Standard Unit</span>
                      </div>
                      <span style={{ color: '#22c55e', fontWeight: 800 }}>✓</span>
                    </div>

                    <div className="phone-overlay-card warn">
                      <div>
                        <div className="phone-overlay-lbl" style={{ color: '#e11d48' }}>Numeral Ht: 3.2 mm</div>
                        <span className="phone-overlay-sub" style={{ color: '#be123c' }}>Rule 7 • Min 4.0mm Mandated</span>
                      </div>
                      <span style={{ color: '#e11d48', fontWeight: 800 }}>⚠</span>
                    </div>
                  </div>

                  {/* Footer */}
                  <div className="phone-footer-bar">
                    <div>
                      <strong style={{ color: '#ffffff', display: 'block' }}>OFFLINE ENGINE</strong>
                      <span>TFLite v2.14 Local</span>
                    </div>
                    <span style={{ fontSize: '14px' }}>⚙️</span>
                  </div>
                </div>
              </div>

              {/* Floating Infraction Badge */}
              <div className="floating-badge-infraction">
                <div className="infraction-title">
                  <span>⚠</span> Rule 7 Infraction
                </div>
                <div className="infraction-body">
                  Letter Height 3.2mm fails Schedule Table 1 (4.0mm required).
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* STATBAR */}
      <div className="statbar">
        <div className="wrap">
          <div>
            <div className="stat-num">20+</div>
            <div className="stat-label">Commodity categories covered beyond food</div>
          </div>
          <div>
            <div className="stat-num">100%</div>
            <div className="stat-label">Offline execution — no internet needed</div>
          </div>
          <div>
            <div className="stat-num">2</div>
            <div className="stat-label">Languages parsed: English &amp; Devanagari</div>
          </div>
          <div>
            <div className="stat-num">&lt;3s</div>
            <div className="stat-label">Average time from photo to verdict</div>
          </div>
        </div>
      </div>

      {/* HOW IT WORKS */}
      <section id="how">
        <div className="wrap">
          <div className="section-head">
            <div className="eyebrow">Offline Processing Pipeline</div>
            <h2>One photo runs the full compliance engine</h2>
            <p>Every step below executes on the officer&apos;s device without relying on server connectivity.</p>
          </div>
          <div className="steps">
            <div className="step">
              <div className="step-num">1</div>
              <h3>Capture &amp; Script Recognition</h3>
              <p>Photograph product labels. The ML Kit OCR extracts text across English and Devanagari scripts on-device.</p>
            </div>
            <div className="step">
              <div className="step-num">2</div>
              <h3>AI Category Classification</h3>
              <p>On-device classifier categorizes packaging into specific Legal Metrology commodity classes.</p>
            </div>
            <div className="step">
              <div className="step-num">3</div>
              <h3>Dynamic Rule Matching</h3>
              <p>Rule engine evaluates declarations, standard pack sizes, and unit price formulas against rulesets.</p>
            </div>
            <div className="step">
              <div className="step-num">4</div>
              <h3>Officer Verification</h3>
              <p>Every flag is presented with confidence scores for the field officer to review and confirm with geotagged proof.</p>
            </div>
          </div>
        </div>
      </section>

      {/* ROLE-BASED ACCESS SECTION */}
      <section className="roles-section" id="roles">
        <div className="wrap">
          <div className="section-head">
            <div className="eyebrow">Role-Based Access Control</div>
            <h2>Two roles, one unified platform</h2>
            <p>Each role gets a tailored experience optimized for their workflow.</p>
          </div>
          <div className="roles-grid">
            <div className="role-card role-card-admin">
              <div className="role-card-icon">⚙️</div>
              <h3>Admin</h3>
              <p>Full system control — manage users, rule bundles, view all inspections across all officers and regions.</p>
              <ul className="role-features">
                <li>✓ User & role management</li>
                <li>✓ All inspection logs</li>
                <li>✓ Rule bundle versioning</li>
                <li>✓ System-wide analytics</li>
              </ul>
            </div>
            <div className="role-card role-card-employee">
              <div className="role-card-icon">🔍</div>
              <h3>Employee (Officer)</h3>
              <p>Field-grade access — create inspections, sync from mobile, view personal scan history and results.</p>
              <ul className="role-features">
                <li>✓ Create inspections</li>
                <li>✓ Mobile sync</li>
                <li>✓ Personal scan history</li>
                <li>✓ Rule result review</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* CATEGORIES */}
      <section className="cat-band" id="categories">
        <div className="wrap">
          <div className="section-head">
            <div className="eyebrow">Comprehensive LMPC Coverage</div>
            <h2>Built for all regulated commodity types</h2>
            <p>Full mapping of Second &amp; Fourth Schedules of Legal Metrology (Packaged Commodities) Rules, 2011.</p>
          </div>
          <div className="cat-grid">
            <div className="cat-tile">
              Packaged Food &amp; FMCG
              <span className="rule-tag">Second Schedule Pack Sizes</span>
            </div>
            <div className="cat-tile">
              Cosmetics &amp; Toiletries
              <span className="rule-tag">Veg/Non-Veg Dot, Rule 6(8)</span>
            </div>
            <div className="cat-tile">
              Cement &amp; Construction
              <span className="rule-tag">Bag Net Weight Declarations</span>
            </div>
            <div className="cat-tile">
              Paints &amp; Varnishes
              <span className="rule-tag">Volume Unit Rules</span>
            </div>
            <div className="cat-tile">
              Textiles &amp; Garments
              <span className="rule-tag">Dimensions &amp; Rule 14</span>
            </div>
            <div className="cat-tile">
              Electricals &amp; Wires
              <span className="rule-tag">Fourth Schedule Specifications</span>
            </div>
            <div className="cat-tile">
              LPG &amp; Gas Cylinders
              <span className="rule-tag">Tare Weight Compliance</span>
            </div>
            <div className="cat-tile">
              Chemicals &amp; Industrial
              <span className="rule-tag">Weight / Volume Declarations</span>
            </div>
          </div>
        </div>
      </section>

      {/* DOWNLOAD SECTION */}
      <section className="download-section" id="download">
        <div className="wrap">
          <div className="download-card">
            <div>
              <h2>Get the RuleScan App for Field Officers</h2>
              <p>Download the prototype Android APK. Designed for immediate offline field inspection with local SQLite storage.</p>
              <div className="download-meta">
                <div>
                  <span>Android 8.0+</span>
                  APK (~48 MB)
                </div>
                <div>
                  <span>v1.0.0 Prototype</span>
                  SIH Build
                </div>
                <div>
                  <span>Offline Ready</span>
                  No Login Required
                </div>
              </div>
            </div>
            <a className="btn btn-primary" href="https://github.com/Purjeet979/SIH/releases/download/v1.0.0/app-release.apk" download>
              Download APK
            </a>
          </div>

          <div style={{ marginTop: '40px', padding: '32px', backgroundColor: 'var(--bg-card)', borderRadius: '16px', border: '1px solid var(--border)' }}>
            <h3 style={{ fontSize: '20px', marginBottom: '16px', color: 'var(--text-primary)' }}>How to Install & Run the App</h3>
            <ol style={{ paddingLeft: '20px', color: 'var(--text-secondary)', lineHeight: '1.8' }}>
              <li><strong>Download:</strong> Click the <em>Download APK</em> button above and save the <code>rulescan.apk</code> file to your Android device.</li>
              <li><strong>Allow Unknown Sources:</strong> Go to your phone's <em>Settings &gt; Security</em> and enable <em>Install unknown apps</em> for your browser or file manager.</li>
              <li><strong>Install:</strong> Tap the downloaded APK file and follow the on-screen prompts to install the RuleScan app.</li>
              <li><strong>Connect:</strong> Launch the app. It will sync scans to your web dashboard automatically!</li>
            </ol>
          </div>
        </div>
      </section>

      {/* FOOTER */}
      <footer id="research">
        <div className="wrap">
          <div className="foot-grid">
            <div>
              <div className="brand" style={{ marginBottom: '8px' }}>
                <img src="/logo.svg" alt="RuleScan Logo" className="brand-logo" />
              </div>
              <p style={{ fontSize: '14px', marginTop: '8px' }}>
                An offline-first compliance inspection system for Legal Metrology (Packaged Commodities) Rules, 2011.
              </p>
              <div style={{ marginTop: '12px', fontSize: '13px', fontWeight: 600, color: 'var(--text-muted)' }}>
                Team Kamchalau Coders · SIH 2026
              </div>
            </div>
            <div>
              <h4>Legal &amp; Technical Specs</h4>
              <ul>
                <li>
                  <a href="https://consumeraffairs.nic.in" target="_blank" rel="noreferrer">
                    Legal Metrology Act &amp; Rules, 2011
                  </a>
                </li>
                <li>
                  <a href="https://github.com/JaidedAI/EasyOCR" target="_blank" rel="noreferrer">
                    On-Device ML Kit OCR
                  </a>
                </li>
                <li>
                  <a href="https://github.com/CacheControl/json-rules-engine" target="_blank" rel="noreferrer">
                    JSON Rule Engine Architecture
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h4>Quick Links</h4>
              <ul>
                <li>
                  <Link href="/dashboard">State Analytics Dashboard</Link>
                </li>
                <li>
                  <Link href="/login">Sign In</Link>
                </li>
                <li>
                  <Link href="/signup">Create Account</Link>
                </li>
                <li>
                  <Link href="#how">Inspection Pipeline</Link>
                </li>
                <li>
                  <Link href="#categories">Regulated Categories</Link>
                </li>
              </ul>
            </div>
          </div>
          <div className="foot-bottom">
            <span>© 2026 Team Kamchalau Coders — Smart India Hackathon</span>
            <span>Problem Statement: SIH26034</span>
          </div>
        </div>
      </footer>
    </>
  );
}
