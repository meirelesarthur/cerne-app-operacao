import { useState } from 'react'
import { Heading } from '@/components/ui'
import { UNIDADES, type Unidade } from '../mocks/estoque'
import { UnidadeCard } from '../components/UnidadeCard'
import { UnidadeDetailSheet } from '../components/UnidadeDetailSheet'

/** Aba "Unidades": lista completa das unidades de armazenagem (spec D2.6). */
export function UnidadesScreen() {
  const [selected, setSelected] = useState<Unidade | null>(null)

  return (
    <div className="flex flex-col gap-3 p-4">
      <Heading level={2}>Unidades</Heading>
      {UNIDADES.map((unidade) => (
        <UnidadeCard key={unidade.id} unidade={unidade} onClick={() => setSelected(unidade)} />
      ))}

      <UnidadeDetailSheet unidade={selected} onClose={() => setSelected(null)} />
    </div>
  )
}
