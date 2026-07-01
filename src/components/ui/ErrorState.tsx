import { AlertTriangle } from 'lucide-react'
import { Button } from './Button'
import { Heading } from './Heading'
import { cn } from '@/lib/cn'

export interface ErrorStateProps {
  title?: string
  description?: string
  onRetry?: () => void
  className?: string
}

/** Estado de erro de carregamento com retry (spec §7.1). */
export function ErrorState({
  title = 'Não foi possível carregar',
  description = 'Ocorreu um erro ao buscar os dados. Tente novamente.',
  onRetry,
  className,
}: ErrorStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center px-6 py-12 text-center', className)}>
      <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-red-50 text-red-600">
        <AlertTriangle size={26} />
      </div>
      <Heading level={3}>{title}</Heading>
      <p className="mt-1 max-w-[280px] text-md text-fg-muted">{description}</p>
      {onRetry && (
        <Button variant="secondary" className="mt-4" onClick={onRetry}>
          Tentar novamente
        </Button>
      )}
    </div>
  )
}
