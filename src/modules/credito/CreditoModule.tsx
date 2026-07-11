import { Routes, Route, Navigate } from 'react-router-dom'
import { CreditoHome } from './screens/CreditoHome'
import { PropostasScreen } from './screens/PropostasScreen'
import { PropostaDetalheScreen } from './screens/PropostaDetalheScreen'
import { ContratosScreen } from './screens/ContratosScreen'
import { AjudaScreen } from './screens/AjudaScreen'
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
      <Route path="proposta/:id" element={<PropostaDetalheScreen />} />
      <Route path="simular" element={<CreditoHome scrollToSimulador />} />
      <Route path="contratos" element={<ContratosScreen />} />
      <Route path="ajuda" element={<AjudaScreen />} />
      <Route path="mais" element={<CreditoMaisScreen />} />
      <Route path="*" element={<Navigate to="/credito" replace />} />
    </Routes>
  )
}
