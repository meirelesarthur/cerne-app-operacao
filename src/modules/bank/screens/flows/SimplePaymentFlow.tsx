import { useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ScanLine, ArrowLeftRight, HandCoins, Info, type LucideIcon } from 'lucide-react'
import {
  Banner,
  Button,
  FormField,
  FormSelect,
  SectionTitle,
  TextInput,
  Textarea,
  SuccessPanel,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { BANCOS, CONTA_ORIGEM } from '@/modules/bank/mocks/banking'
import { formatBRL, parseReais } from '@/modules/bank/lib/currency'
import { BankFlowShell } from '@/modules/bank/components/BankFlowShell'

export type PaymentKind = 'boleto' | 'transferir' | 'cobrar'

interface Meta {
  title: string
  icon: LucideIcon
  confirm: string
  successTitle: string
}

const META: Record<PaymentKind, Meta> = {
  boleto: { title: 'Pagar boleto', icon: ScanLine, confirm: 'Confirmar pagamento', successTitle: 'Pagamento agendado' },
  transferir: { title: 'Transferir', icon: ArrowLeftRight, confirm: 'Confirmar transferência', successTitle: 'Transferência enviada' },
  cobrar: { title: 'Cobrar via Pix', icon: HandCoins, confirm: 'Gerar cobrança', successTitle: 'Cobrança criada' },
}

type Step = 'form' | 'revisao' | 'done'

export interface SimplePaymentFlowProps {
  kind: PaymentKind
  /** Sair do fluxo (voltar ao hub de Pagamentos). */
  onExit: () => void
}

/** Fluxos de boleto/transferência/cobrança: formulário → revisão → sucesso. */
export function SimplePaymentFlow({ kind, onExit }: SimplePaymentFlowProps) {
  const navigate = useNavigate()
  const balanceHidden = useShellStore((s) => s.balanceHidden)
  const meta = META[kind]

  const [step, setStep] = useState<Step>('form')
  const [linha, setLinha] = useState('')
  const [banco, setBanco] = useState('')
  const [agencia, setAgencia] = useState('')
  const [conta, setConta] = useState('')
  const [nome, setNome] = useState('')
  const [valor, setValor] = useState('')
  const [descricao, setDescricao] = useState('')

  const valorNum = parseReais(valor)
  const valorValido = valorNum > 0

  const valid =
    kind === 'boleto'
      ? linha.trim().length >= 6 && valorValido
      : kind === 'transferir'
        ? !!banco && !!agencia.trim() && !!conta.trim() && valorValido
        : valorValido

  const bancoLabel = BANCOS.find((b) => b.value === banco)?.label ?? ''

  const reset = () => {
    setStep('form')
    setLinha('')
    setBanco('')
    setAgencia('')
    setConta('')
    setNome('')
    setValor('')
    setDescricao('')
  }

  const back = () => {
    if (step === 'revisao') setStep('form')
    else onExit()
  }

  // ---- Sucesso ----
  if (step === 'done') {
    const desc: Record<PaymentKind, ReactNode> = {
      boleto: (
        <span>
          Pagamento de <strong className="font-semibold text-fg">{formatBRL(valorNum)}</strong> agendado. O débito
          ocorre na conta na data de vencimento.
        </span>
      ),
      transferir: (
        <span>
          <strong className="font-semibold text-fg">{formatBRL(valorNum)}</strong> enviado para {bancoLabel} · Ag{' '}
          {agencia} · Conta {conta}.
        </span>
      ),
      cobrar: (
        <span>
          Cobrança de <strong className="font-semibold text-fg">{formatBRL(valorNum)}</strong> criada. O código Pix
          copia-e-cola fica disponível no GB Bank web para envio ao pagador.
        </span>
      ),
    }
    return (
      <SuccessPanel title={meta.successTitle} description={desc[kind]}>
        <Button fullWidth onClick={() => navigate('/bank')}>
          Voltar ao Bank
        </Button>
        <Button variant="ghost" fullWidth onClick={reset}>
          Nova operação
        </Button>
      </SuccessPanel>
    )
  }

  // ---- Revisão ----
  if (step === 'revisao') {
    return (
      <BankFlowShell title={meta.title} onBack={back} primaryLabel={meta.confirm} onPrimary={() => setStep('done')}>
        <div className="flex flex-col gap-5">
          <div className="flex flex-col items-center gap-1 pt-1 text-center">
            <span className="flex h-12 w-12 items-center justify-center rounded-full bg-accent-subtle text-accent">
              <meta.icon size={22} aria-hidden="true" />
            </span>
            <p className="mt-1 text-4xl font-bold leading-tight tabular-nums tracking-tight text-fg">
              {balanceHidden ? '••••••' : formatBRL(valorNum)}
            </p>
          </div>

          <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
            {kind === 'boleto' && <ResumoRow label="Linha digitável" value={linha.trim()} />}
            {kind === 'transferir' && (
              <>
                <ResumoRow label="De" value={CONTA_ORIGEM.label} />
                <ResumoRow label="Banco" value={bancoLabel} />
                <ResumoRow label="Agência" value={agencia.trim()} />
                <ResumoRow label="Conta" value={conta.trim()} />
              </>
            )}
            {kind === 'cobrar' && <ResumoRow label="Pagador" value={nome.trim() || 'Não informado'} />}
            {descricao.trim() && <ResumoRow label="Descrição" value={descricao.trim()} />}
          </div>

          <Banner tone="info" icon={<Info size={14} aria-hidden="true" />}>
            Confira os dados antes de confirmar. Esta é uma operação simulada do protótipo.
          </Banner>
        </div>
      </BankFlowShell>
    )
  }

  // ---- Formulário ----
  return (
    <BankFlowShell
      title={meta.title}
      onBack={back}
      primaryLabel="Revisar"
      onPrimary={() => setStep('revisao')}
      primaryDisabled={!valid}
    >
      <div className="flex flex-col gap-5">
        <SectionTitle>Dados da operação</SectionTitle>

        {kind === 'boleto' && (
          <FormField label="Linha digitável" hint="Código de barras do boleto">
            <TextInput
              inputMode="numeric"
              value={linha}
              onChange={(e) => setLinha(e.target.value)}
              placeholder="00000.00000 00000.000000 00000.000000 0 00000000000000"
            />
          </FormField>
        )}

        {kind === 'transferir' && (
          <>
            <FormField label="Banco de destino">
              <FormSelect
                options={BANCOS}
                value={banco}
                onChange={(e) => setBanco(e.target.value)}
                placeholder="Selecione o banco"
              />
            </FormField>
            <div className="grid grid-cols-2 gap-3">
              <FormField label="Agência">
                <TextInput inputMode="numeric" value={agencia} onChange={(e) => setAgencia(e.target.value)} placeholder="0001" />
              </FormField>
              <FormField label="Conta">
                <TextInput inputMode="numeric" value={conta} onChange={(e) => setConta(e.target.value)} placeholder="00000-0" />
              </FormField>
            </div>
          </>
        )}

        {kind === 'cobrar' && (
          <FormField label="Pagador (opcional)">
            <TextInput value={nome} onChange={(e) => setNome(e.target.value)} placeholder="Nome de quem vai pagar" />
          </FormField>
        )}

        <FormField
          label={kind === 'cobrar' ? 'Valor a cobrar' : 'Valor'}
          error={valor !== '' && !valorValido ? 'Informe um valor maior que zero.' : undefined}
        >
          <TextInput
            inputMode="decimal"
            value={valor}
            onChange={(e) => setValor(e.target.value)}
            placeholder="0,00"
            invalid={valor !== '' && !valorValido}
          />
        </FormField>

        <FormField label="Descrição (opcional)">
          <Textarea
            value={descricao}
            onChange={(e) => setDescricao(e.target.value)}
            placeholder="Identifique esta operação"
            maxLength={140}
          />
        </FormField>
      </div>
    </BankFlowShell>
  )
}

function ResumoRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-baseline justify-between gap-3">
      <span className="shrink-0 text-sm text-fg-muted">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{value}</span>
    </div>
  )
}
