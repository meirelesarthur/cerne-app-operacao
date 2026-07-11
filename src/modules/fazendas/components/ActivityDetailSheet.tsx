import type { ReactNode } from 'react'
import { Smartphone, CheckCircle2 } from 'lucide-react'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { Chip } from '@/components/ui/Chip'
import { KIND_ICON, STATUS_META } from './ActivityListItem'
import type { Activity } from '../types'

/** Nome legível do tipo de atividade (spec §6.7). */
const KIND_LABEL: Record<Activity['kind'], string> = {
  pesagem: 'Pesagem',
  evento: 'Evento de rebanho',
  nfe: 'Entrada NF-e',
  venda: 'Venda de animais',
  insumo: 'Aplicação de insumo',
  arracoamento: 'Arraçoamento',
}

/**
 * Rótulos dos segmentos do `subtitle` ("A · B") por tipo — dá semântica de ficha
 * ao mock (fazenda, lote, quantidade, fornecedor…) sem inventar dado novo.
 */
const KIND_DETAIL_LABELS: Record<Activity['kind'], [string, string]> = {
  pesagem: ['Fazenda', 'Quantidade'],
  evento: ['Referência', 'Detalhe'],
  nfe: ['Categoria', 'Fornecedor'],
  venda: ['Comprador', 'Quantidade'],
  insumo: ['Local', 'Insumo'],
  arracoamento: ['Dieta', 'Quantidade'],
}

/** Tipos capturados pelo app de campo — exibem a linha de origem/sincronização. */
const FIELD_KINDS: ReadonlyArray<Activity['kind']> = ['pesagem', 'arracoamento', 'insumo', 'evento']

export interface ActivityDetailSheetProps {
  /** Atividade selecionada — `null` mantém o sheet fechado. */
  activity: Activity | null
  onClose: () => void
}

/**
 * Detalhe de Atividade (Plano de Navegabilidade, B1): BottomSheet acionado pelo
 * `ActivityListItem` em FazendasHome, AtividadesScreen e DashPecuaria. Reaproveita
 * os mesmos ícones e tons de status da lista (fonte única, Lei 2).
 */
export function ActivityDetailSheet({ activity, onClose }: ActivityDetailSheetProps) {
  return (
    <BottomSheet open={!!activity} onClose={onClose} title="Detalhe da atividade">
      {activity && <SheetBody activity={activity} />}
    </BottomSheet>
  )
}

function SheetBody({ activity }: { activity: Activity }) {
  const Icon = KIND_ICON[activity.kind]
  const status = STATUS_META[activity.status]
  const detailLabels = KIND_DETAIL_LABELS[activity.kind]
  const segments = activity.subtitle.split(' · ')
  const syncedFromField = FIELD_KINDS.includes(activity.kind) && activity.status === 'concluida'

  return (
    <div className="flex flex-col gap-4">
      {/* Identidade da atividade */}
      <div className="flex items-center gap-3">
        <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-surface-subtle text-fg-muted">
          <Icon size={22} aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-semibold uppercase tracking-wide text-fg-subtle">{KIND_LABEL[activity.kind]}</p>
          <p className="truncate text-lg font-semibold text-fg">{activity.title}</p>
        </div>
        <Chip tone={status.tone} className="shrink-0">
          {status.label}
        </Chip>
      </div>

      {/* Ficha da atividade */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
        <DetailRow label="Quando" value={activity.time} />
        {segments.map((segment, i) => (
          <DetailRow key={segment} label={detailLabels[i] ?? 'Detalhe'} value={segment} />
        ))}
      </div>

      {/* Origem do registro — só quando o shape indica captura em campo concluída */}
      {syncedFromField && (
        <p className="flex items-center gap-1.5 text-xs text-fg-muted">
          <Smartphone size={13} aria-hidden="true" />
          Registrado no campo
          <span aria-hidden="true">·</span>
          <CheckCircle2 size={13} className="text-accent" aria-hidden="true" />
          sincronizado
        </p>
      )}

      {/* Padrão honesto do protótipo (como no DashConfinamento) */}
      <p className="text-sm text-fg-subtle">
        Histórico completo, anexos e edição desta atividade ficam no sistema web GB CERNE.
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
