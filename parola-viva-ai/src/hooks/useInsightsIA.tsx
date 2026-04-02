import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { sharedSupabase } from '@/integrations/supabase/shared-client';
import { useSharedAuth } from './useSharedAuth';
import { useEffect } from 'react';

interface Insight {
  id: string;
  user_id: string;
  tipo: 'recomendacao' | 'alerta' | 'previsao' | 'chat' | 'dashboard';
  conteudo: string;
  dados_fonte: any;
  relevancia_score: number;
  tags: string[];
  status: 'novo' | 'lido' | 'aplicado' | 'descartado' | 'arquivado';
  valido_ate: string | null;
  aplicacao_origem: string;
  created_at: string;
  updated_at: string;
}

interface UseInsightsOptions {
  tipo?: string;
  status?: string;
  minRelevancia?: number;
  limite?: number;
}

export function useInsightsIA(options: UseInsightsOptions = {}) {
  const { user } = useSharedAuth();
  const queryClient = useQueryClient();

  const { data: insights, isLoading } = useQuery({
    queryKey: ['insights-ia', user?.id, options],
    queryFn: async () => {
      if (!user) return [];

      let query = sharedSupabase
        .from('insights_ia')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (options.tipo) query = query.eq('tipo', options.tipo);
      if (options.status) query = query.eq('status', options.status);
      if (options.minRelevancia) query = query.gte('relevancia_score', options.minRelevancia);
      if (options.limite) query = query.limit(options.limite);

      const { data, error } = await query;
      if (error) throw error;
      return data as Insight[];
    },
    enabled: !!user,
  });

  // Realtime subscription para insights
  useEffect(() => {
    if (!user) return;

    const channel = sharedSupabase
      .channel('insights-changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'insights_ia',
        filter: `user_id=eq.${user.id}`,
      }, () => {
        queryClient.invalidateQueries({ queryKey: ['insights-ia'] });
      })
      .subscribe();

    return () => {
      sharedSupabase.removeChannel(channel);
    };
  }, [user, queryClient]);

  const marcarComoLido = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await sharedSupabase
        .from('insights_ia')
        .update({ status: 'lido' })
        .eq('id', id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['insights-ia'] });
    },
  });

  const countNovos = insights?.filter(i => i.status === 'novo').length || 0;

  return {
    insights,
    isLoading,
    countNovos,
    marcarComoLido: marcarComoLido.mutate,
  };
}
