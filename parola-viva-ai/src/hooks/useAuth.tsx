import { useSharedAuth } from "./useSharedAuth";

/**
 * Wrapper de compatibilidade - usa useSharedAuth internamente
 * @deprecated Use useSharedAuth diretamente para novas implementações
 */
export const useAuth = () => {
  return useSharedAuth();
};
