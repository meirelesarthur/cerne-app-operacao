import { useNavigate } from 'react-router-dom'
import { Boxes, ArrowLeftRight, Warehouse, BarChart3, ChevronRight } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Card, Heading, SectionTitle, MenuItem } from '@/components/ui'

interface LinkItem {
  label: string
  icon: LucideIcon
  to: string
}

const GROUPS: { title: string; items: LinkItem[] }[] = [
  {
    title: 'Operação',
    items: [
      { label: 'Estoque', icon: Boxes, to: '/armazem/estoque' },
      { label: 'Movimentações', icon: ArrowLeftRight, to: '/armazem/movimentacoes' },
      { label: 'Unidades', icon: Warehouse, to: '/armazem/unidades' },
    ],
  },
  {
    title: 'Gestão',
    items: [{ label: 'Relatórios', icon: BarChart3, to: '/armazem/relatorios' }],
  },
]

/** Menu "Mais" do módulo Armazém — acesso consolidado a estoque, unidades e relatórios. */
export function ArmazemMaisScreen() {
  const navigate = useNavigate()
  return (
    <div className="flex flex-col gap-5 p-4">
      <Heading level={2}>Mais</Heading>
      {GROUPS.map((g) => (
        <div key={g.title}>
          <SectionTitle className="mb-2">{g.title}</SectionTitle>
          <Card padded={false} className="divide-y divide-border-default overflow-hidden px-2 py-1">
            {g.items.map((it) => (
              <MenuItem
                key={it.label}
                icon={it.icon}
                label={it.label}
                trailing={<ChevronRight size={16} className="text-fg-subtle" aria-hidden="true" />}
                onClick={() => navigate(it.to)}
              />
            ))}
          </Card>
        </div>
      ))}
    </div>
  )
}
