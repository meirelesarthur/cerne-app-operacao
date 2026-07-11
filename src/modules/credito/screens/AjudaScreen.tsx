import { MessageCircle } from 'lucide-react'
import { Heading, Card, Banner } from '@/components/ui'

interface FaqItem {
  pergunta: string
  resposta: string
}

const FAQ: FaqItem[] = [
  {
    pergunta: 'Quanto tempo leva a análise de uma proposta?',
    resposta: 'Em média, de 2 a 5 dias úteis após o envio de todos os documentos solicitados.',
  },
  {
    pergunta: 'Posso simular mais de uma linha de crédito?',
    resposta:
      'Sim. Use o simulador na Home do módulo Crédito para comparar valores e prazos entre as linhas disponíveis.',
  },
  {
    pergunta: 'O que acontece se um documento estiver pendente?',
    resposta:
      'A proposta permanece em análise até o envio. Verifique a lista de documentos na tela de detalhe da proposta.',
  },
  {
    pergunta: 'Como acompanho as parcelas de um contrato ativo?',
    resposta:
      'Acesse Crédito → Contratos para ver o progresso de pagamento, a próxima parcela e o saldo devedor.',
  },
]

/** Tela "Ajuda" do módulo Crédito: perguntas frequentes + contato com o gerente. */
export function AjudaScreen() {
  return (
    <div className="flex flex-col gap-6 p-4">
      <Heading level={2}>Ajuda</Heading>

      <div className="flex flex-col gap-3">
        {FAQ.map((item) => (
          <Card key={item.pergunta}>
            <p className="text-sm font-semibold text-fg">{item.pergunta}</p>
            <p className="mt-1.5 text-sm text-fg-muted">{item.resposta}</p>
          </Card>
        ))}
      </div>

      <Banner tone="info" icon={<MessageCircle size={14} aria-hidden="true" />} className="rounded-xl border">
        Não encontrou o que precisava? Fale com seu gerente de relacionamento.
      </Banner>
    </div>
  )
}
