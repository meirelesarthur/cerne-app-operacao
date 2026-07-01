/**
 * Dados mockados dos dashboards administrativos (spec §4).
 * Mín. 6–10 registros por lista e ≥1 caso de cada estado de badge (spec §7.5).
 */

/* ---- Financeiro (§4.3) ---- */
// NOTA DE MIGRAÇÃO (spec §4.3): no legado o agrupador financeiro é fixo (grouper_id = 7),
// hardcoded. O time de backend deve tratar isso na migração — não é regra de negócio real.
export const GROUPER_ID_FIXO = 7

export const FINANCEIRO = {
  kpis: { aReceber: 'R$ 1,82 mi', aPagar: 'R$ 940 mil', atrasados: 'R$ 128 mil', investimentos: 'R$ 350 mil' },
  centrosCusto: [
    { label: 'Nutrição', value: 420 },
    { label: 'Sanidade', value: 180 },
    { label: 'Mão de obra', value: 260 },
    { label: 'Manutenção', value: 130 },
    { label: 'Administrativo', value: 90 },
    { label: 'Logística', value: 150 },
  ],
}

/* ---- Pecuária de Corte (§4.1) ---- */
export const PECUARIA = {
  financeiro: [
    { label: 'Receita', value: 'R$ 2,4 mi', delta: 12, spark: [8, 10, 9, 12, 14, 13, 16] },
    { label: 'Custo', value: 'R$ 1,1 mi', delta: -4, spark: [9, 8, 8, 7, 6, 7, 6] },
    { label: 'Margem', value: 'R$ 1,3 mi', delta: 9, spark: [4, 6, 5, 7, 8, 9, 11] },
  ],
}

/* ---- Lotação de Currais / Confinamento (§4.2) ---- */
export interface Curral {
  id: string
  nome: string
  setor: string
  atual: number
  max: number
}
export const CURRAIS: Curral[] = [
  { id: 'c1', nome: 'Curral 01', setor: 'Setor A', atual: 78, max: 100 },
  { id: 'c2', nome: 'Curral 02', setor: 'Setor A', atual: 95, max: 100 },
  { id: 'c3', nome: 'Curral 03', setor: 'Setor B', atual: 100, max: 100 },
  { id: 'c4', nome: 'Curral 04', setor: 'Setor B', atual: 42, max: 100 },
  { id: 'c5', nome: 'Curral 05', setor: 'Setor C', atual: 88, max: 100 },
  { id: 'c6', nome: 'Curral 06', setor: 'Setor C', atual: 60, max: 100 },
  { id: 'c7', nome: 'Curral 07', setor: 'Setor D', atual: 110, max: 100 },
  { id: 'c8', nome: 'Curral 08', setor: 'Setor D', atual: 25, max: 100 },
]

/* ---- Ativos / Depreciação (§4.5) ---- */
export interface Ativo {
  id: string
  nome: string
  categoria: string
  aquisicao: string
  depreciado: number
  proximaManutencao: string
}
export const ATIVOS: Ativo[] = [
  { id: 'at1', nome: 'Trator John Deere 6110', categoria: 'Máquinas', aquisicao: 'R$ 380 mil', depreciado: 45, proximaManutencao: '15/07' },
  { id: 'at2', nome: 'Colheitadeira CR7', categoria: 'Máquinas', aquisicao: 'R$ 620 mil', depreciado: 30, proximaManutencao: '02/08' },
  { id: 'at3', nome: 'Caminhão Boiadeiro', categoria: 'Veículos', aquisicao: 'R$ 240 mil', depreciado: 68, proximaManutencao: '20/07' },
  { id: 'at4', nome: 'Balança de Curral', categoria: 'Equipamentos', aquisicao: 'R$ 45 mil', depreciado: 20, proximaManutencao: '10/09' },
  { id: 'at5', nome: 'Pivô de Irrigação', categoria: 'Infraestrutura', aquisicao: 'R$ 310 mil', depreciado: 55, proximaManutencao: '28/08' },
  { id: 'at6', nome: 'Pulverizador Autopropelido', categoria: 'Máquinas', aquisicao: 'R$ 290 mil', depreciado: 38, proximaManutencao: '05/08' },
]
export const ATIVOS_RESUMO = { total: 'R$ 1,88 mi', depreciacao: 'R$ 720 mil', liquido: 'R$ 1,16 mi' }

