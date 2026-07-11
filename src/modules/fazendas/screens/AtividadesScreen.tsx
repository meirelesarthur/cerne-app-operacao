import { useState } from 'react'
import { Heading } from '@/components/ui/Heading'
import { ActivityListItem } from '../components/ActivityListItem'
import { ActivityDetailSheet } from '../components/ActivityDetailSheet'
import { ATIVIDADES } from '../mocks/atividades'
import type { Activity } from '../types'

/** Aba "Atividades" — lista cronológica completa (spec §6.7). */
export function AtividadesScreen() {
  const [selected, setSelected] = useState<Activity | null>(null)

  return (
    <div className="flex flex-col gap-3 p-4">
      <Heading level={2}>Atividades</Heading>
      <div className="rounded-2xl border border-border-default bg-surface px-3">
        {ATIVIDADES.map((a) => (
          <ActivityListItem key={a.id} activity={a} onClick={() => setSelected(a)} />
        ))}
      </div>

      <ActivityDetailSheet activity={selected} onClose={() => setSelected(null)} />
    </div>
  )
}
