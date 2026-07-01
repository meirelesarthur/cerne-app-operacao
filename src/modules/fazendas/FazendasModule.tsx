import { MODULE_MAP } from '@/shell/moduleConfig'
import { PlaceholderModule } from '@/modules/PlaceholderModule'

/**
 * Módulo Fazendas (ex-"Cerne") — o módulo completo do superapp.
 * STUB da Fase 1: renderiza placeholders por aba. A Home real, o FarmSwitcher e o
 * switch de visão Gerencial/Campo chegam na Fase 2.
 */
export function FazendasModule() {
  return <PlaceholderModule module={MODULE_MAP.fazendas} />
}
