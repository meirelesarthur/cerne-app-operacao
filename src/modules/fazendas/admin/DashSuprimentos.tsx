import { useState } from 'react'
import { Chip, type ChipTone } from '@/components/ui/Chip'
import { DashboardScreen } from './DashboardScreen'
import { COTACOES, type Cotacao, type CotacaoStatus } from '../mocks/dashboards'
import { cn } from '@/lib/cn'

const TIPOS = ['Todos', 'Produto', 'Serviço', 'Frete', 'Manutenção'] as const

const STATUS_META: Record<CotacaoStatus, { label: string; tone: ChipTone }> = {
  cotacao: { label: 'Em cotação', tone: 'blue' },
  aprovada: { label: 'Aprovada', tone: 'brand' },
  recusada: { label: 'Recusada', tone: 'red' },
}

/**
 * Dashboard de Suprimentos (spec §4.4) — status PARCIAL: UI completa com mock,
 * mas com selo "Dados de exemplo" sinalizando fonte a confirmar.
 */
export function DashSuprimentos() {
  const [filtro, setFiltro] = useState<(typeof TIPOS)[number]>('Todos')
  const lista: Cotacao[] = COTACOES.filter((c) => filtro === 'Todos' || c.tipo === filtro)

  return (
    <DashboardScreen title="Suprimentos">
      <div className="no-scrollbar -mx-1 flex gap-2 overflow-x-auto px-1 pb-1">
        {TIPOS.map((tipo) => (
          <button
            key={tipo}
            onClick={() => setFiltro(tipo)}
            className={cn(
              'whitespace-nowrap rounded-full border px-3 py-1 text-sm font-semibold',
              filtro === tipo ? 'border-accent bg-accent text-white' : 'border-border-default bg-surface text-fg-muted',
            )}
          >
            {tipo}
          </button>
        ))}
      </div>

      <ul className="mt-3 flex flex-col gap-2">
        {lista.map((c) => {
          const status = STATUS_META[c.status]
          return (
            <li key={c.id} className="rounded-2xl border border-border-default bg-surface p-3">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="font-semibold text-fg">{c.fornecedor}</p>
                  <p className="text-sm text-fg-muted">
                    {c.tipo} · {c.itens} itens
                  </p>
                </div>
                <Chip tone={status.tone}>{status.label}</Chip>
              </div>
              <div className="mt-2 flex items-center justify-between">
                <span className="text-lg font-bold text-fg">{c.total}</span>
                <span className="text-xs italic text-fg-subtle">Dados de exemplo</span>
              </div>
            </li>
          )
        })}
      </ul>
    </DashboardScreen>
  )
}
