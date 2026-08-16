import { Leaf, Check } from 'lucide-react'
import { Heading } from '@/components/ui/Heading'
import { Chip } from '@/components/ui/Chip'
import { Pressable } from '@/components/ui/Pressable'
import { useFazendasStore } from '../state/fazendasStore'
import { cn } from '@/lib/cn'

/** Aba "Fazendas" — lista de fazendas vinculadas; toque troca o tenant ativo. */
export function FarmListScreen() {
  const farms = useFazendasStore((s) => s.farms)
  const activeFarmId = useFazendasStore((s) => s.activeFarmId)
  const setActiveFarm = useFazendasStore((s) => s.setActiveFarm)

  return (
    <div className="flex flex-col gap-3 p-4">
      <Heading level={2}>Minhas fazendas</Heading>
      <ul className="flex flex-col gap-2">
        {farms.map((f) => {
          const active = f.id === activeFarmId
          return (
            <li key={f.id}>
              <Pressable
                onClick={() => setActiveFarm(f.id)}
                className={cn(
                  'flex w-full items-center gap-3 rounded-2xl border p-3 text-left',
                  active ? 'border-accent bg-accent-subtle' : 'border-border-default bg-surface',
                )}
              >
                <span className="flex h-11 w-11 items-center justify-center rounded-full bg-accent text-white">
                  <Leaf size={20} />
                </span>
                <div className="flex-1">
                  <p className="font-semibold text-fg">{f.name}</p>
                  <p className="text-sm text-fg-muted">
                    {f.city}/{f.uf}
                  </p>
                </div>
                {active ? <Chip tone="brand" icon={<Check size={12} />}>Ativa</Chip> : null}
              </Pressable>
            </li>
          )
        })}
      </ul>
    </div>
  )
}
