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

## Fase 2 — Módulo Fazendas · Home + navegação  ✅
- [x] `FazendasModule`: header do módulo com `FarmSwitcher` (pill + bottom sheet) + rotas internas
- [x] `ViewSwitch` segmentado [Gerencial | Campo] + `ContextBadge` + ícone "olho"/modo consulta
- [x] `fazendasStore` (visão ativa, fazenda ativa, fila de sync) + mocks (fazendas, atividades)
- [x] Home: `ShortcutGrid`, `DashboardCard` (claro + escuro), `SparklineArea`, `ActivityListItem`
- [x] Telas de aba: Home (Gerencial/Campo), Atividades, Fazendas, Mais
- [x] `Heading`/`SectionTitle` (Lei 1) + refactor das páginas da Fase 1 · verificação visual OK

## Fase 3 — Visão Administrativa (7 dashboards)  ✅
- [x] Charts SVG: `SparklineArea`, `BarChart`, `DonutChart`, `ProgressBar`, `KpiStatCard`, `ChartCard`
- [x] Scaffold `DashboardScreen` (skeleton de load + banner offline com timestamp) + `useSimulatedLoad`
- [x] Financeiro (comentário `grouper_id=7` no mock)
- [x] Pecuária de Corte (bloco produtivo/reprodutivo desativado com cadeado)
- [x] Confinamento / Lotação de Currais (grid + progress por ocupação + bottom sheet)
- [x] Ativos / Depreciação
- [x] Suprimentos (filtro por tipo + selo "Dados de exemplo")
- [x] Análise de Uso (badge "Acesso restrito")
- [x] Consultas Gerenciais (hub read-only + placeholder de mapa)
- [x] Fonte Outfit self-hospedada (@fontsource) — sem dependência de rede

## Fase 4 — Visão Operacional (7 fluxos)  ✅
- [x] Componentes de form: `FormField`, `TextInput`, `Textarea`, `FormSelect`, `SearchSelect`, `Stepper`, `Checkbox`, `FileUpload`, `Tooltip`
- [x] Scaffold `FlowShell` (contexto + rodapé + chip offline) + `SuccessScreen` (efeitos no web)
- [x] Pesagem (input manual grande + nota da balança; registra pesagem do dia)
- [x] Eventos de Ciclo do Rebanho (form dinâmico por tipo)
- [x] Arraçoamento / Nutrição (sem rateio — LACUNA)
- [x] Venda de Animais (mês congelado bloqueia edição + contagem/total validados)
- [x] Recebimento / Entrada por XML (upload + conferência de itens)
- [x] Aplicação de Insumos / Ocorrências Agrícolas (validação mínima)
- [x] Regra: transferência exige pesagem do dia → bloqueio funcional real (verificado)

## Fase 5 — Módulos-casca  ✅
- [x] Bank · Crédito · Marketplace · Armazém (header + bottom tab próprio + tela de entrada + abas em desenvolvimento)
- [x] Tela de entrada do módulo-casca com identidade + prévia das áreas planejadas
- [x] Card de deep-link "crédito pré-aprovado" em Fazendas → módulo Crédito (verificado)

## Fase 6 — Estados transversais  ✅
- [x] Offline/sync: `DevToolbar` alterna `isOnline`; `SyncBanner` com contagem de pendências + "Sincronizar"
- [x] Fluxo completo verificado: lançamento offline → fila → banner → sincronizar → fila limpa
- [x] `ErrorState` (com retry) no catálogo; Análise de Uso indisponível offline (dados não cacheáveis)
- [x] Estados por tela: loading (skeleton), vazio (EmptyState), offline (banner+timestamp), erro (retry)

## Fase 7 — Polimento para handoff  ✅
- [x] Revisão do tema `gbMode` (verificado em shell, home e dashboards — CSS vars propagam)
- [x] Microinterações via tokens de transição; acessibilidade (tab bar 64px, botões 40–48px, list rows)
- [x] Documentação inline (JSDoc) nos componentes e módulos
- [x] `README.md` com stack, arquitetura, Leis, notas de handoff e **checklist de aceite §9**
- ↪ Nota: Storybook/testes/Chakra fora do escopo (não exigidos pelo spec); IconButtons secundários do header a ~30px

## Fase 8 — Navegabilidade total (PLANO-NAVEGABILIDADE.md)  ✅
- [x] **A** Quick wins: fila de sync real (`9d56023`), deep-link de notificação (`2a825ea`),
  back no Onboarding (`d572084`), telas "Mais" dos módulos-casca (`2f58d16`),
  destinos enganosos (`772d226`), remoção do PlaceholderModule órfão (`b54878c`)
- [x] **B** Detalhes reaproveitáveis: `ActivityDetailSheet` (`5db1c10`, 3 pontos de uso) e
  `TransactionDetailSheet` (`291e99c`, 4 pontos de uso)
- [x] **C** Bank: hub de Pagamentos com fluxo Pix completo + Cartões/Limites, novos
  `SuccessPanel` e `ToggleSwitch` no catálogo (`b9ffc9d`)
- [x] **D** Marketplace PDP/Categorias/Pedidos/Favoritos (`a3cde95`) · Armazém
  Estoque/Movimentações/Unidades/Relatórios (`4eaa5aa`) · Crédito Proposta/Contratos/Ajuda
  (`fe15cfd`) · detalhes de Ativo e Cotação (`69453c2`)
- [x] **E** Varredura final: menuSections nos 4 módulos-casca destravando rotas órfãs e
  removendo as `*MaisScreen` redundantes (`7fe3099`); verificação visual light/gbMode;
  console limpo; `tsc -b --noEmit` sem erros
- ↪ Placeholders honestos remanescentes (rotulados, por decisão): `/bank/ajuda`,
  `/marketplace/ajuda`, mapa de localização em Consultas, segunda via/ajustar limite em Cartões
