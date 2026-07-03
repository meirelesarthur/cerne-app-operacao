import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { CreditoHome } from './screens/CreditoHome'
import { PropostasScreen } from './screens/PropostasScreen'

/**
 * Módulo Crédito — oferta pré-aprovada, simulador rápido, linhas disponíveis
 * e acompanhamento de propostas. O simulador vive na Home; a aba "Simular"
 * do bottom tab redireciona para lá.
 */
export function CreditoModule() {
  return (
    <Routes>
      <Route index element={<CreditoHome />} />
      <Route path="propostas" element={<PropostasScreen />} />
      <Route path="simular" element={<Navigate to="/credito" replace />} />
      <Route
        path="mais"
        element={
          <EmptyState
            icon={Construction}
            title="Crédito · Mais"
            description="Conteúdo em desenvolvimento. Este módulo será detalhado em uma próxima fase de discovery."
            className="h-full justify-center"
          />
        }
      />
      <Route path="*" element={<Navigate to="/credito" replace />} />
    </Routes>
  )
}
