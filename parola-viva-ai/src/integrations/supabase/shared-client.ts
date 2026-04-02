/**
 * Cliente Supabase compartilhado para SSO e Insights cross-platform
 * Projeto: dzrcgkzzwuxcinncjaba
 */
import { createClient } from '@supabase/supabase-js';

const SHARED_SUPABASE_URL = 'https://dzrcgkzzwuxcinncjaba.supabase.co';
const SHARED_SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cmNna3p6d3V4Y2lubmNqYWJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxMDAzODMsImV4cCI6MjA3NzY3NjM4M30.w75DZ6bpti6VNVbxGAWpPqoG8rlO4evlx1Aa2Mo3A_Q';

if (!SHARED_SUPABASE_URL || !SHARED_SUPABASE_ANON_KEY) {
  throw new Error('Configuração do Supabase compartilhado incompleta.');
}

// Cliente para SSO e Insights compartilhados
export const sharedSupabase = createClient(SHARED_SUPABASE_URL, SHARED_SUPABASE_ANON_KEY, {
  auth: {
    storage: localStorage,
    persistSession: true,
    autoRefreshToken: true,
    storageKey: 'shared-supabase-auth-token',
  }
});
