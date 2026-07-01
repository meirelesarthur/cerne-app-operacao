import { useNavigate } from 'react-router-dom'
import {
  Wallet,
  Beef,
  Warehouse,
  Package,
  MoreHorizontal,
  ChevronDown,
  Scale,
  ArrowLeftRight,
  Wheat,
  Truck,
  FileText,
  Sprout,
  ArrowRight,
} from 'lucide-react'
import { DashboardCard } from '@/components/ui/DashboardCard'
import { Heading, SectionTitle } from '@/components/ui/Heading'
import { Chip } from '@/components/ui/Chip'
import { ShortcutGrid, type Shortcut } from '../components/ShortcutGrid'
import { ContextBadge } from '../components/ContextBadge'
import { ActivityListItem } from '../components/ActivityListItem'
import { useFazendasStore } from '../state/fazendasStore'
import { ATIVIDADES } from '../mocks/atividades'

/**
 * Home do módulo Fazendas (aba Dashboard), reproduzindo o padrão do print.
 * Alterna conteúdo entre a visão Gerencial (leitura) e Campo (escrita) via fazendasStore.
 */
export function FazendasHome() {
  const navigate = useNavigate()
  const view = useFazendasStore((s) => s.view)

  return view === 'gerencial' ? <HomeGerencial navigate={navigate} /> : <HomeCampo navigate={navigate} />
}

function HomeGerencial({ navigate }: { navigate: ReturnType<typeof useNavigate> }) {
  const adminShortcuts: Shortcut[] = [
    { id: 'financeiro', label: 'Financeiro', icon: Wallet, tone: 'brand', onClick: () => navigate('/fazendas/dashboards/financeiro') },
    { id: 'pecuaria', label: 'Pecuária', icon: Beef, tone: 'blue', onClick: () => navigate('/fazendas/dashboards/pecuaria') },
    { id: 'confinamento', label: 'Currais', icon: Warehouse, tone: 'amber', onClick: () => navigate('/fazendas/dashboards/confinamento') },
    { id: 'ativos', label: 'Ativos', icon: Package, tone: 'purple', onClick: () => navigate('/fazendas/dashboards/ativos') },
    { id: 'mais', label: 'Mais', icon: MoreHorizontal, tone: 'brand', onClick: () => navigate('/fazendas/mais') },
  ]

  return (
    <div className="flex flex-col gap-5 p-4">
      <div className="flex items-center justify-between">
        <Heading level={3}>Resumo da safra</Heading>
        <button className="inline-flex items-center gap-1 rounded-full border border-border-default bg-surface px-3 py-1 text-sm font-semibold text-fg">
          Safra 24/25 <ChevronDown size={14} />
        </button>
      </div>

      <ShortcutGrid items={adminShortcuts} columns={5} />

      <div className="grid grid-cols-2 gap-3">
        <DashboardCard icon={Wallet} label="Receita" value="R$ 2,4 mi" delta={12} spark={[8, 10, 9, 12, 14, 13, 16]} />
        <DashboardCard icon={Package} label="Custo" value="R$ 1,1 mi" delta={-4} spark={[9, 8, 8, 7, 6, 7, 6]} />
      </div>
      <DashboardCard icon={Beef} label="Margem operacional" value="R$ 1,3 mi" delta={9} spark={[4, 6, 5, 7, 8, 9, 11]} variant="finance" />

      <div>
        <div className="mb-1 flex items-center justify-between">
          <SectionTitle>Atividades recentes</SectionTitle>
          <button className="inline-flex items-center gap-0.5 text-sm font-semibold text-accent" onClick={() => navigate('/fazendas/atividades')}>
            Ver todas <ArrowRight size={13} />
          </button>
        </div>
        <div className="rounded-2xl border border-border-default bg-surface px-3">
          {ATIVIDADES.slice(0, 4).map((a) => (
            <ActivityListItem key={a.id} activity={a} />
          ))}
        </div>
      </div>
    </div>
  )
}

function HomeCampo({ navigate }: { navigate: ReturnType<typeof useNavigate> }) {
  const syncQueue = useFazendasStore((s) => s.syncQueue)

  const campoShortcuts: Shortcut[] = [
    { id: 'pesagem', label: 'Pesagem', icon: Scale, tone: 'brand', onClick: () => navigate('/fazendas/campo/pesagem') },
    { id: 'ciclo', label: 'Ciclo rebanho', icon: ArrowLeftRight, tone: 'blue', onClick: () => navigate('/fazendas/campo/ciclo') },
    { id: 'arracoamento', label: 'Arraçoamento', icon: Wheat, tone: 'amber', onClick: () => navigate('/fazendas/campo/arracoamento') },
    { id: 'venda', label: 'Venda', icon: Truck, tone: 'purple', onClick: () => navigate('/fazendas/campo/venda') },
    { id: 'nfe', label: 'Entrada NF-e', icon: FileText, tone: 'blue', onClick: () => navigate('/fazendas/campo/recebimento') },
    { id: 'insumos', label: 'Insumos', icon: Sprout, tone: 'brand', onClick: () => navigate('/fazendas/campo/insumos') },
  ]

  return (
    <div className="flex flex-col">
      <ContextBadge />
      <div className="flex flex-col gap-5 p-4">
        <div>
          <Heading level={3}>Lançamentos de campo</Heading>
          <p className="mt-0.5 text-sm text-fg-muted">Escolha o tipo de registro para começar.</p>
        </div>

        <ShortcutGrid items={campoShortcuts} columns={4} />

        <div className="rounded-2xl border border-border-default bg-surface p-4">
          <div className="flex items-center justify-between">
            <SectionTitle>Fila de sincronização</SectionTitle>
            <Chip tone={syncQueue.length ? 'amber' : 'brand'}>
              {syncQueue.length ? `${syncQueue.length} pendente(s)` : 'Tudo sincronizado'}
            </Chip>
          </div>
          <p className="mt-2 text-sm text-fg-muted">
            {syncQueue.length
              ? 'Lançamentos feitos offline serão enviados quando a conexão voltar.'
              : 'Nenhum lançamento aguardando envio.'}
          </p>
        </div>
      </div>
    </div>
  )
}
