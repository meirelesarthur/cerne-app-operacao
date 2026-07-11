import type { TransactionItem } from '@/components/ui'
import type { Movimentacao } from '../mocks/estoque'

/**
 * Adapta uma `Movimentacao` do Armazém para o shape de `TransactionItem`,
 * permitindo reutilizar o `TransactionListItem` (direção com ícone + cor,
 * nunca só cor) já usado no Banking — fonte única de verdade (Lei 2).
 */
export function toTransactionItem(mov: Movimentacao): TransactionItem {
  const isEntrada = mov.tipo === 'entrada'
  return {
    id: mov.id,
    title: mov.item,
    subtitle: isEntrada ? mov.origem : mov.destino,
    time: mov.tempo,
    value: mov.quantidade,
    direction: isEntrada ? 'in' : 'out',
  }
}
