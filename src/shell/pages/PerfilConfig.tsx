import { useNavigate } from 'react-router-dom'
import { Moon, Sun, LogOut, User, ChevronRight } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Card } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { useShellStore } from '@/shell/state/shellStore'
import { useTheme } from '@/context/ThemeContext'

/** Perfil / Configurações do Shell (spec §3.1): conta + tema light/gbMode (config é do Shell). */
export function PerfilConfig() {
  const navigate = useNavigate()
  const user = useShellStore((s) => s.user)
  const { isGbMode, toggle } = useTheme()

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader title="Perfil e configurações" />
      <div className="flex-1 overflow-y-auto p-4">
        <Card className="flex items-center gap-3">
          <span className="flex h-12 w-12 items-center justify-center rounded-full bg-accent text-lg font-bold text-white">
            {user.initials}
          </span>
          <div className="flex-1">
            <p className="text-lg font-semibold text-fg">{user.name}</p>
            <p className="text-sm text-fg-muted capitalize">Perfil: {user.role}</p>
          </div>
          <User size={18} className="text-fg-subtle" />
        </Card>

        <p className="mb-2 mt-6 px-1 text-xs font-semibold uppercase tracking-wide text-fg-subtle">Aparência</p>
        <Card padded={false}>
          <button
            onClick={toggle}
            className="flex w-full items-center gap-3 px-4 py-3"
          >
            <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-accent-subtle text-accent">
              {isGbMode ? <Moon size={18} /> : <Sun size={18} />}
            </span>
            <div className="flex-1 text-left">
              <p className="font-semibold text-fg">Tema</p>
              <p className="text-sm text-fg-muted">{isGbMode ? 'GB Mode (escuro)' : 'Light (claro)'}</p>
            </div>
            <ChevronRight size={18} className="text-fg-subtle" />
          </button>
        </Card>

        <div className="mt-8">
          <Button variant="secondary" fullWidth leftIcon={<LogOut size={16} />} onClick={() => navigate('/login')}>
            Sair
          </Button>
        </div>
      </div>
    </div>
  )
}
