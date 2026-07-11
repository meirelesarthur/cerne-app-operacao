import { useMemo, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Search, SearchX, Truck } from 'lucide-react'
import { Card, Chip, Tag, Button, TextInput, EmptyState, Skeleton } from '@/components/ui'
import { useSimulatedLoad } from '@/lib/useSimulatedLoad'
import { t } from '@/design/tokens'
import { CATEGORIAS, PRODUTOS, OFERTA_DESTAQUE } from '../mocks/produtos'

/** delay escalonado de entrada por seção (motion tokenizado, ver Lei 3) */
const stagger = (i: number) => ({ animationDelay: `calc(${i} * ${t.animation.stagger})` })

/**
 * Home do Marketplace (New-UI): busca de insumos, categorias em pílula,
 * banner de oferta em destaque e grid de produtos do catálogo.
 */
export function MarketplaceHome() {
  const navigate = useNavigate()
  const location = useLocation()
  const loading = useSimulatedLoad(700) === 'loading'
  const [busca, setBusca] = useState('')
  const [categoriaAtiva, setCategoriaAtiva] = useState<string | null>(
    () => (location.state as { categoriaId?: string } | null)?.categoriaId ?? null,
  )

  const produtosFiltrados = useMemo(() => {
    const termo = busca.trim().toLowerCase()
    return PRODUTOS.filter((produto) => {
      const combinaCategoria = !categoriaAtiva || produto.categoriaId === categoriaAtiva
      const combinaBusca = !termo || produto.nome.toLowerCase().includes(termo)
      return combinaCategoria && combinaBusca
    })
  }, [busca, categoriaAtiva])

  return (
    <div className="flex flex-col gap-6 p-4">
      {/* Busca */}
      <div className="animate-rise" style={stagger(0)}>
        <label className="relative block">
          <span className="sr-only">Buscar insumos, máquinas, peças</span>
          <Search
            size={18}
            className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-fg-subtle"
            aria-hidden="true"
          />
          <TextInput
            value={busca}
            onChange={(e) => setBusca(e.target.value)}
            placeholder="Buscar insumos, máquinas, peças…"
            className="pl-10"
          />
        </label>
      </div>

      {/* Categorias */}
      <div className="no-scrollbar -mx-4 flex animate-rise gap-2 overflow-x-auto px-4" style={stagger(1)}>
        {CATEGORIAS.map((categoria) => {
          const ativa = categoriaAtiva === categoria.id
          return (
            <Button
              key={categoria.id}
              size="sm"
              variant={ativa ? 'primary' : 'secondary'}
              leftIcon={<categoria.icon size={14} aria-hidden="true" />}
              className="shrink-0"
              onClick={() => setCategoriaAtiva(ativa ? null : categoria.id)}
            >
              {categoria.label}
            </Button>
          )
        })}
      </div>

      {/* Banner de oferta em destaque */}
      <div className="animate-rise" style={stagger(2)}>
        <div
          className="relative overflow-hidden rounded-3xl p-5 text-white"
          style={{
            background: `linear-gradient(135deg, ${t.component.hub.bankCard.from}, ${t.component.hub.bankCard.to})`,
          }}
        >
          <Chip tone="brand" className="bg-white/15 text-white border-white/20">
            Oferta
          </Chip>
          <p className="mt-3 text-lg font-bold">{OFERTA_DESTAQUE.titulo}</p>
          <p className="mt-1 max-w-[240px] text-sm text-white/80">{OFERTA_DESTAQUE.subtitulo}</p>
          <Button
            variant="secondary"
            size="sm"
            className="mt-4"
            onClick={() => navigate('/marketplace/categorias')}
          >
            {OFERTA_DESTAQUE.cta}
          </Button>
        </div>
      </div>

      {/* Grid de produtos */}
      <div className="animate-rise" style={stagger(3)}>
        {loading ? (
          <div className="grid grid-cols-2 gap-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="rounded-2xl border border-border-default bg-surface p-4">
                <Skeleton className="h-20 w-full" rounded="xl" />
                <Skeleton className="mt-3 h-4 w-full" />
                <Skeleton className="mt-2 h-3 w-2/3" />
                <Skeleton className="mt-3 h-5 w-1/2" />
              </div>
            ))}
          </div>
        ) : produtosFiltrados.length === 0 ? (
          <EmptyState
            icon={SearchX}
            title="Nada encontrado"
            description="Tente outro termo de busca ou limpe os filtros de categoria selecionados."
            action={
              <Button
                variant="secondary"
                size="sm"
                onClick={() => {
                  setBusca('')
                  setCategoriaAtiva(null)
                }}
              >
                Limpar filtros
              </Button>
            }
          />
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {produtosFiltrados.map((produto) => {
              const categoria = CATEGORIAS.find((c) => c.id === produto.categoriaId)
              const Icon = categoria?.icon
              return (
                <Card
                  key={produto.id}
                  interactive
                  onClick={() => navigate(`/marketplace/produto/${produto.id}`)}
                >
                  <div className="flex h-20 items-center justify-center rounded-xl bg-accent-subtle text-accent">
                    {Icon && <Icon size={28} aria-hidden="true" />}
                  </div>
                  <p className="mt-3 line-clamp-2 text-sm font-semibold text-fg">{produto.nome}</p>
                  <p className="mt-0.5 truncate text-xs text-fg-muted">{produto.vendedor}</p>
                  <p className="mt-2 text-lg font-bold tabular-nums text-fg">
                    {produto.preco} <span className="text-xs font-normal text-fg-muted">/{produto.unidade}</span>
                  </p>
                  {(produto.freteGratis || produto.desconto) && (
                    <div className="mt-2 flex flex-wrap gap-1.5">
                      {produto.freteGratis && (
                        <Tag className="inline-flex items-center gap-1">
                          <Truck size={11} aria-hidden="true" />
                          Frete grátis
                        </Tag>
                      )}
                      {produto.desconto && <Chip tone="brand">{produto.desconto}</Chip>}
                    </div>
                  )}
                </Card>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
