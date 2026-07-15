import { useParams, Navigate } from 'react-router-dom'
import { CloudOff } from 'lucide-react'
import { getModule } from '@/shell/moduleConfig'
import { ShellHeader } from '@/shell/components/ShellHeader'
import { ModuleSwitcher } from '@/shell/components/ModuleSwitcher'
import { BottomTabBar } from '@/shell/components/BottomTabBar'
import { RevealMenu } from '@/shell/components/RevealMenu'
import { Banner } from '@/components/ui/Banner'
import { useShellStore } from '@/shell/state/shellStore'
import { HubModule } from '@/modules/hub/HubModule'
import { FazendasModule } from '@/modules/fazendas/FazendasModule'
import { BankModule } from '@/modules/bank/BankModule'
import { CreditoModule } from '@/modules/credito/CreditoModule'
import { MarketplaceModule } from '@/modules/marketplace/MarketplaceModule'
import { ArmazemModule } from '@/modules/armazem/ArmazemModule'
import { CreditoPill } from '@/modules/fazendas/components/CreditoPill'
import { useFazendasStore } from '@/modules/fazendas/state/fazendasStore'
import { t } from '@/design/tokens'
import { cn } from '@/lib/cn'

const rm = t.component.revealMenu

/**
 * Layout do Shell (spec §3.1): header global fixo + barra de módulos + conteúdo do módulo ativo
 * + bottom tab bar do módulo. Trocar de módulo troca tudo abaixo do header, mantendo o header.
 *
 * New-UI: com o RevealMenu aberto (aba Mais/Menu), o app inteiro encolhe e desliza
 * para a esquerda (vira um cartão) revelando o menu escuro à direita — transform+opacity
 * apenas, spring tokenizado, respeitando prefers-reduced-motion.
 */
export function ShellLayout() {
  const { moduleId } = useParams()
  const module = getModule(moduleId)
  const isOnline = useShellStore((s) => s.isOnline)
  const menuOpen = useShellStore((s) => s.menuOpen)
  const closeMenu = useShellStore((s) => s.closeMenu)
  const view = useFazendasStore((s) => s.view)
  const setView = useFazendasStore((s) => s.setView)

  if (!module) return <Navigate to="/inicio" replace />

  const isFazendas = module.id === 'fazendas'

  return (
    <div className="relative h-full overflow-hidden" style={{ background: menuOpen ? rm.bg : undefined }}>
      <RevealMenu module={module} />

      {/* o app inteiro — encolhe como cartão quando o menu abre */}
      <div
        className={cn(
          'relative flex h-full flex-col bg-canvas will-change-transform',
          'transition-transform duration-spring ease-spring motion-reduce:transition-none',
          menuOpen && 'overflow-hidden rounded-3xl shadow-modal',
        )}
        style={{
          transform: menuOpen ? `translateX(${rm.appShiftX}) scale(${rm.appScale})` : undefined,
          transformOrigin: 'left center',
        }}
      >
        <div className="shrink-0">
          <ShellHeader
            onConsultMode={isFazendas ? () => setView('gerencial') : undefined}
            consultActive={isFazendas && view === 'gerencial'}
          >
            {/* contexto do módulo dentro do gradiente (premium clean) */}
            {isFazendas && <CreditoPill />}
          </ShellHeader>
          <ModuleSwitcher activeId={module.id} />
        </div>

        {!isOnline && (
          <Banner tone="offline" icon={<CloudOff size={14} />}>
            Você está offline — os lançamentos serão sincronizados quando a conexão voltar.
          </Banner>
        )}

        {/* sheet claro com topo arredondado sobre o verde do header */}
        <div className="min-h-0 flex-1" style={{ background: t.component.header.tabsBg }}>
          <main
            className={cn(
              'no-scrollbar h-full overflow-y-auto',
              !isFazendas && 'rounded-t-3xl bg-surface', // Fazendas monta o próprio sheet (barra de visão + sync)
            )}
          >
            {module.id === 'inicio' ? (
              <HubModule />
            ) : module.id === 'fazendas' ? (
              <FazendasModule />
            ) : module.id === 'bank' ? (
              <BankModule />
            ) : module.id === 'credito' ? (
              <CreditoModule />
            ) : module.id === 'marketplace' ? (
              <MarketplaceModule />
            ) : module.id === 'armazem' ? (
              <ArmazemModule />
            ) : (
              <Navigate to="/inicio" replace />
            )}
          </main>
        </div>

        <div className="shrink-0">
          <BottomTabBar module={module} />
        </div>

        {/* com o menu aberto, tocar no app encolhido fecha o menu */}
        {menuOpen && (
          <button
            type="button"
            aria-label="Fechar menu"
            onClick={closeMenu}
            className="absolute inset-0 cursor-pointer"
            style={{ zIndex: t.zIndex.overlay }}
          />
        )}
      </div>
    </div>
  )
}
