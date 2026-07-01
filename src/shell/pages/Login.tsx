import { useNavigate } from 'react-router-dom'
import { Sprout } from 'lucide-react'
import { Button } from '@/components/ui/Button'

/**
 * Login do Shell (mock) — usa os tokens component.login (split-screen adaptado a mobile).
 * Sem autenticação real; qualquer entrada leva ao superapp.
 */
export function Login() {
  const navigate = useNavigate()

  return (
    <div className="flex h-full flex-col justify-between bg-[#081a12] px-6 py-10 text-white">
      <div className="flex flex-1 flex-col items-center justify-center text-center">
        <div className="mb-5 flex h-16 w-16 items-center justify-center rounded-3xl bg-accent shadow-brand">
          <Sprout size={32} />
        </div>
        <h1 className="text-3xl font-extrabold">GB CERNE</h1>
        <p className="mt-2 max-w-[260px] text-md text-white/70">
          Superapp corporativo do agronegócio — suas fazendas, banco, crédito e mais em um só lugar.
        </p>
      </div>

      <div className="flex flex-col gap-3">
        <Button fullWidth size="lg" onClick={() => navigate('/fazendas')}>
          Entrar
        </Button>
        <Button fullWidth size="lg" variant="ghost" className="text-white hover:bg-white/10" onClick={() => navigate('/onboarding')}>
          Conhecer o app
        </Button>
      </div>
    </div>
  )
}
