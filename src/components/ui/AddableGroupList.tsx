import { Plus } from 'lucide-react'
import { Button } from './Button'
import { Chip } from './Chip'

export interface AddableGroupListProps {
  groups: string[]
  counts: Record<string, number>
  onAdd: (group: string) => void
}

/** Grupos repetíveis de um formulário, com inclusão demonstrável e contador visível. */
export function AddableGroupList({ groups, counts, onAdd }: AddableGroupListProps) {
  return (
    <div className="flex flex-col gap-2">
      {groups.map((group) => {
        const count = counts[group] ?? 0
        return (
          <div
            key={group}
            className="flex min-h-14 items-center gap-3 rounded-2xl border border-border-default bg-surface-subtle px-3 py-2"
          >
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-fg">{group}</p>
              <p className="text-xs text-fg-muted">{count ? `${count} item(ns) adicionado(s)` : 'Nenhum item adicionado'}</p>
            </div>
            {count > 0 && <Chip tone="brand">{count}</Chip>}
            <Button
              type="button"
              size="sm"
              variant="secondary"
              leftIcon={<Plus size={15} />}
              onClick={() => onAdd(group)}
              aria-label={`Adicionar item em ${group}`}
            >
              Adicionar
            </Button>
          </div>
        )
      })}
    </div>
  )
}
