import { useNavigate } from 'react-router-dom'
import {
  AreaChart,
  Beef,
  Bluetooth,
  Boxes,
  ClipboardList,
  FileClock,
  Gauge,
  Leaf,
  RefreshCw,
  ShieldCheck,
  Sprout,
  Tractor,
  Warehouse,
} from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Banner } from '@/components/ui/Banner'
import { Card } from '@/components/ui/Card'
import { Chip, type ChipTone } from '@/components/ui/Chip'
import { Heading, SectionTitle } from '@/components/ui/Heading'
import { MenuItem } from '@/components/ui/MenuItem'
import {
  ADMIN_FEATURES,
  OPERATIONAL_FEATURES,
  groupFeatures,
  type FeatureDefinition,
  type FeatureStatus,
} from '../functionalCatalog'

type WorkspaceRole = 'administrativo' | 'operacional'

const GROUP_ICONS: Record<string, LucideIcon> = {
  'Painéis de decisão': AreaChart,
  'Consultas e auditoria': ShieldCheck,
  Cadastros: ClipboardList,
  Estoque: Boxes,
  Misturador: Bluetooth,
  Agricultura: Sprout,
  Pecuária: Beef,
  Reprodução: Leaf,
  'Gestão de frota': Tractor,
  'Ordem de serviço': FileClock,
  Sincronização: RefreshCw,
}

const STATUS: Record<FeatureStatus, { label: string; tone: ChipTone }> = {
  ready: { label: 'Pronto', tone: 'brand' },
  mapped: { label: 'Mapeado', tone: 'blue' },
  hardware: { label: 'Hardware', tone: 'amber' },
}

function FeatureStatusChip({ feature }: { feature: FeatureDefinition }) {
  const status = STATUS[feature.status]
  return <Chip tone={status.tone}>{status.label}</Chip>
}

/**
 * Home por responsabilidade. É a fronteira visual e navegável entre leitura/decisão
 * e entrada de dados, alimentada pelo catálogo funcional do AGRO365.
 */
export function ResponsibilityWorkspace({ role }: { role: WorkspaceRole }) {
  const navigate = useNavigate()
  const administrative = role === 'administrativo'
  const features = administrative ? ADMIN_FEATURES : OPERATIONAL_FEATURES
  const grouped = groupFeatures(features)
  const mappedCount = features.filter((feature) => feature.status !== 'ready').length

  const openFeature = (feature: FeatureDefinition) => {
    navigate(feature.existingRoute ?? `/fazendas/${role}/${feature.id}`)
  }

  return (
    <div className="flex flex-col gap-5 p-4">
      <Card variant="ink" className="overflow-hidden">
        <div className="flex items-start justify-between gap-4">
          <div>
            <Chip tone={administrative ? 'blue' : 'brand'}>
              {administrative ? 'Perfil Administração' : 'Perfil Operacional'}
            </Chip>
            <Heading level={2} className="mt-3 text-ink-fg">
              {administrative ? 'Central de gestão' : 'Rotinas de campo'}
            </Heading>
            <p className="mt-1 text-sm text-ink-muted">
              {administrative
                ? 'Indicadores, consultas e auditoria para supervisão e tomada de decisão.'
                : 'Cadastros e lançamentos executados pelos funcionários da fazenda.'}
            </p>
          </div>
          <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-ink-bubble text-nav-active">
            {administrative ? <Gauge size={22} /> : <Warehouse size={22} />}
          </span>
        </div>
        <div className="mt-5 grid grid-cols-2 gap-2 border-t border-ink-line pt-4">
          <div>
            <p className="text-2xl font-bold tabular-nums">{features.length}</p>
            <p className="text-xs text-ink-muted">funcionalidades no perfil</p>
          </div>
          <div>
            <p className="text-2xl font-bold tabular-nums">{mappedCount}</p>
            <p className="text-xs text-ink-muted">itens na esteira de evolução</p>
          </div>
        </div>
      </Card>

      <Banner tone="info" icon={<ShieldCheck size={15} />}>
        {administrative
          ? 'Este ambiente não cria lançamentos operacionais.'
          : 'Dashboards e decisões gerenciais não ficam disponíveis neste ambiente.'}
      </Banner>

      {Object.entries(grouped).map(([group, items]) => {
        const Icon = GROUP_ICONS[group] ?? ClipboardList
        return (
          <section key={group}>
            <SectionTitle className="mb-2">{group}</SectionTitle>
            <div className="flex flex-col gap-2">
              {items.map((feature) => (
                <MenuItem
                  key={feature.id}
                  icon={Icon}
                  label={feature.title}
                  description={feature.objective}
                  trailing={<FeatureStatusChip feature={feature} />}
                  onClick={() => openFeature(feature)}
                />
              ))}
            </div>
          </section>
        )
      })}
    </div>
  )
}
