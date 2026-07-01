import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction } from 'lucide-react'
import type { ModuleDef } from '@/shell/moduleConfig'
import { EmptyState } from '@/components/ui/EmptyState'

/**
 * Módulo-casca genérico (spec §3.4/§5): header/bottom tab próprios do módulo (via ShellLayout)
 * + 1 tela por aba em estado "conteúdo em desenvolvimento". Usado por Bank/Crédito/Marketplace/Armazém.
 */
export function PlaceholderModule({ module }: { module: ModuleDef }) {
  return (
    <Routes>
      {module.bottomTabs.map((tab) => (
        <Route
          key={tab.id}
          path={tab.path === '' ? undefined : tab.path}
          index={tab.path === ''}
          element={
            <EmptyState
              icon={Construction}
              title={`${module.label} · ${tab.label}`}
              description="Conteúdo em desenvolvimento. Este módulo será detalhado em uma próxima fase de discovery."
            />
          }
        />
      ))}
      <Route path="*" element={<Navigate to={module.homeRoute} replace />} />
    </Routes>
  )
}
