import { useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Boxes } from 'lucide-react'
import { Card, Chip, EmptyState, FormSelect, Heading, ProgressBar, type ChipTone, type FormSelectOption } from '@/components/ui'
import { ITENS_ESTOQUE, UNIDADES, type UnidadeStatus } from '../mocks/estoque'

const STATUS_CHIP: Record<UnidadeStatus, { tone: ChipTone; label: string }> = {
  ok: { tone: 'brand', label: 'Ok' },
  atencao: { tone: 'amber', label: 'Atenção' },
  critico: { tone: 'red', label: 'Crítico' },
}

const PROGRESS_TONE: Record<UnidadeStatus, 'brand' | 'amber' | 'red'> = {
  ok: 'brand',
  atencao: 'amber',
  critico: 'red',
}

/**
 * Aba "Estoque": itens armazenados por unidade, com filtro por unidade
 * (spec D2.1). Aceita `?unidade=<id>` na URL para chegar já filtrada a
 * partir do CTA do `UnidadeDetailSheet`.
 */
export function EstoqueScreen() {
  const [searchParams, setSearchParams] = useSearchParams()
  const [unidadeId, setUnidadeId] = useState(searchParams.get('unidade') ?? '')

  const options: FormSelectOption[] = useMemo(
    () => [{ value: '', label: 'Todas as unidades' }, ...UNIDADES.map((u) => ({ value: u.id, label: u.nome }))],
    [],
  )

  const itens = unidadeId ? ITENS_ESTOQUE.filter((it) => it.unidadeId === unidadeId) : ITENS_ESTOQUE
  const unidadeNome = (id: string) => UNIDADES.find((u) => u.id === id)?.nome ?? ''

  const onChangeUnidade = (value: string) => {
    setUnidadeId(value)
    setSearchParams(value ? { unidade: value } : {})
  }

  return (
    <div className="flex flex-col gap-4 p-4">
      <Heading level={2}>Estoque</Heading>

      <FormSelect
        options={options}
        value={unidadeId}
        onChange={(e) => onChangeUnidade(e.target.value)}
        aria-label="Filtrar por unidade"
      />

      {itens.length === 0 ? (
        <EmptyState
          icon={Boxes}
          title="Nenhum item"
          description="Não há itens de estoque para esta unidade."
          className="h-full justify-center"
        />
      ) : (
        <div className="flex flex-col gap-3">
          {itens.map((it) => {
            const chip = STATUS_CHIP[it.status]
            return (
              <Card key={it.id}>
                <div className="flex items-center justify-between gap-2">
                  <p className="truncate text-sm font-semibold text-fg">{it.produto}</p>
                  <Chip tone={chip.tone} className="shrink-0">
                    {chip.label}
                  </Chip>
                </div>
                <p className="mt-0.5 text-xs text-fg-muted">{unidadeNome(it.unidadeId)}</p>
                <div className="mt-3 flex items-center gap-3">
                  <ProgressBar value={it.ocupacaoPct} tone={PROGRESS_TONE[it.status]} className="flex-1" />
                  <span className="shrink-0 text-xs font-medium tabular-nums text-fg-muted">
                    {it.quantidadeLabel} / {it.capacidadeLabel}
                  </span>
                </div>
              </Card>
            )
          })}
        </div>
      )}
    </div>
  )
}
