import { useState } from 'react'
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
  TransactionDetailSheet,
  type TransactionItem,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { SALDO, RESUMO_MES, TRANSACOES, CARTAO } from '@/modules/bank/mocks/banking'
import { BankCardVisual } from '@/modules/bank/components/BankCardVisual'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

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
  const [selected, setSelected] = useState<TransactionItem | null>(null)

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
        <Card padded={false} interactive onClick={() => navigate('/bank/cartoes')} className="overflow-hidden">
          <BankCardVisual />
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
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-accent text-white">
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
            <TransactionListItem key={tx.id} transaction={tx} onClick={() => setSelected(tx)} />
          ))}
        </Card>
        <Button variant="ghost" fullWidth className="mt-2" onClick={() => navigate('/bank/extrato')}>
          Ver extrato
        </Button>
      </div>

      <TransactionDetailSheet transaction={selected} onClose={() => setSelected(null)} hidden={balanceHidden} />
    </div>
  )
}
