import type { LucideIcon } from 'lucide-react'
import {
  Sprout,
  Landmark,
  HandCoins,
  ShoppingBag,
  Warehouse,
  LayoutDashboard,
  Activity,
  Wallet,
  MoreHorizontal,
  Home,
  Receipt,
  CreditCard,
  FileText,
  Calculator,
  Boxes,
  ArrowLeftRight,
  ListOrdered,
  LayoutGrid,
  Menu,
  Beef,
  Package,
  Users,
  Search,
  RefreshCw,
  Zap,
  History,
  SlidersHorizontal,
  HelpCircle,
  ClipboardList,
  FileSignature,
  Heart,
  BarChart3,
} from 'lucide-react'

/**
 * Registro central de módulos do superapp (spec §3.4/§7.3).
 * O Shell itera este registro para montar a Barra de Módulos e injeta os `bottomTabs`
 * do módulo ativo no BottomTabBar genérico. Nenhuma navegação de módulo é hardcodada fora daqui.
 */

export interface BottomTab {
  id: string
  label: string
  icon: LucideIcon
  /** rota relativa dentro do módulo (ex.: '' = home, 'atividades'). */
  path: string
  /** botão central elevado (ex.: "Registrar" em campo) */
  elevated?: boolean
  /** ação especial em vez de navegação (ex.: 'menu' abre o RevealMenu global) */
  action?: 'menu'
}

export interface ModuleMenuItem {
  id: string
  label: string
  icon: LucideIcon
  /** rota absoluta do destino */
  route: string
}

export interface ModuleMenuSection {
  title: string
  items: ModuleMenuItem[]
}

export interface ModuleDef {
  id: string
  label: string
  icon: LucideIcon
  /** rota inicial absoluta do módulo */
  homeRoute: string
  bottomTabs: BottomTab[]
  /**
   * funcionalidades exibidas no RevealMenu (aba Mais) — contextuais ao módulo.
   * Quando ausente, o menu deriva uma seção única das bottomTabs navegáveis.
   */
  menuSections?: ModuleMenuSection[]
}

/** Fallback do RevealMenu: seção única derivada das abas navegáveis do módulo. */
export function getMenuSections(module: ModuleDef): ModuleMenuSection[] {
  if (module.menuSections) return module.menuSections
  return [
    {
      title: 'Funcionalidades',
      items: module.bottomTabs
        .filter((tab) => tab.path !== '' && !tab.action)
        .map((tab) => ({ id: tab.id, label: tab.label, icon: tab.icon, route: `/${module.id}/${tab.path}` })),
    },
  ]
}

