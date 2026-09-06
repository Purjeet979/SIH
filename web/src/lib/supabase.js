import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://ganoupqtsujbtrikhiia.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhbm91cHF0c3VqYnRyaWtoaWlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MjQyMDQsImV4cCI6MjEwNDIwMDIwNH0.tySQFHOj3VMOcEAU469yca_5nYNok0286yYmnC1j6aY';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
