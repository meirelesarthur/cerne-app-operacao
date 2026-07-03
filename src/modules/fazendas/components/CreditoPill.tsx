import { useNavigate } from 'react-router-dom'
import { CreditCard } from 'lucide-react'
import { t } from '@/design/tokens'

/**
 * Pílula de crédito pré-aprovado no header do Shell (premium clean):
 * deep link discreto para o módulo Crédito, no estilo da referência.
 */
export function CreditoPill() {
  const navigate = useNavigate()
  return (
    <button
      type="button"
      onClick={() => navigate('/credito')}
      className="inline-flex items-center gap-2 rounded-full py-1.5 pl-2.5 pr-3.5"
      style={{ background: t.component.header.creditBg, border: `1px solid ${t.component.header.creditBorder}` }}
    >
      <CreditCard size={14} className="text-brand-400" aria-hidden="true" />
      <span className="text-sm font-bold tabular-nums text-brand-400">R$ 480.000,00</span>
      <span className="text-xs font-normal text-white/55">crédito pré aprovado</span>
    </button>
  )
}
