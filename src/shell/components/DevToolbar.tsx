import { useState } from 'react'
import { Wifi, WifiOff, Moon, Sun, SlidersHorizontal, X } from 'lucide-react'
import { useShellStore } from '@/shell/state/shellStore'
import { useTheme } from '@/context/ThemeContext'
import { cn } from '@/lib/cn'

/**
 * Toggle de dev (spec §7.3) — visível só no protótipo. Alterna `isOnline` (banners de sync)
 * e o tema (light/gbMode). Fica flutuante no canto, fora do fluxo do app.
 */
export function DevToolbar() {
  const [open, setOpen] = useState(false)
  const isOnline = useShellStore((s) => s.isOnline)
  const toggleOnline = useShellStore((s) => s.toggleOnline)
  const { isGbMode, toggle: toggleTheme } = useTheme()

  return (
    <div className="pointer-events-none fixed bottom-4 right-4 z-[1200] flex flex-col items-end gap-2">
      {open && (
        <div className="pointer-events-auto flex flex-col gap-2 rounded-2xl border border-border-default bg-surface p-2 shadow-modal">
          <button
            onClick={toggleOnline}
            className={cn(
              'flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold',
              isOnline ? 'text-fg' : 'bg-amber-100 text-amber-800',
            )}
          >
            {isOnline ? <Wifi size={16} /> : <WifiOff size={16} />}
            {isOnline ? 'Online' : 'Offline'}
          </button>
          <button
            onClick={toggleTheme}
            className="flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold text-fg"
          >
            {isGbMode ? <Moon size={16} /> : <Sun size={16} />}
            {isGbMode ? 'GB Mode' : 'Light'}
          </button>
        </div>
      )}
      <button
        onClick={() => setOpen((o) => !o)}
        aria-label="Ferramentas de desenvolvimento"
        className="pointer-events-auto flex h-11 w-11 items-center justify-center rounded-full bg-neutral-900 text-white shadow-modal"
      >
        {open ? <X size={20} /> : <SlidersHorizontal size={18} />}
      </button>
    </div>
  )
}
