import { Inbox, CloudOff, Scale, FileText, Truck, Wheat, ArrowLeftRight, Sprout } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Banner } from '@/components/ui/Banner'
import { Button } from '@/components/ui/Button'
import { Chip } from '@/components/ui/Chip'
import { EmptyState } from '@/components/ui/EmptyState'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import type { Activity } from '../types'

const KIND_ICON: Record<Activity['kind'], LucideIcon> = {
  pesagem: Scale,
  evento: ArrowLeftRight,
  nfe: FileText,
  venda: Truck,
  insumo: Sprout,
  arracoamento: Wheat,
}

/** Tela "Fila de sincronização" (spec §3.2/§6.9) — lista os lançamentos ainda não enviados ao servidor. */
export function SyncQueueScreen() {
  const isOnline = useShellStore((s) => s.isOnline)
  const queue = useFazendasStore((s) => s.syncQueue)
  const clearSync = useFazendasStore((s) => s.clearSync)

  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title="Fila de sincronização" />

      {queue.length > 0 && !isOnline && (
        <Banner tone="offline" icon={<CloudOff size={14} />}>
          Sem conexão — os itens serão enviados automaticamente assim que a internet voltar.
        </Banner>
      )}

      <div className="no-scrollbar flex flex-1 flex-col gap-4 overflow-y-auto p-4">
        {queue.length === 0 ? (
          <EmptyState
            icon={Inbox}
            title="Nenhum lançamento pendente"
            description="Tudo o que foi registrado em campo já está sincronizado com o servidor."
            className="flex-1 justify-center"
          />
        ) : (
          <>
            <div className="overflow-hidden rounded-2xl border border-border-default bg-surface px-3">
              {queue.map((item) => {
                const Icon = KIND_ICON[item.kind]
                return (
                  <div
                    key={item.id}
                    className="flex items-center gap-3 border-b border-border-subtle py-3 last:border-b-0"
                  >
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-surface-subtle text-fg-muted">
                      <Icon size={18} />
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-semibold text-fg">{item.label}</p>
                      <p className="truncate text-sm text-fg-muted">{item.detail}</p>
                    </div>
                    <Chip tone="amber">Pendente</Chip>
                  </div>
                )
              })}
            </div>

            <Button fullWidth disabled={!isOnline} onClick={clearSync}>
              Sincronizar agora
            </Button>
          </>
        )}
      </div>
    </div>
  )
}
