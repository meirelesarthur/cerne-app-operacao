import { useNavigate } from 'react-router-dom'
import { Sprout, Landmark, HandCoins, ShoppingBag, ArrowLeft } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Heading } from '@/components/ui/Heading'
import { IconButton } from '@/components/ui/IconButton'

const HIGHLIGHTS = [
  { icon: Sprout, title: 'Fazendas', desc: 'Dashboards gerenciais e lançamentos de campo.' },
  { icon: Landmark, title: 'Bank', desc: 'Conta e pagamentos do produtor.' },
  { icon: HandCoins, title: 'Crédito', desc: 'Crédito pré-aprovado e simulações.' },
  { icon: ShoppingBag, title: 'Marketplace', desc: 'Compra e venda de insumos.' },
]

/** Onboarding mínimo do Shell — apresenta os módulos do superapp. */
export function Onboarding() {
  const navigate = useNavigate()

  return (
    <div className="flex h-full flex-col bg-canvas px-6 py-8">
      <IconButton label="Voltar para o login" className="self-start" onClick={() => navigate('/login')}>
        <ArrowLeft size={20} />
      </IconButton>

      <Heading level={2} className="mt-4">
        Um app, vários módulos
      </Heading>
      <p className="mt-1 text-md text-fg-muted">Cada módulo é um app da empresa, agora unificado.</p>

      <div className="mt-6 flex flex-1 flex-col gap-3">
        {HIGHLIGHTS.map((h) => (
          <Card key={h.title} className="flex items-center gap-3">
            <span className="flex h-11 w-11 items-center justify-center rounded-xl bg-accent-subtle text-accent">
              <h.icon size={22} />
            </span>
            <div>
              <p className="font-semibold text-fg">{h.title}</p>
              <p className="text-sm text-fg-muted">{h.desc}</p>
            </div>
          </Card>
        ))}
      </div>

      <Button fullWidth size="lg" onClick={() => navigate('/fazendas')}>
        Começar
      </Button>
    </div>
  )
}
