import { MapPin } from 'lucide-react'
import { useFazendasStore } from '../state/fazendasStore'

/**
 * Badge de contexto fixo no topo de formulários operacionais (spec §3.5):
 * "Lançando em: {fazenda}" — mantém o tenant sempre visível (mitigação de UX p/ IDOR).
 */
export function ContextBadge() {
  const activeFarm = useFazendasStore((s) => s.activeFarm())
  return (
    <div className="flex items-center gap-1.5 border-b border-brand-200 bg-brand-50 px-4 py-2 text-sm font-semibold text-brand-700">
      <MapPin size={14} />
      Lançando em: {activeFarm.name}
    </div>
  )
}
