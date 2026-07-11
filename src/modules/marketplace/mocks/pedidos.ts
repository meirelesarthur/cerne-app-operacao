/** Status possíveis de um pedido do Marketplace (protótipo). */
export type PedidoStatus = 'entregue' | 'em-transporte' | 'processando'

/** Item de linha de um pedido (nome do produto + quantidade), dados mockados. */
export interface PedidoItem {
  nome: string
  quantidade: number
}

/** Pedido do Marketplace (dados determinísticos, protótipo). */
export interface Pedido {
  id: string
  numero: string
  /** data já formatada, ex.: '08/07/2026' */
  data: string
  itens: PedidoItem[]
  /** valor total já formatado em BRL, ex.: 'R$ 489,90' */
  valor: string
  status: PedidoStatus
}

export const PEDIDOS: Pedido[] = [
  {
    id: 'pedido-1',
    numero: '#48213',
    data: '08/07/2026',
    itens: [
      { nome: 'Semente de soja Intacta', quantidade: 2 },
      { nome: 'Ureia 45% granulada', quantidade: 5 },
    ],
    valor: 'R$ 1.729,30',
    status: 'em-transporte',
  },
  {
    id: 'pedido-2',
    numero: '#47905',
    data: '29/06/2026',
    itens: [{ nome: 'Ração confinamento 30kg', quantidade: 10 }],
    valor: 'R$ 985,00',
    status: 'entregue',
  },
  {
    id: 'pedido-3',
    numero: '#48260',
    data: '11/07/2026',
    itens: [{ nome: 'Arame liso 500m', quantidade: 3 }],
    valor: 'R$ 839,70',
    status: 'processando',
  },
]
