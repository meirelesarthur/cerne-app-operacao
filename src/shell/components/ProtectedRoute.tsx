import type { ReactNode } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { useShellStore } from '@/shell/state/shellStore'

/**
 * Protege as áreas internas durante a demonstração e preserva o destino para
 * inspeção. A autorização real continua sendo responsabilidade do backend.
 */
export function ProtectedRoute({ children }: { children: ReactNode }) {
  const isAuthenticated = useShellStore((state) => state.isAuthenticated)
  const location = useLocation()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />
  }

  return children
}
