import { FileBarChart } from 'lucide-react'
import { Card, Chip, EmptyState, Heading } from '@/components/ui'
import { RELATORIOS } from '../mocks/estoque'

/** Aba "Relatórios": relatórios mockados de operação do armazém (spec D2.5). */
export function RelatoriosScreen() {
  return (
    <div className="flex flex-col gap-3 p-4">
      <Heading level={2}>Relatórios</Heading>

      {RELATORIOS.length === 0 ? (
        <EmptyState
          icon={FileBarChart}
          title="Nenhum relatório"
          description="Ainda não há relatórios gerados para o armazém."
          className="h-full justify-center"
        />
      ) : (
        RELATORIOS.map((rel) => (
          <Card key={rel.id}>
            <div className="flex items-center justify-between gap-2">
              <p className="truncate text-sm font-semibold text-fg">{rel.nome}</p>
              <Chip tone={rel.disponivel ? 'brand' : 'neutral'} className="shrink-0">
                {rel.disponivel ? 'Disponível' : 'Indisponível'}
              </Chip>
            </div>
            <p className="mt-0.5 text-xs text-fg-muted">{rel.periodo}</p>
          </Card>
        ))
      )}
    </div>
  )
}
