'use client';

import Link from 'next/link';
import { useAuth } from '@/context/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import ThemeToggle from '../../ThemeToggle';

export default function AdminPage() {
  const { user, profile, role, loading, signOut, isAdmin } = useAuth();
  const router = useRouter();
  const [users, setUsers] = useState([]);
  const [ruleBundles, setRuleBundles] = useState([]);
  const [activeTab, setActiveTab] = useState('users');

  useEffect(() => {
    if (!loading && (!user || !isAdmin)) {
      router.push('/dashboard');
    }
  }, [loading, user, isAdmin, router]);

  useEffect(() => {
    if (user && isAdmin) {
      fetchUsers();
      fetchRuleBundles();
    }
  }, [user, isAdmin]);

  const fetchUsers = async () => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && data) {
        setUsers(data);
      }
    } catch (err) {
      console.error('Error fetching users:', err);
    }
  };

  const fetchRuleBundles = async () => {
    try {
      const { data, error } = await supabase
        .from('rule_bundles')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && data) {
        setRuleBundles(data);
      }
    } catch (err) {
      console.error('Error fetching rule bundles:', err);
    }
  };

  const handleRoleChange = async (userId, newRole) => {
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ role: newRole })
        .eq('id', userId);

      if (!error) {
        setUsers(prev => prev.map(u => u.id === userId ? { ...u, role: newRole } : u));
      }
    } catch (err) {
      console.error('Error updating role:', err);
    }
  };

  const handleSignOut = async () => {
    await signOut();
    router.push('/');
  };

  if (loading || !isAdmin) {
    return (
      <div className="dashboard-body">
        <div className="dash-loading">
          <div className="dash-loading-spinner"></div>
          <p>Loading admin panel...</p>
        </div>
      </div>
    );
  }

  // Demo users if no real data
  const demoUsers = [
    { id: 1, full_name: 'Admin User', role: 'ADMIN', department: 'Legal Metrology HQ', created_at: '2026-01-15' },
    { id: 2, full_name: 'R. Deshmukh', role: 'EMPLOYEE', department: 'Nagpur Division', created_at: '2026-02-20' },
    { id: 3, full_name: 'S. Kulkarni', role: 'EMPLOYEE', department: 'Wardha Division', created_at: '2026-03-01' },
    { id: 4, full_name: 'P. Joshi', role: 'EMPLOYEE', department: 'Amravati Division', created_at: '2026-04-10' },
    { id: 5, full_name: 'Public Viewer', role: 'USER', department: null, created_at: '2026-05-05' },
  ];

  const demoRuleBundles = [
    { id: 1, bundle_version: '2026.01', is_active: true, effective_from: '2026-01-01', source_reference: 'LMPC Rules, 2011', rules: Array(9).fill({}) },
  ];

  const displayUsers = users.length > 0 ? users : demoUsers;
  const displayBundles = ruleBundles.length > 0 ? ruleBundles : demoRuleBundles;

  const roleColors = {
    ADMIN: { bg: 'rgba(139,92,246,0.12)', color: '#8b5cf6', border: '#7c3aed' },
    EMPLOYEE: { bg: 'rgba(37,99,235,0.12)', color: '#2563eb', border: '#1d4ed8' },
    USER: { bg: 'rgba(13,148,136,0.12)', color: '#0d9488', border: '#0f766e' },
  };

  return (
    <div className="dashboard-body">
      {/* TOP BAR */}
      <div className="topbar">
        <div className="brand">
          <img src="/logo.svg" alt="RuleScan Logo" className="brand-logo" />
          <span className="brand-badge" style={{ backgroundColor: 'rgba(139,92,246,0.12)', color: '#8b5cf6', borderColor: '#7c3aed' }}>
            Admin Panel
          </span>
        </div>
        <nav>
          <Link href="/">Home</Link>
          <Link href="/dashboard">Dashboard</Link>
          <Link className="active" href="/dashboard/admin">Admin</Link>
        </nav>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <ThemeToggle />
          <button className="dash-signout-btn" onClick={handleSignOut}>Sign Out</button>
        </div>
      </div>

      <div className="shell">
        <div className="page-head">
          <div>
            <h1>Admin Control Panel</h1>
            <p>Manage users, roles, and rule bundles for the RuleScan ecosystem</p>
          </div>
          <span className="demo-tag">
            {users.length > 0 ? '🟢 Live Data' : '🟡 Demo Data'}
          </span>
        </div>

        {/* TAB NAVIGATION */}
        <div className="admin-tabs">
          <button
            className={`admin-tab ${activeTab === 'users' ? 'active' : ''}`}
            onClick={() => setActiveTab('users')}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
            User Management
          </button>
          <button
            className={`admin-tab ${activeTab === 'rules' ? 'active' : ''}`}
            onClick={() => setActiveTab('rules')}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
            Rule Bundles
          </button>
        </div>

        {/* USERS TAB */}
        {activeTab === 'users' && (
          <div className="panel panel-glass">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div>
                <h3 style={{ margin: 0 }}>Registered Users</h3>
                <div className="sub" style={{ margin: 0 }}>
                  {displayUsers.length} total users across all roles
                </div>
              </div>
              <div className="admin-role-summary">
                <span className="admin-role-chip" style={{ backgroundColor: roleColors.ADMIN.bg, color: roleColors.ADMIN.color, borderColor: roleColors.ADMIN.border }}>
                  {displayUsers.filter(u => u.role === 'ADMIN').length} Admin
                </span>
                <span className="admin-role-chip" style={{ backgroundColor: roleColors.EMPLOYEE.bg, color: roleColors.EMPLOYEE.color, borderColor: roleColors.EMPLOYEE.border }}>
                  {displayUsers.filter(u => u.role === 'EMPLOYEE').length} Employee
                </span>
                <span className="admin-role-chip" style={{ backgroundColor: roleColors.USER.bg, color: roleColors.USER.color, borderColor: roleColors.USER.border }}>
                  {displayUsers.filter(u => u.role === 'USER').length} User
                </span>
              </div>
            </div>

            <div className="table-responsive">
              <table>
                <thead>
                  <tr>
                    <th>User</th>
                    <th>Role</th>
                    <th>Department</th>
                    <th>Joined</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {displayUsers.map((u, i) => (
                    <tr key={u.id || i}>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                          <div className="dash-avatar" style={{ backgroundColor: roleColors[u.role]?.color || '#6b7280', width: 36, height: 36, fontSize: 14 }}>
                            {(u.full_name || '?')[0].toUpperCase()}
                          </div>
                          <div>
                            <div style={{ fontWeight: 600 }}>{u.full_name || 'Unnamed'}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        <span className="admin-role-chip" style={{
                          backgroundColor: roleColors[u.role]?.bg || '#f1f5f9',
                          color: roleColors[u.role]?.color || '#6b7280',
                          borderColor: roleColors[u.role]?.border || '#94a3b8'
                        }}>
                          {u.role}
                        </span>
                      </td>
                      <td>{u.department || '—'}</td>
                      <td>{new Date(u.created_at).toLocaleDateString()}</td>
                      <td>
                        <select
                          className="admin-role-select"
                          value={u.role}
                          onChange={(e) => handleRoleChange(u.id, e.target.value)}
                        >
                          <option value="USER">USER</option>
                          <option value="EMPLOYEE">EMPLOYEE</option>
                          <option value="ADMIN">ADMIN</option>
                        </select>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* RULE BUNDLES TAB */}
        {activeTab === 'rules' && (
          <div className="panel panel-glass">
            <div style={{ marginBottom: '20px' }}>
              <h3 style={{ margin: 0 }}>Rule Bundles</h3>
              <div className="sub" style={{ margin: 0 }}>
                Versioned LMPC rule sets that power the inspection engine
              </div>
            </div>

            {displayBundles.map((bundle, i) => (
              <div key={bundle.id || i} className="admin-bundle-card">
                <div className="admin-bundle-header">
                  <div>
                    <h4 style={{ margin: 0, fontSize: '16px', fontWeight: 700 }}>
                      LMPC Rule Bundle v{bundle.bundle_version}
                    </h4>
                    <p style={{ margin: '4px 0 0', fontSize: '13px', color: 'var(--text-secondary)' }}>
                      {bundle.source_reference || 'Legal Metrology (Packaged Commodities) Rules, 2011'}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                    {bundle.is_active && (
                      <span className="chip chip-ok">✓ Active</span>
                    )}
                    <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                      Effective: {bundle.effective_from ? new Date(bundle.effective_from).toLocaleDateString() : '—'}
                    </span>
                  </div>
                </div>
                <div className="admin-bundle-rules">
                  <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)' }}>
                    Contains {Array.isArray(bundle.rules) ? bundle.rules.length : '?'} rules
                  </span>
                  <div className="admin-rule-tags">
                    {['Rule 6', 'Rule 6(8)', 'Rule 7', 'Rule 8', 'Rule 9', 'Rule 11', 'Rule 12', 'Rule 13', 'Rule 26'].map(r => (
                      <span key={r} className="admin-rule-tag">{r}</span>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
