import type { LucideIcon } from 'lucide-react'
import { Sprout, FlaskConical, ShieldCheck, Beef, Tractor, Wrench } from 'lucide-react'

/** Categoria de insumo/produto do Marketplace, com ícone para chips e cards. */
export interface Categoria {
  id: string
  label: string
  icon: LucideIcon
}

/** Item de catálogo do Marketplace (dados determinísticos, protótipo). */
export interface Produto {
  id: string
  nome: string
  vendedor: string
  /** valor já formatado em BRL, ex.: 'R$ 189,90' */
  preco: string
  /** unidade de venda, ex.: 'saca 60kg' */
  unidade: string
  categoriaId: string
  freteGratis?: boolean
  /** percentual promocional formatado, ex.: '-12%' */
  desconto?: string
}

export const CATEGORIAS: Categoria[] = [
  { id: 'sementes', label: 'Sementes', icon: Sprout },
  { id: 'fertilizantes', label: 'Fertilizantes', icon: FlaskConical },
  { id: 'defensivos', label: 'Defensivos', icon: ShieldCheck },
  { id: 'nutricao-animal', label: 'Nutrição animal', icon: Beef },
  { id: 'maquinas', label: 'Máquinas', icon: Tractor },
  { id: 'pecas', label: 'Peças', icon: Wrench },
]

export const PRODUTOS: Produto[] = [
  {
    id: 'prod-1',
    nome: 'Semente de soja Intacta',
    vendedor: 'AgroSeed Distribuidora',
    preco: 'R$ 489,90',
    unidade: 'saca 40kg',
    categoriaId: 'sementes',
    freteGratis: true,
  },
  {
    id: 'prod-2',
    nome: 'Ureia 45% granulada',
    vendedor: 'Fertil Nordeste',
    preco: 'R$ 149,90',
    unidade: 'saca 60kg',
    categoriaId: 'fertilizantes',
    desconto: '-18%',
  },
  {
    id: 'prod-3',
    nome: 'Herbicida sistêmico pós-emergente',
    vendedor: 'DefendAgro',
    preco: 'R$ 312,00',
    unidade: 'L',
    categoriaId: 'defensivos',
    desconto: '-12%',
  },
  {
    id: 'prod-4',
    nome: 'Ração confinamento 30kg',
    vendedor: 'NutriBoi Alimentos',
    preco: 'R$ 98,50',
    unidade: 'saca 30kg',
    categoriaId: 'nutricao-animal',
    freteGratis: true,
  },
  {
    id: 'prod-5',
    nome: 'Óleo diesel S10 (1000L)',
    vendedor: 'Petro Rural Combustíveis',
    preco: 'R$ 6.190,00',
    unidade: 'un',
    categoriaId: 'maquinas',
  },
  {
    id: 'prod-6',
    nome: 'Arame liso 500m',
    vendedor: 'Cercas & Arames Sul',
    preco: 'R$ 279,90',
    unidade: 'un',
    categoriaId: 'pecas',
    freteGratis: true,
  },
]

/** Banner promocional em destaque na home do Marketplace. */
export const OFERTA_DESTAQUE = {
  titulo: 'Semana do Plantio',
  subtitulo: 'Fertilizantes com até 18% off + frete grátis',
  cta: 'Ver ofertas',
}
