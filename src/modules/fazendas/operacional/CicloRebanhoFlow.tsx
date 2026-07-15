import { useState } from 'react'
import { Baby, Milk, ArrowLeftRight, HeartCrack, AlertTriangle } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { SearchSelect } from '@/components/ui/SearchSelect'
import { TextInput } from '@/components/ui/TextInput'
import { Textarea } from '@/components/ui/Textarea'
import { Banner } from '@/components/ui/Banner'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { LOTES_OPCOES, CAUSAS_MORTE } from '../mocks/operacional'

type EventType = 'nascimento' | 'desmame' | 'transferencia' | 'morte'

const EVENTS: { type: EventType; label: string; icon: LucideIcon; desc: string }[] = [
  { type: 'nascimento', label: 'Nascimento', icon: Baby, desc: 'Registrar bezerro' },
  { type: 'desmame', label: 'Desmame', icon: Milk, desc: 'Desmame de animal' },
  { type: 'transferencia', label: 'TransferÃªncia', icon: ArrowLeftRight, desc: 'Entre lotes' },
  { type: 'morte', label: 'Morte / Perda', icon: HeartCrack, desc: 'Baixa de animal' },
]

/** Eventos de Ciclo do Rebanho (spec Â§5.2) â€” formulÃ¡rio dinÃ¢mico por tipo de evento. */
export function CicloRebanhoFlow() {
  const [type, setType] = useState<EventType | null>(null)
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)
  const pesagemDoDiaFeita = useFazendasStore((s) => s.pesagemDoDiaFeita)

  // form fields (dinÃ¢micos)
  const [lote, setLote] = useState('')
  const [loteDestino, setLoteDestino] = useState('')
  const [data, setData] = useState('')
  const [qtd, setQtd] = useState('')
  const [causa, setCausa] = useState('')
  const [obs, setObs] = useState('')

  if (done) {
    return (
      <SuccessScreen
        title="Evento registrado"
        queued={done.queued}
        effects="Isso vai atualizar a mÃ¡quina de estados do animal e a base de venda/SISBOV."
      />
    )
  }

  if (!type) {
    return (
      <FlowShell title="Eventos do rebanho">
        <p className="mb-3 text-md text-fg-muted">Escolha o tipo de evento a registrar.</p>
        <div className="grid grid-cols-2 gap-3">
          {EVENTS.map((e) => (
            <button
              key={e.type}
              onClick={() => setType(e.type)}
              className="flex flex-col items-start gap-2 rounded-2xl border border-border-default bg-surface p-4 text-left shadow-card active:scale-[0.99]"
            >
              <span className="flex h-11 w-11 items-center justify-center rounded-full bg-accent-subtle text-accent">
                <e.icon size={22} />
              </span>
              <span className="font-semibold text-fg">{e.label}</span>
              <span className="text-sm text-fg-muted">{e.desc}</span>
            </button>
          ))}
        </div>
      </FlowShell>
    )
  }

  const isTransfer = type === 'transferencia'
  const transferBlocked = isTransfer && !pesagemDoDiaFeita

  // validaÃ§Ã£o por tipo
  let valid = false
  if (type === 'nascimento') valid = !!lote && !!data
  else if (type === 'desmame') valid = !!lote && !!data
  else if (type === 'transferencia') valid = !!lote && !!loteDestino && !!qtd && !transferBlocked
  else if (type === 'morte') valid = !!lote && !!data && !!causa

  const confirmar = () => {
    const queued = !isOnline
    if (queued) enqueueSync({ id: `evt-${type}`, label: `Evento: ${type}`, detail: 'Ciclo do rebanho', kind: 'evento' })
    setDone({ queued })
  }

  const label = EVENTS.find((e) => e.type === type)!.label

  return (
    <FlowShell
      title={label}
      primaryLabel="Registrar evento"
      onPrimary={confirmar}
      primaryDisabled={!valid}
      onBack={() => setType(null)}
    >
      <div className="flex flex-col gap-5">
        {transferBlocked && (
          <Banner tone="error" icon={<AlertTriangle size={14} />} className="rounded-lg border">
            TransferÃªncia bloqueada: Ã© necessÃ¡rio registrar a <strong>pesagem do dia</strong> antes de transferir o lote (DUV-179).
          </Banner>
        )}

        <FormField label={isTransfer ? 'Lote de origem' : type === 'nascimento' ? 'Animal-mÃ£e / lote' : 'Animal / lote'} required>
          <SearchSelect options={LOTES_OPCOES} value={lote} onChange={setLote} placeholder="Buscar..." />
        </FormField>

        {isTransfer && (
          <>
            <FormField label="Lote de destino" required>
              <SearchSelect
                options={LOTES_OPCOES.filter((l) => l.value !== lote)}
                value={loteDestino}
                onChange={setLoteDestino}
                placeholder="Buscar lote de destino..."
              />
            </FormField>
            <FormField label="Quantidade" required>
              <TextInput type="number" inputMode="numeric" value={qtd} onChange={(e) => setQtd(e.target.value)} placeholder="NÂº de animais" />
            </FormField>
          </>
        )}

        {type !== 'transferencia' && (
          <FormField label="Data" required>
            <TextInput type="date" value={data} onChange={(e) => setData(e.target.value)} />
          </FormField>
        )}

        {type === 'nascimento' && (
          <FormField label="Peso ao nascer" hint="Opcional">
            <TextInput type="number" inputMode="decimal" value={qtd} onChange={(e) => setQtd(e.target.value)} placeholder="kg" />
          </FormField>
        )}

        {type === 'morte' && (
          <>
            <FormField label="Causa" required>
              <FormSelect options={CAUSAS_MORTE} value={causa} onChange={(e) => setCausa(e.target.value)} placeholder="Selecione a causa" />
            </FormField>
            <FormField label="ObservaÃ§Ã£o">
              <Textarea value={obs} onChange={(e) => setObs(e.target.value)} placeholder="Detalhes adicionais..." />
            </FormField>
          </>
        )}
      </div>
    </FlowShell>
  )
}
