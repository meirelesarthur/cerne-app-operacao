import { useNavigate } from 'react-router-dom'
import { HandCoins, ArrowRight } from 'lucide-react'

/**
 * Card de deep-link de crédito pré-aprovado (spec §6.4): o dado/régua vive no módulo Crédito;
 * aqui é só um ponto de entrada com deep link entre módulos.
 */
export function CreditoBanner() {
  const navigate = useNavigate()
  return (
    <button
      onClick={() => navigate('/credito')}
      className="flex w-full items-center gap-3 rounded-2xl border border-border-tint bg-accent-subtle p-4 text-left"
    >
      <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent text-white">
        <HandCoins size={22} />
      </span>
      <div className="min-w-0 flex-1">
        <p className="text-sm font-medium text-accent">Crédito pré-aprovado</p>
        <p className="truncate font-bold text-fg">R$ 480.000,00 disponíveis</p>
        <p className="text-xs text-accent">Ver no módulo Crédito</p>
      </div>
      <ArrowRight size={18} className="shrink-0 text-accent" />
    </button>
  )
}
