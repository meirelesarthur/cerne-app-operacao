import { useNavigate } from 'react-router-dom'
import { ClipboardCheck, LayoutDashboard } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Heading } from '@/components/ui/Heading'
import { t } from '@/design/tokens'
import loginBg from '@/images/login_bg.png'
import logoMinWhite from '@/images/logo-min-white.svg'
import { useShellStore, type AccessRole } from '@/shell/state/shellStore'

/**
 * Login do Shell (mock, sem autenticação real): arte de campo em tela cheia
 * como fundo fixo (não rola), véu verde só no topo para a marca branca, e
 * cartão de boas-vindas com a escolha explícita do ambiente. O protótipo não
 * autentica credenciais: cada CTA define o perfil e abre somente suas rotas.
 */
export function Login() {
  const navigate = useNavigate()
  const loginAs = useShellStore((s) => s.loginAs)
  const enterAs = (role: AccessRole) => {
    loginAs(role)
    navigate(role === 'admin' ? '/fazendas/administracao' : '/fazendas/operacional')
  }

  return (
    <div className="relative h-full bg-canvas">
      {/* arte de fundo integral — fixa no viewport; o conteúdo rola por cima */}
      <img
        src={loginBg}
        alt=""
        aria-hidden="true"
        className="absolute inset-0 h-full w-full object-cover"
      />
      <div
        aria-hidden="true"
        className="absolute inset-0"
        style={{
          background: `linear-gradient(180deg, ${t.component.login.heroScrim.from} 0%, ${t.component.login.heroScrim.mid} 40%, ${t.component.login.heroScrim.to} 68%)`,
        }}
      />

      <div className="no-scrollbar relative flex h-full flex-col overflow-y-auto">
        {/* bloco da marca sobre a arte */}
        <div className="flex shrink-0 flex-col items-center gap-3 px-6 pb-10 pt-14 text-center">
          <img src={logoMinWhite} alt="Logo GB" className="h-16 w-16 rounded-2xl shadow-brand" />
          <Heading level={1} className="text-white">
            GB CERNE
          </Heading>
          <p className="max-w-[260px] text-md text-white/70">
            Fazendas, banco, crédito e mercado — o agro inteiro em um só app.
          </p>
        </div>

        {/* cartão de escolha de responsabilidade flutuando sobre a arte */}
        <div className="flex flex-1 flex-col px-5 pb-8">
          <Card className="rounded-3xl p-6 shadow-modal">
            <div className="flex flex-col items-center gap-1 text-center">
              <Heading level={2}>Bem-vindo!</Heading>
              <p className="flex items-center gap-1 text-sm text-fg-muted">
                Primeira vez por aqui?
                <Button variant="link" onClick={() => navigate('/onboarding')}>
                  Conhecer o app
                </Button>
              </p>
            </div>

            <div className="mt-6 flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <p className="text-center text-sm font-semibold text-fg">Escolha o ambiente de acesso</p>
                <Button
                  fullWidth
                  size="lg"
                  leftIcon={<LayoutDashboard size={19} />}
                  onClick={() => enterAs('admin')}
                >
                  Login Administração
                </Button>
                <Button
                  fullWidth
                  size="lg"
                  variant="secondary"
                  leftIcon={<ClipboardCheck size={19} />}
                  onClick={() => enterAs('operador')}
                >
                  Login Operacional
                </Button>
                <p className="mt-1 text-center text-xs text-fg-muted">
                  Acesso demonstrativo sem autenticação real. Cada perfil abre apenas as responsabilidades correspondentes.
                </p>
              </div>
            </div>
          </Card>

          <p className="mt-auto pt-6 text-center text-xs text-white/70">
            GB CERNE · Superapp corporativo do agronegócio
          </p>
        </div>
      </div>
    </div>
  )
}
