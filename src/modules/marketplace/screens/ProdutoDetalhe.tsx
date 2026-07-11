import { useState } from 'react'
import { useParams } from 'react-router-dom'
import { Check, PackageSearch, ShoppingCart, Truck } from 'lucide-react'
import { Avatar, Banner, Button, Chip, EmptyState, Heading, SectionTitle, Tag } from '@/components/ui'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { CATEGORIAS, PRODUTOS } from '../mocks/produtos'

/**
 * Página do Produto (PDP) do Marketplace — acessada a partir do card na Home.
 * Substitui o resumo paliativo em BottomSheet da fase anterior (A5).
 */
export function ProdutoDetalhe() {
  const { id } = useParams()
  const produto = PRODUTOS.find((p) => p.id === id)
  const [adicionado, setAdicionado] = useState(false)

  if (!produto) {
    return (
      <div className="flex h-full flex-col">
        <SubPageHeader title="Produto" />
        <EmptyState
          icon={PackageSearch}
          title="Produto não encontrado"
          description="Este produto pode ter sido removido do catálogo. Volte e tente outro item."
          className="flex-1 justify-center"
        />
      </div>
    )
  }

  const categoria = CATEGORIAS.find((c) => c.id === produto.categoriaId)
  const Icon = categoria?.icon

  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title={produto.nome} />

      <div className="no-scrollbar flex flex-1 flex-col gap-5 overflow-y-auto p-4">
        {/* Thumbnail tokenizada: ícone da categoria em superfície brand suave */}
        <div className="flex h-40 items-center justify-center rounded-2xl bg-accent-subtle text-accent">
          {Icon && <Icon size={48} aria-hidden="true" />}
        </div>

        <div className="flex flex-col gap-1">
          {categoria && <Tag className="w-fit">{categoria.label}</Tag>}
          <Heading level={2} className="mt-1">
            {produto.nome}
          </Heading>
          <p className="text-3xl font-bold tabular-nums text-fg">
            {produto.preco} <span className="text-sm font-normal text-fg-muted">/{produto.unidade}</span>
          </p>
          {(produto.freteGratis || produto.desconto) && (
            <div className="mt-1 flex flex-wrap gap-1.5">
              {produto.freteGratis && (
                <Tag className="inline-flex items-center gap-1">
                  <Truck size={11} aria-hidden="true" />
                  Frete grátis
                </Tag>
              )}
              {produto.desconto && <Chip tone="brand">{produto.desconto}</Chip>}
            </div>
          )}
        </div>

        {/* Vendedor */}
        <div className="flex items-center gap-3 rounded-2xl border border-border-default bg-surface p-3">
          <Avatar name={produto.vendedor} size="md" />
          <div className="min-w-0 flex-1">
            <p className="truncate font-semibold text-fg">{produto.vendedor}</p>
            <Chip tone="neutral">Vendedor do catálogo</Chip>
          </div>
        </div>

        {/* Descrição */}
        <div className="flex flex-col gap-2">
          <SectionTitle>Descrição</SectionTitle>
          <p className="text-sm text-fg-muted">{produto.descricao}</p>
        </div>

        {/* Especificações */}
        <div className="flex flex-col gap-3 rounded-2xl border border-border-default bg-surface-subtle p-4">
          <SectionTitle className="px-0">Especificações</SectionTitle>
          {produto.especificacoes.map((spec) => (
            <div key={spec.label} className="flex items-baseline justify-between gap-3">
              <span className="shrink-0 text-sm text-fg-muted">{spec.label}</span>
              <span className="min-w-0 truncate text-right text-sm font-semibold text-fg">{spec.valor}</span>
            </div>
          ))}
        </div>

        {adicionado && (
          <Banner tone="success" icon={<Check size={14} aria-hidden="true" />} className="rounded-xl border">
            Produto adicionado ao pedido (protótipo).
          </Banner>
        )}

        <div className="mt-auto flex flex-col gap-2 pt-2">
          <Button
            fullWidth
            size="lg"
            disabled={adicionado}
            leftIcon={adicionado ? <Check size={18} aria-hidden="true" /> : <ShoppingCart size={18} aria-hidden="true" />}
            onClick={() => setAdicionado(true)}
          >
            {adicionado ? 'Adicionado ao pedido' : 'Adicionar ao pedido'}
          </Button>
          <p className="text-center text-xs text-fg-subtle">
            Finalização de compra integrada em uma próxima fase.
          </p>
        </div>
      </div>
    </div>
  )
}
