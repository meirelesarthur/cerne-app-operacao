import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Sprout } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Heading } from '@/components/ui/Heading'
import { FormField } from '@/components/ui/FormField'
import { TextInput } from '@/components/ui/TextInput'
import { Checkbox } from '@/components/ui/Checkbox'
import { t } from '@/design/tokens'
import loginBg from '@/images/login_bg.png'

/**
 * Login do Shell (mock, sem autenticação real): arte de campo em tela cheia
 * como fundo fixo (não rola), véu verde só no topo para a marca branca, e
 * cartão de boas-vindas com o formulário flutuando sobre a arte.
 * Qualquer entrada leva ao superapp.
 */
export function Login() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [manterConectado, setManterConectado] = useState(true)

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
          <span className="flex h-16 w-16 items-center justify-center rounded-3xl border border-white/20 bg-white/10 text-white shadow-brand">
            <Sprout size={32} />
          </span>
          <Heading level={1} className="text-white">
            GB CERNE
          </Heading>
          <p className="max-w-[260px] text-md text-white/70">
            Fazendas, banco, crédito e mercado — o agro inteiro em um só app.
          </p>
        </div>

        {/* cartão do formulário flutuando sobre a arte */}
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
            <FormField label="E-mail" htmlFor="login-email">
              <TextInput
                id="login-email"
                type="email"
                autoComplete="email"
                placeholder="seu@email.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </FormField>

            <FormField label="Senha" htmlFor="login-senha">
              <TextInput
                id="login-senha"
                type="password"
                autoComplete="current-password"
                placeholder="Digite sua senha"
                value={senha}
                onChange={(e) => setSenha(e.target.value)}
              />
            </FormField>

            <div className="flex items-center justify-between">
              <Checkbox checked={manterConectado} onChange={setManterConectado} label="Manter conectado" />
              {/* mock — recuperação de senha fora do escopo do protótipo */}
              <Button variant="link">Esqueceu a senha?</Button>
            </div>

            <Button fullWidth size="lg" className="mt-1 rounded-full" onClick={() => navigate('/inicio')}>
              Entrar
            </Button>
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
