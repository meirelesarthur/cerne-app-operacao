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

export type PropostaStatus = 'analise' | 'aprovada' | 'contratada'

export interface Proposta {
  id: string
  linha: string
  valor: string
  data: string
  status: PropostaStatus
}

/** Propostas de crédito em andamento ou concluídas do produtor. */
export const PROPOSTAS: Proposta[] = [
  { id: 'prop1', linha: 'Custeio Safra 25/26', valor: 'R$ 250.000,00', data: '28/06', status: 'analise' },
  { id: 'prop2', linha: 'Investimento — Máquinas', valor: 'R$ 180.000,00', data: '15/06', status: 'aprovada' },
  { id: 'prop3', linha: 'CPR Financeira', valor: 'R$ 96.500,00', data: '02/05', status: 'contratada' },
]
