import { useNavigate } from 'react-router-dom'
import { Calculator, ClipboardList, FileSignature, HelpCircle, ChevronRight } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Card, Heading, SectionTitle, MenuItem } from '@/components/ui'

interface LinkItem {
  label: string
  icon: LucideIcon
  to: string
}

const GROUPS: { title: string; items: LinkItem[] }[] = [
  {
    title: 'Crédito',
    items: [
      { label: 'Simular', icon: Calculator, to: '/credito/simular' },
      { label: 'Propostas', icon: ClipboardList, to: '/credito/propostas' },
      { label: 'Contratos', icon: FileSignature, to: '/credito/contratos' },
    ],
  },
  {
    title: 'Suporte',
    items: [{ label: 'Ajuda', icon: HelpCircle, to: '/credito/ajuda' }],
  },
]

/** Menu "Mais" do módulo Crédito — acesso consolidado a simulação, propostas e contratos. */
export function CreditoMaisScreen() {
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
