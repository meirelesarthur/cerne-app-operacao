import { useNavigate } from 'react-router-dom'
import { Zap, ScanLine, ArrowLeftRight, HandCoins, ArrowDownLeft, ArrowUpRight, ArrowRight, TrendingUp } from 'lucide-react'
import {
  BalanceCard,
  BalanceSummaryItem,
  QuickAction,
  Card,
  Button,
  ProgressBar,
  SectionTitle,
  TransactionListItem,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { SALDO, RESUMO_MES, TRANSACOES, CARTAO } from '@/modules/bank/mocks/banking'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

const hubCard = t.component.hub.bankCard

/**
 * Home do módulo GB Bank (New-UI): saldo, ações rápidas, cartão corporativo,
 * deep-link para Crédito e últimas movimentações — experiência completa do
 * Banking (a versão condensada vive na Carteira do hub Início).
 */
export function BankHome() {
  const navigate = useNavigate()
  const loading = useSimulatedLoad(700) === 'loading'
  const balanceHidden = useShellStore((s) => s.balanceHidden)
  const toggleBalanceHidden = useShellStore((s) => s.toggleBalanceHidden)

  return (
    <div className="flex flex-col gap-6 p-4">
      {/* Saldo da conta */}
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
                label="Entradas no mês"
                value={RESUMO_MES.entradas}
                hidden={balanceHidden}
              />
              <BalanceSummaryItem
                icon={<ArrowUpRight size={14} aria-hidden="true" />}
                label="Saídas no mês"
                value={RESUMO_MES.saidas}
                hidden={balanceHidden}
              />
            </div>
          }
        />
      </div>

      {/* Ações rápidas */}
      <div className="grid animate-rise grid-cols-4 gap-2" style={stagger(1)}>
        <QuickAction icon={Zap} label="Pix" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={ScanLine} label="Pagar" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={ArrowLeftRight} label="Transferir" onClick={() => navigate('/bank/pagamentos')} />
        <QuickAction icon={HandCoins} label="Cobrar" onClick={() => navigate('/bank/pagamentos')} />
      </div>

      {/* Cartão corporativo */}
      <div className="animate-rise" style={stagger(2)}>
        <SectionTitle className="mb-2">Meu cartão</SectionTitle>
        <Card padded={false} className="overflow-hidden">
          <div
            className="relative overflow-hidden p-5 text-white"
            style={{ background: `linear-gradient(135deg, ${hubCard.from} 0%, ${hubCard.to} 100%)` }}
          >
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
            <p className="relative mt-6 text-lg font-semibold tabular-nums tracking-widest">
              •••• •••• •••• {CARTAO.final}
            </p>
          </div>

          <div className="p-4">
            <div className="flex items-center justify-between text-sm">
              <span className="text-fg-muted">Limite disponível</span>
              <span className="font-semibold tabular-nums text-fg">
                {balanceHidden ? '••••' : CARTAO.limiteDisponivel} / {balanceHidden ? '••••' : CARTAO.limiteTotal}
              </span>
            </div>
            <ProgressBar value={CARTAO.usoPct} className="mt-2" colorByOccupancy />
          </div>
        </Card>
      </div>

      {/* Deep-link para o módulo Crédito */}
      <div className="animate-rise" style={stagger(3)}>
        <Card interactive onClick={() => navigate('/credito')}>
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-accent text-white">
              <TrendingUp size={22} aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-fg">Antecipe recebíveis da safra</p>
              <p className="truncate text-xs text-fg-muted">Simule no módulo Crédito</p>
            </div>
            <ArrowRight size={18} className="shrink-0 text-accent" aria-hidden="true" />
          </div>
        </Card>
      </div>

      {/* Últimas movimentações */}
      <div className="animate-rise" style={stagger(4)}>
        <SectionTitle className="mb-2">Últimas movimentações</SectionTitle>
        <Card padded={false} className="px-4">
          {TRANSACOES.slice(0, 3).map((tx) => (
            <TransactionListItem key={tx.id} transaction={tx} />
          ))}
        </Card>
        <Button variant="ghost" fullWidth className="mt-2" onClick={() => navigate('/bank/extrato')}>
          Ver extrato
        </Button>
      </div>
    </div>
  )
}
