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
 * Login do Shell (mock, sem autenticação real) — tema claro premium:
 * banner superior no gradiente institucional com ondas decorativas
 * (troque por arte gerada quando pronta, mantendo o slot do logo) e
 * cartão de boas-vindas com o formulário. Qualquer entrada leva ao superapp.
 */
export function Login() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [manterConectado, setManterConectado] = useState(true)

  return (
    <div className="no-scrollbar flex h-full flex-col overflow-y-auto bg-canvas">
      {/* banner da marca — arte do hero (campo + tecnologia) com véu verde para legibilidade */}
      <div className="relative shrink-0 overflow-hidden px-6 pb-24 pt-14">
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
            background: `linear-gradient(180deg, ${t.component.login.heroScrim.from} 0%, ${t.component.login.heroScrim.mid} 55%, ${t.component.login.heroScrim.to} 100%)`,
          }}
        />

        <div className="relative flex flex-col items-center gap-3 text-center">
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
      </div>

      {/* cartão do formulário sobreposto ao banner (estilo referência) */}
      <div className="relative -mt-10 flex flex-1 flex-col px-5 pb-8">
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

        <p className="mt-auto pt-6 text-center text-xs text-fg-subtle">
          GB CERNE · Superapp corporativo do agronegócio
        </p>
      </div>
    </div>
  )
}
