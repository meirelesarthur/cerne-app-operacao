import { useParams, Navigate } from 'react-router-dom'
import { CloudOff } from 'lucide-react'
import { getModule } from '@/shell/moduleConfig'
import { ShellHeader } from '@/shell/components/ShellHeader'
import { ModuleSwitcher } from '@/shell/components/ModuleSwitcher'
import { BottomTabBar } from '@/shell/components/BottomTabBar'
import { Banner } from '@/components/ui/Banner'
import { useShellStore } from '@/shell/state/shellStore'
import { PlaceholderModule } from '@/modules/PlaceholderModule'
import { HubModule } from '@/modules/hub/HubModule'
import { FazendasModule } from '@/modules/fazendas/FazendasModule'
import { useFazendasStore } from '@/modules/fazendas/state/fazendasStore'

/**
 * Layout do Shell (spec §3.1): header global fixo + barra de módulos + conteúdo do módulo ativo
 * + bottom tab bar do módulo. Trocar de módulo troca tudo abaixo do header, mantendo o header.
 */
export function ShellLayout() {
  const { moduleId } = useParams()
  const module = getModule(moduleId)
  const isOnline = useShellStore((s) => s.isOnline)
  const view = useFazendasStore((s) => s.view)
  const setView = useFazendasStore((s) => s.setView)

  if (!module) return <Navigate to="/inicio" replace />

  const isFazendas = module.id === 'fazendas'

  return (
    <div className="flex h-full flex-col">
      <div className="shrink-0">
        <ShellHeader
          onConsultMode={isFazendas ? () => setView('gerencial') : undefined}
          consultActive={isFazendas && view === 'gerencial'}
        />
        <ModuleSwitcher activeId={module.id} />
      </div>

      {!isOnline && (
        <Banner tone="offline" icon={<CloudOff size={14} />}>
          Você está offline — os lançamentos serão sincronizados quando a conexão voltar.
        </Banner>
      )}

      <main className="no-scrollbar flex-1 overflow-y-auto">
        {module.id === 'inicio' ? (
          <HubModule />
        ) : module.id === 'fazendas' ? (
          <FazendasModule />
        ) : (
          <PlaceholderModule module={module} />
        )}
      </main>

      <div className="shrink-0">
        <BottomTabBar module={module} />
      </div>
    </div>
  )
}
