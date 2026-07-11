import { ChevronRight, Scale, FileText, Truck, Wheat, ArrowLeftRight, Sprout } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Chip, type ChipTone } from '@/components/ui/Chip'
import type { Activity, ActivityStatus } from '../types'

/** Ícone por tipo de atividade — fonte única, reutilizado no ActivityDetailSheet (Lei 2). */
export const KIND_ICON: Record<Activity['kind'], LucideIcon> = {
  pesagem: Scale,
  evento: ArrowLeftRight,
  nfe: FileText,
  venda: Truck,
  insumo: Sprout,
  arracoamento: Wheat,
}

/** Rótulo + tom de status — fonte única, reutilizado no ActivityDetailSheet (Lei 2). */
export const STATUS_META: Record<ActivityStatus, { label: string; tone: ChipTone }> = {
  andamento: { label: 'Em andamento', tone: 'blue' },
  concluida: { label: 'Concluída', tone: 'brand' },
  autorizada: { label: 'Autorizada', tone: 'brand' },
  atrasada: { label: 'Atrasada', tone: 'red' },
}

/** Item da lista "Atividades recentes" (spec §6.7). */
export function ActivityListItem({ activity, onClick }: { activity: Activity; onClick?: () => void }) {
  const Icon = KIND_ICON[activity.kind]
  const status = STATUS_META[activity.status]

  return (
    <button
      onClick={onClick}
      className="flex w-full items-center gap-3 border-b border-border-subtle px-1 py-3 text-left last:border-b-0"
    >
      <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-surface-subtle text-fg-muted">
        <Icon size={18} />
      </span>
      <div className="min-w-0 flex-1">
        <p className="truncate font-semibold text-fg">{activity.title}</p>
        <p className="truncate text-sm text-fg-muted">{activity.subtitle}</p>
      </div>
      <div className="flex shrink-0 flex-col items-end gap-1">
        <Chip tone={status.tone}>{status.label}</Chip>
        <span className="text-xs text-fg-subtle">{activity.time}</span>
      </div>
      <ChevronRight size={16} className="shrink-0 text-fg-subtle" />
    </button>
  )
}
