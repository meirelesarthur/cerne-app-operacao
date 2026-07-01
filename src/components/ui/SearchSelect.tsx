import { useState } from 'react'
import { Search, Check } from 'lucide-react'
import { cn } from '@/lib/cn'

export interface SearchSelectOption {
  value: string
  label: string
  detail?: string
}

export interface SearchSelectProps {
  options: SearchSelectOption[]
  value?: string
  onChange: (value: string) => void
  placeholder?: string
}

/** Seleção com busca (ex.: selecionar lote/carga). Lista inline filtrável. */
export function SearchSelect({ options, value, onChange, placeholder = 'Buscar...' }: SearchSelectProps) {
  const [query, setQuery] = useState('')
  const filtered = options.filter((o) => o.label.toLowerCase().includes(query.toLowerCase()))

  return (
    <div className="flex flex-col gap-2">
      <div className="relative">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-fg-subtle" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={placeholder}
          className="h-10 w-full rounded-lg border border-border-default bg-surface pl-9 pr-3 text-md text-fg placeholder:text-fg-subtle focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40"
        />
      </div>
      <ul className="max-h-56 overflow-y-auto rounded-lg border border-border-default bg-surface">
        {filtered.length === 0 && <li className="px-3 py-4 text-center text-sm text-fg-subtle">Nada encontrado</li>}
        {filtered.map((o) => {
          const selected = o.value === value
          return (
            <li key={o.value}>
              <button
                type="button"
                onClick={() => onChange(o.value)}
                className={cn(
                  'flex w-full items-center justify-between gap-2 border-b border-border-subtle px-3 py-2.5 text-left last:border-b-0',
                  selected && 'bg-accent-subtle',
                )}
              >
                <span>
                  <span className="block font-medium text-fg">{o.label}</span>
                  {o.detail && <span className="block text-sm text-fg-muted">{o.detail}</span>}
                </span>
                {selected && <Check size={16} className="text-accent" />}
              </button>
            </li>
          )
        })}
      </ul>
    </div>
  )
}
