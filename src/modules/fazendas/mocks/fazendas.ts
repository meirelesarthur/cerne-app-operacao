import type { Farm } from '../types'

/** Fazendas vinculadas ao usuário (multi-tenant, spec §3.5). */
export const FAZENDAS: Farm[] = [
  { id: 'f1', name: 'Fazenda São Pedro', city: 'Barretos', uf: 'SP' },
  { id: 'f2', name: 'Fazenda Santa Rita', city: 'Uberaba', uf: 'MG' },
  { id: 'f3', name: 'Fazenda Boa Vista', city: 'Rio Verde', uf: 'GO' },
  { id: 'f4', name: 'Fazenda Três Lagoas', city: 'Três Lagoas', uf: 'MS' },
  { id: 'f5', name: 'Fazenda Vale do Sol', city: 'Sorriso', uf: 'MT' },
]
