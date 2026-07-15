import { useState } from 'react'
import { Zap, ScanLine, ArrowLeftRight, HandCoins, ChevronRight, type LucideIcon } from 'lucide-react'
import { Heading, SectionTitle, Card, QuickAction } from '@/components/ui'
import { PixFlow } from './flows/PixFlow'
import { SimplePaymentFlow, type PaymentKind } from './flows/SimplePaymentFlow'

type Flow = 'pix' | PaymentKind

interface Acao {
  flow: Flow
  icon: LucideIcon
  label: string
  description: string
}

const ACOES: Acao[] = [
  { flow: 'pix', icon: Zap, label: 'Pix', description: 'Envie na hora por chave ou contato' },
  { flow: 'boleto', icon: ScanLine, label: 'Pagar boleto', description: 'Pague contas e boletos por cÃ³digo' },
  { flow: 'transferir', icon: ArrowLeftRight, label: 'Transferir', description: 'TED/entre contas para outro banco' },
  { flow: 'cobrar', icon: HandCoins, label: 'Cobrar', description: 'Gere uma cobranÃ§a Pix para receber' },
]

export interface PagamentosScreenProps {
  /** Abre direto em um fluxo especÃ­fico (ex.: deep-link /bank/pix). */
  initialFlow?: Flow
}

/**
 * Hub de Pagamentos do GB Bank â€” destino das QuickActions (Pix/Pagar/Transferir/
 * Cobrar). Cada aÃ§Ã£o entra num fluxo mockado (revisÃ£o â†’ sucesso). O Pix Ã© o
 * fluxo de referÃªncia, completo; os demais sÃ£o formulÃ¡rios simples honestos.
 */
export function PagamentosScreen({ initialFlow }: PagamentosScreenProps) {
  const [flow, setFlow] = useState<Flow | null>(initialFlow ?? null)
  const exit = () => setFlow(null)

  if (flow === 'pix') return <PixFlow onExit={exit} />
  if (flow) return <SimplePaymentFlow kind={flow} onExit={exit} />

  return (
    <div className="flex flex-col gap-5 p-4">
      <div>
        <Heading level={3}>Pagamentos</Heading>
        <p className="mt-0.5 text-sm text-fg-muted">Pix, boletos, transferÃªncias e cobranÃ§as em um sÃ³ lugar.</p>
      </div>

      <div className="grid grid-cols-4 gap-2">
        {ACOES.map((a) => (
          <QuickAction key={a.flow} icon={a.icon} label={a.label} onClick={() => setFlow(a.flow)} />
        ))}
      </div>

      <div>
        <SectionTitle className="mb-2">Todas as opÃ§Ãµes</SectionTitle>
        <div className="flex flex-col gap-2">
          {ACOES.map((a) => (
            <Card key={a.flow} interactive onClick={() => setFlow(a.flow)}>
              <div className="flex items-center gap-3">
                <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent-subtle text-accent">
                  <a.icon size={22} aria-hidden="true" />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-fg">{a.label}</p>
                  <p className="truncate text-xs text-fg-muted">{a.description}</p>
                </div>
                <ChevronRight size={18} className="shrink-0 text-fg-subtle" aria-hidden="true" />
              </div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  )
}
