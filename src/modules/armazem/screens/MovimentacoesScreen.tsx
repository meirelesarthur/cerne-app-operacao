import { useState } from 'react'
import { Card, Heading, TransactionListItem } from '@/components/ui'
import { MOVIMENTACOES, type Movimentacao } from '../mocks/estoque'
import { toTransactionItem } from '../lib/movimentacoes'
import { MovimentacaoDetailSheet } from '../components/MovimentacaoDetailSheet'

/** Aba "Movimentações": lista completa de entradas/saídas do armazém (spec D2.2). */
export function MovimentacoesScreen() {
  const [selected, setSelected] = useState<Movimentacao | null>(null)

  return (
    <div className="flex flex-col gap-4 p-4">
      <Heading level={2}>Movimentações</Heading>

      <Card padded={false} className="px-4">
        {MOVIMENTACOES.map((mov) => (
          <TransactionListItem key={mov.id} transaction={toTransactionItem(mov)} onClick={() => setSelected(mov)} />
        ))}
      </Card>

      <MovimentacaoDetailSheet movimentacao={selected} onClose={() => setSelected(null)} />
    </div>
  )
}
