import { useNavigate } from 'react-router-dom'
import { Heart } from 'lucide-react'
import { Card, EmptyState } from '@/components/ui'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { CATEGORIAS, PRODUTOS, FAVORITOS_IDS } from '../mocks/produtos'

/** Favoritos do Marketplace — lista mockada de produtos marcados como favoritos. */
export function MarketplaceFavoritos() {
  const navigate = useNavigate()
  const favoritos = FAVORITOS_IDS.map((id) => PRODUTOS.find((p) => p.id === id)).filter((p) => !!p)

  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title="Favoritos" />
      <div className="no-scrollbar flex-1 overflow-y-auto p-4">
        {favoritos.length === 0 ? (
          <EmptyState
            icon={Heart}
            title="Nenhum favorito ainda"
            description="Toque no coração de um produto para guardá-lo aqui e encontrar mais rápido na próxima vez."
            className="h-full justify-center"
          />
        ) : (
          <div className="flex flex-col gap-3">
            {favoritos.map((produto) => {
              const categoria = CATEGORIAS.find((c) => c.id === produto.categoriaId)
              const Icon = categoria?.icon
              return (
                <Card
                  key={produto.id}
                  interactive
                  onClick={() => navigate(`/marketplace/produto/${produto.id}`)}
                  className="flex flex-row items-center gap-3"
                >
                  <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-accent-subtle text-accent">
                    {Icon && <Icon size={24} aria-hidden="true" />}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-fg">{produto.nome}</p>
                    <p className="truncate text-xs text-fg-muted">{produto.vendedor}</p>
                    <p className="mt-1 text-md font-bold tabular-nums text-fg">{produto.preco}</p>
                  </div>
                  <Heart size={18} className="shrink-0 fill-accent text-accent" aria-hidden="true" />
                </Card>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
