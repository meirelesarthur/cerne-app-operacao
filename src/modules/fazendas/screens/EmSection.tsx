import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui/EmptyState'
import { SubPageHeader } from '@/shell/components/SubPageHeader'

/** Placeholder de seção interna ainda não construída (usado até Fases 3/4). */
export function EmSection({ title }: { title: string }) {
  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title={title} />
      <EmptyState
        icon={Construction}
        title="Em desenvolvimento"
        description="Esta tela será construída na próxima fase da esteira."
        className="flex-1 justify-center"
      />
    </div>
  )
}
