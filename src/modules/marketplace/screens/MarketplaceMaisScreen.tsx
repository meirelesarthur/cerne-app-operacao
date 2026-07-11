import { useNavigate } from 'react-router-dom'
import { LayoutGrid, Package, Heart, HelpCircle, ChevronRight } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Card, Heading, SectionTitle, MenuItem } from '@/components/ui'

interface LinkItem {
  label: string
  icon: LucideIcon
  to: string
}

const GROUPS: { title: string; items: LinkItem[] }[] = [
  {
    title: 'Compras',
    items: [
      { label: 'Categorias', icon: LayoutGrid, to: '/marketplace/categorias' },
      { label: 'Pedidos', icon: Package, to: '/marketplace/pedidos' },
      { label: 'Favoritos', icon: Heart, to: '/marketplace/favoritos' },
    ],
  },
  {
    title: 'Suporte',
    items: [{ label: 'Ajuda', icon: HelpCircle, to: '/marketplace/ajuda' }],
  },
]

/** Menu "Mais" do módulo Marketplace — acesso consolidado a categorias, pedidos e favoritos. */
export function MarketplaceMaisScreen() {
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
