import type { LucideIcon } from 'lucide-react'
import { Sprout, FlaskConical, ShieldCheck, Beef, Tractor, Wrench } from 'lucide-react'

/** Categoria de insumo/produto do Marketplace, com ícone para chips e cards. */
export interface Categoria {
  id: string
  label: string
  icon: LucideIcon
}

/** Par chave-valor de especificação técnica, exibido na página do produto (PDP). */
export interface Especificacao {
  label: string
  valor: string
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
  /** texto descritivo mockado, exibido na PDP */
  descricao: string
  /** lista chave-valor de especificações técnicas, exibida na PDP */
  especificacoes: Especificacao[]
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
    descricao:
      'Semente de soja com tecnologia Intacta, alta germinação e resistência a lagartas. Indicada para plantio em solos de média a alta fertilidade, com ciclo precoce.',
    especificacoes: [
      { label: 'Ciclo', valor: 'Precoce (105-115 dias)' },
      { label: 'Germinação', valor: 'mín. 90%' },
      { label: 'Tratamento de semente', valor: 'Sim, industrial' },
      { label: 'Validade', valor: '12 meses após tratamento' },
    ],
  },
  {
    id: 'prod-2',
    nome: 'Ureia 45% granulada',
    vendedor: 'Fertil Nordeste',
    preco: 'R$ 149,90',
    unidade: 'saca 60kg',
    categoriaId: 'fertilizantes',
    desconto: '-18%',
    descricao:
      'Fertilizante nitrogenado granulado de alta concentração, indicado para adubação de cobertura em grandes culturas e pastagens.',
    especificacoes: [
      { label: 'Teor de nitrogênio', valor: '45%' },
      { label: 'Granulometria', valor: '2-4 mm' },
      { label: 'Origem', valor: 'Nacional' },
      { label: 'Armazenamento', valor: 'Local seco e coberto' },
    ],
  },
  {
    id: 'prod-3',
    nome: 'Herbicida sistêmico pós-emergente',
    vendedor: 'DefendAgro',
    preco: 'R$ 312,00',
    unidade: 'L',
    categoriaId: 'defensivos',
    desconto: '-12%',
    descricao:
      'Herbicida sistêmico de ação pós-emergente, com absorção rápida via folhas indicado para controle de plantas daninhas de folha larga e estreita.',
    especificacoes: [
      { label: 'Classe toxicológica', valor: 'III - medianamente tóxico' },
      { label: 'Modo de ação', valor: 'Sistêmico foliar' },
      { label: 'Formulação', valor: 'Concentrado solúvel' },
      { label: 'Carência', valor: '30 dias' },
    ],
  },
  {
    id: 'prod-4',
    nome: 'Ração confinamento 30kg',
    vendedor: 'NutriBoi Alimentos',
    preco: 'R$ 98,50',
    unidade: 'saca 30kg',
    categoriaId: 'nutricao-animal',
    freteGratis: true,
    descricao:
      'Ração balanceada para bovinos em fase de confinamento, formulada para ganho de peso acelerado com alta conversão alimentar.',
    especificacoes: [
      { label: 'Proteína bruta', valor: 'mín. 18%' },
      { label: 'Fase indicada', valor: 'Terminação' },
      { label: 'Composição', valor: 'Milho, farelo de soja, minerais' },
      { label: 'Validade', valor: '6 meses' },
    ],
  },
  {
    id: 'prod-5',
    nome: 'Óleo diesel S10 (1000L)',
    vendedor: 'Petro Rural Combustíveis',
    preco: 'R$ 6.190,00',
    unidade: 'un',
    categoriaId: 'maquinas',
    descricao:
      'Diesel S10 com baixo teor de enxofre para máquinas e implementos agrícolas, entrega programada direto na propriedade em tanque próprio.',
    especificacoes: [
      { label: 'Volume', valor: '1000 L' },
      { label: 'Teor de enxofre', valor: 'máx. 10 mg/kg' },
      { label: 'Entrega', valor: 'Caminhão-tanque próprio' },
      { label: 'Prazo de entrega', valor: '2-4 dias úteis' },
    ],
  },
  {
    id: 'prod-6',
    nome: 'Arame liso 500m',
    vendedor: 'Cercas & Arames Sul',
    preco: 'R$ 279,90',
    unidade: 'un',
    categoriaId: 'pecas',
    freteGratis: true,
    descricao:
      'Arame liso galvanizado de alta resistência, indicado para cercas de divisa e contenção de pastagens.',
    especificacoes: [
      { label: 'Comprimento', valor: '500 m' },
      { label: 'Revestimento', valor: 'Galvanizado a fogo' },
      { label: 'Bitola', valor: '14 (2,11 mm)' },
      { label: 'Resistência à tração', valor: 'mín. 480 kgf/mm²' },
    ],
  },
]

/** IDs de produtos favoritados (mock determinístico, protótipo). */
export const FAVORITOS_IDS: string[] = ['prod-1', 'prod-4']

/** Banner promocional em destaque na home do Marketplace. */
export const OFERTA_DESTAQUE = {
  titulo: 'Semana do Plantio',
  subtitulo: 'Fertilizantes com até 18% off + frete grátis',
  cta: 'Ver ofertas',
}
