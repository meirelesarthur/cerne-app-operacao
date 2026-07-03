import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import { EmptyState } from '@/components/ui'
import { ArmazemHome } from './screens/ArmazemHome'

/**
 * Módulo Armazém: home operacional completa + demais abas em desenvolvimento
 * (spec §3.4). Rotas relativas a /armazem, injetadas pelo ShellLayout.
 */
export function ArmazemModule() {
  return (
    <Routes>
      <Route index element={<ArmazemHome />} />
      <Route
        path="estoque"
        element={
          <EmptyState icon={Construction} title="Armazém · Estoque" className="h-full justify-center" />
        }
      />
      <Route
        path="movimentacoes"
        element={
          <EmptyState icon={Construction} title="Armazém · Movimentações" className="h-full justify-center" />
        }
      />
      <Route
        path="mais"
        element={<EmptyState icon={Construction} title="Armazém · Mais" className="h-full justify-center" />}
      />
      <Route path="*" element={<Navigate to="/armazem" replace />} />
    </Routes>
  )
}
