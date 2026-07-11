import { Routes, Route, Navigate } from 'react-router-dom'
import { ArmazemHome } from './screens/ArmazemHome'
import { EstoqueScreen } from './screens/EstoqueScreen'
import { MovimentacoesScreen } from './screens/MovimentacoesScreen'
import { UnidadesScreen } from './screens/UnidadesScreen'
import { RelatoriosScreen } from './screens/RelatoriosScreen'
import { ArmazemMaisScreen } from './screens/ArmazemMaisScreen'

/**
 * Módulo Armazém: home operacional + abas de Estoque, Movimentações,
 * Unidades e Relatórios (spec §3.4, D2). Rotas relativas a /armazem,
 * injetadas pelo ShellLayout.
 */
export function ArmazemModule() {
  return (
    <Routes>
      <Route index element={<ArmazemHome />} />
      <Route path="estoque" element={<EstoqueScreen />} />
      <Route path="movimentacoes" element={<MovimentacoesScreen />} />
      <Route path="unidades" element={<UnidadesScreen />} />
      <Route path="relatorios" element={<RelatoriosScreen />} />
      <Route path="mais" element={<ArmazemMaisScreen />} />
      <Route path="*" element={<Navigate to="/armazem" replace />} />
    </Routes>
  )
}
