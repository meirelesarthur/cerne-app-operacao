import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { TriangleAlert, ShoppingBag, ArrowRight } from 'lucide-react'
import { Card, Chip, Heading, KpiStatCard, SectionTitle, Skeleton, TransactionListItem } from '@/components/ui'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { KPIS, UNIDADES, MOVIMENTACOES, ALERTAS, type Unidade, type Movimentacao } from '../mocks/estoque'
import { toTransactionItem } from '../lib/movimentacoes'
import { UnidadeCard } from '../components/UnidadeCard'
import { UnidadeDetailSheet } from '../components/UnidadeDetailSheet'
import { MovimentacaoDetailSheet } from '../components/MovimentacaoDetailSheet'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

/**
 * Home do módulo Armazém: ocupação e alertas em destaque, unidades de
 * armazenagem (cards interativos com detalhe) e últimas movimentações
 * físicas (itens interativos com detalhe) — spec D2.
 */
export function ArmazemHome() {
  const navigate = useNavigate()
  const loading = useSimulatedLoad(700) === 'loading'
  const [selectedUnidade, setSelectedUnidade] = useState<Unidade | null>(null)
  const [selectedMov, setSelectedMov] = useState<Movimentacao | null>(null)

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

      {/* Unidades de armazenagem — cards interativos, abrem detalhe da unidade */}
      <div className="animate-rise" style={stagger(2)}>
        <SectionTitle className="mb-2">Unidades de armazenagem</SectionTitle>
        <div className="flex flex-col gap-3">
          {UNIDADES.map((unidade) => (
            <UnidadeCard key={unidade.id} unidade={unidade} onClick={() => setSelectedUnidade(unidade)} />
          ))}
        </div>
      </div>

      {/* Movimentações recentes — itens interativos, abrem detalhe da movimentação */}
      <div className="animate-rise" style={stagger(3)}>
        <SectionTitle className="mb-2">Movimentações recentes</SectionTitle>
        <Card padded={false} className="px-4">
          {MOVIMENTACOES.map((mov) => (
            <TransactionListItem
              key={mov.id}
              transaction={toTransactionItem(mov)}
              onClick={() => setSelectedMov(mov)}
            />
          ))}
        </Card>
      </div>

      {/* Banner deep-link para o Marketplace */}
      <div className="animate-rise" style={stagger(4)}>
        <Card interactive onClick={() => navigate('/marketplace')}>
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent text-white">
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

      <UnidadeDetailSheet unidade={selectedUnidade} onClose={() => setSelectedUnidade(null)} />
      <MovimentacaoDetailSheet movimentacao={selectedMov} onClose={() => setSelectedMov(null)} />
    </div>
  )
}
