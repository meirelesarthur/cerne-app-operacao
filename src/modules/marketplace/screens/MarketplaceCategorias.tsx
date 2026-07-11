import { useNavigate } from 'react-router-dom'
import { Card, Tag } from '@/components/ui'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { CATEGORIAS, PRODUTOS } from '../mocks/produtos'

/**
 * Categorias do Marketplace — grade derivada das categorias com produtos no
 * catálogo mockado. Tocar numa categoria leva à Home já filtrada por ela.
 */
export function MarketplaceCategorias() {
  const navigate = useNavigate()

  const categoriasComContagem = CATEGORIAS.map((categoria) => ({
    categoria,
    total: PRODUTOS.filter((p) => p.categoriaId === categoria.id).length,
  })).filter((c) => c.total > 0)

  return (
    <div className="flex h-full flex-col">
      <SubPageHeader title="Categorias" />
      <div className="no-scrollbar flex-1 overflow-y-auto p-4">
        <div className="grid grid-cols-2 gap-3">
          {categoriasComContagem.map(({ categoria, total }) => (
            <Card
              key={categoria.id}
              interactive
              onClick={() => navigate('/marketplace', { state: { categoriaId: categoria.id } })}
            >
              <div className="flex h-16 w-16 items-center justify-center rounded-xl bg-accent-subtle text-accent">
                <categoria.icon size={26} aria-hidden="true" />
              </div>
              <p className="mt-3 text-sm font-semibold text-fg">{categoria.label}</p>
              <Tag className="mt-1.5 w-fit">
                {total} {total === 1 ? 'produto' : 'produtos'}
              </Tag>
            </Card>
          ))}
        </div>
      </div>
    </div>
  )
}
