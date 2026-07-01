import { useParams, Navigate } from 'react-router-dom'
import { CloudOff } from 'lucide-react'
import { getModule } from '@/shell/moduleConfig'
import { ShellHeader } from '@/shell/components/ShellHeader'
import { ModuleSwitcher } from '@/shell/components/ModuleSwitcher'
import { BottomTabBar } from '@/shell/components/BottomTabBar'
import { Banner } from '@/components/ui/Banner'
import { useShellStore } from '@/shell/state/shellStore'
import { PlaceholderModule } from '@/modules/PlaceholderModule'
import { FazendasModule } from '@/modules/fazendas/FazendasModule'

/**
 * Layout do Shell (spec §3.1): header global fixo + barra de módulos + conteúdo do módulo ativo
 * + bottom tab bar do módulo. Trocar de módulo troca tudo abaixo do header, mantendo o header.
 */
export function ShellLayout() {
  const { moduleId } = useParams()
  const module = getModule(moduleId)
  const isOnline = useShellStore((s) => s.isOnline)

  if (!module) return <Navigate to="/fazendas" replace />

  return (
    <div className="flex h-full flex-col">
      <div className="shrink-0">
        <ShellHeader />
        <ModuleSwitcher activeId={module.id} />
      </div>

      {!isOnline && (
        <Banner tone="offline" icon={<CloudOff size={14} />}>
          Você está offline — os lançamentos serão sincronizados quando a conexão voltar.
        </Banner>
      )}

      <main className="no-scrollbar flex-1 overflow-y-auto">
        {module.id === 'fazendas' ? <FazendasModule /> : <PlaceholderModule module={module} />}
      </main>

      <div className="shrink-0">
        <BottomTabBar module={module} />
      </div>
    </div>
  )
}
