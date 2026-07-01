import { useState } from 'react'
import { ChevronDown, Circle } from 'lucide-react'
import { DashboardScreen } from './DashboardScreen'
import { USO_FAZENDAS } from '../mocks/dashboards'
import { cn } from '@/lib/cn'

const PERIODOS = ['Hoje', '7 dias', '30 dias'] as const

/**
 * Análise de Uso / Atividade (spec §4.6) — observabilidade multi-tenant.
 * Tela sensível: marcada como "Acesso restrito" no cabeçalho (via DashboardScreen).
 */
export function DashUso() {
  const [periodo, setPeriodo] = useState<(typeof PERIODOS)[number]>('Hoje')
  const [expandido, setExpandido] = useState<string | null>(USO_FAZENDAS[0].id)

  return (
    <DashboardScreen title="Análise de Uso" restricted>
      <div className="no-scrollbar -mx-1 flex gap-2 overflow-x-auto px-1 pb-1">
        {PERIODOS.map((p) => (
          <button
            key={p}
            onClick={() => setPeriodo(p)}
            className={cn(
              'whitespace-nowrap rounded-full border px-3 py-1 text-sm font-semibold',
              periodo === p ? 'border-accent bg-accent text-white' : 'border-border-default bg-surface text-fg-muted',
            )}
          >
            {p}
          </button>
        ))}
      </div>

      <ul className="mt-3 flex flex-col gap-2">
        {USO_FAZENDAS.map((f) => {
          const open = expandido === f.id
          return (
            <li key={f.id} className="overflow-hidden rounded-2xl border border-border-default bg-surface">
              <button
                onClick={() => setExpandido(open ? null : f.id)}
                className="flex w-full items-center gap-3 p-3 text-left"
              >
                <Circle size={10} className={f.online > 0 ? 'fill-brand-500 text-brand-500' : 'fill-neutral-300 text-neutral-300'} />
                <div className="flex-1">
                  <p className="font-semibold text-fg">{f.nome}</p>
                  <p className="text-sm text-fg-muted">{f.online} usuário(s) online</p>
                </div>
                <ChevronDown size={18} className={cn('text-fg-subtle transition-transform', open && 'rotate-180')} />
              </button>
              {open && (
                <ul className="border-t border-border-subtle">
                  {f.usuarios.map((u) => (
                    <li key={u.nome} className="flex items-center gap-3 px-4 py-2.5">
                      <Circle size={8} className={u.ativo ? 'fill-brand-500 text-brand-500' : 'fill-neutral-300 text-neutral-300'} />
                      <span className="flex-1 text-sm text-fg">{u.nome}</span>
                      <span className="text-xs text-fg-subtle">{u.ultimoAcesso}</span>
                    </li>
                  ))}
                </ul>
              )}
            </li>
          )
        })}
      </ul>
    </DashboardScreen>
  )
}
