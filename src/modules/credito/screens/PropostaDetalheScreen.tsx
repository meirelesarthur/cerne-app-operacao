import type { ReactNode } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Check, FileText, Frown, X } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Card, Chip, SectionTitle, Banner, Button, EmptyState } from '@/components/ui'
import type { ChipTone, BannerTone } from '@/components/ui'
import { cn } from '@/lib/cn'
import { PROPOSTAS, type Proposta, type PropostaStatus } from '../mocks/credito'

const STATUS_LABEL: Record<PropostaStatus, string> = {
  analise: 'Em anÃ¡lise',
  aprovada: 'Aprovada',
  recusada: 'Recusada',
  contratada: 'Contratada',
}

const STATUS_TONE: Record<PropostaStatus, ChipTone> = {
  analise: 'amber',
  aprovada: 'brand',
  recusada: 'red',
  contratada: 'blue',
}

type StepState = 'done' | 'current' | 'pending' | 'rejected'

interface TimelineStep {
  label: string
  date?: string
  state: StepState
}

const markerCls: Record<StepState, string> = {
  done: 'border-accent bg-accent text-white',
  current: 'border-accent bg-surface text-accent ring-4 ring-accent/15',
  pending: 'border-border-default bg-surface-subtle text-fg-subtle',
  rejected: 'border-red-500 bg-red-500 text-white',
}

const labelCls: Record<StepState, string> = {
  done: 'text-fg',
  current: 'text-fg',
  pending: 'text-fg-subtle',
  rejected: 'text-red-600',
}

/** Monta a timeline de etapas da proposta a partir do status e histÃ³rico de datas. */
function buildTimeline({ status, historico }: Proposta): TimelineStep[] {
  if (status === 'recusada') {
    return [
      { label: 'Proposta enviada', date: historico.enviada, state: 'done' },
      { label: 'Em anÃ¡lise', date: historico.analise, state: 'done' },
      { label: 'Recusada', date: historico.decisao, state: 'rejected' },
    ]
  }

  return [
    { label: 'Proposta enviada', date: historico.enviada, state: 'done' },
    {
      label: 'Em anÃ¡lise',
      date: historico.analise,
      state: status === 'analise' ? 'current' : 'done',
    },
    {
      label: 'Aprovada',
      date: historico.decisao,
      state: status === 'analise' ? 'pending' : status === 'aprovada' ? 'current' : 'done',
    },
    {
      label: 'Contratada',
      date: historico.contratada,
      state: status === 'contratada' ? 'current' : 'pending',
    },
  ]
}

function Timeline({ steps }: { steps: TimelineStep[] }) {
  return (
    <div className="flex flex-col">
      {steps.map((step, i) => {
        const isLast = i === steps.length - 1
        return (
          <div key={step.label} className="flex gap-3">
            <div className="flex flex-col items-center">
              <span
                className={cn(
                  'flex h-7 w-7 shrink-0 items-center justify-center rounded-full border-2',
                  markerCls[step.state],
                )}
              >
                {step.state === 'done' && <Check size={14} aria-hidden="true" />}
                {step.state === 'rejected' && <X size={14} aria-hidden="true" />}
              </span>
              {!isLast && (
                <span
                  className={cn(
                    'my-0.5 min-h-[20px] w-px flex-1',
                    step.state === 'pending' ? 'bg-border-default' : 'bg-accent',
                  )}
                />
              )}
            </div>
            <div className={cn(!isLast && 'pb-5')}>
              <p className={cn('text-sm font-semibold', labelCls[step.state])}>{step.label}</p>
              {step.date && <p className="mt-0.5 text-xs text-fg-muted">{step.date}</p>}
            </div>
          </div>
        )
      })}
    </div>
  )
}

