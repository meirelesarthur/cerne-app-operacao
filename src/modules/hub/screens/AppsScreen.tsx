import { useNavigate } from 'react-router-dom'
import { MiniAppTile, Heading, SectionTitle } from '@/components/ui'
import { t } from '@/design/tokens'
import { HUB_APPS, APPS_EM_BREVE } from '../mocks/apps'

const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

/**
 * Catálogo completo de mini-apps (New-UI). Ponto único de descoberta:
 * apps disponíveis + roadmap visível ("Em breve") para gerar antecipação
 * sem esconder destinos de navegação.
 */
export function AppsScreen() {
  const navigate = useNavigate()

  return (
    <div className="flex flex-col gap-5 p-4">
      <div className="animate-rise" style={stagger(0)}>
        <Heading level={3}>Todos os apps</Heading>
        <p className="mt-0.5 text-sm text-fg-muted">Um só lugar para toda a operação — do campo ao banco.</p>
      </div>

      <div className="animate-rise" style={stagger(1)}>
        <SectionTitle className="mb-2">Disponíveis</SectionTitle>
        <div className="grid grid-cols-2 gap-3">
          {HUB_APPS.map((app) => (
            <MiniAppTile
              key={app.id}
              icon={app.icon}
              name={app.name}
              description={app.description}
              badge={app.badge}
              onClick={app.route ? () => navigate(app.route!) : undefined}
            />
          ))}
        </div>
      </div>

      <div className="animate-rise" style={stagger(2)}>
        <SectionTitle className="mb-2">Em breve</SectionTitle>
        <div className="grid grid-cols-2 gap-3">
          {APPS_EM_BREVE.map((app) => (
            <MiniAppTile key={app.id} icon={app.icon} name={app.name} description={app.description} badge="breve" disabled />
          ))}
        </div>
      </div>
    </div>
  )
}
