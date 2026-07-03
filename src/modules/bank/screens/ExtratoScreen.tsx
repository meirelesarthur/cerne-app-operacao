import { useState } from 'react'
import { Inbox } from 'lucide-react'
import { Heading, Button, Card, EmptyState, TransactionListItem } from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { SALDO, TRANSACOES } from '@/modules/bank/mocks/banking'

type Filtro = 'tudo' | 'in' | 'out'

/**
 * Extrato do GB Bank (New-UI): saldo compacto + filtro de direção (entradas/
 * saídas) sobre a lista de movimentações completa.
 */
export function ExtratoScreen() {
  const [filtro, setFiltro] = useState<Filtro>('tudo')
  const balanceHidden = useShellStore((s) => s.balanceHidden)

  const transacoesFiltradas = TRANSACOES.filter((tx) => filtro === 'tudo' || tx.direction === filtro)

  return (
    <div className="flex flex-col gap-5 p-4">
      <div>
        <Heading level={3}>Extrato</Heading>
        <p className="mt-0.5 text-sm text-fg-muted">
          Saldo disponível: <span className="font-semibold tabular-nums text-fg">{balanceHidden ? '••••••' : SALDO.valor}</span>
        </p>
      </div>

      <div className="flex gap-2">
        <Button variant={filtro === 'tudo' ? 'primary' : 'secondary'} size="sm" onClick={() => setFiltro('tudo')}>
          Tudo
        </Button>
        <Button variant={filtro === 'in' ? 'primary' : 'secondary'} size="sm" onClick={() => setFiltro('in')}>
          Entradas
        </Button>
        <Button variant={filtro === 'out' ? 'primary' : 'secondary'} size="sm" onClick={() => setFiltro('out')}>
          Saídas
        </Button>
      </div>

      {transacoesFiltradas.length === 0 ? (
        <EmptyState
          icon={Inbox}
          title="Nada por aqui"
          description="Não há movimentações para este filtro."
          className="h-full justify-center"
        />
      ) : (
        <Card padded={false} className="px-4">
          {transacoesFiltradas.map((tx) => (
            <TransactionListItem key={tx.id} transaction={tx} />
          ))}
        </Card>
      )}
    </div>
  )
}
