import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { CreditoHome } from './screens/CreditoHome'
import { PropostasScreen } from './screens/PropostasScreen'
import { CreditoMaisScreen } from './screens/CreditoMaisScreen'

/**
 * Módulo Crédito — oferta pré-aprovada, simulador rápido, linhas disponíveis
 * e acompanhamento de propostas. O simulador vive na Home; a aba "Simular"
 * do bottom tab renderiza a mesma Home rolada automaticamente até a seção.
 */
export function CreditoModule() {
  return (
    <Routes>
      <Route index element={<CreditoHome />} />
      <Route path="propostas" element={<PropostasScreen />} />
      <Route path="simular" element={<CreditoHome scrollToSimulador />} />
      <Route
        path="contratos"
        element={
          <EmptyState
            icon={Construction}
            title="Crédito · Contratos"
            description="Conteúdo em desenvolvimento. Este módulo será detalhado em uma próxima fase de discovery."
            className="h-full justify-center"
          />
        }
      />
      <Route
        path="ajuda"
        element={
          <EmptyState
            icon={Construction}
            title="Crédito · Ajuda"
            description="Conteúdo em desenvolvimento. Este módulo será detalhado em uma próxima fase de discovery."
            className="h-full justify-center"
          />
        }
      />
      <Route path="mais" element={<CreditoMaisScreen />} />
      <Route path="*" element={<Navigate to="/credito" replace />} />
    </Routes>
  )
}
