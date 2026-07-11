import { useState } from 'react'
import { Clock, Inbox, PackageCheck, Truck } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { BottomSheet, Card, Chip, EmptyState } from '@/components/ui'
import type { ChipTone } from '@/components/ui'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { PEDIDOS, type Pedido, type PedidoStatus } from '../mocks/pedidos'

const STATUS_LABEL: Record<PedidoStatus, string> = {
  entregue: 'Entregue',
  'em-transporte': 'Em transporte',
  processando: 'Processando',
}

const STATUS_TONE: Record<PedidoStatus, ChipTone> = {
  entregue: 'brand',
  'em-transporte': 'blue',
  processando: 'amber',
}

const STATUS_ICON: Record<PedidoStatus, LucideIcon> = {
  entregue: PackageCheck,
  'em-transporte': Truck,
  processando: Clock,
}

/** Lista de pedidos do Marketplace (dados mockados) — item abre detalhe em BottomSheet. */
export function MarketplacePedidos() {
  const [pedidoSelecionado, setPedidoSelecionado] = useState<Pedido | null>(null)

  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title="Pedidos" />
      <div className="no-scrollbar flex-1 overflow-y-auto p-4">
        {PEDIDOS.length === 0 ? (
          <EmptyState
            icon={Inbox}
            title="Nenhum pedido ainda"
            description="Seus pedidos de insumos e máquinas aparecerão aqui assim que você comprar no Marketplace."
            className="h-full justify-center"
          />
        ) : (
          <div className="flex flex-col gap-3">
            {PEDIDOS.map((pedido) => {
              const StatusIcon = STATUS_ICON[pedido.status]
              return (
                <Card key={pedido.id} interactive onClick={() => setPedidoSelecionado(pedido)}>
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="font-semibold text-fg">Pedido {pedido.numero}</p>
                      <p className="text-xs text-fg-muted">{pedido.data}</p>
                    </div>
                    <Chip tone={STATUS_TONE[pedido.status]} icon={<StatusIcon size={12} aria-hidden="true" />}>
                      {STATUS_LABEL[pedido.status]}
                    </Chip>
                  </div>
                  <p className="mt-2 truncate text-sm text-fg-muted">
                    {pedido.itens.map((item) => item.nome).join(', ')}
                  </p>
                  <p className="mt-2 text-lg font-bold tabular-nums text-fg">{pedido.valor}</p>
                </Card>
              )
            })}
          </div>
        )}
      </div>

      <BottomSheet
        open={!!pedidoSelecionado}
        onClose={() => setPedidoSelecionado(null)}
        title={pedidoSelecionado ? `Pedido ${pedidoSelecionado.numero}` : undefined}
      >
        {pedidoSelecionado && (
          <div className="flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Data</span>
              <span className="font-semibold text-fg">{pedidoSelecionado.data}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-fg-muted">Status</span>
              <Chip
                tone={STATUS_TONE[pedidoSelecionado.status]}
                icon={(() => {
                  const StatusIcon = STATUS_ICON[pedidoSelecionado.status]
                  return <StatusIcon size={12} aria-hidden="true" />
                })()}
              >
                {STATUS_LABEL[pedidoSelecionado.status]}
              </Chip>
            </div>

            <div className="flex flex-col gap-2 rounded-2xl border border-border-default bg-surface-subtle p-3">
              {pedidoSelecionado.itens.map((item) => (
                <div key={item.nome} className="flex items-center justify-between gap-3">
                  <span className="min-w-0 truncate text-sm text-fg">{item.nome}</span>
                  <span className="shrink-0 text-sm text-fg-muted">x{item.quantidade}</span>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-between border-t border-border-default pt-3">
              <span className="font-semibold text-fg">Total</span>
              <span className="text-lg font-bold tabular-nums text-fg">{pedidoSelecionado.valor}</span>
            </div>
          </div>
        )}
      </BottomSheet>
    </div>
  )
}
