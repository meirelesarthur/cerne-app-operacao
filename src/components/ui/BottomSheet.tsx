import { useEffect, type ReactNode } from 'react'
import { createPortal } from 'react-dom'
import { cn } from '@/lib/cn'

export interface BottomSheetProps {
  open: boolean
  onClose: () => void
  title?: string
  children: ReactNode
  /** Máximo de altura do conteúdo (em % da viewport). */
  maxHeight?: string
}

/** Bottom sheet padrão (spec §6.11): radius modal no topo, handle centralizada, overlay. */
export function BottomSheet({ open, onClose, title, children, maxHeight = '85vh' }: BottomSheetProps) {
  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, onClose])

  if (!open) return null

  return createPortal(
    <div className="fixed inset-0 z-[1100] flex items-end justify-center">
      <div
        className="absolute inset-0 bg-black/40 animate-[fadeIn_150ms_ease-out]"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        className={cn(
          'relative w-full max-w-phone bg-surface shadow-modal',
          'rounded-t-modal pb-[env(safe-area-inset-bottom)]',
          'animate-[slideUp_250ms_cubic-bezier(0.34,1.56,0.64,1)]',
        )}
        style={{ maxHeight }}
        role="dialog"
        aria-modal="true"
        aria-label={title}
      >
        <div className="flex justify-center pt-3 pb-1">
          <span className="h-1 w-10 rounded-full bg-neutral-300" />
        </div>
        {title && <h2 className="px-5 pb-2 pt-1 text-lg font-semibold text-fg">{title}</h2>}
        <div className="overflow-y-auto px-5 pb-5" style={{ maxHeight: `calc(${maxHeight} - 64px)` }}>
          {children}
        </div>
      </div>
    </div>,
    document.body,
  )
}
