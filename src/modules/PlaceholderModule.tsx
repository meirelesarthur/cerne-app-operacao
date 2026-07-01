import { Routes, Route, Navigate } from 'react-router-dom'
import { Construction, Sparkles } from 'lucide-react'
import type { ModuleDef } from '@/shell/moduleConfig'
import { EmptyState } from '@/components/ui/EmptyState'
import { Heading } from '@/components/ui/Heading'
import { Chip } from '@/components/ui/Chip'

/**
 * Módulo-casca genérico (spec §3.4/§5): header/bottom tab próprios (via ShellLayout)
 * + tela inicial de apresentação + demais abas em "conteúdo em desenvolvimento".
 * Usado por Bank/Crédito/Marketplace/Armazém.
 */
export function PlaceholderModule({ module }: { module: ModuleDef }) {
  return (
    <Routes>
      <Route index element={<ModuleEntry module={module} />} />
      {module.bottomTabs
        .filter((tab) => tab.path !== '')
        .map((tab) => (
          <Route
            key={tab.id}
            path={tab.path}
            element={
              <EmptyState
                icon={Construction}
                title={`${module.label} · ${tab.label}`}
                description="Conteúdo em desenvolvimento. Este módulo será detalhado em uma próxima fase de discovery."
                className="h-full justify-center"
              />
            }
          />
        ))}
      <Route path="*" element={<Navigate to={module.homeRoute} replace />} />
    </Routes>
  )
}

/** Tela inicial do módulo-casca: identidade do módulo + prévia das áreas planejadas. */
function ModuleEntry({ module }: { module: ModuleDef }) {
  const Icon = module.icon
  const planejadas = module.bottomTabs.filter((t) => t.path !== '')

  return (
    <div className="flex h-full flex-col items-center px-6 py-10 text-center">
      <div className="flex h-20 w-20 items-center justify-center rounded-3xl bg-accent-subtle text-accent">
        <Icon size={36} strokeWidth={1.5} />
      </div>
      <Heading level={1} className="mt-5">
        {module.label}
      </Heading>
      <p className="mt-2 max-w-[300px] text-md text-fg-muted">
        Este é um app da empresa sendo unificado no superapp. Sua experiência completa chega em uma próxima fase.
      </p>

      <div className="mt-6 flex flex-wrap justify-center gap-2">
        {planejadas.map((t) => (
          <Chip key={t.id} tone="neutral" icon={<Sparkles size={11} />}>
            {t.label}
          </Chip>
        ))}
      </div>
    </div>
  )
}
