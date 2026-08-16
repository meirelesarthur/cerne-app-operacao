import { RefreshCw, CloudOff } from 'lucide-react'
import { Banner } from '@/components/ui/Banner'
import { Button } from '@/components/ui/Button'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'

/**
 * Banner de status de sincronização (spec §6.9): mostra a contagem de lançamentos pendentes.
 * Online → permite "Sincronizar agora" (esvazia a fila). Offline → aguarda conexão.
 */
export function SyncBanner() {
  const isOnline = useShellStore((s) => s.isOnline)
  const queue = useFazendasStore((s) => s.syncQueue)
  const clearSync = useFazendasStore((s) => s.clearSync)

  if (queue.length === 0) return null

  const label = `${queue.length} lançamento${queue.length > 1 ? 's' : ''} aguardando sincronização`

  return (
    <Banner
      tone="warning"
      icon={isOnline ? <RefreshCw size={14} /> : <CloudOff size={14} />}
      action={
        isOnline ? (
          <Button size="sm" variant="ghost" className="px-2 text-amber-800" onClick={clearSync}>
            Sincronizar
          </Button>
        ) : undefined
      }
    >
      {label}
    </Banner>
  )
}
