import { LayoutDashboard, ClipboardList } from 'lucide-react'
import { useFazendasStore } from '../state/fazendasStore'
import type { FarmView } from '../types'
import { cn } from '@/lib/cn'

/**
 * Switch de Visão Gerencial ⇄ Campo (spec §3.3) — segmented control abaixo do header do módulo.
 * "Gerencial" = Administrativa (leitura); "Campo" = Operacional (escrita).
 */
const OPTIONS: { value: FarmView; label: string; icon: typeof LayoutDashboard }[] = [
  { value: 'gerencial', label: 'Gerencial', icon: LayoutDashboard },
  { value: 'campo', label: 'Campo', icon: ClipboardList },
]

export function ViewSwitch() {
  const view = useFazendasStore((s) => s.view)
  const setView = useFazendasStore((s) => s.setView)

  return (
    <div className="flex rounded-full bg-white/15 p-0.5" role="tablist" aria-label="Visão">
      {OPTIONS.map((opt) => {
        const active = view === opt.value
        return (
          <button
            key={opt.value}
            role="tab"
            aria-selected={active}
            onClick={() => setView(opt.value)}
            className={cn(
              'flex flex-1 items-center justify-center gap-1.5 rounded-full px-3 py-1.5 text-sm font-semibold transition-colors',
              active ? 'bg-white text-brand-700 shadow-card' : 'text-white/80',
            )}
          >
            <opt.icon size={15} />
            {opt.label}
          </button>
        )
      })}
    </div>
  )
}
