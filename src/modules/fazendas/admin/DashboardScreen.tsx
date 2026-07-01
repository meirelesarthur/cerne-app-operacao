import type { ReactNode } from 'react'
import { CloudOff, ShieldAlert } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Banner } from '@/components/ui/Banner'
import { Chip } from '@/components/ui/Chip'
import { CardSkeleton } from '@/components/ui/Skeleton'
import { useShellStore } from '@/shell/state/shellStore'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'

export interface DashboardScreenProps {
  title: string
  /** marca a tela como de acesso restrito (spec §4.6). */
  restricted?: boolean
  children: ReactNode
}

/**
 * Scaffold comum dos dashboards administrativos (spec §7.1): cabeçalho, banner de offline
 * com timestamp da última sincronização, e skeleton de carregamento.
 */
export function DashboardScreen({ title, restricted, children }: DashboardScreenProps) {
  const isOnline = useShellStore((s) => s.isOnline)
  const state = useSimulatedLoad()

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader
        title={title}
        action={
          restricted ? (
            <Chip tone="amber" icon={<ShieldAlert size={12} />} className="mr-1">
              Acesso restrito
            </Chip>
          ) : undefined
        }
      />

      {!isOnline && (
        <Banner tone="info" icon={<CloudOff size={14} />}>
          Dados de 01/07 às 08:00 — última sincronização.
        </Banner>
      )}

      {state === 'loading' ? (
        <div className="grid grid-cols-2 gap-3 p-4">
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
          <CardSkeleton />
        </div>
      ) : (
        <div className="no-scrollbar flex-1 overflow-y-auto p-4">{children}</div>
      )}
    </div>
  )
}
