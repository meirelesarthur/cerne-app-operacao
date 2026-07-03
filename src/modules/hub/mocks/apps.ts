import type { LucideIcon } from 'lucide-react'
import { Sprout, Landmark, HandCoins, ShoppingBag, Warehouse, CloudSun, LineChart, Headset, ShieldCheck } from 'lucide-react'

/**
 * Catálogo de mini-apps do hub (New-UI). O contrato { icon, name, description,
 * route, badge } permite injetar novos apps sem alterar as telas do hub.
 */

export interface HubApp {
  id: string
  icon: LucideIcon
  name: string
  description: string
  route?: string
  badge?: 'novo' | 'breve'
}

export const HUB_APPS: HubApp[] = [
  { id: 'fazendas', icon: Sprout, name: 'Fazendas', description: 'Gestão da operação e lançamentos de campo', route: '/fazendas' },
  { id: 'bank', icon: Landmark, name: 'GB Bank', description: 'Conta, Pix, pagamentos e cartões', route: '/bank', badge: 'novo' },
  { id: 'credito', icon: HandCoins, name: 'Crédito', description: 'Simule e contrate crédito para a safra', route: '/credito' },
  { id: 'marketplace', icon: ShoppingBag, name: 'Marketplace', description: 'Insumos, máquinas e serviços', route: '/marketplace' },
  { id: 'armazem', icon: Warehouse, name: 'Armazém', description: 'Estoque, movimentações e logística', route: '/armazem' },
]

export const APPS_EM_BREVE: HubApp[] = [
  { id: 'clima', icon: CloudSun, name: 'Clima', description: 'Previsão hiperlocal por talhão', badge: 'breve' },
  { id: 'cotacoes', icon: LineChart, name: 'Cotações', description: 'Boi gordo, soja e milho em tempo real', badge: 'breve' },
  { id: 'consultoria', icon: Headset, name: 'Consultoria', description: 'Especialistas GB a um toque', badge: 'breve' },
  { id: 'seguros', icon: ShieldCheck, name: 'Seguros', description: 'Proteção de safra e patrimônio', badge: 'breve' },
]
