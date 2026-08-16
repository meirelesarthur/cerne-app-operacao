import { useState } from 'react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { SearchSelect } from '@/components/ui/SearchSelect'
import { Stepper } from '@/components/ui/Stepper'
import { TextInput } from '@/components/ui/TextInput'
import { Textarea } from '@/components/ui/Textarea'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { LOTES_OPCOES, DIETAS, DEPOSITOS } from '../mocks/operacional'

/**
 * Arraçoamento / Nutrição (spec §5.3): registro simples de quantidade.
 * Rateio/apropriação de custo está em LACUNA no recorte — NÃO implementado aqui.
 */
export function ArracoamentoFlow() {
  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)

  const [lote, setLote] = useState('')
  const [dieta, setDieta] = useState('')
  const [qtd, setQtd] = useState(500)
  const [deposito, setDeposito] = useState('')
  const [area, setArea] = useState('')
  const [modulo, setModulo] = useState('')
  const [cocho, setCocho] = useState('')
  const [observacao, setObservacao] = useState('')
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  const valid = lote && dieta && deposito && area && modulo && cocho && qtd > 0

  const confirmar = () => {
    const queued = !isOnline
    if (queued) enqueueSync({ id: `arr-${lote}`, label: 'Arraçoamento', detail: `${qtd} kg`, kind: 'arracoamento' })
    setDone({ queued })
  }

  if (done) {
    return <SuccessScreen title="Arraçoamento registrado" queued={done.queued} effects="A quantidade fornecida será baixada do estoque do depósito de origem." />
  }

  return (
    <FlowShell title="Arraçoamento" primaryLabel="Registrar arraçoamento" onPrimary={confirmar} primaryDisabled={!valid}>
      <div className="flex flex-col gap-5">
        <FormField label="Lote" required>
          <SearchSelect options={LOTES_OPCOES} value={lote} onChange={setLote} placeholder="Buscar lote..." />
        </FormField>
        <FormField label="Dieta / produto" required>
          <FormSelect options={DIETAS} value={dieta} onChange={(e) => setDieta(e.target.value)} placeholder="Selecione a dieta" />
        </FormField>
        <FormField label="Quantidade fornecida" required hint="Sem cálculo de rateio de custo nesta fase.">
          <Stepper value={qtd} onChange={setQtd} step={50} min={0} suffix="kg" />
        </FormField>
        <FormField label="Depósito de origem" required>
          <FormSelect options={DEPOSITOS} value={deposito} onChange={(e) => setDeposito(e.target.value)} placeholder="Selecione o depósito" />
        </FormField>
        <FormField label="Área" required>
          <FormSelect
            options={[
              { value: 'pasto-norte', label: 'Pasto Norte' },
              { value: 'confinamento', label: 'Confinamento' },
            ]}
            value={area}
            onChange={(e) => setArea(e.target.value)}
            placeholder="Selecione a área"
          />
        </FormField>
        <FormField label="Módulo" required>
          <TextInput value={modulo} onChange={(e) => setModulo(e.target.value)} placeholder="Informe o módulo" />
        </FormField>
        <FormField label="Cocho" required>
          <TextInput value={cocho} onChange={(e) => setCocho(e.target.value)} placeholder="Informe o cocho" />
        </FormField>
        <FormField label="Observação">
          <Textarea value={observacao} onChange={(e) => setObservacao(e.target.value)} placeholder="Informações adicionais" />
        </FormField>
      </div>
    </FlowShell>
  )
}
