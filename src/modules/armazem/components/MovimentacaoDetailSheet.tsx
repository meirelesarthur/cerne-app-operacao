import type { ReactNode } from 'react'
import { ArrowDownLeft, ArrowUpRight } from 'lucide-react'
import { BottomSheet, Chip } from '@/components/ui'
import { cn } from '@/lib/cn'
import type { Movimentacao } from '../mocks/estoque'

export interface MovimentacaoDetailSheetProps {
  /** Movimentação selecionada — `null` mantém o sheet fechado. */
  movimentacao: Movimentacao | null
  onClose: () => void
}

/**
 * Detalhe de Movimentação do Armazém: BottomSheet acionado pelo item de
 * lista (`TransactionListItem`) tanto na Home quanto em Movimentações — o
 * mesmo componente é reutilizado nos dois pontos de entrada (Lei 2).
 */
export function MovimentacaoDetailSheet({ movimentacao, onClose }: MovimentacaoDetailSheetProps) {
  return (
    <BottomSheet open={!!movimentacao} onClose={onClose} title="Detalhe da movimentação">
      {movimentacao && <SheetBody mov={movimentacao} />}
    </BottomSheet>
  )
}

function SheetBody({ mov }: { mov: Movimentacao }) {
  const isEntrada = mov.tipo === 'entrada'

  return (
    <div className="flex flex-col gap-4">
      {/* Cabeçalho: direção sempre com ícone + texto, nunca só cor */}
      <div className="flex flex-col items-center gap-2 pt-1 text-center">
        <span
          className={cn(
            'flex h-12 w-12 items-center justify-center rounded-full',
            isEntrada ? 'bg-accent-subtle text-accent' : 'bg-surface-subtle text-fg-muted',
          )}
          aria-hidden="true"
        >
          {isEntrada ? <ArrowDownLeft size={22} /> : <ArrowUpRight size={22} />}
        </span>
        <Chip
          tone={isEntrada ? 'brand' : 'neutral'}
          icon={isEntrada ? <ArrowDownLeft size={12} aria-hidden="true" /> : <ArrowUpRight size={12} aria-hidden="true" />}
        >
          {isEntrada ? 'Entrada' : 'Saída'}
        </Chip>
        <p
          className={cn(
            'text-3xl font-bold leading-tight tabular-nums tracking-tight',
            isEntrada ? 'text-accent' : 'text-fg',
          )}
        >
          {isEntrada ? '+' : '−'} {mov.quantidade}
        </p>
        <p className="text-lg font-semibold text-fg">{mov.item}</p>
        <p className="text-sm text-fg-muted">{mov.tempo}</p>
      </div>

      {/* Ficha da movimentação */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
        <DetailRow label="Origem" value={mov.origem} />
        <DetailRow label="Destino" value={mov.destino} />
        <DetailRow label="Responsável" value={mov.responsavel} />
        <DetailRow label="Veículo" value={mov.veiculo} />
      </div>

      {/* Nota da movimentação */}
      <div className="rounded-2xl border border-border-default p-4">
        <p className="text-xs font-semibold uppercase tracking-wide text-fg-subtle">Nota</p>
        <p className="mt-1 text-sm text-fg">{mov.nota}</p>
      </div>

      {/* Padrão honesto do protótipo (como no TransactionDetailSheet/ActivityDetailSheet) */}
      <p className="text-sm text-fg-subtle">
        Comprovante fiscal e histórico completo ficam disponíveis no sistema web GB CERNE.
      </p>
    </div>
  )
}

function DetailRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3">
      <span className="shrink-0 text-sm text-fg-muted">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{value}</span>
    </div>
  )
}
