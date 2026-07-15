import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Zap, ScanLine, ArrowLeftRight, Receipt, ArrowRight, ArrowDownLeft, ArrowUpRight, HandCoins } from 'lucide-react'
import {
  BalanceCard,
  BalanceSummaryItem,
  QuickAction,
  MiniAppTile,
  TransactionListItem,
  TransactionDetailSheet,
  type TransactionItem,
  Card,
  Button,
  Chip,
  SectionTitle,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { SALDO, RESUMO_MES, TRANSACOES, CREDITO_PREAPROVADO } from '@/modules/bank/mocks/banking'
import { HUB_APPS } from '../mocks/apps'

/** delay escalonado de entrada por seÃ§Ã£o (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

/**
 * Home do hub agregador (New-UI): Banking no centro da experiÃªncia
 * (saldo + aÃ§Ãµes rÃ¡pidas + Ãºltimas movimentaÃ§Ãµes) e grid de mini-apps
 * injetÃ¡vel via catÃ¡logo â€” novos apps entram sem tocar nesta tela.
 */
export function HubHome() {
  const navigate = useNavigate()
  const loading = useSimulatedLoad(700) === 'loading'
  const balanceHidden = useShellStore((s) => s.balanceHidden)
  const toggleBalanceHidden = useShellStore((s) => s.toggleBalanceHidden)
  const [selected, setSelected] = useState<TransactionItem | null>(null)

  return (
    <div className="flex flex-col gap-6 p-4">
      {/* Banking central â€” saldo */}
      <div className="animate-rise" style={stagger(0)}>
        <BalanceCard
          value={SALDO.valor}
          accountLabel={SALDO.conta}
          hidden={balanceHidden}
          onToggleHidden={toggleBalanceHidden}
          loading={loading}
          footer={
            <div className="grid grid-cols-2 gap-3">
              <BalanceSummaryItem
                icon={<ArrowDownLeft size={14} aria-hidden="true" />}
                label="Entradas no mÃªs"
                value={RESUMO_MES.entradas}
                hidden={balanceHidden}
              />
              <BalanceSummaryItem
                icon={<ArrowUpRight size={14} aria-hidden="true" />}
                label="SaÃ­das no mÃªs"
                value={RESUMO_MES.saidas}
                hidden={balanceHidden}
              />
            </div>
          }
        />
      </div>

      {/* AÃ§Ãµes rÃ¡pidas do Banking */}
      <div className="grid animate-rise grid-cols-4 gap-2" style={stagger(1)}>
        <QuickAction icon={Zap} label="Pix" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={ScanLine} label="Pagar" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={ArrowLeftRight} label="Transferir" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={Receipt} label="Extrato" onClick={() => navigate('/bank/extrato')} />
      </div>

      {/* Destaque de crÃ©dito â€” deep link entre mÃ³dulos */}
      <div className="animate-rise" style={stagger(2)}>
        <Card interactive onClick={() => navigate('/credito')}>
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent text-white">
              <HandCoins size={22} aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <p className="text-sm font-medium text-fg-muted">CrÃ©dito Agro</p>
                <Chip tone="brand">PrÃ©-aprovado</Chip>
              </div>
              <p className="truncate text-lg font-bold tabular-nums text-fg">{CREDITO_PREAPROVADO.valor}</p>
              <p className="truncate text-xs text-fg-muted">{CREDITO_PREAPROVADO.condicao}</p>
            </div>
            <ArrowRight size={18} className="shrink-0 text-accent" aria-hidden="true" />
          </div>
        </Card>
      </div>

      {/* Grid de mini-apps â€” injeÃ§Ã£o contÃ­nua via catÃ¡logo */}
      <div className="animate-rise" style={stagger(3)}>
        <div className="mb-2 flex items-center justify-between">
          <SectionTitle>Seus apps</SectionTitle>
          <Button variant="ghost" size="sm" rightIcon={<ArrowRight size={13} />} onClick={() => navigate('/inicio/apps')}>
            Ver todos
          </Button>
        </div>
        <div className="grid grid-cols-2 gap-3">
          {HUB_APPS.map((app) => (
            <MiniAppTile
              key={app.id}
              icon={app.icon}
              name={app.name}
              description={app.description}
              badge={app.badge}
              onClick={app.route ? () => navigate(app.route!) : undefined}
            />
          ))}
        </div>
      </div>

      {/* Ãšltimas movimentaÃ§Ãµes â€” Banking sempre Ã  mÃ£o */}
      <div className="animate-rise" style={stagger(4)}>
        <div className="mb-2 flex items-center justify-between">
          <SectionTitle>Ãšltimas movimentaÃ§Ãµes</SectionTitle>
          <Button variant="ghost" size="sm" rightIcon={<ArrowRight size={13} />} onClick={() => navigate('/bank/extrato')}>
            Extrato
          </Button>
        </div>
        <Card padded={false} className="px-4">
          {TRANSACOES.slice(0, 3).map((tx) => (
            <TransactionListItem key={tx.id} transaction={tx} onClick={() => setSelected(tx)} />
          ))}
        </Card>
      </div>

      <TransactionDetailSheet transaction={selected} onClose={() => setSelected(null)} hidden={balanceHidden} />
    </div>
  )
}
