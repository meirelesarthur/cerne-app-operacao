import { useNavigate } from 'react-router-dom'
import { Landmark, ArrowDownLeft, ArrowUpRight } from 'lucide-react'
import {
  BalanceCard,
  BalanceSummaryItem,
  TransactionListItem,
  KpiStatCard,
  Card,
  Button,
  Heading,
  SectionTitle,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { SALDO, RESUMO_MES, TRANSACOES } from '@/modules/bank/mocks/banking'

const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

/**
 * Carteira do hub (New-UI): visão condensada do Banking sem sair do Início.
 * A experiência completa (cartões, agendamentos, comprovantes) vive no
 * módulo GB Bank — daqui só se navega, nunca se duplica regra de negócio.
 */
export function CarteiraScreen() {
  const navigate = useNavigate()
  const loading = useSimulatedLoad(700) === 'loading'
  const balanceHidden = useShellStore((s) => s.balanceHidden)
  const toggleBalanceHidden = useShellStore((s) => s.toggleBalanceHidden)

  return (
    <div className="flex flex-col gap-5 p-4">
      <div className="animate-rise" style={stagger(0)}>
        <Heading level={3}>Carteira</Heading>
        <p className="mt-0.5 text-sm text-fg-muted">Resumo da sua conta GB Bank.</p>
      </div>

      <div className="animate-rise" style={stagger(1)}>
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

      <div className="grid animate-rise grid-cols-2 gap-3" style={stagger(2)}>
        <KpiStatCard label="Entradas no mês" value={balanceHidden ? '••••' : RESUMO_MES.entradas} tone="positive" caption="+12% vs. mês anterior" />
        <KpiStatCard label="Saídas no mês" value={balanceHidden ? '••••' : RESUMO_MES.saidas} caption="folha, insumos e energia" />
      </div>

      <div className="animate-rise" style={stagger(3)}>
        <SectionTitle className="mb-2">Movimentações recentes</SectionTitle>
        <Card padded={false} className="px-4">
          {TRANSACOES.map((tx) => (
            <TransactionListItem key={tx.id} transaction={tx} />
          ))}
        </Card>
      </div>

      <div className="animate-rise" style={stagger(4)}>
        <Button fullWidth size="lg" leftIcon={<Landmark size={18} />} onClick={() => navigate('/bank')}>
          Abrir GB Bank completo
        </Button>
      </div>
    </div>
  )
}
