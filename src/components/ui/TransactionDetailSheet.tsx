import { useEffect, useState, type ReactNode } from 'react'
import { ArrowDownLeft, ArrowUpRight, Copy, Check } from 'lucide-react'
import { cn } from '@/lib/cn'
import { BottomSheet } from './BottomSheet'
import { Chip } from './Chip'
import { IconButton } from './IconButton'
import type { TransactionItem } from './TransactionListItem'

export interface TransactionDetailSheetProps {
  /** Transação selecionada — `null` mantém o sheet fechado. */
  transaction: TransactionItem | null
  onClose: () => void
  /** Oculta valores (privacidade) — espelha o `balanceHidden` global, como no BalanceCard. */
  hidden?: boolean
}

/** ID de operação mockado e determinístico (sem Date.now) — protótipo. */
const operationId = (id: string) => `E9040088-2607-${id.toUpperCase().padStart(6, '0')}-GBNK`

/**
 * Detalhe de Transação (Plano de Navegabilidade, B2): BottomSheet com anatomia
 * de comprovante bancário, acionado pelo `TransactionListItem` no hub Início e
 * no GB Bank. Direção sempre com ícone + texto (nunca só cor) e valores
 * tabulares, seguindo o padrão do TransactionListItem/BalanceCard.
 */
export function TransactionDetailSheet({ transaction, onClose, hidden = false }: TransactionDetailSheetProps) {
  return (
    <BottomSheet open={!!transaction} onClose={onClose} title="Detalhe da transação">
      {transaction && <SheetBody transaction={transaction} hidden={hidden} />}
    </BottomSheet>
  )
}

function SheetBody({ transaction: tx, hidden }: { transaction: TransactionItem; hidden: boolean }) {
  const isIn = tx.direction === 'in'
  const opId = operationId(tx.id)
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (!copied) return
    const timer = setTimeout(() => setCopied(false), 1600)
    return () => clearTimeout(timer)
  }, [copied])

  const copyOpId = () => {
    void navigator.clipboard?.writeText(opId).catch(() => undefined)
    setCopied(true)
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Cabeçalho do comprovante: direção acessível + valor grande */}
      <div className="flex flex-col items-center gap-2 pt-1 text-center">
        <span
          className={cn(
            'flex h-12 w-12 items-center justify-center rounded-full',
            isIn ? 'bg-accent-subtle text-accent' : 'bg-surface-subtle text-fg-muted',
          )}
          aria-hidden="true"
        >
          {isIn ? <ArrowDownLeft size={22} /> : <ArrowUpRight size={22} />}
        </span>
        <Chip
          tone={isIn ? 'brand' : 'neutral'}
          icon={isIn ? <ArrowDownLeft size={12} aria-hidden="true" /> : <ArrowUpRight size={12} aria-hidden="true" />}
        >
          {isIn ? 'Entrada' : 'Saída'}
        </Chip>
        <p className={cn('text-4xl font-bold leading-tight tabular-nums tracking-tight', isIn ? 'text-accent' : 'text-fg')}>
          {hidden ? '••••••' : `${isIn ? '+' : '−'} ${tx.value}`}
        </p>
        <p className="text-sm text-fg-muted">{tx.time}</p>
      </div>

      {/* Ficha do comprovante */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
        <ReceiptRow label={isIn ? 'De' : 'Para'} value={tx.title} />
        {tx.subtitle && <ReceiptRow label="Descrição" value={tx.subtitle} />}
        <ReceiptRow label="Data" value={tx.time} />
        <ReceiptRow label="Situação" value={<Chip tone="brand">Efetivada</Chip>} />
      </div>

      {/* ID da operação — bloco copiável */}
      <div className="flex items-center justify-between gap-3 rounded-2xl border border-border-default p-4">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-fg-subtle">ID da operação</p>
          <p className="mt-0.5 truncate text-sm font-semibold tabular-nums tracking-wide text-fg">{opId}</p>
        </div>
        <IconButton
          label={copied ? 'ID copiado' : 'Copiar ID da operação'}
          variant="solid"
          size="lg"
          onClick={copyOpId}
          className="shrink-0"
        >
          {copied ? <Check size={16} className="text-accent" aria-hidden="true" /> : <Copy size={16} aria-hidden="true" />}
        </IconButton>
      </div>

      {/* Padrão honesto do protótipo */}
      <p className="text-sm text-fg-subtle">
        O comprovante oficial em PDF fica disponível no GB Bank web.
      </p>
    </div>
  )
}

function ReceiptRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3">
      <span className="shrink-0 text-sm text-fg-muted">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{value}</span>
    </div>
  )
}
