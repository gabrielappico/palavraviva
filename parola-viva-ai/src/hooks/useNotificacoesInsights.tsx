import { useInsightsIA } from './useInsightsIA';

export function useNotificacoesInsights() {
  const { countNovos } = useInsightsIA({ status: 'novo' });
  
  return {
    countNovos,
    temNovos: countNovos > 0,
  };
}
