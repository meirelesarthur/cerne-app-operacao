/** Mocks determinísticos da visão de Estoque do módulo Armazém. */

/** KPIs de topo da home do Armazém. */
export const KPIS = {
  ocupacao: '72%',
  ocupacaoPct: 72,
  skus: '148',
  alertas: '3',
}

export type UnidadeStatus = 'ok' | 'atencao' | 'critico'

export interface Unidade {
  id: string
  nome: string
  produto: string
  capacidade: string
  ocupacaoPct: number
  status: UnidadeStatus
}

/** Unidades de armazenagem (silos, galpões, câmaras) com nível de ocupação. */
export const UNIDADES: Unidade[] = [
  {
    id: 'un-1',
    nome: 'Silo 01 — Soja',
    produto: 'Soja em grão',
    capacidade: '12.000 t',
    ocupacaoPct: 84,
    status: 'ok',
  },
  {
    id: 'un-2',
    nome: 'Silo 02 — Milho',
    produto: 'Milho em grão',
    capacidade: '12.000 t',
    ocupacaoPct: 95,
    status: 'atencao',
  },
  {
    id: 'un-3',
    nome: 'Galpão de insumos',
    produto: 'Fertilizantes e defensivos',
    capacidade: '3.500 t',
    ocupacaoPct: 58,
    status: 'ok',
  },
  {
    id: 'un-4',
    nome: 'Câmara fria — Vacinas',
    produto: 'Imunobiológicos',
    capacidade: '2.400 doses',
    ocupacaoPct: 31,
    status: 'critico',
  },
]

export type MovimentacaoTipo = 'entrada' | 'saida'

export interface Movimentacao {
  id: string
  tipo: MovimentacaoTipo
  item: string
  quantidade: string
  origem: string
  tempo: string
}

/** Últimas movimentações de entrada e saída registradas no armazém. */
export const MOVIMENTACOES: Movimentacao[] = [
  {
    id: 'mov-1',
    tipo: 'entrada',
    item: 'Soja em grão',
    quantidade: '+120 t',
    origem: 'NF-e 4821 · Cooperativa',
    tempo: 'hoje, 07:40',
  },
  {
    id: 'mov-2',
    tipo: 'saida',
    item: 'Ração bovina',
    quantidade: '−48 sacas',
    origem: 'Fazenda Santa Rita',
    tempo: 'hoje, 06:55',
  },
  {
    id: 'mov-3',
    tipo: 'entrada',
    item: 'Fertilizante NPK',
    quantidade: '+8 t',
    origem: 'NF-e 4795 · Fornecedor Agrovale',
    tempo: 'ontem, 17:20',
  },
  {
    id: 'mov-4',
    tipo: 'saida',
    item: 'Vacina febre aftosa',
    quantidade: '−320 doses',
    origem: 'Fazenda Boa Vista',
    tempo: 'ontem, 14:05',
  },
  {
    id: 'mov-5',
    tipo: 'saida',
    item: 'Milho em grão',
    quantidade: '−65 t',
    origem: 'Venda · Cliente 1182',
    tempo: 'ontem, 09:30',
  },
]

export interface Alerta {
  id: string
  titulo: string
  detalhe: string
}

/** Alertas ativos que exigem ação no armazém. */
export const ALERTAS: Alerta[] = [
  {
    id: 'al-1',
    titulo: 'Vacina febre aftosa abaixo do mínimo',
    detalhe: 'Estoque atual cobre menos de 5 dias de aplicação prevista.',
  },
  {
    id: 'al-2',
    titulo: 'Silo 02 acima de 90% da capacidade',
    detalhe: 'Avaliar escoamento antes da próxima colheita de milho.',
  },
]
