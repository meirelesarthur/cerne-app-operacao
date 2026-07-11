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
  /** Endereço mock exibido no detalhe da unidade. */
  endereco: string
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
    endereco: 'Rod. BR-153, km 42 — Rio Verde/GO',
  },
  {
    id: 'un-2',
    nome: 'Silo 02 — Milho',
    produto: 'Milho em grão',
    capacidade: '12.000 t',
    ocupacaoPct: 95,
    status: 'atencao',
    endereco: 'Rod. BR-153, km 43 — Rio Verde/GO',
  },
  {
    id: 'un-3',
    nome: 'Galpão de insumos',
    produto: 'Fertilizantes e defensivos',
    capacidade: '3.500 t',
    ocupacaoPct: 58,
    status: 'ok',
    endereco: 'Av. dos Agricultores, 1200 — Rio Verde/GO',
  },
  {
    id: 'un-4',
    nome: 'Câmara fria — Vacinas',
    produto: 'Imunobiológicos',
    capacidade: '2.400 doses',
    ocupacaoPct: 31,
    status: 'critico',
    endereco: 'Rua das Indústrias, 88 — Rio Verde/GO',
  },
]

export interface ItemEstoque {
  id: string
  unidadeId: string
  produto: string
  quantidadeLabel: string
  capacidadeLabel: string
  ocupacaoPct: number
  status: UnidadeStatus
}

/**
 * Itens armazenados por unidade — granularidade abaixo do agregado de
 * `UNIDADES`, usada na aba Estoque (spec D2.1).
 */
export const ITENS_ESTOQUE: ItemEstoque[] = [
  {
    id: 'it-1',
    unidadeId: 'un-1',
    produto: 'Soja em grão',
    quantidadeLabel: '10.080 t',
    capacidadeLabel: '12.000 t',
    ocupacaoPct: 84,
    status: 'ok',
  },
  {
    id: 'it-2',
    unidadeId: 'un-2',
    produto: 'Milho em grão',
    quantidadeLabel: '11.400 t',
    capacidadeLabel: '12.000 t',
    ocupacaoPct: 95,
    status: 'atencao',
  },
  {
    id: 'it-3',
    unidadeId: 'un-3',
    produto: 'Fertilizante NPK',
    quantidadeLabel: '900 t',
    capacidadeLabel: '1.500 t',
    ocupacaoPct: 60,
    status: 'ok',
  },
  {
    id: 'it-4',
    unidadeId: 'un-3',
    produto: 'Defensivos agrícolas',
    quantidadeLabel: '380 t',
    capacidadeLabel: '800 t',
    ocupacaoPct: 48,
    status: 'ok',
  },
  {
    id: 'it-5',
    unidadeId: 'un-3',
    produto: 'Ração bovina',
    quantidadeLabel: '750 t',
    capacidadeLabel: '1.200 t',
    ocupacaoPct: 63,
    status: 'ok',
  },
  {
    id: 'it-6',
    unidadeId: 'un-4',
    produto: 'Vacina febre aftosa',
    quantidadeLabel: '340 doses',
    capacidadeLabel: '1.400 doses',
    ocupacaoPct: 24,
    status: 'critico',
  },
  {
    id: 'it-7',
    unidadeId: 'un-4',
    produto: 'Vacina brucelose',
    quantidadeLabel: '404 doses',
    capacidadeLabel: '1.000 doses',
    ocupacaoPct: 40,
    status: 'atencao',
  },
]

export type MovimentacaoTipo = 'entrada' | 'saida'

export interface Movimentacao {
  id: string
  tipo: MovimentacaoTipo
  item: string
  /** magnitude formatada, sem sinal (ex.: "120 t") — sinal e cor derivam da direção (Lei 3, nunca só cor). */
  quantidade: string
  unidadeId: string
  origem: string
  destino: string
  tempo: string
  nota: string
  responsavel: string
  veiculo: string
}

/** Últimas movimentações de entrada e saída registradas no armazém. */
export const MOVIMENTACOES: Movimentacao[] = [
  {
    id: 'mov-1',
    tipo: 'entrada',
    item: 'Soja em grão',
    quantidade: '120 t',
    unidadeId: 'un-1',
    origem: 'NF-e 4821 · Cooperativa Agrovale',
    destino: 'Silo 01 — Soja',
    tempo: 'hoje, 07:40',
    nota: 'Recebimento de safra 24/25, lote conferido na balança rodoviária.',
    responsavel: 'Carlos Andrade',
    veiculo: 'Carreta bitrem · ABC-1234',
  },
  {
    id: 'mov-2',
    tipo: 'saida',
    item: 'Ração bovina',
    quantidade: '48 sacas',
    unidadeId: 'un-3',
    origem: 'Galpão de insumos',
    destino: 'Fazenda Santa Rita',
    tempo: 'hoje, 06:55',
    nota: 'Reposição programada de arraçoamento do confinamento.',
    responsavel: 'Marina Souza',
    veiculo: 'Caminhão toco · DEF-5678',
  },
  {
    id: 'mov-3',
    tipo: 'entrada',
    item: 'Fertilizante NPK',
    quantidade: '8 t',
    unidadeId: 'un-3',
    origem: 'NF-e 4795 · Fornecedor Agrovale',
    destino: 'Galpão de insumos',
    tempo: 'ontem, 17:20',
    nota: 'Compra via Marketplace, entrega parcial da NF-e 4795.',
    responsavel: 'Carlos Andrade',
    veiculo: 'Caminhão baú · GHI-9012',
  },
  {
    id: 'mov-4',
    tipo: 'saida',
    item: 'Vacina febre aftosa',
    quantidade: '320 doses',
    unidadeId: 'un-4',
    origem: 'Câmara fria — Vacinas',
    destino: 'Fazenda Boa Vista',
    tempo: 'ontem, 14:05',
    nota: 'Aplicação em lote programada pelo calendário sanitário.',
    responsavel: 'Dra. Renata Lima',
    veiculo: 'Utilitário refrigerado · JKL-3456',
  },
  {
    id: 'mov-5',
    tipo: 'saida',
    item: 'Milho em grão',
    quantidade: '65 t',
    unidadeId: 'un-2',
    origem: 'Silo 02 — Milho',
    destino: 'Venda · Cliente 1182',
    tempo: 'ontem, 09:30',
    nota: 'Venda spot liquidada, escoamento por carreta graneleira.',
    responsavel: 'Paulo Ribeiro',
    veiculo: 'Carreta graneleira · MNO-7890',
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

export interface Relatorio {
  id: string
  nome: string
  periodo: string
  disponivel: boolean
}

/** Relatórios mockados da aba "Relatórios" (spec D2.5). */
export const RELATORIOS: Relatorio[] = [
  { id: 'rel-1', nome: 'Ocupação por unidade', periodo: 'Julho/2026', disponivel: true },
  { id: 'rel-2', nome: 'Movimentações consolidadas', periodo: '2º trimestre 2026', disponivel: true },
  { id: 'rel-3', nome: 'Perdas e quebras de estoque', periodo: 'Junho/2026', disponivel: false },
]
