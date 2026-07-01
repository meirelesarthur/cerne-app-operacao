import type { LucideIcon } from 'lucide-react'

export interface Shortcut {
  id: string
  label: string
  icon: LucideIcon
  onClick?: () => void
  /** tom do container do ícone (usa paleta de acento) */
  tone?: 'brand' | 'blue' | 'amber' | 'purple'
}

const toneCls: Record<NonNullable<Shortcut['tone']>, string> = {
  brand: 'bg-accent-subtle text-accent',
  blue: 'bg-blue-50 text-blue-600',
  amber: 'bg-amber-50 text-amber-600',
  purple: 'bg-[#f5f3ff] text-[#7c3aed]',
}

/**
 * Grid de atalhos ícone + label (spec §6.5). Reutilizável entre hubs do módulo.
 */
export function ShortcutGrid({ items, columns = 4 }: { items: Shortcut[]; columns?: 4 | 5 }) {
  return (
    <div className={columns === 5 ? 'grid grid-cols-5 gap-2' : 'grid grid-cols-4 gap-3'}>
      {items.map((it) => (
        <button key={it.id} onClick={it.onClick} className="flex flex-col items-center gap-1.5">
          <span
            className={`flex h-14 w-14 items-center justify-center rounded-2xl ${toneCls[it.tone ?? 'brand']}`}
          >
            <it.icon size={22} />
          </span>
          <span className="text-center text-xs font-medium leading-tight text-fg-muted">{it.label}</span>
        </button>
      ))}
    </div>
  )
}
