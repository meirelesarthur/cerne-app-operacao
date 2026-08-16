import { useState, type ReactNode } from 'react'
import { TrendingUp, TrendingDown } from 'lucide-react'
import { Chip, type ChipTone } from '@/components/ui/Chip'
import { Card } from '@/components/ui/Card'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { SparklineArea } from '@/components/ui/SparklineArea'
import { Pressable } from '@/components/ui/Pressable'
import { DashboardScreen } from './DashboardScreen'
import { COTACOES, type Cotacao, type CotacaoStatus } from '../mocks/dashboards'
import { cn } from '@/lib/cn'
import { t } from '@/design/tokens'

const TIPOS = ['Todos', 'Produto', 'Serviço', 'Frete', 'Manutenção'] as const

const STATUS_META: Record<CotacaoStatus, { label: string; tone: ChipTone }> = {
  cotacao: { label: 'Em cotação', tone: 'blue' },
  aprovada: { label: 'Aprovada', tone: 'brand' },
  recusada: { label: 'Recusada', tone: 'red' },
}

/** Formata número cru do mock como preço em reais (mesmo padrão de `precoAtual`). */
const formatPreco = (v: number) => v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })

/**
 * Dashboard de Suprimentos (spec §4.4) — status PARCIAL: UI completa com mock,
 * mas com selo "Dados de exemplo" sinalizando fonte a confirmar.
 */
export function DashSuprimentos() {
  const [filtro, setFiltro] = useState<(typeof TIPOS)[number]>('Todos')
  const [selected, setSelected] = useState<Cotacao | null>(null)
  const lista: Cotacao[] = COTACOES.filter((c) => filtro === 'Todos' || c.tipo === filtro)

  return (
    <DashboardScreen title="Suprimentos">
      <div className="no-scrollbar -mx-1 flex gap-2 overflow-x-auto px-1 pb-1">
        {TIPOS.map((tipo) => (
          <Pressable
            key={tipo}
            onClick={() => setFiltro(tipo)}
            className={cn(
              'whitespace-nowrap rounded-full border px-3 py-1 text-sm font-semibold',
              filtro === tipo ? 'border-accent bg-accent text-white' : 'border-border-default bg-surface text-fg-muted',
            )}
          >
            {tipo}
          </Pressable>
        ))}
      </div>

      <div className="mt-3 flex flex-col gap-2">
        {lista.map((c) => {
          const status = STATUS_META[c.status]
          return (
            <Card key={c.id} interactive padded={false} className="p-3" onClick={() => setSelected(c)}>
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="font-semibold text-fg">{c.fornecedor}</p>
                  <p className="text-sm text-fg-muted">
                    {c.tipo} · {c.itens} itens
                  </p>
                </div>
                <Chip tone={status.tone}>{status.label}</Chip>
              </div>
              <div className="mt-2 flex items-center justify-between">
                <span className="text-lg font-bold text-fg">{c.total}</span>
                <span className="text-xs italic text-fg-subtle">Dados de exemplo</span>
              </div>
            </Card>
          )
        })}
      </div>

      <BottomSheet open={!!selected} onClose={() => setSelected(null)} title="Detalhe da cotação">
        {selected && <CotacaoSheetBody cotacao={selected} />}
      </BottomSheet>
    </DashboardScreen>
  )
}

function CotacaoSheetBody({ cotacao: c }: { cotacao: Cotacao }) {
  const status = STATUS_META[c.status]
  const alta = c.variacao >= 0
  const historicoLabels = ['2 cotações atrás', 'Cotação anterior', 'Atual']

  return (
    <div className="flex flex-col gap-4">
      {/* Identidade da cotação */}
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wide text-fg-subtle">{c.tipo}</p>
          <p className="truncate text-lg font-semibold text-fg">{c.produto}</p>
          <p className="truncate text-sm text-fg-muted">{c.fornecedor}</p>
        </div>
        <Chip tone={status.tone} className="shrink-0">
          {status.label}
        </Chip>
      </div>

      {/* Preço vigente + variação acessível (ícone + sinal, nunca só cor) */}
      <div className="flex flex-col items-center gap-1 rounded-2xl border border-border-default bg-surface-subtle p-4 text-center">
        <p className="text-3xl font-bold tabular-nums tracking-tight text-fg">{c.precoAtual}</p>
        <p className="text-xs text-fg-subtle">por {c.unidade}</p>
        <span
          className={cn(
            'mt-1 inline-flex items-center gap-1 text-sm font-semibold tabular-nums',
            alta ? 'text-brand-600' : 'text-red-600',
          )}
        >
          {alta ? <TrendingUp size={14} aria-hidden="true" /> : <TrendingDown size={14} aria-hidden="true" />}
          {alta ? '+' : ''}
          {c.variacao.toLocaleString('pt-BR', { maximumFractionDigits: 1 })}% frente à cotação anterior
        </span>
      </div>

      {/* Ficha da cotação */}
      <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
        <DetailRow label="Unidade" value={c.unidade} />
        <DetailRow label="Validade da cotação" value={c.validade} />
        <DetailRow label="Itens" value={c.itens} />
        <DetailRow label="Total" value={c.total} />
      </div>

      {/* Mini-histórico de preço (3 pontos) */}
      <div>
        <p className="mb-2 text-sm text-fg-muted">Histórico de preço</p>
        <SparklineArea
          data={c.historico}
          color={alta ? t.color.brand[600] : t.color.red[500]}
          width={240}
          height={40}
          className="w-full"
        />
        <div className="mt-2 flex items-center justify-between">
          {c.historico.map((v, i) => (
            <div key={historicoLabels[i]} className="text-center">
              <p className="text-xs text-fg-subtle">{historicoLabels[i]}</p>
              <p className="text-sm font-semibold tabular-nums text-fg">{formatPreco(v)}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Selo do dashboard (spec §4.4) + padrão honesto do protótipo */}
      <p className="text-sm text-fg-subtle">
        <span className="italic">Dados de exemplo</span> — ficha completa da cotação, anexos e histórico de
        negociação ficam no sistema web GB CERNE.
      </p>
    </div>
  )
}

function DetailRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3">
      <span className="shrink-0 text-sm text-fg-muted">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{value}</span>
    </div>
  )
}
