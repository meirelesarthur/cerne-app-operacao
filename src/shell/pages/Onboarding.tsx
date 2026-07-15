import { useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Sprout, Landmark, ShoppingBag } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Heading } from '@/components/ui/Heading'
import { PageDots } from '@/components/ui/PageDots'
import { IllustrationSlot } from '@/components/ui/IllustrationSlot'
import onboard1 from '@/images/onboard1.png'
import onboard2 from '@/images/onboard2.png'
import onboard3 from '@/images/onboard3.png'

/** Slides do onboarding — ilustrações geradas em src/images (ícones ficam como fallback). */
const SLIDES = [
  {
    id: 'fazendas',
    icon: Sprout,
    image: onboard1,
    title: 'Sua fazenda na palma da mão',
    desc: 'Dashboards gerenciais e lançamentos de campo, mesmo sem sinal — tudo sincroniza quando a conexão volta.',
  },
  {
    id: 'bank',
    icon: Landmark,
    image: onboard2,
    title: 'Banco e crédito do produtor',
    desc: 'Conta digital, Pix, pagamentos e crédito pré-aprovado para a safra, direto no app.',
  },
  {
    id: 'marketplace',
    icon: ShoppingBag,
    image: onboard3,
    title: 'Compre, venda e armazene',
    desc: 'Marketplace de insumos e gestão do armazém integrados à operação, sem sair do superapp.',
  },
]

/**
 * Onboarding do Shell — carrossel de 3 telas (ilustração + título + descrição),
 * com dots, Pular e Próximo; o último slide convida a começar. Suporta swipe.
 */
export function Onboarding() {
  const navigate = useNavigate()
  const [slide, setSlide] = useState(0)
  const touchX = useRef<number | null>(null)

  const isLast = slide === SLIDES.length - 1
  const current = SLIDES[slide]

  const finish = () => navigate('/login')
  const next = () => (isLast ? finish() : setSlide((s) => s + 1))

  const onTouchStart = (e: React.TouchEvent) => {
    touchX.current = e.touches[0].clientX
  }
  const onTouchEnd = (e: React.TouchEvent) => {
    if (touchX.current === null) return
    const delta = e.changedTouches[0].clientX - touchX.current
    touchX.current = null
    if (delta < -48 && !isLast) setSlide((s) => s + 1)
    if (delta > 48 && slide > 0) setSlide((s) => s - 1)
  }

  return (
    <div className="flex h-full flex-col bg-canvas px-6 pb-8 pt-10">
      {/* slide ativo — key força a animação de entrada a cada troca */}
      <div
        key={current.id}
        className="flex flex-1 flex-col items-center justify-center gap-8 text-center"
        onTouchStart={onTouchStart}
        onTouchEnd={onTouchEnd}
      >
        <div className="animate-rise w-full">
          <IllustrationSlot alt={current.title} icon={current.icon} src={current.image} />
        </div>

        <div className="animate-rise flex flex-col items-center gap-3">
          <PageDots count={SLIDES.length} active={slide} onSelect={setSlide} />
          <Heading level={1} className="max-w-[280px] leading-tight">
            {current.title}
          </Heading>
          <p className="max-w-[300px] text-md leading-relaxed text-fg-muted">{current.desc}</p>
        </div>
      </div>

      {/* ações — botões em largura total, empilhados; no último slide sobra só o CTA */}
      <div className="flex flex-col gap-2">
        <Button fullWidth size="lg" className="rounded-full" onClick={next}>
          {isLast ? 'Começar' : 'Próximo'}
        </Button>
        {!isLast && (
          <Button fullWidth size="lg" variant="ghost" className="rounded-full text-fg-muted" onClick={finish}>
            Pular
          </Button>
        )}
      </div>
    </div>
  )
}
