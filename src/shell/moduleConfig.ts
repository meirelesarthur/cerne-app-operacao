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

export interface ModuleDef {
  id: string
  label: string
  icon: LucideIcon
  /** rota inicial absoluta do módulo */
  homeRoute: string
  bottomTabs: BottomTab[]
  /** módulo-casca (placeholder) x módulo completo */
  placeholder?: boolean
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
  },
  {
    id: 'bank',
    label: 'Bank',
    icon: Landmark,
    homeRoute: '/bank',
    placeholder: true,
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'extrato', label: 'Extrato', icon: Receipt, path: 'extrato' },
      { id: 'pagamentos', label: 'Pagamentos', icon: ArrowLeftRight, path: 'pagamentos' },
      { id: 'cartoes', label: 'Cartões', icon: CreditCard, path: 'cartoes' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
  },
  {
    id: 'credito',
    label: 'Crédito',
    icon: HandCoins,
    homeRoute: '/credito',
    placeholder: true,
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'propostas', label: 'Minhas Propostas', icon: FileText, path: 'propostas' },
      { id: 'simular', label: 'Simular', icon: Calculator, path: 'simular' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
  },
  {
    id: 'marketplace',
    label: 'Marketplace',
    icon: ShoppingBag,
    homeRoute: '/marketplace',
    placeholder: true,
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'categorias', label: 'Categorias', icon: ListOrdered, path: 'categorias' },
      { id: 'pedidos', label: 'Pedidos', icon: Receipt, path: 'pedidos' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
  },
  {
    id: 'armazem',
    label: 'Armazém',
    icon: Warehouse,
    homeRoute: '/armazem',
    placeholder: true,
    bottomTabs: [
      { id: 'inicio', label: 'Início', icon: Home, path: '' },
      { id: 'estoque', label: 'Estoque', icon: Boxes, path: 'estoque' },
      { id: 'movimentacoes', label: 'Movimentações', icon: ArrowLeftRight, path: 'movimentacoes' },
      { id: 'mais', label: 'Mais', icon: MoreHorizontal, path: 'mais', action: 'menu' },
    ],
  },
]

export const MODULE_MAP: Record<string, ModuleDef> = Object.fromEntries(MODULES.map((m) => [m.id, m]))

export function getModule(id: string | undefined): ModuleDef | undefined {
  return id ? MODULE_MAP[id] : undefined
}
