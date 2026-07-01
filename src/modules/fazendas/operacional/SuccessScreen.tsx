import { useNavigate } from 'react-router-dom'
import { CheckCircle2, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Heading } from '@/components/ui/Heading'

export interface SuccessScreenProps {
  title: string
  /** texto informativo sobre os efeitos no web (spec §5) — não executa nada real. */
  effects: string
  /** verdadeiro quando o lançamento foi para a fila offline. */
  queued?: boolean
}

/** Tela de sucesso pós-lançamento, com resumo dos efeitos no sistema web. */
export function SuccessScreen({ title, effects, queued }: SuccessScreenProps) {
  const navigate = useNavigate()

  return (
    <div className="flex h-full flex-col items-center justify-center gap-4 bg-canvas p-6 text-center">
      <div className="flex h-16 w-16 items-center justify-center rounded-full bg-brand-50 text-accent">
        {queued ? <RefreshCw size={32} /> : <CheckCircle2 size={32} />}
      </div>
      <Heading level={2}>{queued ? 'Enviado para sincronização' : title}</Heading>
      <p className="max-w-[300px] text-md text-fg-muted">
        {queued ? 'O lançamento será processado assim que a conexão voltar. ' : ''}
        {effects}
      </p>
      <div className="mt-2 flex w-full max-w-[300px] flex-col gap-2">
        <Button fullWidth onClick={() => navigate('/fazendas')}>
          Voltar ao início
        </Button>
      </div>
    </div>
  )
}
