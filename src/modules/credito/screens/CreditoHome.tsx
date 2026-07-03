import { useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Sprout, Tractor, FileText, Users, ArrowRight, HandCoins } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { Card, Button, Chip, SectionTitle } from '@/components/ui'
import type { ChipTone } from '@/components/ui'
import { t } from '@/design/tokens'
import {
  PRE_APROVADO,
  SIMULACAO,
  VALORES_SIMULACAO,
  PRAZOS_SIMULACAO,
  LINHAS,
  PROPOSTAS,
  type PropostaStatus,
} from '../mocks/credito'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

const hub = t.component.hub.bankCard

const LINHA_ICONS: Record<string, LucideIcon> = {
  'custeio-safra': Sprout,
  'investimento-maquinas': Tractor,
  'cpr-financeira': FileText,
  'consorcio-agro': Users,
}

const STATUS_LABEL: Record<PropostaStatus, string> = {
  analise: 'Em análise',
  aprovada: 'Aprovada',
  contratada: 'Contratada',
}

const STATUS_TONE: Record<PropostaStatus, ChipTone> = {
  analise: 'amber',
  aprovada: 'brand',
  contratada: 'blue',
}

/**
 * Home do módulo Crédito: oferta pré-aprovada em destaque, simulador rápido
 * (valor × prazo → parcela estimada), linhas de crédito disponíveis e as
 * propostas mais recentes do produtor.
 */
export function CreditoHome() {
  const navigate = useNavigate()
  const simuladorRef = useRef<HTMLDivElement>(null)
  const [valorSelecionado, setValorSelecionado] = useState<string>(VALORES_SIMULACAO[2])
  const [prazoSelecionado, setPrazoSelecionado] = useState<number>(PRAZOS_SIMULACAO[1])

  const opcaoAtual = SIMULACAO.find((s) => s.valor === valorSelecionado && s.prazo === prazoSelecionado)
  const linhaAtual = LINHAS.find((l) => l.id === 'custeio-safra')

  const scrollToSimulador = () => {
    simuladorRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  return (
    <div className="flex flex-col gap-6 p-4">
      {/* Hero — oferta pré-aprovada */}
      <div className="animate-rise" style={stagger(0)}>
        <section
          aria-label="Crédito pré-aprovado"
          className="relative overflow-hidden rounded-3xl p-5 text-white shadow-card"
          style={{ background: `linear-gradient(135deg, ${hub.from} 0%, ${hub.to} 100%)` }}
        >
          <div
            aria-hidden="true"
            className="pointer-events-none absolute -right-10 -top-16 h-44 w-44 rounded-full"
            style={{ background: `radial-gradient(circle, ${hub.glow} 0%, transparent 70%)` }}
          />

          <div className="relative flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-white/10">
              <HandCoins size={16} aria-hidden="true" />
            </span>
            <Chip tone="brand" className="border-white/20 bg-white/10 text-white">
              Pré-aprovado
            </Chip>
          </div>

          <p className="relative mt-3 text-4xl font-bold leading-tight tabular-nums tracking-tight">
            {PRE_APROVADO.valor}
          </p>
          <p className="relative mt-1 text-sm" style={{ color: hub.fgMuted }}>
            Validade {PRE_APROVADO.validade} · {PRE_APROVADO.taxa}
          </p>

          <div className="relative mt-4">
            <Button variant="secondary" onClick={scrollToSimulador}>
              Simular agora
            </Button>
          </div>
        </section>
      </div>

      {/* Simulador rápido */}
      <div ref={simuladorRef} className="animate-rise scroll-mt-4" style={stagger(1)}>
        <SectionTitle className="mb-2">Simulador rápido</SectionTitle>

        <p className="mb-1.5 px-1 text-xs font-medium text-fg-muted">Valor</p>
        <div className="flex flex-wrap gap-2">
          {VALORES_SIMULACAO.map((valor) => (
            <Button
              key={valor}
              size="sm"
              variant={valor === valorSelecionado ? 'primary' : 'secondary'}
              onClick={() => setValorSelecionado(valor)}
            >
              {valor}
            </Button>
          ))}
        </div>

        <p className="mb-1.5 mt-3 px-1 text-xs font-medium text-fg-muted">Prazo</p>
        <div className="flex flex-wrap gap-2">
          {PRAZOS_SIMULACAO.map((prazo) => (
            <Button
              key={prazo}
              size="sm"
              variant={prazo === prazoSelecionado ? 'primary' : 'secondary'}
              onClick={() => setPrazoSelecionado(prazo)}
            >
              {prazo} meses
            </Button>
          ))}
        </div>

        <Card className="mt-3">
          <p className="text-xs font-medium text-fg-muted">Parcela estimada</p>
          <p className="mt-1 text-2xl font-bold tabular-nums text-fg">{opcaoAtual?.parcela ?? '—'}</p>
          <p className="mt-0.5 text-xs text-fg-subtle">Taxa {linhaAtual?.taxa} · {prazoSelecionado} parcelas</p>
          <Button fullWidth className="mt-4" onClick={() => navigate('/credito/propostas')}>
            Enviar proposta
          </Button>
        </Card>
      </div>

      {/* Linhas disponíveis */}
      <div className="animate-rise" style={stagger(2)}>
        <SectionTitle className="mb-2">Linhas disponíveis</SectionTitle>
        <div className="flex flex-col gap-3">
          {LINHAS.map((linha) => {
            const Icon = LINHA_ICONS[linha.id] ?? FileText
            return (
              <Card key={linha.id} interactive onClick={() => navigate('/credito/propostas')}>
                <div className="flex items-center gap-3">
                  <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-accent text-white">
                    <Icon size={22} aria-hidden="true" />
                  </span>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <p className="truncate text-sm font-semibold text-fg">{linha.nome}</p>
                      <Chip tone="brand">{linha.taxa}</Chip>
                    </div>
                    <p className="mt-0.5 truncate text-xs text-fg-muted">{linha.descricao}</p>
                  </div>
                  <ArrowRight size={18} className="shrink-0 text-accent" aria-hidden="true" />
                </div>
              </Card>
            )
          })}
        </div>
      </div>

      {/* Minhas propostas */}
      <div className="animate-rise" style={stagger(3)}>
        <div className="mb-2 flex items-center justify-between">
          <SectionTitle>Minhas propostas</SectionTitle>
          <Button variant="ghost" size="sm" rightIcon={<ArrowRight size={13} />} onClick={() => navigate('/credito/propostas')}>
            Ver todas
          </Button>
        </div>
        <Card padded={false} className="px-4">
          {PROPOSTAS.slice(0, 2).map((proposta) => (
            <div key={proposta.id} className="flex items-center gap-3 border-b border-border-default py-3 last:border-0">
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-fg">{proposta.linha}</p>
                <p className="mt-0.5 text-xs text-fg-muted">{proposta.data}</p>
              </div>
              <div className="flex shrink-0 flex-col items-end gap-1">
                <p className="text-sm font-semibold tabular-nums text-fg">{proposta.valor}</p>
                <Chip tone={STATUS_TONE[proposta.status]}>{STATUS_LABEL[proposta.status]}</Chip>
              </div>
            </div>
          ))}
        </Card>
      </div>
    </div>
  )
}
