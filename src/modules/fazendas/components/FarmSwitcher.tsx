import { useState } from 'react'
import { Leaf, ChevronDown, Check } from 'lucide-react'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { useFazendasStore } from '../state/fazendasStore'
import { cn } from '@/lib/cn'

/**
 * Farm switcher (spec §3.5/§6.3): pill verde translúcida no header do módulo Fazendas.
 * Abre bottom sheet com as fazendas do usuário. A troca define o tenant dos lançamentos.
 */
export function FarmSwitcher() {
  const [open, setOpen] = useState(false)
  const farms = useFazendasStore((s) => s.farms)
  const activeFarmId = useFazendasStore((s) => s.activeFarmId)
  const setActiveFarm = useFazendasStore((s) => s.setActiveFarm)
  const active = farms.find((f) => f.id === activeFarmId) ?? farms[0]

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-white/10 py-1.5 pl-2.5 pr-3 text-md font-medium text-white"
      >
        <Leaf size={14} className="text-brand-400" />
        {active.name}
        <ChevronDown size={14} className="text-white/50" />
      </button>

      <BottomSheet open={open} onClose={() => setOpen(false)} title="Trocar de fazenda">
        <ul className="flex flex-col gap-1">
          {farms.map((f) => {
            const isActive = f.id === activeFarmId
            return (
              <li key={f.id}>
                <button
                  onClick={() => {
                    setActiveFarm(f.id)
                    setOpen(false)
                  }}
                  className={cn(
                    'flex w-full items-center gap-3 rounded-xl border p-3 text-left',
                    isActive ? 'border-accent bg-accent-subtle' : 'border-border-default bg-surface',
                  )}
                >
                  <span className="flex h-10 w-10 items-center justify-center rounded-full bg-accent text-sm font-bold text-white">
                    {f.name.split(' ').slice(-1)[0].slice(0, 2).toUpperCase()}
                  </span>
                  <div className="flex-1">
                    <p className="font-semibold text-fg">{f.name}</p>
                    <p className="text-sm text-fg-muted">
                      {f.city}/{f.uf}
                    </p>
                  </div>
                  {isActive && <Check size={18} className="text-accent" />}
                </button>
              </li>
            )
          })}
        </ul>
      </BottomSheet>
    </>
  )
}
