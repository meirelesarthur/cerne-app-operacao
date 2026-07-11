import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { BankHome } from './screens/BankHome'
import { ExtratoScreen } from './screens/ExtratoScreen'
import { BankMaisScreen } from './screens/BankMaisScreen'

/**
 * Módulo GB Bank (New-UI): home investor-ready com saldo, ações rápidas,
 * cartão corporativo e deep-link para Crédito. Rotas relativas a /bank.
 */
export function BankModule() {
  return (
    <Routes>
      <Route index element={<BankHome />} />
      <Route path="extrato" element={<ExtratoScreen />} />
      <Route
        path="pagamentos"
        element={
          <EmptyState
            icon={Construction}
            title="Bank · Pagamentos"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="cartoes"
        element={
          <EmptyState
            icon={Construction}
            title="Bank · Cartões"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="pix"
        element={
          <EmptyState
            icon={Construction}
            title="Bank · Pix"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="limites"
        element={
          <EmptyState
            icon={Construction}
            title="Bank · Limites"
            description="Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase."
            className="h-full justify-center"
          />
        }
      />
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
      <Route path="mais" element={<BankMaisScreen />} />
      <Route path="*" element={<Navigate to="/bank" replace />} />
    </Routes>
  )
}
