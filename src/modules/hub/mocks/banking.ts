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

export const TRANSACOES: TransactionItem[] = [
  { id: 'tx1', title: 'Venda de gado · Frigorífico Boi Forte', subtitle: 'TED recebida', time: 'hoje, 09:12', value: 'R$ 86.400,00', direction: 'in' },
  { id: 'tx2', title: 'Agropecuária Vale Verde', subtitle: 'Pix · insumos', time: 'hoje, 08:05', value: 'R$ 12.380,00', direction: 'out' },
  { id: 'tx3', title: 'Folha de pagamento', subtitle: 'Lote agendado', time: 'ontem', value: 'R$ 38.120,50', direction: 'out' },
  { id: 'tx4', title: 'Cooperativa Cerrado', subtitle: 'Liquidação de soja', time: 'ontem', value: 'R$ 154.900,00', direction: 'in' },
  { id: 'tx5', title: 'Energia rural · CEMIG', subtitle: 'Débito automático', time: 'seg', value: 'R$ 4.812,90', direction: 'out' },
  { id: 'tx6', title: 'Combustível · Posto Trevo', subtitle: 'Cartão corporativo', time: 'seg', value: 'R$ 2.640,00', direction: 'out' },
  { id: 'tx7', title: 'Arrendamento pasto leste', subtitle: 'Pix recebido', time: 'dom', value: 'R$ 18.500,00', direction: 'in' },
]