export const MODULES: ModuleDef[] = [
  {
    // New-UI — hub agregador: porta de entrada do superapp, Banking central
    id: 'inicio',
    label: 'Início',
    icon: Home,
    homeRoute: '/inicio',
    bottomTabs: [
      { id: 'home', label: 'Início', icon: Home, path: '' },
      { id: 'apps', label: 'Apps', icon: LayoutGrid, path: 'apps' },
      { id: 'carteira', label: 'Carteira', icon: Wallet, path: 'carteira' },
      { id: 'menu', label: 'Menu', icon: Menu, path: 'menu', action: 'menu' },
    ],
  },
  {
    id: 'fazendas',
    label: 'Fazendas',
    icon: Sprout,
    homeRoute: '/fazendas',
    bottomTabs: [
      { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard, path: '' },
      { id: 'fazendas', label: 'Fazendas', icon: Sprout, path: 'fazendas' },
      { id: 'atividades', label: 'Atividades', icon: Activity, path: 'atividades' },
      { id: 'financeiro', label: 'Financeiro', icon: Wallet, path: 'financeiro' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
    menuSections: [
      {
        title: 'Dashboards gerenciais',
        items: [
          { id: 'financeiro', label: 'Financeiro', icon: Wallet, route: '/fazendas/dashboards/financeiro' },
          { id: 'pecuaria', label: 'Pecuária de Corte', icon: Beef, route: '/fazendas/dashboards/pecuaria' },
          { id: 'confinamento', label: 'Lotação de Currais', icon: Warehouse, route: '/fazendas/dashboards/confinamento' },
          { id: 'ativos', label: 'Ativos / Depreciação', icon: Package, route: '/fazendas/dashboards/ativos' },
          { id: 'suprimentos', label: 'Suprimentos', icon: Boxes, route: '/fazendas/dashboards/suprimentos' },
          { id: 'uso', label: 'Análise de Uso', icon: Users, route: '/fazendas/dashboards/uso' },
          { id: 'consultas', label: 'Consultas Gerenciais', icon: Search, route: '/fazendas/dashboards/consultas' },
        ],
      },
      {
        title: 'Operacional',
        items: [
          { id: 'sync', label: 'Fila de sincronização', icon: RefreshCw, route: '/fazendas/mais/sync' },
          { id: 'atividades', label: 'Todas as atividades', icon: Activity, route: '/fazendas/atividades' },
        ],
      },
    ],
  },
  {
    id: 'bank',
    label: 'Bank',
    icon: Landmark,
    homeRoute: '/bank',
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'extrato', label: 'Extrato', icon: Receipt, path: 'extrato' },
      { id: 'pagamentos', label: 'Pagamentos', icon: ArrowLeftRight, path: 'pagamentos' },
      { id: 'cartoes', label: 'Cartões', icon: CreditCard, path: 'cartoes' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
    menuSections: [
      {
        title: 'Pagamentos e transferências',
        items: [
          { id: 'pix', label: 'Pix', icon: Zap, route: '/bank/pix' },
          { id: 'pagamentos', label: 'Pagamentos', icon: Receipt, route: '/bank/pagamentos' },
          { id: 'extrato', label: 'Extrato', icon: History, route: '/bank/extrato' },
        ],
      },
      {
        title: 'Cartão',
        items: [
          { id: 'cartoes', label: 'Cartões', icon: CreditCard, route: '/bank/cartoes' },
          { id: 'limites', label: 'Limites', icon: SlidersHorizontal, route: '/bank/limites' },
        ],
      },
      {
        title: 'Suporte',
        items: [{ id: 'ajuda', label: 'Ajuda', icon: HelpCircle, route: '/bank/ajuda' }],
      },
    ],
  },
  {
    id: 'credito',
    label: 'Crédito',
    icon: HandCoins,
    homeRoute: '/credito',
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'propostas', label: 'Minhas Propostas', icon: FileText, path: 'propostas' },
      { id: 'simular', label: 'Simular', icon: Calculator, path: 'simular' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
    menuSections: [
      {
        title: 'Crédito',
        items: [
          { id: 'simular', label: 'Simular', icon: Calculator, route: '/credito/simular' },
          { id: 'propostas', label: 'Propostas', icon: ClipboardList, route: '/credito/propostas' },
          { id: 'contratos', label: 'Contratos', icon: FileSignature, route: '/credito/contratos' },
        ],
      },
      {
        title: 'Suporte',
        items: [{ id: 'ajuda', label: 'Ajuda', icon: HelpCircle, route: '/credito/ajuda' }],
      },
    ],
  },
  {
    id: 'marketplace',
    label: 'Marketplace',
    icon: ShoppingBag,
    homeRoute: '/marketplace',
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'categorias', label: 'Categorias', icon: ListOrdered, path: 'categorias' },
      { id: 'pedidos', label: 'Pedidos', icon: Receipt, path: 'pedidos' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
    menuSections: [
      {
        title: 'Compras',
        items: [
          { id: 'categorias', label: 'Categorias', icon: LayoutGrid, route: '/marketplace/categorias' },
          { id: 'pedidos', label: 'Pedidos', icon: Package, route: '/marketplace/pedidos' },
          { id: 'favoritos', label: 'Favoritos', icon: Heart, route: '/marketplace/favoritos' },
        ],
      },
      {
        title: 'Suporte',
        items: [{ id: 'ajuda', label: 'Ajuda', icon: HelpCircle, route: '/marketplace/ajuda' }],
      },
    ],
  },
  {
    id: 'armazem',
    label: 'Armazém',
    icon: Warehouse,
    homeRoute: '/armazem',
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'estoque', label: 'Estoque', icon: Boxes, path: 'estoque' },
      { id: 'movimentacoes', label: 'Movimentações', icon: ArrowLeftRight, path: 'movimentacoes' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
    menuSections: [
      {
        title: 'Operação',
        items: [
          { id: 'estoque', label: 'Estoque', icon: Boxes, route: '/armazem/estoque' },
          { id: 'movimentacoes', label: 'Movimentações', icon: ArrowLeftRight, route: '/armazem/movimentacoes' },
          { id: 'unidades', label: 'Unidades', icon: Warehouse, route: '/armazem/unidades' },
        ],
      },
      {
        title: 'Gestão',
        items: [{ id: 'relatorios', label: 'Relatórios', icon: BarChart3, route: '/armazem/relatorios' }],
      },
    ],
  },
]

export const MODULE_MAP: Record<string, ModuleDef> = Object.fromEntries(MODULES.map((m) => [m.id, m]))

export function getModule(id: string | undefined): ModuleDef | undefined {
  return id ? MODULE_MAP[id] : undefined
}
