import { useState } from 'react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { TextInput } from '@/components/ui/TextInput'
import { Textarea } from '@/components/ui/Textarea'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { TALHOES, CICLOS, INSUMOS } from '../mocks/operacional'
import { cn } from '@/lib/cn'

type Lancamento = 'aplicacao' | 'ocorrencia'

/**
 * Aplicação de Insumos / Ocorrências Agrícolas (spec §5.6) — status PARCIAL.
 * Sem validações cruzadas complexas: apenas campos obrigatórios básicos (talhão, data, tipo).
 */
export function InsumosFlow() {
  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)

  const [talhao, setTalhao] = useState('')
  const [ciclo, setCiclo] = useState('')
  const [tipo, setTipo] = useState<Lancamento>('aplicacao')
  const [data, setData] = useState('')
  const [insumo, setInsumo] = useState('')
  const [qtd, setQtd] = useState('')
  const [descricao, setDescricao] = useState('')
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  // validação mínima (talhão + data + tipo)
  const valid = !!talhao && !!data

  const confirmar = () => {
    const queued = !isOnline
    if (queued) enqueueSync({ id: `ins-${talhao}`, label: `Insumo (${tipo})`, detail: 'Talhão', kind: 'insumo' })
    setDone({ queued })
  }

  if (done) {
    return <SuccessScreen title="Lançamento registrado" queued={done.queued} effects="A ocorrência/aplicação será vinculada ao talhão e ciclo de produção." />
  }

  return (
    <FlowShell title="Insumos / Ocorrências" primaryLabel="Registrar" onPrimary={confirmar} primaryDisabled={!valid}>
      <div className="flex flex-col gap-5">
        <FormField label="Área / talhão" required>
          <FormSelect options={TALHOES} value={talhao} onChange={(e) => setTalhao(e.target.value)} placeholder="Selecione o talhão" />
        </FormField>
        <FormField label="Ciclo de produção">
          <FormSelect options={CICLOS} value={ciclo} onChange={(e) => setCiclo(e.target.value)} placeholder="Selecione o ciclo" />
        </FormField>

        <FormField label="Tipo de lançamento" required>
          <div className="flex gap-2">
            {(['aplicacao', 'ocorrencia'] as Lancamento[]).map((op) => (
              <button
                key={op}
                type="button"
                onClick={() => setTipo(op)}
                className={cn(
                  'flex-1 rounded-lg border px-3 py-2 text-md font-semibold capitalize',
                  tipo === op ? 'border-accent bg-accent text-white' : 'border-border-default bg-surface text-fg-muted',
                )}
              >
                {op === 'aplicacao' ? 'Aplicação' : 'Ocorrência'}
              </button>
            ))}
          </div>
        </FormField>

        <FormField label="Data" required>
          <TextInput type="date" value={data} onChange={(e) => setData(e.target.value)} />
        </FormField>

        {tipo === 'aplicacao' ? (
          <>
            <FormField label="Produto / insumo">
              <FormSelect options={INSUMOS} value={insumo} onChange={(e) => setInsumo(e.target.value)} placeholder="Selecione o insumo" />
            </FormField>
            <FormField label="Quantidade">
              <TextInput type="number" inputMode="decimal" value={qtd} onChange={(e) => setQtd(e.target.value)} placeholder="Quantidade aplicada" />
            </FormField>
          </>
        ) : (
          <FormField label="Descrição da ocorrência">
            <Textarea value={descricao} onChange={(e) => setDescricao(e.target.value)} placeholder="Descreva a ocorrência..." />
          </FormField>
        )}
      </div>
    </FlowShell>
  )
}
