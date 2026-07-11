import { Card, Chip, ProgressBar, type ChipTone } from '@/components/ui'
import type { Unidade, UnidadeStatus } from '../mocks/estoque'

/** Rótulo + tom de status — fonte única, reutilizado no UnidadeDetailSheet (Lei 2). */
export const STATUS_CHIP: Record<UnidadeStatus, { tone: ChipTone; label: string }> = {
  ok: { tone: 'brand', label: 'Normal' },
  atencao: { tone: 'amber', label: 'Atenção' },
  critico: { tone: 'red', label: 'Crítico' },
}

export interface UnidadeCardProps {
  unidade: Unidade
  onClick?: () => void
}

/** Card de unidade de armazenagem — reutilizado na Home e na aba Unidades (Lei 2). */
export function UnidadeCard({ unidade, onClick }: UnidadeCardProps) {
  const chip = STATUS_CHIP[unidade.status]
  return (
    <Card interactive={!!onClick} onClick={onClick}>
      <div className="flex items-center justify-between gap-2">
        <p className="truncate text-sm font-semibold text-fg">{unidade.nome}</p>
        <Chip tone={chip.tone} className="shrink-0">
          {chip.label}
        </Chip>
      </div>
      <p className="mt-0.5 text-xs text-fg-muted">
        {unidade.produto} · {unidade.capacidade}
      </p>
      <div className="mt-3 flex items-center gap-3">
        <ProgressBar value={unidade.ocupacaoPct} colorByOccupancy className="flex-1" />
        <span className="shrink-0 text-sm font-semibold tabular-nums text-fg">{unidade.ocupacaoPct}%</span>
      </div>
    </Card>
  )
}
