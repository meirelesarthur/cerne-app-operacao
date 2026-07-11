import { t } from '@/design/tokens'
import { CARTAO } from '@/modules/bank/mocks/banking'

const hubCard = t.component.hub.bankCard

export interface BankCardVisualProps {
  /** Exibe o número do cartão (mascarado além dos 4 finais); default true. */
  showNumber?: boolean
  className?: string
}

/**
 * Face do cartão corporativo GB — gradiente premium (tokens component.hub.bankCard)
 * reutilizado pela BankHome e pela tela de Cartões (fonte única, Lei 2).
 */
export function BankCardVisual({ showNumber = true, className }: BankCardVisualProps) {
  return (
    <div
      className={className}
      style={{ background: `linear-gradient(135deg, ${hubCard.from} 0%, ${hubCard.to} 100%)` }}
    >
      <div className="relative overflow-hidden p-5 text-white">
        <div
          aria-hidden="true"
          className="pointer-events-none absolute -right-8 -top-14 h-40 w-40 rounded-full"
          style={{ background: `radial-gradient(circle, ${hubCard.glow} 0%, transparent 70%)` }}
        />
        <div className="relative flex items-start justify-between">
          <div>
            <p className="text-xs font-medium" style={{ color: hubCard.fgMuted }}>
              {CARTAO.tipo}
            </p>
            <p className="mt-0.5 text-sm font-semibold">{CARTAO.titular}</p>
          </div>
          <span className="text-sm font-bold italic tracking-tight">{CARTAO.bandeira}</span>
        </div>
        {showNumber && (
          <p className="relative mt-6 text-lg font-semibold tabular-nums tracking-widest">
            •••• •••• •••• {CARTAO.final}
          </p>
        )}
        <div className="relative mt-4 flex items-end justify-between">
          <div>
            <p className="text-xs uppercase tracking-wide" style={{ color: hubCard.fgMuted }}>
              Validade
            </p>
            <p className="text-sm font-semibold tabular-nums">{CARTAO.validade}</p>
          </div>
          <p className="text-xs font-medium" style={{ color: hubCard.fgMuted }}>
            Final {CARTAO.final}
          </p>
        </div>
      </div>
    </div>
  )
}
