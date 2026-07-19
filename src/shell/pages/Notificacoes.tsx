import { BellOff, Sprout, Landmark, HandCoins } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { EmptyState } from '@/components/ui/EmptyState'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Chip } from '@/components/ui/Chip'
import { useShellStore } from '@/shell/state/shellStore'
import { getModule } from '@/shell/moduleConfig'
import { cn } from '@/lib/cn'

const MODULE_ICON: Record<string, typeof Sprout> = {
  fazendas: Sprout,
  credito: HandCoins,
  bank: Landmark,
}

/** Notificações agregadas de todos os módulos (spec §3.1). */
export function Notificacoes() {
  const navigate = useNavigate()
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
            const destination = getModule(n.moduleId)?.homeRoute ?? '/inicio'
            return (
              <li key={n.id} className="mb-2">
                <Card
                  interactive
                  padded={false}
                  onClick={() => navigate(destination)}
                  className={cn('flex items-start gap-3 p-3', !n.read && 'ring-1 ring-cta/60')}
                >
                  <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-accent-subtle text-accent">
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
                </Card>
              </li>
            )
          })}
        </ul>
      )}
    </div>
  )
}