/** Banner + CTA contextual conforme o status atual da proposta â€” sem prometer aÃ§Ãµes inexistentes. */
function StatusCta({ proposta }: { proposta: Proposta }) {
  const navigate = useNavigate()

  const content: Record<PropostaStatus, { tone: BannerTone; text: string; action?: ReactNode }> = {
    analise: {
      tone: 'info',
      text: 'Sua proposta estÃ¡ em anÃ¡lise. O retorno costuma levar de 2 a 5 dias Ãºteis.',
    },
    aprovada: {
      tone: 'success',
      text: 'Proposta aprovada! Nossa equipe vai formalizar o contrato em breve.',
    },
    recusada: {
      tone: 'error',
      text: 'Proposta recusada. VocÃª pode simular novamente com outros valores ou prazo.',
      action: (
        <Button size="sm" variant="secondary" onClick={() => navigate('/credito/simular')}>
          Simular novamente
        </Button>
      ),
    },
    contratada: {
      tone: 'success',
      text: 'Contrato ativo. Acompanhe as parcelas na tela de contratos.',
      action: (
        <Button size="sm" variant="secondary" onClick={() => navigate('/credito/contratos')}>
          Ver contratos
        </Button>
      ),
    },
  }

  const { tone, text, action } = content[proposta.status]

  return (
    <div className="flex flex-col gap-2">
      <Banner tone={tone} className="rounded-xl border" action={action}>
        {text}
      </Banner>
      {proposta.status === 'analise' && (
        <Button fullWidth disabled>
          Aguardando anÃ¡lise
        </Button>
      )}
    </div>
  )
}

/** Detalhe de uma proposta de crÃ©dito: status, timeline de etapas, dados e documentos. */
export function PropostaDetalheScreen() {
  const { id } = useParams()
  const navigate = useNavigate()
  const proposta = PROPOSTAS.find((p) => p.id === id)

  if (!proposta) {
    return (
      <div className="flex h-full flex-col bg-canvas">
        <SubPageHeader title="Proposta" />
        <EmptyState
          icon={Frown}
          title="Proposta nÃ£o encontrada"
          description="Essa proposta pode ter sido removida ou o link estÃ¡ incorreto."
          action={
            <Button onClick={() => navigate('/credito/propostas')}>Ver todas as propostas</Button>
          }
          className="h-full justify-center"
        />
      </div>
    )
  }

  const steps = buildTimeline(proposta)

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader title={proposta.linha} />
      <div className="no-scrollbar flex-1 overflow-y-auto p-4">
        <div className="flex flex-col gap-5">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs text-fg-muted">Valor solicitado</p>
              <p className="text-2xl font-bold tabular-nums text-fg">{proposta.valor}</p>
            </div>
            <Chip tone={STATUS_TONE[proposta.status]}>{STATUS_LABEL[proposta.status]}</Chip>
          </div>

          <StatusCta proposta={proposta} />

          <Card>
            <SectionTitle className="mb-3 px-0">Andamento</SectionTitle>
            <Timeline steps={steps} />
          </Card>

          <Card>
            <SectionTitle className="mb-3 px-0">Dados da proposta</SectionTitle>
            <div className="flex flex-col gap-2.5 text-sm">
              <div className="flex items-center justify-between">
                <span className="text-fg-muted">Linha</span>
                <span className="font-semibold text-fg">{proposta.linha}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-fg-muted">Valor</span>
                <span className="font-semibold text-fg">{proposta.valor}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-fg-muted">Prazo</span>
                <span className="font-semibold text-fg">{proposta.prazo} meses</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-fg-muted">Taxa</span>
                <span className="font-semibold text-fg">{proposta.taxa}</span>
              </div>
            </div>
          </Card>

          <Card>
            <SectionTitle className="mb-3 px-0">Documentos</SectionTitle>
            <div className="flex flex-col gap-3">
              {proposta.documentos.map((doc) => (
                <div key={doc.nome} className="flex items-center gap-3">
                  <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-surface-subtle text-fg-muted">
                    <FileText size={18} aria-hidden="true" />
                  </span>
                  <p className="min-w-0 flex-1 truncate text-sm font-medium text-fg">{doc.nome}</p>
                  <Chip tone={doc.enviado ? 'brand' : 'amber'}>{doc.enviado ? 'Enviado' : 'Pendente'}</Chip>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  )
}
