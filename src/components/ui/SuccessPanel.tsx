import type { ReactNode } from 'react'
import { CheckCircle2, type LucideIcon } from 'lucide-react'
import { cn } from '@/lib/cn'
import { Heading } from './Heading'

export interface SuccessPanelProps {
  title: string
  /** Texto/descrição dos efeitos da operação — aceita nós ricos (valores em destaque). */
  description?: ReactNode
  /** Ícone do selo (padrão: check). */
  icon?: LucideIcon
  /** Ações (botões) renderizadas abaixo — compostas pela tela chamadora (Lei 1). */
  children?: ReactNode
  className?: string
}

/**
 * Painel de sucesso genérico pós-operação, no padrão da SuccessScreen de Fazendas
 * (NEW_UI_SUPERAPP.md), agora reutilizável no catálogo. A navegação de saída é
 * responsabilidade da tela chamadora, passada via `children` (botões ui/).
 */
export function SuccessPanel({ title, description, icon: Icon = CheckCircle2, children, className }: SuccessPanelProps) {
  return (
    <div className={cn('flex h-full flex-col items-center justify-center gap-4 bg-canvas p-6 text-center', className)}>
      <div className="flex h-16 w-16 items-center justify-center rounded-full bg-brand-50 text-accent animate-rise">
        <Icon size={32} aria-hidden="true" />
      </div>
      <Heading level={2}>{title}</Heading>
      {description && <div className="max-w-[300px] text-md text-fg-muted">{description}</div>}
      {children && <div className="mt-2 flex w-full max-w-[300px] flex-col gap-2">{children}</div>}
    </div>
  )
}
