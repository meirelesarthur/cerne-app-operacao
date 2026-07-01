import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { IconButton } from '@/components/ui/IconButton'
import type { ReactNode } from 'react'

/** Cabeçalho de página secundária (Notificações, Perfil, telas internas) com voltar. */
export function SubPageHeader({ title, onBack, action }: { title: string; onBack?: () => void; action?: ReactNode }) {
  const navigate = useNavigate()
  return (
    <header className="flex items-center gap-2 border-b border-border-default bg-surface px-2 py-2">
      <IconButton label="Voltar" onClick={onBack ?? (() => navigate(-1))}>
        <ArrowLeft size={20} />
      </IconButton>
      <h1 className="flex-1 text-lg font-semibold text-fg">{title}</h1>
      {action}
    </header>
  )
}
