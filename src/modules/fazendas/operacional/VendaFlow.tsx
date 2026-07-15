import { useState } from 'react'
import { Lock } from 'lucide-react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { SearchSelect } from '@/components/ui/SearchSelect'
import { TextInput } from '@/components/ui/TextInput'
import { Stepper } from '@/components/ui/Stepper'
import { Tooltip } from '@/components/ui/Tooltip'
import { SectionTitle } from '@/components/ui/Heading'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { LOTES_OPCOES, COND_PAGAMENTO } from '../mocks/operacional'

// contagem de cabeÃ§as por lote (mock) â€” usado para validar que a contagem bate (spec Â§5.5)
const LOTE_CABECAS: Record<string, number> = { l42: 128, l19: 96, l07: 150, l33: 64, l51: 110, l88: 82 }

/** Venda de Animais (spec Â§5.5): mÃªs congelado bloqueia ediÃ§Ã£o; total > 0; contagem deve bater. */
export function VendaFlow() {
  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)

  const [lote, setLote] = useState('')
  const [cliente, setCliente] = useState('')
  const [cond, setCond] = useState('')
  const [dataEmbarque, setDataEmbarque] = useState('')
  const [qtd, setQtd] = useState(0)
  const [total, setTotal] = useState('')
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  const esperado = lote ? LOTE_CABECAS[lote] : 0
  const contagemBate = !lote || qtd === esperado
  const totalValido = Number(total) > 0
  const valid = !!lote && !!cliente && !!cond && !!dataEmbarque && contagemBate && totalValido

  const confirmar = () => {
    const queued = !isOnline
    if (queued) enqueueSync({ id: `venda-${lote}`, label: 'Venda de animais', detail: cliente, kind: 'venda' })
    setDone({ queued })
  }

  if (done) {
    return <SuccessScreen title="Venda registrada" queued={done.queued} effects="Isso vai gerar NF-e + GTA e um tÃ­tulo a receber." />
  }

  return (
    <FlowShell title="Venda de animais" primaryLabel="Confirmar venda" onPrimary={confirmar} primaryDisabled={!valid}>
      <div className="flex flex-col gap-5">
        {/* DemonstraÃ§Ã£o de mÃªs congelado â€” venda de mÃªs fechado bloqueada para ediÃ§Ã£o */}
        <div>
          <SectionTitle className="mb-2">MÃªs anterior (fechado)</SectionTitle>
          <div className="flex items-center gap-3 rounded-xl border border-border-default bg-surface-subtle p-3 opacity-90">
            <span className="flex h-9 w-9 items-center justify-center rounded-full bg-neutral-200 text-neutral-500">
              <Lock size={16} />
            </span>
            <div className="flex-1">
              <p className="font-medium text-fg-muted">Venda #3382 Â· FrigorÃ­fico Central</p>
              <p className="text-sm text-fg-subtle">Junho/2026 Â· R$ 420.000</p>
            </div>
            <Tooltip content="MÃªs congelado â€” ediÃ§Ã£o bloqueada">
              <span className="text-fg-subtle">
                <Lock size={16} />
              </span>
            </Tooltip>
          </div>
        </div>

        <SectionTitle>Nova venda</SectionTitle>
        <FormField label="Lote / animais" required>
          <SearchSelect options={LOTES_OPCOES} value={lote} onChange={(v) => { setLote(v); setQtd(LOTE_CABECAS[v] ?? 0) }} placeholder="Buscar lote..." />
        </FormField>

        <FormField
          label="Quantidade de animais"
          required
          error={!contagemBate ? `A contagem deve bater com o lote (${esperado} cabeÃ§as).` : undefined}
        >
          <Stepper value={qtd} onChange={setQtd} min={0} max={esperado || 999} />
        </FormField>

        <FormField label="Cliente" required>
          <TextInput value={cliente} onChange={(e) => setCliente(e.target.value)} placeholder="Nome do comprador" />
        </FormField>

        <FormField label="CondiÃ§Ã£o de pagamento" required>
          <FormSelect options={COND_PAGAMENTO} value={cond} onChange={(e) => setCond(e.target.value)} placeholder="Selecione" />
        </FormField>

        <FormField label="Data de embarque" required>
          <TextInput type="date" value={dataEmbarque} onChange={(e) => setDataEmbarque(e.target.value)} />
        </FormField>

        <FormField label="Valor total (R$)" required error={total !== '' && !totalValido ? 'O total deve ser maior que zero.' : undefined}>
          <TextInput type="number" inputMode="decimal" value={total} onChange={(e) => setTotal(e.target.value)} placeholder="0,00" invalid={total !== '' && !totalValido} />
        </FormField>
      </div>
    </FlowShell>
  )
}
