import { useParams } from 'react-router-dom'
import type { ComponentType } from 'react'
import { PesagemFlow } from './PesagemFlow'
import { CicloRebanhoFlow } from './CicloRebanhoFlow'
import { ArracoamentoFlow } from './ArracoamentoFlow'
import { VendaFlow } from './VendaFlow'
import { RecebimentoXmlFlow } from './RecebimentoXmlFlow'
import { InsumosFlow } from './InsumosFlow'
import { EmSection } from '../screens/EmSection'

/** Resolve o fluxo operacional pela rota /fazendas/campo/:flowId (spec §5). */
const FLOWS: Record<string, ComponentType> = {
  pesagem: PesagemFlow,
  ciclo: CicloRebanhoFlow,
  arracoamento: ArracoamentoFlow,
  venda: VendaFlow,
  recebimento: RecebimentoXmlFlow,
  insumos: InsumosFlow,
}

export function CampoFlow() {
  const { flowId } = useParams()
  const Flow = flowId ? FLOWS[flowId] : undefined
  if (!Flow) return <EmSection title="Lançamento" />
  return <Flow />
}
