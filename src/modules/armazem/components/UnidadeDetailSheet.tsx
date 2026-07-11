import { useNavigate } from 'react-router-dom'
import { MapPin } from 'lucide-react'
import { BottomSheet, Button, Chip, ProgressBar } from '@/components/ui'
import { ITENS_ESTOQUE, type Unidade } from '../mocks/estoque'
import { STATUS_CHIP } from './UnidadeCard'

export interface UnidadeDetailSheetProps {
  /** Unidade selecionada — `null` mantém o sheet fechado. */
  unidade: Unidade | null
  onClose: () => void
}

/**
 * Detalhe de Unidade de armazenagem: BottomSheet acionado pelo `UnidadeCard`
 * na Home e na aba Unidades — capacidade, ocupação, produtos armazenados,
 * endereço mock e CTA para o estoque já filtrado pela unidade.
 */
export function UnidadeDetailSheet({ unidade, onClose }: UnidadeDetailSheetProps) {
  return (
    <BottomSheet open={!!unidade} onClose={onClose} title="Detalhe da unidade">
      {unidade && <SheetBody unidade={unidade} onClose={onClose} />}
    </BottomSheet>
  )
}

function SheetBody({ unidade, onClose }: { unidade: Unidade; onClose: () => void }) {
  const navigate = useNavigate()
  const chip = STATUS_CHIP[unidade.status]
  const itens = ITENS_ESTOQUE.filter((it) => it.unidadeId === unidade.id)

  const irParaEstoque = () => {
    onClose()
    navigate(`/armazem/estoque?unidade=${unidade.id}`)
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between gap-2">
        <p className="text-lg font-semibold text-fg">{unidade.nome}</p>
        <Chip tone={chip.tone} className="shrink-0">
          {chip.label}
        </Chip>
      </div>

      {/* Ocupação */}
      <div className="rounded-2xl border border-border-default bg-surface-subtle p-4">
        <div className="flex items-center justify-between gap-3">
          <span className="text-sm text-fg-muted">Ocupação</span>
          <span className="text-sm font-semibold tabular-nums text-fg">
            {unidade.ocupacaoPct}% de {unidade.capacidade}
          </span>
        </div>
        <ProgressBar value={unidade.ocupacaoPct} colorByOccupancy className="mt-2" />
      </div>

      {/* Produtos armazenados */}
      {itens.length > 0 && (
        <div className="flex flex-col gap-2">
          <p className="text-xs font-semibold uppercase tracking-wide text-fg-subtle">Produtos armazenados</p>
          {itens.map((it) => (
            <div
              key={it.id}
              className="flex items-center justify-between gap-3 rounded-xl border border-border-default p-3"
            >
              <span className="min-w-0 truncate text-sm font-medium text-fg">{it.produto}</span>
              <span className="shrink-0 text-sm tabular-nums text-fg-muted">{it.quantidadeLabel}</span>
            </div>
          ))}
        </div>
      )}

      {/* Endereço mock */}
      <p className="flex items-center gap-1.5 text-sm text-fg-muted">
        <MapPin size={14} className="shrink-0" aria-hidden="true" />
        {unidade.endereco}
      </p>

      <Button variant="primary" fullWidth onClick={irParaEstoque}>
        Ver estoque da unidade
      </Button>
    </div>
  )
}
