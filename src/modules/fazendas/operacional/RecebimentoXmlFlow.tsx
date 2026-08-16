import { useState } from 'react'
import { FileText } from 'lucide-react'
import { FlowShell } from './FlowShell'
import { SuccessScreen } from './SuccessScreen'
import { FileUpload } from '@/components/ui/FileUpload'
import { Checkbox } from '@/components/ui/Checkbox'
import { Card } from '@/components/ui/Card'
import { SectionTitle } from '@/components/ui/Heading'
import { useShellStore } from '@/shell/state/shellStore'
import { useFazendasStore } from '../state/fazendasStore'
import { NFE_ITENS, NFE_CABECALHO } from '../mocks/operacional'

/** Recebimento / Entrada por XML (NF-e) (spec §5.4): upload + conferência de itens. */
export function RecebimentoXmlFlow() {
  const isOnline = useShellStore((s) => s.isOnline)
  const enqueueSync = useFazendasStore((s) => s.enqueueSync)

  const [file, setFile] = useState<string | null>(null)
  const [conferidos, setConferidos] = useState<Record<string, boolean>>({})
  const [done, setDone] = useState<null | { queued: boolean }>(null)

  const toggle = (id: string) => setConferidos((c) => ({ ...c, [id]: !c[id] }))
  const totalConferidos = NFE_ITENS.filter((i) => conferidos[i.id]).length

  const confirmar = () => {
    const queued = !isOnline
    if (queued) enqueueSync({ id: `nfe-${NFE_CABECALHO.numero}`, label: `NF-e #${NFE_CABECALHO.numero}`, detail: NFE_CABECALHO.fornecedor, kind: 'nfe' })
    setDone({ queued })
  }

  if (done) {
    return (
      <SuccessScreen
        title="Entrada processada"
        queued={done.queued}
        effects="Movimento de compra será processado e um título a pagar será gerado no financeiro."
      />
    )
  }

  return (
    <FlowShell
      title="Entrada por XML (NF-e)"
      primaryLabel={file ? 'Confirmar entrada' : undefined}
      onPrimary={confirmar}
      primaryDisabled={!file}
    >
      <div className="flex flex-col gap-5">
        <div>
          <SectionTitle className="mb-2">Arquivo da nota</SectionTitle>
          <FileUpload onFile={setFile} />
        </div>

        {file && (
          <>
            <Card>
              <div className="flex items-center gap-3">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-accent-subtle text-accent">
                  <FileText size={20} />
                </span>
                <div className="flex-1">
                  <p className="font-semibold text-fg">{NFE_CABECALHO.fornecedor}</p>
                  <p className="text-sm text-fg-muted">NF-e #{NFE_CABECALHO.numero}</p>
                </div>
                <span className="text-lg font-bold text-fg">{NFE_CABECALHO.total}</span>
              </div>
            </Card>

            <div>
              <div className="mb-2 flex items-center justify-between">
                <SectionTitle>Itens da nota</SectionTitle>
                <span className="text-xs text-fg-muted">
                  {totalConferidos}/{NFE_ITENS.length} conferidos
                </span>
              </div>
              <ul className="overflow-hidden rounded-2xl border border-border-default bg-surface">
                {NFE_ITENS.map((item) => (
                  <li key={item.id} className="flex items-center gap-3 border-b border-border-subtle px-4 py-3 last:border-b-0">
                    <Checkbox
                      checked={!!conferidos[item.id]}
                      onChange={() => toggle(item.id)}
                      ariaLabel={`Conferir ${item.descricao}`}
                    />
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-medium text-fg">{item.descricao}</p>
                      <p className="text-sm text-fg-muted">{item.qtd}</p>
                    </div>
                    <span className="text-sm font-semibold text-fg">{item.valor}</span>
                  </li>
                ))}
              </ul>
            </div>
          </>
        )}
      </div>
    </FlowShell>
  )
}
