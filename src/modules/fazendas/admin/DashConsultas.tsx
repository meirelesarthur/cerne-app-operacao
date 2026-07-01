import { useState } from 'react'
import { Layers, Boxes, Scale, MapPin, Lock, MapPinned } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Chip } from '@/components/ui/Chip'
import { EmptyState } from '@/components/ui/EmptyState'
import { SectionTitle } from '@/components/ui/Heading'
import { DashboardScreen } from './DashboardScreen'
import { LOTES, ESTOQUE, PESAGENS_DIA } from '../mocks/dashboards'
import { cn } from '@/lib/cn'

type Section = 'lotes' | 'estoque' | 'pesagens' | 'localizacao'

const HUB: { id: Section; label: string; icon: LucideIcon }[] = [
  { id: 'lotes', label: 'Lotes', icon: Layers },
  { id: 'estoque', label: 'Estoque', icon: Boxes },
  { id: 'pesagens', label: 'Pesagens do dia', icon: Scale },
  { id: 'localizacao', label: 'Localização', icon: MapPin },
]

/**
 * Consultas Gerenciais read-only (spec §4.7). 100% leitura: nenhum botão de ação/edição.
 * Localização de animais = placeholder de mapa (PESADO/diferido no recorte).
 */
export function DashConsultas() {
  const [section, setSection] = useState<Section>('lotes')

  return (
    <DashboardScreen title="Consultas Gerenciais">
      <div className="mb-4 flex items-center gap-1.5 text-xs font-medium text-fg-subtle">
        <Lock size={12} /> Somente leitura — dados espelhados do web.
      </div>

      <div className="grid grid-cols-4 gap-2">
        {HUB.map((h) => (
          <button
            key={h.id}
            onClick={() => setSection(h.id)}
            className={cn(
              'flex flex-col items-center gap-1.5 rounded-2xl border p-3',
              section === h.id ? 'border-accent bg-accent-subtle' : 'border-border-default bg-surface',
            )}
          >
            <h.icon size={20} className={section === h.id ? 'text-accent' : 'text-fg-muted'} />
            <span className="text-center text-xs font-medium leading-tight text-fg-muted">{h.label}</span>
          </button>
        ))}
      </div>

      <SectionTitle className="mb-2 mt-5">{HUB.find((h) => h.id === section)?.label}</SectionTitle>

      {section === 'lotes' && (
        <ReadOnlyList
          rows={LOTES.map((l) => ({
            id: l.id,
            title: l.nome,
            subtitle: `${l.cabecas} cabeças · ${l.peso}`,
            meta: l.local,
          }))}
        />
      )}
      {section === 'estoque' && (
        <ReadOnlyList
          rows={ESTOQUE.map((e) => ({ id: e.id, title: e.produto, subtitle: e.deposito, meta: e.qtd }))}
        />
      )}
      {section === 'pesagens' && (
        <ReadOnlyList
          rows={PESAGENS_DIA.map((p) => ({
            id: p.id,
            title: p.lote,
            subtitle: `${p.cabecas} cabeças · ${p.peso}`,
            meta: p.hora,
          }))}
        />
      )}
      {section === 'localizacao' && (
        <div className="rounded-2xl border border-dashed border-border-strong bg-surface-subtle">
          <EmptyState
            icon={MapPinned}
            title="Mapa de localização"
            description="Carregamento otimizado em desenvolvimento. O mapa de localização de animais será habilitado em uma próxima fase."
          />
        </div>
      )}
    </DashboardScreen>
  )
}

function ReadOnlyList({ rows }: { rows: { id: string; title: string; subtitle: string; meta: string }[] }) {
  return (
    <ul className="overflow-hidden rounded-2xl border border-border-default bg-surface">
      {rows.map((r) => (
        <li key={r.id} className="flex items-center justify-between gap-3 border-b border-border-subtle px-4 py-3 last:border-b-0">
          <div className="min-w-0">
            <p className="truncate font-semibold text-fg">{r.title}</p>
            <p className="truncate text-sm text-fg-muted">{r.subtitle}</p>
          </div>
          <Chip tone="neutral">{r.meta}</Chip>
        </li>
      ))}
    </ul>
  )
}
