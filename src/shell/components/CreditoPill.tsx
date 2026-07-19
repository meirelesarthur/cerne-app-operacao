import { useNavigate } from 'react-router-dom'
import { CreditCard } from 'lucide-react'

/**
 * Pílula de crédito pré-aprovado no header do Shell (Nova UI): cápsula de
 * superfície theme-aware com valor em destaque — deep link para o módulo Crédito.
 */
export function CreditoPill() {
  const navigate = useNavigate()
  return (
    <button
      type="button"
      onClick={() => navigate('/credito')}
      className="inline-flex items-center gap-2 rounded-full border border-border-tint bg-surface py-1.5 pl-3 pr-3.5 shadow-card transition-all hover:shadow-card-hover active:scale-[0.98]"
    >
      <CreditCard size={14} className="text-accent" aria-hidden="true" />
      <span className="text-sm font-bold tabular-nums text-accent">R$ 480.000,00</span>
      <span className="text-xs font-medium text-fg-muted">crédito pré aprovado</span>
    </button>
  )
}
