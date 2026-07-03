import { useNavigate } from 'react-router-dom'
import { TriangleAlert, ArrowDownLeft, ArrowUpRight, ShoppingBag, ArrowRight } from 'lucide-react'
import { Card, Chip, Heading, KpiStatCard, ProgressBar, SectionTitle, Skeleton } from '@/components/ui'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { KPIS, UNIDADES, MOVIMENTACOES, ALERTAS, type UnidadeStatus } from '../mocks/estoque'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

const STATUS_CHIP: Record<UnidadeStatus, { tone: 'brand' | 'amber' | 'red'; label: string }> = {
  ok: { tone: 'brand', label: 'Normal' },
  atencao: { tone: 'amber', label: 'Atenção' },
  critico: { tone: 'red', label: 'Crítico' },
}

/**
 * Home do módulo Armazém: ocupação e alertas em destaque, unidades de
 * armazenagem com nível de estoque e últimas movimentações físicas.
 */
export function ArmazemHome() {
  const navigate = useNavigate()
  const loading = useSimulatedLoad(700) === 'loading'

  return (
    <div className="flex flex-col gap-6 p-4">
      {/* KPIs de topo */}
      <div className="grid animate-rise grid-cols-3 gap-3" style={stagger(0)}>
        {loading ? (
          <>
            <Skeleton className="h-[74px]" rounded="xl" />
            <Skeleton className="h-[74px]" rounded="xl" />
            <Skeleton className="h-[74px]" rounded="xl" />
          </>
        ) : (
          <>
            <KpiStatCard label="Ocupação total" value={KPIS.ocupacao} />
            <KpiStatCard label="SKUs em estoque" value={KPIS.skus} />
            <KpiStatCard label="Alertas" value={KPIS.alertas} tone="warning" />
          </>
        )}
      </div>

      {/* Alertas ativos */}
      <div className="animate-rise" style={stagger(1)}>
        <Card>
          <div className="flex items-center gap-2">
            <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-amber-50 text-amber-600">
              <TriangleAlert size={16} aria-hidden="true" />
            </span>
            <Heading level={4}>Alertas</Heading>
          </div>
          <div className="mt-3 flex flex-col gap-3">
            {ALERTAS.map((alerta) => (
              <div key={alerta.id} className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-fg">{alerta.titulo}</p>
                  <p className="mt-0.5 text-xs text-fg-muted">{alerta.detalhe}</p>
                </div>
                <Chip tone="amber" className="shrink-0">
                  Ação sugerida
                </Chip>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Unidades de armazenagem */}
      <div className="animate-rise" style={stagger(2)}>
        <SectionTitle className="mb-2">Unidades de armazenagem</SectionTitle>
        <div className="flex flex-col gap-3">
          {UNIDADES.map((unidade) => {
            const chip = STATUS_CHIP[unidade.status]
            return (
              <Card key={unidade.id}>
                <div className="flex items-center justify-between gap-2">
                  <p className="truncate text-sm font-semibold text-fg">{unidade.nome}</p>
                  <Chip tone={chip.tone} className="shrink-0">
                    {chip.label}
                  </Chip>
                </div>
                <p className="mt-0.5 text-xs text-fg-muted">
                  {unidade.produto} · {unidade.capacidade}
                </p>
                <div className="mt-3 flex items-center gap-3">
                  <ProgressBar value={unidade.ocupacaoPct} colorByOccupancy className="flex-1" />
                  <span className="shrink-0 text-sm font-semibold tabular-nums text-fg">
                    {unidade.ocupacaoPct}%
                  </span>
                </div>
              </Card>
            )
          })}
        </div>
      </div>

      {/* Movimentações recentes */}
      <div className="animate-rise" style={stagger(3)}>
        <SectionTitle className="mb-2">Movimentações recentes</SectionTitle>
        <Card padded={false} className="px-4">
          {MOVIMENTACOES.map((mov) => {
            const isEntrada = mov.tipo === 'entrada'
            return (
              <div
                key={mov.id}
                className="flex items-center gap-3 border-b border-border-default py-3 last:border-0"
              >
                <span
                  className={
                    isEntrada
                      ? 'flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-accent-subtle text-accent'
                      : 'flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-surface-subtle text-fg-muted'
                  }
                  aria-hidden="true"
                >
                  {isEntrada ? <ArrowDownLeft size={18} /> : <ArrowUpRight size={18} />}
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-fg">{mov.item}</p>
                  <p className="truncate text-xs text-fg-muted">{mov.origem}</p>
                </div>
                <div className="shrink-0 text-right">
                  <p className={isEntrada ? 'text-sm font-bold tabular-nums text-accent' : 'text-sm font-bold tabular-nums text-fg'}>
                    {mov.quantidade}
                  </p>
                  <p className="text-xs text-fg-subtle">{mov.tempo}</p>
                </div>
              </div>
            )
          })}
        </Card>
      </div>

      {/* Banner deep-link para o Marketplace */}
      <div className="animate-rise" style={stagger(4)}>
        <Card interactive onClick={() => navigate('/marketplace')}>
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-accent text-white">
              <ShoppingBag size={22} aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-semibold text-fg">Reponha insumos no Marketplace</p>
              <p className="truncate text-xs text-fg-muted">Compre direto dos fornecedores parceiros</p>
            </div>
            <ArrowRight size={18} className="shrink-0 text-accent" aria-hidden="true" />
          </div>
        </Card>
      </div>
    </div>
  )
}
