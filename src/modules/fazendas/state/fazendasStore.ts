import { create } from 'zustand'
import type { Farm, FarmView, SyncItem } from '../types'
import { FAZENDAS } from '../mocks/fazendas'

/**
 * Store do módulo Fazendas (spec §7.3) — isolada do Shell.
 * Guarda a visão ativa (Gerencial/Campo), a fazenda ativa (tenant) e a fila de sync mockada.
 * Tudo em memória (sem localStorage).
 */
interface FazendasState {
  farms: Farm[]
  activeFarmId: string
  view: FarmView
  syncQueue: SyncItem[]
  setActiveFarm: (id: string) => void
  setView: (v: FarmView) => void
  enqueueSync: (item: SyncItem) => void
  clearSync: () => void
  activeFarm: () => Farm
}

export const useFazendasStore = create<FazendasState>((set, get) => ({
  farms: FAZENDAS,
  activeFarmId: FAZENDAS[0].id,
  view: 'gerencial',
  syncQueue: [],
  setActiveFarm: (id) => set({ activeFarmId: id }),
  setView: (v) => set({ view: v }),
  enqueueSync: (item) => set((s) => ({ syncQueue: [...s.syncQueue, item] })),
  clearSync: () => set({ syncQueue: [] }),
  activeFarm: () => get().farms.find((f) => f.id === get().activeFarmId) ?? get().farms[0],
}))
