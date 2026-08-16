import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { ThemeProvider } from './context/ThemeContext'
import { PhoneFrame } from './shell/components/PhoneFrame'
import { ShellLayout } from './shell/ShellLayout'
import { Login } from './shell/pages/Login'
import { Onboarding } from './shell/pages/Onboarding'
import { Notificacoes } from './shell/pages/Notificacoes'
import { PerfilConfig } from './shell/pages/PerfilConfig'

/**
 * Raiz do app. Roteamento em dois níveis (spec §7.3):
 *   /:moduleId/*  → ShellLayout escolhe o módulo e injeta seu bottom tab bar
 *   telas de Shell (login/onboarding/notificações/perfil) ficam fora da moldura de módulo.
 */
export function App() {
  return (
    <ThemeProvider>
      <BrowserRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
        <PhoneFrame>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/onboarding" element={<Onboarding />} />
            <Route path="/notificacoes" element={<Notificacoes />} />
            <Route path="/perfil" element={<PerfilConfig />} />
            <Route path="/:moduleId/*" element={<ShellLayout />} />
            {/* fluxo do protótipo: raiz parte do onboarding → login → superapp */}
            <Route path="/" element={<Navigate to="/onboarding" replace />} />
            <Route path="*" element={<Navigate to="/inicio" replace />} />
          </Routes>
        </PhoneFrame>
      </BrowserRouter>
    </ThemeProvider>
  )
}
