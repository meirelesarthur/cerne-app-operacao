import type { LucideIcon } from 'lucide-react'
import { Pressable } from '@/components/ui/Pressable'

export interface Shortcut {
  id: string
  label: string
  icon: LucideIcon
  onClick?: () => void
}

/**
 * Grid de atalhos ícone + label (spec §6.5). Reutilizável entre hubs do módulo.
 * Nova UI: bolhas monotom (acento da marca) — consistência visual em vez de
 * cores por item; a distinção vem do ícone e do rótulo, não do fundo.
 */
export function ShortcutGrid({ items, columns = 4 }: { items: Shortcut[]; columns?: 4 | 5 }) {
  return (
    <div className={columns === 5 ? 'grid grid-cols-5 gap-2' : 'grid grid-cols-4 gap-3'}>
      {items.map((it) => (
        <Pressable key={it.id} onClick={it.onClick} className="flex flex-col items-center gap-1.5">
          <span className="flex h-14 w-14 items-center justify-center rounded-2xl border border-border-tint bg-accent-subtle text-accent">
            <it.icon size={22} />
          </span>
          <span className="text-center text-xs font-medium leading-tight text-fg-muted">{it.label}</span>
        </Pressable>
      ))}
    </div>
  )
}
