import { useNavigate } from 'react-router-dom'
import { Zap, Receipt, History, CreditCard, SlidersHorizontal, HelpCircle, ChevronRight } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Card, Heading, SectionTitle, MenuItem } from '@/components/ui'

interface LinkItem {
  label: string
  icon: LucideIcon
  to: string
}

const GROUPS: { title: string; items: LinkItem[] }[] = [
  {
    title: 'Pagamentos e transferências',
    items: [
      { label: 'Pix', icon: Zap, to: '/bank/pix' },
      { label: 'Pagamentos', icon: Receipt, to: '/bank/pagamentos' },
      { label: 'Extrato', icon: History, to: '/bank/extrato' },
    ],
  },
  {
    title: 'Cartão',
    items: [
      { label: 'Cartões', icon: CreditCard, to: '/bank/cartoes' },
      { label: 'Limites', icon: SlidersHorizontal, to: '/bank/limites' },
    ],
  },
  {
    title: 'Suporte',
    items: [{ label: 'Ajuda', icon: HelpCircle, to: '/bank/ajuda' }],
  },
]

/** Menu "Mais" do módulo Bank — acesso consolidado a pagamentos, cartão e suporte. */
export function BankMaisScreen() {
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
