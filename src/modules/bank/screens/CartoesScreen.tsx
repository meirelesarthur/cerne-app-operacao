import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Lock, ShieldCheck, RefreshCw, SlidersHorizontal, ChevronRight, Construction } from 'lucide-react'
import {
  Heading,
  SectionTitle,
  Card,
  Banner,
  Button,
  ProgressBar,
  ToggleSwitch,
  MenuItem,
  BottomSheet,
  Chip,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { CARTAO } from '@/modules/bank/mocks/banking'
import { BankCardVisual } from '@/modules/bank/components/BankCardVisual'

type Sheet = 'segundaVia' | 'ajustarLimite'

const SHEET_META: Record<Sheet, { title: string; body: string }> = {
  segundaVia: {
    title: 'Segunda via do cartão',
    body: 'A solicitação de segunda via (novo plástico ou virtual) será processada no GB Bank web. Este fluxo será detalhado em uma próxima fase.',
  },
  ajustarLimite: {
    title: 'Ajustar limite',
    body: 'O pedido de aumento/redução de limite passa por análise de crédito. Este fluxo será detalhado em uma próxima fase.',
  },
}

/** Gestão do cartão corporativo GB — cartão visual, limite e ações (bloqueio, segunda via, limite). */
export function CartoesScreen() {
  const navigate = useNavigate()
  const balanceHidden = useShellStore((s) => s.balanceHidden)
  const [blocked, setBlocked] = useState(false)
  const [sheet, setSheet] = useState<Sheet | null>(null)

  return (
    <div className="flex flex-col gap-5 p-4">
      <Heading level={3}>Cartões</Heading>

      {/* Cartão visual + limite */}
      <Card padded={false} className="overflow-hidden">
        <div className={blocked ? 'opacity-60 saturate-50 transition-all' : 'transition-all'}>
          <BankCardVisual />
        </div>
        <div className="p-4">
          <div className="flex items-center justify-between text-sm">
            <span className="text-fg-muted">Limite disponível</span>
            <span className="font-semibold tabular-nums text-fg">
              {balanceHidden ? '••••' : CARTAO.limiteDisponivel} / {balanceHidden ? '••••' : CARTAO.limiteTotal}
            </span>
          </div>
          <ProgressBar value={CARTAO.usoPct} className="mt-2" colorByOccupancy />
          <p className="mt-2 text-xs text-fg-subtle">
            {balanceHidden ? '••••' : CARTAO.limiteUsado} usados de {balanceHidden ? '••••' : CARTAO.limiteTotal}
          </p>
        </div>
      </Card>

      {blocked && (
        <Banner tone="warning" icon={<Lock size={14} aria-hidden="true" />}>
          Cartão bloqueado temporariamente. Compras e saques estão suspensos até você reativar.
        </Banner>
      )}

      {/* Bloqueio temporário */}
      <Card>
        <div className="flex items-center gap-3">
          <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent-subtle text-accent">
            {blocked ? <Lock size={20} aria-hidden="true" /> : <ShieldCheck size={20} aria-hidden="true" />}
          </span>
          <div className="min-w-0 flex-1">
            <p className="text-sm font-semibold text-fg">Bloquear temporariamente</p>
            <p className="text-xs text-fg-muted">Suspende o cartão sem cancelá-lo. Reative a qualquer momento.</p>
          </div>
          <ToggleSwitch
            checked={blocked}
            onChange={setBlocked}
            label={blocked ? 'Reativar cartão' : 'Bloquear cartão temporariamente'}
          />
        </div>
      </Card>

      {/* Ações do cartão */}
      <div>
        <SectionTitle className="mb-2">Ações do cartão</SectionTitle>
        <Card padded={false} className="divide-y divide-border-default overflow-hidden px-2 py-1">
          <MenuItem
            icon={RefreshCw}
            label="Segunda via"
            description="Solicitar novo cartão físico ou virtual"
            trailing={<ChevronRight size={16} className="text-fg-subtle" aria-hidden="true" />}
            onClick={() => setSheet('segundaVia')}
          />
          <MenuItem
            icon={SlidersHorizontal}
            label="Ajustar limite"
            description="Pedir aumento ou redução do limite"
            trailing={<ChevronRight size={16} className="text-fg-subtle" aria-hidden="true" />}
            onClick={() => setSheet('ajustarLimite')}
          />
          <MenuItem
            icon={SlidersHorizontal}
            label="Ver limites e faixas"
            description="Crédito, Pix e saque"
            trailing={<ChevronRight size={16} className="text-fg-subtle" aria-hidden="true" />}
            onClick={() => navigate('/bank/limites')}
          />
        </Card>
      </div>

      <BottomSheet open={sheet !== null} onClose={() => setSheet(null)} title={sheet ? SHEET_META[sheet].title : ''}>
        {sheet && (
          <div className="flex flex-col gap-4">
            <Chip tone="amber" icon={<Construction size={12} aria-hidden="true" />} className="self-start">
              Em desenvolvimento
            </Chip>
            <p className="text-sm text-fg-muted">{SHEET_META[sheet].body}</p>
            <Button fullWidth onClick={() => setSheet(null)}>
              Entendi
            </Button>
          </div>
        )}
      </BottomSheet>
    </div>
  )
}
