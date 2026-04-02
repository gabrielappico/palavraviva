import { createContext, useContext, useEffect, useState } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { sharedSupabase } from '@/integrations/supabase/shared-client';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

interface SharedAuthContextType {
  user: User | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<{ error: any }>;
  signUp: (email: string, password: string, fullName: string) => Promise<{ error: any }>;
  signOut: () => Promise<void>;
  signInWithGoogle: () => Promise<{ error: any }>;
}

const SharedAuthContext = createContext<SharedAuthContextType>({
  user: null,
  session: null,
  loading: true,
  signIn: async () => ({ error: null }),
  signUp: async () => ({ error: null }),
  signOut: async () => {},
  signInWithGoogle: async () => ({ error: null }),
});

export const useSharedAuth = () => {
  const context = useContext(SharedAuthContext);
  if (!context) throw new Error('useSharedAuth must be used within SharedAuthProvider');
  return context;
};

export const SharedAuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  // Sincroniza perfil entre os dois projetos Supabase
  const syncProfile = async (userId: string, email: string, fullName?: string) => {
    try {
      // Sincroniza no projeto compartilhado (SSO)
      const { error: sharedError } = await sharedSupabase
        .from('profiles')
        .upsert({
          id: userId,
          email,
          full_name: fullName || '',
          updated_at: new Date().toISOString(),
        });

      if (sharedError) console.error('Erro ao sincronizar perfil compartilhado:', sharedError);

      // Sincroniza no projeto local
      const { error: localError } = await supabase
        .from('profiles')
        .upsert({
          id: userId,
          email,
          full_name: fullName || '',
          updated_at: new Date().toISOString(),
        });

      if (localError) console.error('Erro ao sincronizar perfil local:', localError);
    } catch (error) {
      console.error('Erro na sincronização de perfis:', error);
    }
  };

  useEffect(() => {
    // Listener de mudanças de autenticação no projeto compartilhado
    const { data: { subscription } } = sharedSupabase.auth.onAuthStateChange(
      async (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        setLoading(false);

        // Sincroniza perfil quando usuário faz login
        if (session?.user) {
          setTimeout(() => {
            syncProfile(
              session.user.id,
              session.user.email || '',
              session.user.user_metadata?.full_name
            );
          }, 0);
        }
      }
    );

    // Verifica sessão existente
    sharedSupabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);

      if (session?.user) {
        syncProfile(
          session.user.id,
          session.user.email || '',
          session.user.user_metadata?.full_name
        );
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      const { error } = await sharedSupabase.auth.signInWithPassword({
        email,
        password,
      });
      
      if (error) {
        toast.error(error.message);
        return { error };
      }

      toast.success('Login realizado com sucesso!');
      return { error: null };
    } catch (error: any) {
      toast.error(error.message);
      return { error };
    }
  };

  const signUp = async (email: string, password: string, fullName: string) => {
    try {
      const { error } = await sharedSupabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/dashboard`,
          data: {
            full_name: fullName,
          },
        },
      });
      
      if (error) {
        toast.error(error.message);
        return { error };
      }

      toast.success('Conta criada com sucesso!');
      return { error: null };
    } catch (error: any) {
      toast.error(error.message);
      return { error };
    }
  };

  const signOut = async () => {
    try {
      await sharedSupabase.auth.signOut();
      toast.success('Logout realizado com sucesso!');
    } catch (error: any) {
      toast.error(error.message);
    }
  };

  const signInWithGoogle = async () => {
    try {
      const { error } = await sharedSupabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/dashboard`,
        },
      });
      
      if (error) {
        toast.error(error.message);
        return { error };
      }

      return { error: null };
    } catch (error: any) {
      toast.error(error.message);
      return { error };
    }
  };

  return (
    <SharedAuthContext.Provider value={{ user, session, loading, signIn, signUp, signOut, signInWithGoogle }}>
      {children}
    </SharedAuthContext.Provider>
  );
};
