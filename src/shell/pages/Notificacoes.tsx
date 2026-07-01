import { BellOff, Sprout, Landmark, HandCoins } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { EmptyState } from '@/components/ui/EmptyState'
import { Button } from '@/components/ui/Button'
import { Chip } from '@/components/ui/Chip'
import { useShellStore } from '@/shell/state/shellStore'
import { cn } from '@/lib/cn'

const MODULE_ICON: Record<string, typeof Sprout> = {
  fazendas: Sprout,
  credito: HandCoins,
  bank: Landmark,
}

/** Notificações agregadas de todos os módulos (spec §3.1). */
export function Notificacoes() {
  const notifications = useShellStore((s) => s.notifications)
  const markAllRead = useShellStore((s) => s.markAllRead)
  const hasUnread = notifications.some((n) => !n.read)

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader
        title="Notificações"
        action={
          hasUnread ? (
            <Button variant="ghost" size="sm" onClick={markAllRead}>
              Marcar lidas
            </Button>
          ) : undefined
        }
      />
      {notifications.length === 0 ? (
        <EmptyState icon={BellOff} title="Sem notificações" description="Você está em dia." />
      ) : (
        <ul className="flex-1 overflow-y-auto p-3">
          {notifications.map((n) => {
            const Icon = MODULE_ICON[n.moduleId] ?? Sprout
            return (
              <li
                key={n.id}
                className={cn(
                  'mb-2 flex items-start gap-3 rounded-xl border border-border-default bg-surface p-3',
                  !n.read && 'border-l-4 border-l-accent',
                )}
              >
                <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-accent-subtle text-accent">
                  <Icon size={18} />
                </span>
                <div className="flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="font-semibold text-fg">{n.title}</p>
                    <span className="text-xs text-fg-subtle">{n.time}</span>
                  </div>
                  <p className="text-sm text-fg-muted">{n.detail}</p>
                  <Chip tone="neutral" className="mt-1">
                    {n.moduleId}
                  </Chip>
                </div>
              </li>
            )
          })}
        </ul>
      )}
    </div>
  )
}
