import type { ReactNode } from 'react'
import { ArrowDownLeft, ArrowUpRight } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface TransactionItem {
  id: string
  title: string
  subtitle?: string
  time: string
  /** valor formatado sem sinal (ex.: "R$ 12.400,00") */
  value: string
  direction: 'in' | 'out'
}

export interface TransactionListItemProps {
  transaction: TransactionItem
  onClick?: () => void
  className?: string
}

/**
 * Linha de extrato do Banking (New-UI): direção com ícone + cor (nunca cor
 * sozinha), valores tabulares para alinhamento perfeito de colunas numéricas.
 */
export function TransactionListItem({ transaction: tx, onClick, className }: TransactionListItemProps) {
  const isIn = tx.direction === 'in'

  const content: ReactNode = (
    <>
      <span
        className={cn(
          'flex h-10 w-10 shrink-0 items-center justify-center rounded-full',
          isIn ? 'bg-accent-subtle text-accent' : 'bg-surface-subtle text-fg-muted',
        )}
        aria-hidden="true"
      >
        {isIn ? <ArrowDownLeft size={18} /> : <ArrowUpRight size={18} />}
      </span>
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold text-fg">{tx.title}</p>
        {tx.subtitle && <p className="truncate text-xs text-fg-muted">{tx.subtitle}</p>}
      </div>
      <div className="shrink-0 text-right">
        <p className={cn('text-sm font-bold tabular-nums', isIn ? 'text-accent' : 'text-fg')}>
          {isIn ? '+' : '−'} {tx.value}
        </p>
        <p className="text-xs text-fg-subtle">{tx.time}</p>
      </div>
    </>
  )

  const baseCls = cn(
    'flex w-full items-center gap-3 border-b border-border-default py-3 text-left last:border-0',
    className,
  )

  if (onClick) {
    return (
      <button type="button" onClick={onClick} className={cn(baseCls, 'transition-colors hover:bg-surface-subtle')}>
        {content}
      </button>
    )
  }

  return <div className={baseCls}>{content}</div>
}
