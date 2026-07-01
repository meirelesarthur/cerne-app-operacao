import type { Activity } from '../types'

/** Atividades recentes do rebanho/fazenda (spec §6.7). */
export const ATIVIDADES: Activity[] = [
  { id: 'a1', title: 'Pesagem do Lote 42', subtitle: 'São Pedro · 128 cabeças', status: 'concluida', time: 'há 12 min', kind: 'pesagem' },
  { id: 'a2', title: 'Entrada NF-e #4471', subtitle: 'Insumos · Agropecuária Vale', status: 'andamento', time: 'há 40 min', kind: 'nfe' },
  { id: 'a3', title: 'Venda de animais', subtitle: 'Frigorífico Central · 60 cab.', status: 'autorizada', time: 'há 2 h', kind: 'venda' },
  { id: 'a4', title: 'Arraçoamento Curral 7', subtitle: 'Dieta Engorda · 1.200 kg', status: 'concluida', time: 'há 3 h', kind: 'arracoamento' },
  { id: 'a5', title: 'Transferência de lote', subtitle: 'Lote 12 → Lote 19', status: 'atrasada', time: 'ontem', kind: 'evento' },
  { id: 'a6', title: 'Aplicação de insumo', subtitle: 'Talhão 3 · Herbicida', status: 'concluida', time: 'ontem', kind: 'insumo' },
  { id: 'a7', title: 'Nascimento registrado', subtitle: 'Matriz 208 · bezerro macho', status: 'concluida', time: '2 dias', kind: 'evento' },
  { id: 'a8', title: 'Pesagem do Lote 19', subtitle: 'Santa Rita · 96 cabeças', status: 'concluida', time: '2 dias', kind: 'pesagem' },
]
