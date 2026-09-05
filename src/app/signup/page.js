'use client';

import { useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function SignUpPage() {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [selectedRole, setSelectedRole] = useState('USER');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { signUp } = useAuth();
  const router = useRouter();

  const roles = [
    { value: 'USER', label: 'User', desc: 'View compliance reports & analytics', icon: '👤' },
    { value: 'EMPLOYEE', label: 'Employee (Officer)', desc: 'Create inspections & field scans', icon: '🔍' },
    { value: 'ADMIN', label: 'Admin', desc: 'Full access — manage all data', icon: '⚙️' },
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters.');
      return;
    }

    setIsLoading(true);

    try {
      await signUp(email, password, fullName, selectedRole);
      setSuccess('Account created! Check your email for verification, then sign in.');
      setTimeout(() => router.push('/login'), 3000);
    } catch (err) {
      setError(err.message || 'Signup failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
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
            <h2>Join RuleScan</h2>
            <p>Create your account to access the Legal Metrology compliance ecosystem. Choose your role to get the right level of access.</p>
            
            <div className="auth-features">
              {roles.map(r => (
                <div className={`auth-feature-item ${selectedRole === r.value ? 'active' : ''}`} key={r.value}>
                  <span className="auth-feature-icon">{r.icon}</span>
                  <div>
                    <strong>{r.label}</strong>
                    <span>{r.desc}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Panel — Signup Form */}
        <div className="auth-form-panel">
          <div className="auth-form-wrapper">
            <div className="auth-form-header">
              <h1>Create Account</h1>
              <p>Fill in your details to get started</p>
            </div>

            {error && (
              <div className="auth-error">
                <span>⚠</span> {error}
              </div>
            )}

            {success && (
              <div className="auth-success">
                <span>✓</span> {success}
              </div>
            )}

            <form onSubmit={handleSubmit} className="auth-form">
              <div className="auth-field">
                <label htmlFor="fullName">Full Name</label>
                <div className="auth-input-wrap">
                  <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                  </svg>
                  <input
                    id="fullName"
                    type="text"
                    placeholder="John Doe"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className="auth-field">
                <label htmlFor="signupEmail">Email Address</label>
                <div className="auth-input-wrap">
                  <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="2" y="4" width="20" height="16" rx="2"></rect>
                    <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"></path>
                  </svg>
                  <input
                    id="signupEmail"
                    type="email"
                    placeholder="you@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    autoComplete="email"
                  />
                </div>
              </div>

              <div className="auth-field-row">
                <div className="auth-field">
                  <label htmlFor="signupPassword">Password</label>
                  <div className="auth-input-wrap">
                    <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                    <input
                      id="signupPassword"
                      type="password"
                      placeholder="Min 6 chars"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      autoComplete="new-password"
                    />
                  </div>
                </div>
                <div className="auth-field">
                  <label htmlFor="confirmPassword">Confirm</label>
                  <div className="auth-input-wrap">
                    <svg className="auth-input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                    <input
                      id="confirmPassword"
                      type="password"
                      placeholder="Repeat"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      required
                      autoComplete="new-password"
                    />
                  </div>
                </div>
              </div>

              <div className="auth-field">
                <label>Select Your Role</label>
                <div className="auth-role-picker">
                  {roles.map(r => (
                    <button
                      type="button"
                      key={r.value}
                      className={`auth-role-option ${selectedRole === r.value ? 'selected' : ''}`}
                      onClick={() => setSelectedRole(r.value)}
                    >
                      <span className="auth-role-icon">{r.icon}</span>
                      <span className="auth-role-label">{r.label}</span>
                    </button>
                  ))}
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
                    Creating account...
                  </>
                ) : (
                  'Create Account'
                )}
              </button>
            </form>

            <div className="auth-divider">
              <span>Already have an account?</span>
            </div>

            <Link href="/login" className="auth-alt-btn">
              Sign In Instead
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
