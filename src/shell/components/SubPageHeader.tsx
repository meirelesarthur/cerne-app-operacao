import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { IconButton } from '@/components/ui/IconButton'
import { Heading } from '@/components/ui/Heading'
import type { ReactNode } from 'react'

/**
 * Cabeçalho de página secundária (Nova UI): bolha circular de voltar + título
 * centralizado sobre o canvas, como na referência ("Profile", "Payments").
 */
export function SubPageHeader({ title, onBack, action }: { title: string; onBack?: () => void; action?: ReactNode }) {
  const navigate = useNavigate()
  return (
    <header className="flex items-center gap-3 bg-canvas px-4 py-3">
      <IconButton label="Voltar" variant="solid" size="lg" onClick={onBack ?? (() => navigate(-1))}>
        <ArrowLeft size={20} />
      </IconButton>
      <Heading level={3} className="min-w-0 flex-1 truncate text-center">
        {title}
      </Heading>
      {action ?? <span className="h-12 w-12 shrink-0" aria-hidden="true" />}
    </header>
  )
}
