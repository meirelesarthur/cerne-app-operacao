import { useEffect, useState } from 'react'

export type LoadState = 'loading' | 'ready'

/**
 * Simula um carregamento assíncrono (spec §7.1) para demonstrar o skeleton nas telas de dado.
 * Sem rede real; apenas um atraso curto ao montar. Não usa Date.now (compat. com o ambiente).
 */
export function useSimulatedLoad(ms = 600): LoadState {
  const [state, setState] = useState<LoadState>('loading')
  useEffect(() => {
    const id = setTimeout(() => setState('ready'), ms)
    return () => clearTimeout(id)
  }, [ms])
  return state
}
