# Roadmap — Protótipo Superapp GB CERNE (módulo Fazendas)

Esteira de desenvolvimento em fases, conforme `spec-cerne-app.md` §8 e o `CLAUDE.md`.
Marcação `[x]` a cada etapa concluída, com o commit correspondente.

> **Escopo:** protótipo frontend mobile de alta fidelidade, dados mockados, sem backend.
> **Stack:** React 18 + Vite 5 + TS · Tailwind (tokens) · react-router · zustand · lucide-react · charts SVG próprios.
> **Fora de escopo (não exigido pelo spec):** Chakra UI, Storybook, testes automatizados — opcionais na Fase 7.

---

## Fase 0 — Fundação  ✅
- [x] Scaffold Vite (React + TS strict), alias `@/`, `git init` — `c25058c`
- [x] `src/design/tokens.ts` (fonte única, Lei 3) — `c25058c`
- [x] `tailwind.config.ts` derivado dos tokens + `darkMode` por `data-theme` — `c25058c`
- [x] `src/styles/tokens.css` (CSS vars light/gbMode) + fonte Outfit — `c25058c`
- [x] `scripts/export-tokens-dtcg.ts` + `tokens/tokens.json` (Lei 5) — `c25058c`
- [x] `ThemeContext` + `useTheme` (light/gbMode) — `c25058c`
- [x] Componentes base `ui/`: Button, Card, Chip, Badge, Tag, IconButton, Skeleton, Banner, BottomSheet, Modal, Spinner — `c25058c`
- [x] `shell/moduleConfig.ts` (registro dos 5 módulos) + `shell/state/shellStore.ts` (zustand) — `c25058c`
- [x] Build de produção + typecheck passando · `npm run tokens:export` ok

## Fase 1 — Shell  ✅
- [x] `ShellLayout`: header global (saudação, sino c/ badge) + banner offline
- [x] `ModuleSwitcher` (barra de módulos, scroll horizontal, item ativo sublinhado)
- [x] `BottomTabBar` genérico consumindo `moduleConfig`
- [x] `DevToolbar` (toggle offline + toggle tema)
- [x] Roteamento react-router `/:moduleId/*` (troca módulo mantém header do Shell)
- [x] Telas do Shell: Login, Onboarding, Notificações, Perfil/Configurações
- [x] `PhoneFrame` (moldura mobile) + verificação visual (troca de módulo + gbMode)
- ↪ ícone "olho"/modo consulta: fica para a Fase 2 (contextual ao módulo Fazendas)

## Fase 2 — Módulo Fazendas · Home + navegação
- [ ] `FazendasModule`: header do módulo com `FarmSwitcher` (pill + bottom sheet)
- [ ] `ViewSwitch` segmentado [Gerencial | Campo] + `ContextBadge`
- [ ] `fazendasStore` (visão ativa, fazenda ativa, fila de sync)
- [ ] Home: `ShortcutGrid`, `DashboardCard` (claro + escuro), `ActivityListItem`

## Fase 3 — Visão Administrativa (7 dashboards)
- [ ] Charts SVG: `SparklineArea`, `BarChart`, `DonutChart`, `ProgressBar`, `KpiStatCard`, `ChartCard`
- [ ] Financeiro (comentário `grouper_id=7`)
- [ ] Pecuária de Corte (bloco produtivo/reprodutivo desativado)
- [ ] Confinamento / Lotação de Currais
- [ ] Ativos / Depreciação
- [ ] Suprimentos (selo "Dados de exemplo")
- [ ] Análise de Uso (badge "Acesso restrito")
- [ ] Consultas Gerenciais (read-only + placeholder de mapa)

## Fase 4 — Visão Operacional (7 fluxos)
- [ ] Componentes de form: `FormField`, `FormSelect`, `SearchSelect`, `Stepper`, `FileUpload`
- [ ] Pesagem (input manual + nota da balança)
- [ ] Eventos de Ciclo do Rebanho
- [ ] Arraçoamento / Nutrição (sem rateio)
- [ ] Venda de Animais (mês congelado bloqueia edição)
- [ ] Recebimento / Entrada por XML (NF-e)
- [ ] Aplicação de Insumos / Ocorrências Agrícolas
- [ ] Regra: transferência exige pesagem do dia (bloqueio funcional real)

## Fase 5 — Módulos-casca
- [ ] Bank · Crédito · Marketplace · Armazém (header + bottom tab próprio + EmptyState)
- [ ] Card de deep-link "crédito pré-aprovado" em Fazendas → módulo Crédito

## Fase 6 — Estados transversais
- [ ] Offline/sync: `DevToolbar` alterna `isOnline`; `SyncBanner` + banner de pendências
- [ ] Revisão de skeleton/erro/vazio no módulo Fazendas

## Fase 7 — Polimento para handoff
- [ ] Revisão do tema `gbMode`
- [ ] Microinterações (transições) + acessibilidade (toque ≥40px, contraste)
- [ ] Documentação inline dos componentes
- [ ] Checklist de aceite (§9 do spec)
