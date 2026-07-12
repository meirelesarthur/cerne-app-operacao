import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { BankHome } from './screens/BankHome'
import { ExtratoScreen } from './screens/ExtratoScreen'
import { PagamentosScreen } from './screens/PagamentosScreen'
import { CartoesScreen } from './screens/CartoesScreen'
import { LimitesScreen } from './screens/LimitesScreen'

/**
 * Módulo GB Bank (New-UI): home investor-ready com saldo, ações rápidas,
 * cartão corporativo e deep-link para Crédito. Rotas relativas a /bank.
 */
export function BankModule() {
  return (
    <Routes>
      <Route index element={<BankHome />} />
      <Route path="extrato" element={<ExtratoScreen />} />
      <Route path="pagamentos" element={<PagamentosScreen />} />
      <Route path="cartoes" element={<CartoesScreen />} />
      <Route path="pix" element={<PagamentosScreen initialFlow="pix" />} />
      <Route path="limites" element={<LimitesScreen />} />
      <Route
        path="ajuda"
        element={
          <EmptyState
            icon={Construction}
            title="Bank · Ajuda"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route path="*" element={<Navigate to="/bank" replace />} />
    </Routes>
  )
}