/* ---- Suprimentos (§4.4) — status PARCIAL: usar selo "Dados de exemplo" ---- */
export type CotacaoStatus = 'cotacao' | 'aprovada' | 'recusada'
export interface Cotacao {
  id: string
  fornecedor: string
  tipo: 'Produto' | 'Serviço' | 'Frete' | 'Manutenção'
  total: string
  itens: number
  status: CotacaoStatus
}
export const COTACOES: Cotacao[] = [
  { id: 'q1', fornecedor: 'Agropecuária Vale', tipo: 'Produto', total: 'R$ 48.900', itens: 12, status: 'aprovada' },
  { id: 'q2', fornecedor: 'Nutrição Total', tipo: 'Produto', total: 'R$ 132.400', itens: 8, status: 'cotacao' },
  { id: 'q3', fornecedor: 'TransBoi Logística', tipo: 'Frete', total: 'R$ 22.100', itens: 3, status: 'cotacao' },
  { id: 'q4', fornecedor: 'MecAgro Serviços', tipo: 'Manutenção', total: 'R$ 15.700', itens: 5, status: 'recusada' },
  { id: 'q5', fornecedor: 'Veterinária Campo', tipo: 'Serviço', total: 'R$ 9.300', itens: 4, status: 'aprovada' },
  { id: 'q6', fornecedor: 'Sementes Sul', tipo: 'Produto', total: 'R$ 61.200', itens: 15, status: 'cotacao' },
]

/* ---- Análise de Uso (§4.6) ---- */
export interface FazendaAtividade {
  id: string
  nome: string
  online: number
  usuarios: { nome: string; ultimoAcesso: string; ativo: boolean }[]
}
export const USO_FAZENDAS: FazendaAtividade[] = [
  {
    id: 'f1',
    nome: 'Fazenda São Pedro',
    online: 3,
    usuarios: [
      { nome: 'João Silva', ultimoAcesso: 'há 2 min', ativo: true },
      { nome: 'Maria Souza', ultimoAcesso: 'há 4 min', ativo: true },
      { nome: 'Pedro Alves', ultimoAcesso: 'há 1 min', ativo: true },
      { nome: 'Ana Lima', ultimoAcesso: 'há 3 h', ativo: false },
    ],
  },
  {
    id: 'f2',
    nome: 'Fazenda Santa Rita',
    online: 1,
    usuarios: [
      { nome: 'Carlos Dias', ultimoAcesso: 'há 30 s', ativo: true },
      { nome: 'Rita Nunes', ultimoAcesso: 'ontem', ativo: false },
    ],
  },
  {
    id: 'f3',
    nome: 'Fazenda Boa Vista',
    online: 0,
    usuarios: [{ nome: 'Luís Prado', ultimoAcesso: 'há 2 dias', ativo: false }],
  },
]

/* ---- Consultas Gerenciais (§4.7) — read-only ---- */
export const LOTES = [
  { id: 'l1', nome: 'Lote 42', cabecas: 128, peso: '18.240 kg', local: 'Curral 02' },
  { id: 'l2', nome: 'Lote 19', cabecas: 96, peso: '13.100 kg', local: 'Curral 05' },
  { id: 'l3', nome: 'Lote 07', cabecas: 150, peso: '22.500 kg', local: 'Piquete 3' },
  { id: 'l4', nome: 'Lote 33', cabecas: 64, peso: '9.800 kg', local: 'Curral 01' },
]
export const ESTOQUE = [
  { id: 'e1', produto: 'Ração Engorda', deposito: 'Armazém A', qtd: '12.400 kg' },
  { id: 'e2', produto: 'Sal Mineral', deposito: 'Armazém A', qtd: '3.200 kg' },
  { id: 'e3', produto: 'Vacina Aftosa', deposito: 'Farmácia', qtd: '540 doses' },
  { id: 'e4', produto: 'Herbicida', deposito: 'Depósito B', qtd: '180 L' },
]
export const PESAGENS_DIA = [
  { id: 'p1', lote: 'Lote 42', hora: '07:12', peso: '142 kg/cab', cabecas: 128 },
  { id: 'p2', lote: 'Lote 19', hora: '08:03', peso: '136 kg/cab', cabecas: 96 },
  { id: 'p3', lote: 'Lote 07', hora: '09:20', peso: '150 kg/cab', cabecas: 150 },
]
