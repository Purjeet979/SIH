'use client';

import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/supabase';

const AuthContext = createContext({});

export const DEMO_ACCOUNTS = {
  'officer@rulescan.gov.in': {
    email: 'officer@rulescan.gov.in',
    password: 'officer123',
    user: { id: 'demo-officer-01', email: 'officer@rulescan.gov.in' },
    profile: { id: 'demo-officer-01', full_name: 'Insp. Rajesh Kumar', role: 'EMPLOYEE', badge_no: 'DL-OFF-01' },
    role: 'EMPLOYEE',
  },
  'admin@rulescan.gov.in': {
    email: 'admin@rulescan.gov.in',
    password: 'admin123',
    user: { id: 'demo-admin-01', email: 'admin@rulescan.gov.in' },
    profile: { id: 'demo-admin-01', full_name: 'Director Vikram Malhotra', role: 'ADMIN' },
    role: 'ADMIN',
  },
};

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [role, setRole] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchProfile = useCallback(async (userId) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Error fetching profile:', error);
        return null;
      }
      setProfile(data);
      setRole(data?.role || 'USER');
      return data;
    } catch (err) {
      console.error('Profile fetch error:', err);
      return null;
    }
  }, []);

  useEffect(() => {
    // Get initial session (first check local demo session, then Supabase)
    const getSession = async () => {
      try {
        if (typeof window !== 'undefined') {
          const stored = localStorage.getItem('rulescan_auth_session');
          if (stored) {
            const parsed = JSON.parse(stored);
            setUser(parsed.user);
            setProfile(parsed.profile);
            setRole(parsed.role);
            setLoading(false);
            return;
          }
        }
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          setUser(session.user);
          await fetchProfile(session.user.id);
        }
      } catch (err) {
        console.error('Session error:', err);
      } finally {
        setLoading(false);
      }
    };

    getSession();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (session?.user) {
          setUser(session.user);
          await fetchProfile(session.user.id);
        } else {
          if (typeof window !== 'undefined' && !localStorage.getItem('rulescan_auth_session')) {
            setUser(null);
            setProfile(null);
            setRole(null);
          }
        }
        setLoading(false);
      }
    );

    return () => subscription.unsubscribe();
  }, [fetchProfile]);

  const signUp = async (email, password, fullName, selectedRole = 'USER') => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          role: selectedRole,
        },
      },
    });

    if (error) throw error;
    return data;
  };

  const signIn = async (email, password) => {
    const normalized = (email || '').trim().toLowerCase();
    const demo = DEMO_ACCOUNTS[normalized];

    // Check hardcoded demo accounts first
    if (demo) {
      if (password !== demo.password) {
        throw new Error(`Incorrect password for ${demo.role === 'ADMIN' ? 'Admin' : 'Officer'}. Demo password is: ${demo.password}`);
      }
      setUser(demo.user);
      setProfile(demo.profile);
      setRole(demo.role);

      if (typeof window !== 'undefined') {
        localStorage.setItem(
          'rulescan_auth_session',
          JSON.stringify({
            user: demo.user,
            profile: demo.profile,
            role: demo.role,
          })
        );
      }
      return { user: demo.user, profile: demo.profile, role: demo.role };
    }

    // Fall back to Supabase auth for other accounts
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    return data;
  };

  const signOut = async () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('rulescan_auth_session');
    }
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    setUser(null);
    setProfile(null);
    setRole(null);
  };

  const value = {
    user,
    profile,
    role,
    loading,
    signUp,
    signIn,
    signOut,
    isAdmin: role === 'ADMIN',
    isEmployee: role === 'EMPLOYEE',
    isUser: role === 'USER',
    isAuthenticated: !!user,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
