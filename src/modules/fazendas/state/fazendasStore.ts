import { create } from 'zustand'
import type { Farm, SyncItem } from '../types'
import { FAZENDAS } from '../mocks/fazendas'

/**
 * Store do módulo Fazendas (spec §7.3) — isolada do Shell.
 * Guarda a fazenda ativa (tenant) e a fila de sincronização mockada.
 * Tudo em memória (sem localStorage).
 */
interface FazendasState {
  farms: Farm[]
  activeFarmId: string
  syncQueue: SyncItem[]
  /** pesagem do dia registrada? Pré-requisito da transferência de lote (spec §5.1/§5.2/DUV-179). */
  pesagemDoDiaFeita: boolean
  setActiveFarm: (id: string) => void
  enqueueSync: (item: SyncItem) => void
  clearSync: () => void
  registrarPesagemDoDia: () => void
  activeFarm: () => Farm
}

export const useFazendasStore = create<FazendasState>((set, get) => ({
  farms: FAZENDAS,
  activeFarmId: FAZENDAS[0].id,
  syncQueue: [],
  pesagemDoDiaFeita: false,
  setActiveFarm: (id) => set({ activeFarmId: id }),
  enqueueSync: (item) => set((s) => ({ syncQueue: [...s.syncQueue, item] })),
  clearSync: () => set({ syncQueue: [] }),
  registrarPesagemDoDia: () => set({ pesagemDoDiaFeita: true }),
  activeFarm: () => get().farms.find((f) => f.id === get().activeFarmId) ?? get().farms[0],
}))
