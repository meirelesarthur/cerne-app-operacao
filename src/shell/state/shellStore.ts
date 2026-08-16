import { create } from 'zustand'

/**
 * Store do Shell (spec §7.3) — estado de nível superapp.
 * Tudo em memória; SEM localStorage/sessionStorage (restrição do protótipo).
 */

export interface UserProfile {
  name: string
  initials: string
  role: AccessRole
}

export type AccessRole = 'operador' | 'admin'

export interface AppNotification {
  id: string
  moduleId: string
  title: string
  detail: string
  time: string
  read: boolean
}

interface ShellState {
  user: UserProfile
  /** Sessão demonstrativa; não representa autenticação ou RBAC de produção. */
  isAuthenticated: boolean
  notifications: AppNotification[]
  /** toggle de dev (spec §7.3) — simula perda de conexão para demonstrar banners de sync. */
  isOnline: boolean
  /** privacidade do Banking no hub — oculta saldo/valores em todas as telas do Início. */
  balanceHidden: boolean
  /** menu "reveal" global (aba Mais/Menu) — spec do superapp. */
  menuOpen: boolean
  loginAs: (role: AccessRole) => void
  logout: () => void
  setOnline: (v: boolean) => void
  toggleOnline: () => void
  toggleBalanceHidden: () => void
  markAllRead: () => void
  unreadCount: () => number
  openMenu: () => void
  closeMenu: () => void
  toggleMenu: () => void
}

const MOCK_NOTIFICATIONS: AppNotification[] = [
  { id: 'n1', moduleId: 'fazendas', title: 'Pesagem registrada', detail: 'Lote 42 · Fazenda São Pedro', time: 'há 5 min', read: false },
  { id: 'n2', moduleId: 'credito', title: 'Crédito pré-aprovado', detail: 'R$ 480.000,00 disponíveis', time: 'há 1 h', read: false },
  { id: 'n3', moduleId: 'fazendas', title: 'NF-e processada', detail: 'Entrada de insumos conferida', time: 'há 3 h', read: false },
  { id: 'n4', moduleId: 'bank', title: 'Pagamento agendado', detail: 'Fornecedor Agropecuária Vale', time: 'ontem', read: true },
]

export const useShellStore = create<ShellState>((set, get) => ({
  user: { name: 'Silvio Ventura', initials: 'SV', role: 'admin' },
  isAuthenticated: false,
  notifications: MOCK_NOTIFICATIONS,
  isOnline: true,
  balanceHidden: false,
  menuOpen: false,
  loginAs: (role) =>
    set({
      user:
        role === 'admin'
          ? { name: 'Silvio Ventura', initials: 'SV', role }
          : { name: 'João Oliveira', initials: 'JO', role },
      isAuthenticated: true,
      menuOpen: false,
    }),
  logout: () => set({ isAuthenticated: false, menuOpen: false }),
  setOnline: (v) => set({ isOnline: v }),
  toggleOnline: () => set((s) => ({ isOnline: !s.isOnline })),
  toggleBalanceHidden: () => set((s) => ({ balanceHidden: !s.balanceHidden })),
  markAllRead: () => set((s) => ({ notifications: s.notifications.map((n) => ({ ...n, read: true })) })),
  unreadCount: () => get().notifications.filter((n) => !n.read).length,
  openMenu: () => set({ menuOpen: true }),
  closeMenu: () => set({ menuOpen: false }),
  toggleMenu: () => set((s) => ({ menuOpen: !s.menuOpen })),
}))
