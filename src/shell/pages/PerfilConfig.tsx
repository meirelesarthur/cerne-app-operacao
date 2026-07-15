import { useNavigate } from 'react-router-dom'
import { Moon, Sun, LogOut, User, Bell } from 'lucide-react'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { Card } from '@/components/ui/Card'
import { Avatar } from '@/components/ui/Avatar'
import { MenuItem } from '@/components/ui/MenuItem'
import { useShellStore } from '@/shell/state/shellStore'
import { useTheme } from '@/context/ThemeContext'

/**
 * Perfil / Configurações do Shell (Nova UI): hero ink com avatar central
 * (tela "Profile" da referência) + lista de itens-cápsula. Conta + tema
 * light/gbMode continuam funções do Shell.
 */
export function PerfilConfig() {
  const navigate = useNavigate()
  const user = useShellStore((s) => s.user)
  const { isGbMode, toggle } = useTheme()
  const roleLabel = user.role === 'operador' ? 'Operador' : 'Administrador'

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader title="Perfil" />
      <div className="no-scrollbar flex flex-1 flex-col gap-3 overflow-y-auto p-4">
        {/* hero ink — identidade centralizada como na referência */}
        <Card variant="ink" className="flex flex-col items-center gap-3 py-8 text-center">
          <Avatar name={user.name} initials={user.initials} size="lg" className="h-20 w-20 text-2xl" />
          <div>
            <p className="text-2xl font-bold tracking-tight">{user.name}</p>
            <p className="mt-0.5 text-sm text-ink-muted">
              {roleLabel} · GB CERNE
            </p>
          </div>
        </Card>

        <MenuItem
          icon={User}
          label="Editar perfil"
          description="Atualize seus dados"
          onClick={() => navigate('/perfil')}
        />
        <MenuItem
          icon={Bell}
          label="Notificações"
          description="Gerencie seus avisos"
          onClick={() => navigate('/notificacoes')}
        />
        <MenuItem
          icon={isGbMode ? Moon : Sun}
          label="Tema"
          description={isGbMode ? 'GB Mode (escuro)' : 'Light (claro)'}
          onClick={toggle}
        />

        <div className="mt-4">
          <MenuItem icon={LogOut} tone="danger" label="Sair" onClick={() => navigate('/login')} />
        </div>
      </div>
    </div>
  )
}
