import { useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowRight, Zap, Info } from 'lucide-react'
import {
  Avatar,
  Banner,
  Button,
  Card,
  FormField,
  SectionTitle,
  TextInput,
  Textarea,
  SuccessPanel,
} from '@/components/ui'
import { useShellStore } from '@/shell/state/shellStore'
import { CONTA_ORIGEM, PIX_CONTATOS, type PixContato } from '@/modules/bank/mocks/banking'
import { formatBRL, parseReais } from '@/modules/bank/lib/currency'
import { BankFlowShell } from '@/modules/bank/components/BankFlowShell'

interface Destino {
  nome: string
  chave: string
  tipoChave: string
  inicial?: string
}

type Step = 'chave' | 'valor' | 'revisao' | 'done'

export interface PixFlowProps {
  /** Sair do fluxo (voltar ao hub de Pagamentos). */
  onExit: () => void
}

/** Fluxo Pix completo mockado: chave → valor → revisão → sucesso. */
export function PixFlow({ onExit }: PixFlowProps) {
  const navigate = useNavigate()
  const balanceHidden = useShellStore((s) => s.balanceHidden)

  const [step, setStep] = useState<Step>('chave')
  const [chaveManual, setChaveManual] = useState('')
  const [destino, setDestino] = useState<Destino | null>(null)
  const [valor, setValor] = useState('')
  const [mensagem, setMensagem] = useState('')

  const valorNum = parseReais(valor)
  const valorValido = valorNum > 0

  const selecionarContato = (c: PixContato) => {
    setDestino({ nome: c.nome, chave: c.chave, tipoChave: c.tipoChave, inicial: c.inicial })
    setStep('valor')
  }

  const continuarManual = () => {
    setDestino({ nome: 'Nova chave Pix', chave: chaveManual.trim(), tipoChave: 'Chave Pix' })
    setStep('valor')
  }

  const reset = () => {
    setStep('chave')
    setChaveManual('')
    setDestino(null)
    setValor('')
    setMensagem('')
  }

  const back = () => {
    if (step === 'valor') setStep('chave')
    else if (step === 'revisao') setStep('valor')
    else onExit()
  }

  const stepLabel: Record<Step, string> = { chave: '1 de 3', valor: '2 de 3', revisao: '3 de 3', done: '' }

  // ---- Sucesso ----
  if (step === 'done' && destino) {
    return (
      <SuccessPanel
        title="Pix enviado"
        description={
          <span>
            <span className="font-semibold text-fg">{formatBRL(valorNum)}</span> para{' '}
            <span className="font-semibold text-fg">{destino.nome}</span>. O comprovante fica disponível no extrato.
          </span>
        }
      >
        <Button fullWidth onClick={() => navigate('/bank')}>
          Voltar ao Bank
        </Button>
        <Button variant="ghost" fullWidth onClick={() => navigate('/bank/extrato')}>
          Ver extrato
        </Button>
        <Button variant="ghost" fullWidth onClick={reset}>
          Fazer novo Pix
        </Button>
      </SuccessPanel>
    )
  }

  // ---- Passo 1: chave ----
  if (step === 'chave') {
    return (
      <BankFlowShell title="Pix" onBack={back} headerAction={<StepPill>{stepLabel.chave}</StepPill>}>
        <div className="flex flex-col gap-6">
          <div>
            <SectionTitle className="mb-2">Enviar para uma chave</SectionTitle>
            <FormField label="Chave Pix" hint="CPF/CNPJ, e-mail, telefone ou chave aleatória">
              <TextInput
                value={chaveManual}
                onChange={(e) => setChaveManual(e.target.value)}
                placeholder="Digite ou cole a chave"
              />
            </FormField>
            <Button
              className="mt-3"
              variant="secondary"
              fullWidth
              disabled={!chaveManual.trim()}
              rightIcon={<ArrowRight size={16} aria-hidden="true" />}
              onClick={continuarManual}
            >
              Continuar
            </Button>
          </div>

          <div>
            <SectionTitle className="mb-2">Contatos frequentes</SectionTitle>
            <div className="flex flex-col gap-2">
              {PIX_CONTATOS.map((c) => (
                <Card key={c.id} interactive onClick={() => selecionarContato(c)}>
                  <div className="flex items-center gap-3">
                    <Avatar name={c.nome} initials={c.inicial} />
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm font-semibold text-fg">{c.nome}</p>
                      <p className="truncate text-xs text-fg-muted">
                        {c.tipoChave} · {c.chave}
                      </p>
                    </div>
                    <ArrowRight size={18} className="shrink-0 text-accent" aria-hidden="true" />
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </BankFlowShell>
    )
  }

  // ---- Passo 2: valor ----
  if (step === 'valor' && destino) {
    return (
      <BankFlowShell
        title="Pix"
        onBack={back}
        headerAction={<StepPill>{stepLabel.valor}</StepPill>}
        primaryLabel="Revisar"
        onPrimary={() => setStep('revisao')}
        primaryDisabled={!valorValido}
      >
        <div className="flex flex-col gap-6">
          <DestinoResumo destino={destino} />

          <FormField
            label="Valor do Pix"
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

          <div className="flex items-center justify-between rounded-xl border border-border-default bg-surface-subtle px-3 py-2 text-sm">
            <span className="text-fg-muted">Saldo disponível</span>
            <span className="font-semibold tabular-nums text-fg">
              {balanceHidden ? '••••••' : CONTA_ORIGEM.saldo}
            </span>
          </div>

          <FormField label="Mensagem (opcional)">
            <Textarea
              value={mensagem}
              onChange={(e) => setMensagem(e.target.value)}
              placeholder="Ex.: pagamento de insumos"
              maxLength={140}
            />
          </FormField>
        </div>
      </BankFlowShell>
    )
  }

  // ---- Passo 3: revisão ----
  if (step === 'revisao' && destino) {
    return (
      <BankFlowShell
        title="Revisar Pix"
        onBack={back}
        headerAction={<StepPill>{stepLabel.revisao}</StepPill>}
        primaryLabel="Confirmar Pix"
        onPrimary={() => setStep('done')}
      >
        <div className="flex flex-col gap-5">
          <div className="flex flex-col items-center gap-1 pt-1 text-center">
            <span className="flex h-12 w-12 items-center justify-center rounded-full bg-accent-subtle text-accent">
              <Zap size={22} aria-hidden="true" />
            </span>
            <p className="mt-1 text-4xl font-bold leading-tight tabular-nums tracking-tight text-fg">
              {balanceHidden ? '••••••' : formatBRL(valorNum)}
            </p>
            <p className="text-sm text-fg-muted">Pix para {destino.nome}</p>
          </div>

          <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
            <ResumoRow label="De" value={CONTA_ORIGEM.label} />
            <ResumoRow label="Para" value={destino.nome} />
            <ResumoRow label={destino.tipoChave} value={destino.chave} />
            {mensagem.trim() && <ResumoRow label="Mensagem" value={mensagem.trim()} />}
            <ResumoRow label="Quando" value="Agora" />
          </div>

          <Banner tone="info" icon={<Info size={14} aria-hidden="true" />}>
            O Pix é processado na hora, 24/7. Confira os dados antes de confirmar.
          </Banner>
        </div>
      </BankFlowShell>
    )
  }

  return null
}

function StepPill({ children }: { children: ReactNode }) {
  return <span className="text-xs font-semibold text-fg-subtle">{children}</span>
}

function DestinoResumo({ destino }: { destino: Destino }) {
  return (
    <Card>
      <div className="flex items-center gap-3">
        <Avatar name={destino.nome} initials={destino.inicial} />
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-semibold text-fg">{destino.nome}</p>
          <p className="truncate text-xs text-fg-muted">
            {destino.tipoChave} · {destino.chave}
          </p>
        </div>
      </div>
    </Card>
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
