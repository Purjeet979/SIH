'use client';

import { useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { signIn } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const res = await signIn(email, password);
      if (res?.role === 'ADMIN' || email.toLowerCase().includes('admin')) {
        router.push('/dashboard/admin');
      } else {
        router.push('/dashboard');
      }
    } catch (err) {
      setError(err.message || 'Login failed. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  const setDemoAccount = (demoEmail, demoPassword) => {
    setEmail(demoEmail);
    setPassword(demoPassword);
    setError('');
  };

  return (
    <div className="auth-page">
      {/* Animated Background */}
      <div className="auth-bg-grid"></div>
      <div className="auth-bg-glow auth-bg-glow-1"></div>
      <div className="auth-bg-glow auth-bg-glow-2"></div>
      <div className="auth-bg-glow auth-bg-glow-3"></div>

      <div className="auth-container">
        {/* Left Panel — Branding */}
        <div className="auth-branding">
          <div className="auth-branding-content">
            <Link href="/" className="auth-brand-link">
              <img src="/logo.svg" alt="RuleScan" className="auth-brand-logo" />
            </Link>
            <h2>Welcome Back</h2>
            <p>Sign in to access your Legal Metrology compliance dashboard, inspection reports, and analytics.</p>
            
            <div className="auth-features">
              <div className="auth-feature-item">
                <span className="auth-feature-icon">📊</span>
                <div>
                  <strong>Live Dashboard</strong>
                  <span>Real-time compliance analytics</span>
                </div>
              </div>
              <div className="auth-feature-item">
                <span className="auth-feature-icon">🔍</span>
                <div>
                  <strong>Inspection Logs</strong>
                  <span>Track field officer scans</span>
                </div>
              </div>
              <div className="auth-feature-item">
                <span className="auth-feature-icon">🛡️</span>
                <div>
                  <strong>Role-Based Access</strong>
                  <span>Admin, Employee & User views</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Right Panel — Login Form */}
        <div className="auth-form-panel">
          <div className="auth-form-wrapper">
            <div className="auth-form-header">
              <h1>Sign In</h1>
              <p>Enter your credentials to continue</p>
            </div>

            {error && (
              <div className="auth-error">
                <span>⚠</span> {error}
              </div>
            )}

            {/* Quick Demo Login Fillers */}
            <div style={{
              background: 'var(--card-bg, #f8fafc)',
              border: '1px solid var(--line, #e2e8f0)',
              borderRadius: '10px',
              padding: '12px',
              marginBottom: '18px',
            }}>
              <div style={{fontSize: '11px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px', color: 'var(--text-muted, #64748b)', marginBottom: '8px'}}>
                🔑 Quick Demo Accounts (Click to Fill)
              </div>
              <div style={{display: 'flex', gap: '8px', flexWrap: 'wrap'}}>
                <button
                  type="button"
                  onClick={() => setDemoAccount('officer@rulescan.com', 'Purjeet@9506')}
                  style={{
                    flex: '1 1 140px',
                    padding: '8px 10px',
                    borderRadius: '8px',
                    border: '1px solid ' + (email === 'officer@rulescan.com' ? '#2563eb' : 'var(--line, #cbd5e1)'),
                    background: email === 'officer@rulescan.com' ? '#eff6ff' : 'var(--surface, #fff)',
                    cursor: 'pointer',
                    textAlign: 'left',
                    transition: 'all 0.15s ease'
                  }}
                >
                  <div style={{fontSize: '12px', fontWeight: '700', color: 'var(--text-dark, #1e293b)'}}>👮 Field Officer</div>
                  <div style={{fontSize: '10.5px', color: 'var(--text-muted, #64748b)'}}>officer@rulescan.com</div>
                  <div style={{fontSize: '10px', color: '#2563eb', fontWeight: '600'}}>Pass: Purjeet@9506</div>
                </button>
                <button
                  type="button"
                  onClick={() => setDemoAccount('admin@rulescan.com', 'admin123')}
                  style={{
                    flex: '1 1 140px',
                    padding: '8px 10px',
                    borderRadius: '8px',
                    border: '1px solid ' + (email === 'admin@rulescan.com' ? '#8b5cf6' : 'var(--line, #cbd5e1)'),
                    background: email === 'admin@rulescan.com' ? '#f5f3ff' : 'var(--surface, #fff)',
                    cursor: 'pointer',
                    textAlign: 'left',
                    transition: 'all 0.15s ease'
                  }}
                >
                  <div style={{fontSize: '12px', fontWeight: '700', color: 'var(--text-dark, #1e293b)'}}>🛡️ State Admin</div>
                  <div style={{fontSize: '10.5px', color: 'var(--text-muted, #64748b)'}}>admin@rulescan.com</div>
                  <div style={{fontSize: '10px', color: '#7c3aed', fontWeight: '600'}}>Pass: admin123</div>
                </button>
              </div>
            </div>

            <form onSubmit={handleSubmit} className="auth-form">
              <div className="auth-field">
                <label htmlFor="email">Email Address</label>
                <div className="auth-input-wrap">
                  <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="2" y="4" width="20" height="16" rx="2"></rect>
                    <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"></path>
                  </svg>
                  <input
                    id="email"
                    type="email"
                    placeholder="you@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    autoComplete="email"
                  />
                </div>
              </div>

              <div className="auth-field">
                <label htmlFor="password">Password</label>
                <div className="auth-input-wrap">
                  <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                  </svg>
                  <input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    autoComplete="current-password"
                  />
                </div>
              </div>

              <button
                type="submit"
                className="auth-submit-btn"
                disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <span className="auth-spinner"></span>
                    Signing in...
                  </>
                ) : (
                  'Sign In'
                )}
              </button>
            </form>

            <div className="auth-divider">
              <span>New to RuleScan?</span>
            </div>

            <Link href="/signup" className="auth-alt-btn">
              Create an Account
            </Link>

            <div className="auth-footer-link">
              <Link href="/">← Back to Home</Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
