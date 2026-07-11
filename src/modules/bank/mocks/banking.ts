import type { TransactionItem } from '@/components/ui'

/**
 * Mocks do Banking exibidos no hub (New-UI). Determinísticos — sem Date.now.
 * Em produção, viriam do BFF do módulo Bank via contrato de "widget de hub".
 */

export const SALDO = {
  valor: 'R$ 128.450,32',
  conta: 'Conta GB Bank · Ag 0001 · CC 48213-7',
}

export const RESUMO_MES = {
  entradas: 'R$ 342.800,00',
  saidas: 'R$ 214.349,68',
}

export const CREDITO_PREAPROVADO = {
  valor: 'R$ 480.000,00',
  condicao: 'Custeio safra 25/26 · a partir de 1,29% a.m.',
}

export const CARTAO = {
  final: '4821',
  titular: 'ARTHUR M',
  bandeira: 'Mastercard',
  tipo: 'GB Corp · Crédito',
  validade: '08/29',
  limiteUsado: 'R$ 53.500,00',
  limiteDisponivel: 'R$ 96.500,00',
  limiteTotal: 'R$ 150.000,00',
  usoPct: 36,
}

/** Faixas de limite exibidas em Bank › Limites (mock determinístico). */
export const FAIXAS_LIMITE = [
  { id: 'credito', label: 'Limite de crédito', usadoPct: 36, usado: 'R$ 53.500,00', total: 'R$ 150.000,00' },
  { id: 'pixDia', label: 'Pix por transação (diurno)', usadoPct: 25, usado: 'R$ 12.380,00', total: 'R$ 50.000,00' },
  { id: 'pixNoite', label: 'Pix por transação (noturno)', usadoPct: 0, usado: 'R$ 0,00', total: 'R$ 1.000,00' },
  { id: 'saque', label: 'Saque diário', usadoPct: 12, usado: 'R$ 240,00', total: 'R$ 2.000,00' },
]

/** Conta de origem para os fluxos de pagamento (Pix, transferência). */
export const CONTA_ORIGEM = {
  label: 'GB Bank · Ag 0001 · CC 48213-7',
  saldo: SALDO.valor,
}

export interface PixContato {
  id: string
  nome: string
  chave: string
  tipoChave: string
  inicial: string
}

/** Contatos Pix frequentes (mock) — atalhos na entrada do fluxo Pix. */
export const PIX_CONTATOS: PixContato[] = [
  { id: 'p1', nome: 'Agropecuária Vale Verde', chave: 'contato@valeverde.com.br', tipoChave: 'E-mail', inicial: 'AV' },
  { id: 'p2', nome: 'Cooperativa Cerrado', chave: '12.345.678/0001-90', tipoChave: 'CNPJ', inicial: 'CC' },
  { id: 'p3', nome: 'João Batista · arrendamento', chave: '(62) 98411-2033', tipoChave: 'Telefone', inicial: 'JB' },
  { id: 'p4', nome: 'Frigorífico Boi Forte', chave: '047.882.910-55', tipoChave: 'CPF', inicial: 'BF' },
]

/** Bancos de destino para transferência (mock). */
export const BANCOS = [
  { value: 'gbbank', label: 'GB Bank' },
  { value: '001', label: 'Banco do Brasil' },
  { value: '237', label: 'Bradesco' },
  { value: '341', label: 'Itaú Unibanco' },
  { value: '104', label: 'Caixa Econômica' },
  { value: '077', label: 'Banco Inter' },
]

export const TRANSACOES: TransactionItem[] = [
  { id: 'tx1', title: 'Venda de gado · Frigorífico Boi Forte', subtitle: 'TED recebida', time: 'hoje, 09:12', value: 'R$ 86.400,00', direction: 'in' },
  { id: 'tx2', title: 'Agropecuária Vale Verde', subtitle: 'Pix · insumos', time: 'hoje, 08:05', value: 'R$ 12.380,00', direction: 'out' },
  { id: 'tx3', title: 'Folha de pagamento', subtitle: 'Lote agendado', time: 'ontem', value: 'R$ 38.120,50', direction: 'out' },
  { id: 'tx4', title: 'Cooperativa Cerrado', subtitle: 'Liquidação de soja', time: 'ontem', value: 'R$ 154.900,00', direction: 'in' },
  { id: 'tx5', title: 'Energia rural · CEMIG', subtitle: 'Débito automático', time: 'seg', value: 'R$ 4.812,90', direction: 'out' },
  { id: 'tx6', title: 'Combustível · Posto Trevo', subtitle: 'Cartão corporativo', time: 'seg', value: 'R$ 2.640,00', direction: 'out' },
  { id: 'tx7', title: 'Arrendamento pasto leste', subtitle: 'Pix recebido', time: 'dom', value: 'R$ 18.500,00', direction: 'in' },
]
