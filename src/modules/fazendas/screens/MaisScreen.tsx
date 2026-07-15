import { useNavigate } from 'react-router-dom'
import {
  Wallet,
  Beef,
  Warehouse,
  Package,
  Boxes,
  Activity as ActivityIcon,
  Users,
  Search,
  RefreshCw,
  ChevronRight,
} from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Heading, SectionTitle } from '@/components/ui/Heading'

interface LinkItem {
  label: string
  icon: LucideIcon
  to: string
}

const GROUPS: { title: string; items: LinkItem[] }[] = [
  {
    title: 'Dashboards gerenciais',
    items: [
      { label: 'Financeiro', icon: Wallet, to: '/fazendas/dashboards/financeiro' },
      { label: 'PecuÃ¡ria de Corte', icon: Beef, to: '/fazendas/dashboards/pecuaria' },
      { label: 'LotaÃ§Ã£o de Currais', icon: Warehouse, to: '/fazendas/dashboards/confinamento' },
      { label: 'Ativos / DepreciaÃ§Ã£o', icon: Package, to: '/fazendas/dashboards/ativos' },
      { label: 'Suprimentos', icon: Boxes, to: '/fazendas/dashboards/suprimentos' },
      { label: 'AnÃ¡lise de Uso', icon: Users, to: '/fazendas/dashboards/uso' },
      { label: 'Consultas Gerenciais', icon: Search, to: '/fazendas/dashboards/consultas' },
    ],
  },
  {
    title: 'Operacional',
    items: [
      { label: 'Fila de sincronizaÃ§Ã£o', icon: RefreshCw, to: '/fazendas/mais/sync' },
      { label: 'Todas as atividades', icon: ActivityIcon, to: '/fazendas/atividades' },
    ],
  },
]

/** Menu "Mais" (spec Â§3.2) â€” hub expandido com acesso a dashboards e Ã¡reas do mÃ³dulo. */
export function MaisScreen() {
  const navigate = useNavigate()
  return (
    <div className="flex flex-col gap-5 p-4">
      <Heading level={2}>Mais</Heading>
      {GROUPS.map((g) => (
        <div key={g.title}>
          <SectionTitle className="mb-2">{g.title}</SectionTitle>
          <div className="overflow-hidden rounded-2xl border border-border-default bg-surface">
            {g.items.map((it) => (
              <button
                key={it.label}
                onClick={() => navigate(it.to)}
                className="flex w-full items-center gap-3 border-b border-border-subtle px-4 py-3 text-left last:border-b-0"
              >
                <span className="flex h-9 w-9 items-center justify-center rounded-full bg-accent-subtle text-accent">
                  <it.icon size={18} />
                </span>
                <span className="flex-1 font-medium text-fg">{it.label}</span>
                <ChevronRight size={16} className="text-fg-subtle" />
              </button>
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}
