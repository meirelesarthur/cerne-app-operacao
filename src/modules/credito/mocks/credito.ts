/**
 * Mocks do módulo Crédito. Determinísticos — sem Date.now/Math.random e sem
 * matemática financeira em runtime: os valores de parcela já vêm pré-computados
 * (tabela Price, ~1,3% a.m.) para consumo direto pela tela.
 */

/** Oferta de crédito pré-aprovado exibida no hero da Home do módulo. */
export const PRE_APROVADO = {
  valor: 'R$ 480.000,00',
  validade: 'até 30/09',
  taxa: 'a partir de 1,29% a.m.',
}

export interface SimulacaoOpcao {
  valor: string
  prazo: number
  parcela: string
}

/** Matriz pré-computada de simulação: 3 valores × 3 prazos (12/24/36 meses). */
export const SIMULACAO: SimulacaoOpcao[] = [
  { valor: 'R$ 100.000', prazo: 12, parcela: 'R$ 9.054,17' },
  { valor: 'R$ 100.000', prazo: 24, parcela: 'R$ 4.877,22' },
  { valor: 'R$ 100.000', prazo: 36, parcela: 'R$ 3.495,99' },
  { valor: 'R$ 250.000', prazo: 12, parcela: 'R$ 22.635,42' },
  { valor: 'R$ 250.000', prazo: 24, parcela: 'R$ 12.193,05' },
  { valor: 'R$ 250.000', prazo: 36, parcela: 'R$ 8.739,97' },
  { valor: 'R$ 480.000', prazo: 12, parcela: 'R$ 43.460,01' },
  { valor: 'R$ 480.000', prazo: 24, parcela: 'R$ 23.410,66' },
  { valor: 'R$ 480.000', prazo: 36, parcela: 'R$ 16.780,74' },
]

/** Valores disponíveis no simulador (colunas da matriz `SIMULACAO`). */
export const VALORES_SIMULACAO = ['R$ 100.000', 'R$ 250.000', 'R$ 480.000'] as const

/** Prazos disponíveis no simulador, em meses (linhas da matriz `SIMULACAO`). */
export const PRAZOS_SIMULACAO = [12, 24, 36] as const

export interface LinhaCredito {
  id: string
  nome: string
  taxa: string
  descricao: string
}

/** Linhas de crédito ofertadas ao produtor. */
export const LINHAS: LinhaCredito[] = [
  {
    id: 'custeio-safra',
    nome: 'Custeio Safra 25/26',
    taxa: '1,29% a.m.',
    descricao: 'Capital de giro para insumos, sementes e defensivos do ciclo atual.',
  },
  {
    id: 'investimento-maquinas',
    nome: 'Investimento — Máquinas',
    taxa: '1,45% a.m.',
    descricao: 'Aquisição de tratores, colheitadeiras e implementos agrícolas.',
  },
  {
    id: 'cpr-financeira',
    nome: 'CPR Financeira',
    taxa: '1,19% a.m.',
    descricao: 'Antecipação de recebíveis com lastro em Cédula de Produto Rural.',
  },
  {
    id: 'consorcio-agro',
    nome: 'Consórcio Agro',
    taxa: 'taxa adm 0,12% a.m.',
    descricao: 'Planejamento de longo prazo para máquinas e equipamentos sem juros.',
  },
]

export type PropostaStatus = 'analise' | 'aprovada' | 'recusada' | 'contratada'

/** Documento exigido para análise da proposta. */
export interface DocumentoProposta {
  nome: string
  enviado: boolean
}

/** Datas das etapas percorridas pela proposta — alimenta a timeline do detalhe. */
export interface HistoricoProposta {
  enviada: string
  analise?: string
  decisao?: string
  contratada?: string
}

export interface Proposta {
  id: string
  linha: string
  valor: string
  data: string
  status: PropostaStatus
  prazo: number
  taxa: string
  historico: HistoricoProposta
  documentos: DocumentoProposta[]
}

/** Propostas de crédito em andamento ou concluídas do produtor. */
export const PROPOSTAS: Proposta[] = [
  {
    id: 'prop1',
    linha: 'Custeio Safra 25/26',
    valor: 'R$ 250.000,00',
    data: '28/06',
    status: 'analise',
    prazo: 12,
    taxa: '1,29% a.m.',
    historico: { enviada: '28/06', analise: '29/06' },
    documentos: [
      { nome: 'CPF/CNPJ', enviado: true },
      { nome: 'Comprovante de renda', enviado: true },
      { nome: 'Matrícula do imóvel rural', enviado: false },
    ],
  },
  {
    id: 'prop2',
    linha: 'Investimento — Máquinas',
    valor: 'R$ 180.000,00',
    data: '15/06',
    status: 'aprovada',
    prazo: 24,
    taxa: '1,45% a.m.',
    historico: { enviada: '15/06', analise: '17/06', decisao: '20/06' },
    documentos: [
      { nome: 'CPF/CNPJ', enviado: true },
      { nome: 'Comprovante de renda', enviado: true },
      { nome: 'Nota fiscal proforma', enviado: true },
    ],
  },
  {
    id: 'prop3',
    linha: 'CPR Financeira',
    valor: 'R$ 96.500,00',
    data: '02/05',
    status: 'contratada',
    prazo: 24,
    taxa: '1,19% a.m.',
    historico: { enviada: '02/05', analise: '04/05', decisao: '08/05', contratada: '12/05' },
    documentos: [
      { nome: 'CPF/CNPJ', enviado: true },
      { nome: 'CPR assinada', enviado: true },
      { nome: 'Comprovante de safra', enviado: true },
    ],
  },
  {
    id: 'prop4',
    linha: 'Consórcio Agro',
    valor: 'R$ 120.000,00',
    data: '10/04',
    status: 'recusada',
    prazo: 36,
    taxa: 'taxa adm 0,12% a.m.',
    historico: { enviada: '10/04', analise: '12/04', decisao: '18/04' },
    documentos: [
      { nome: 'CPF/CNPJ', enviado: true },
      { nome: 'Comprovante de renda', enviado: false },
    ],
  },
]

/** Contrato de crédito ativo — origem de uma proposta contratada. */
export interface Contrato {
  id: string
  linha: string
  valor: string
  parcelasPagas: number
  parcelasTotal: number
  proximaParcela: string
  vencimento: string
  saldoDevedor: string
}

/** Contratos ativos do produtor (parcelas pré-computadas — ver nota acima). */
export const CONTRATOS: Contrato[] = [
  {
    id: 'contrato1',
    linha: 'CPR Financeira',
    valor: 'R$ 96.500,00',
    parcelasPagas: 8,
    parcelasTotal: 24,
    proximaParcela: 'R$ 4.520,33',
    vencimento: '05/08',
    saldoDevedor: 'R$ 68.220,17',
  },
  {
    id: 'contrato2',
    linha: 'Custeio Safra 24/25',
    valor: 'R$ 150.000,00',
    parcelasPagas: 11,
    parcelasTotal: 12,
    proximaParcela: 'R$ 13.187,50',
    vencimento: '20/07',
    saldoDevedor: 'R$ 13.187,50',
  },
]
