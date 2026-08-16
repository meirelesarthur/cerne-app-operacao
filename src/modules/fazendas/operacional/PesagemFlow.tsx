import { useState } from 'react'
import { Info } from 'lucide-react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { SearchSelect } from '@/components/ui/SearchSelect'
import { TextInput } from '@/components/ui/TextInput'
import { Banner } from '@/components/ui/Banner'
import { SectionTitle } from '@/components/ui/Heading'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { LOTES_OPCOES, DEPOSITOS } from '../mocks/operacional'

/** Pesagem (spec §5.1): leitura manual do peso (app não lê a balança) + registra pesagem do dia. */
export function PesagemFlow() {
  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)
  const registrarPesagemDoDia = useFazendasStore((s) => s.registrarPesagemDoDia)

  const [lote, setLote] = useState('')
  const [responsavel, setResponsavel] = useState('')
  const [especie, setEspecie] = useState('')
  const [categoria, setCategoria] = useState('')
  const [peso, setPeso] = useState('')
  const [deposito, setDeposito] = useState('')
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  const valid = responsavel && especie && categoria && lote && Number(peso) > 0 && deposito

  const confirmar = () => {
    registrarPesagemDoDia()
    const queued = !isOnline
    if (queued) {
      const loteLabel = LOTES_OPCOES.find((l) => l.value === lote)?.label ?? 'lote'
      enqueueSync({ id: `pes-${lote}`, label: `Pesagem ${loteLabel}`, detail: `${peso} kg`, kind: 'pesagem' })
    }
    setDone({ queued })
  }

  if (done) {
    return (
      <SuccessScreen
        title="Pesagem registrada"
        queued={done.queued}
        effects="Isso vai atualizar o estoque e pode gerar NF-e/transferência."
      />
    )
  }

  return (
    <FlowShell title="Pesagem" primaryLabel="Registrar pesagem" onPrimary={confirmar} primaryDisabled={!valid}>
      <div className="flex flex-col gap-5">
        <FormField label="Responsável" required>
          <FormSelect
            options={[
              { value: 'joao', label: 'João Oliveira' },
              { value: 'maria', label: 'Maria Souza' },
            ]}
            value={responsavel}
            onChange={(e) => setResponsavel(e.target.value)}
            placeholder="Selecione o responsável"
          />
        </FormField>
        <FormField label="Espécie" required>
          <FormSelect
            options={[
              { value: 'bovino', label: 'Bovino' },
              { value: 'bubalino', label: 'Bubalino' },
            ]}
            value={especie}
            onChange={(e) => setEspecie(e.target.value)}
            placeholder="Selecione a espécie"
          />
        </FormField>
        <FormField label="Categoria" required>
          <FormSelect
            options={[
              { value: 'bezerro', label: 'Bezerro' },
              { value: 'novilha', label: 'Novilha' },
              { value: 'vaca', label: 'Vaca' },
              { value: 'boi', label: 'Boi' },
            ]}
            value={categoria}
            onChange={(e) => setCategoria(e.target.value)}
            placeholder="Selecione a categoria"
          />
        </FormField>
        <FormField label="Lote / carga" required>
          <SearchSelect options={LOTES_OPCOES} value={lote} onChange={setLote} placeholder="Buscar lote..." />
        </FormField>

        <div>
          <SectionTitle className="mb-2">Peso</SectionTitle>
          <Banner tone="info" icon={<Info size={14} />} className="mb-3 rounded-lg border">
            Leitura da balança não disponível neste app — informe o peso manualmente ou use um leitor Bluetooth quando integrado.
          </Banner>
          <div className="flex items-end gap-2">
            <TextInput
              type="number"
              inputMode="decimal"
              value={peso}
              onChange={(e) => setPeso(e.target.value)}
              placeholder="0"
              className="h-16 text-center text-4xl font-bold"
            />
            <span className="pb-4 text-lg font-semibold text-fg-muted">kg</span>
          </div>
        </div>

        <FormField label="Depósito de destino" required>
          <FormSelect options={DEPOSITOS} value={deposito} onChange={(e) => setDeposito(e.target.value)} placeholder="Selecione o depósito" />
        </FormField>
      </div>
    </FlowShell>
  )
}
