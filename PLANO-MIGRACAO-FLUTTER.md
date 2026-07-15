# Plano de Migração — Protótipo React → App Flutter (GB CERNE)

**Objetivo:** levar o GB CERNE de protótipo React navegável a **app de produção em Flutter/Dart**,
aproveitando o que o protótipo já define como contrato (tokens DTCG, catálogo de componentes,
arquitetura de módulos) e entregando ao time mobile uma esteira com fases, critérios de aceite
e ordem de ataque.

> **Base:** inventário do repo em 15/07/2026 — ~10,3k LOC TS/TSX · 43 componentes de catálogo
> (~2,1k LOC) · 67 telas em 6 módulos (~6,5k LOC) · shell ~1,2k LOC · `design/tokens.ts` 388 LOC
> com export DTCG (`tokens/tokens.json`) já operacional (Lei 5).
> **Natureza do trabalho:** reescrita guiada, não conversão automática. O custo concentra no
> catálogo de widgets; as telas são composição (Lei 1) e saem rápido depois.

---

## 0. Premissas e papéis

| Item | Decisão |
|---|---|
| Papel do protótipo React | **Spec viva congelada** — referência de UX/fluxos; não recebe feature nova após o início da F2, apenas correções de spec |
| Papel do app Flutter | Produto de produção — único destino de features novas a partir da F4 |
| Contrato entre os dois | `tokens/tokens.json` (DTCG) + catálogo `src/components/ui/` (nomes e props) + `moduleConfig.ts` (mapa de navegação) |
| Fluxo de design | Inalterado (Lei 5): código define tokens → Figma/Supernova consomem. O Flutter passa a ser mais um consumidor do mesmo JSON |
| Time sugerido | 2 devs Flutter + 1 dev do protótipo como "guardião da spec" (part-time) |
| Stack Flutter | Flutter estável · Dart 3 · `go_router` (navegação 2 níveis) · Riverpod (estado) · `style_dictionary` (tokens → Dart) · `lucide_icons` · `fl_chart` ou `CustomPainter` · Isar/Drift (offline, F6) |

**Regra de ouro da esteira:** nenhuma tela é iniciada antes de o widget de catálogo que ela usa
existir e estar aprovado (espelho da Lei 1). Toda cor/espaço/raio no Flutter vem do tema gerado
dos tokens — hardcode é violação, igual à Lei 3.

---

## 1. Mapa de equivalências (referência)

### 1.1 Fundações
| Protótipo (React) | App (Flutter) |
|---|---|
| `design/tokens.ts` → `tokens/tokens.json` | Style Dictionary target Flutter → `AppTheme`/`ThemeExtension` gerados (não editados à mão) |
| CSS vars light/gbMode (`data-theme`) | `ThemeData` claro + `ThemeExtension` GB Mode, troca via provider |
| Tailwind classes | Widgets + tema; sem equivalente direto (reescrita) |
| Fonte Outfit self-hosted | `google_fonts` pin local / asset font Outfit |
| react-router-dom 2 níveis (`/:moduleId/*`) | `go_router` com `ShellRoute` (header + module-bar persistentes) e rotas aninhadas por módulo |
| zustand (`shellStore`, `fazendasStore`, …) | Riverpod (`Notifier` por store; mesma modelagem de estado) |
| lucide-react | `lucide_icons` (mapa por nome) |
| SVG charts próprios (`BarChart`, `DonutChart`, `SparklineArea`) | `CustomPainter` (fidelidade) ou `fl_chart` (velocidade) — decidir na F2 |
| `PhoneFrame` (bezel desktop) | Não migra — é artefato de protótipo |

### 1.2 Catálogo `ui/` → widgets (43 itens, esforço da F2)
| Grupo | Componentes | Equivalência Flutter |
|---|---|---|
| Ações | `Button` (5 variantes), `IconButton`, `QuickAction` | `FilledButton`/`OutlinedButton`/`TextButton` custom + tema |
| Superfícies | `Card`, `DashboardCard`, `BentoTile`, `MiniAppTile`, `ChartCard`, `KpiStatCard`, `BalanceCard` | `Container`+`InkWell` custom widgets |
| Formulário | `TextInput`, `Textarea`, `FormField`, `FormSelect`, `SearchSelect`, `Checkbox`, `ToggleSwitch`, `FileUpload`, `Stepper` | `TextFormField` custom + `showModalBottomSheet` para selects |
| Feedback | `Banner`, `EmptyState`, `ErrorState`, `SuccessPanel`, `Skeleton`/`CardSkeleton`, `Spinner`, `Tooltip`, `ProgressBar` | widgets custom + `shimmer` |
| Overlay | `Modal`, `BottomSheet`, `TransactionDetailSheet` | `showDialog`/`showModalBottomSheet` |
| Dados | `TransactionListItem`, `MenuItem`, `Badge`, `Chip`, `Tag`, `Avatar`, `Heading`/`SectionTitle`, `PageDots`, `IllustrationSlot` | `ListTile` custom + `Text` com estilos do tema |
| Gráficos | `BarChart`, `DonutChart`, `SparklineArea` | `CustomPainter`/`fl_chart` |

### 1.3 Módulos → ordem de valor (esforço da F4)
| Ordem | Módulo | Conteúdo | Peso |
|---|---|---|---|
| 1º | Shell + Início (hub) | header, module-bar, reveal menu, bottom tabs, Banking hub | M |
| 2º | Fazendas | 7 dashboards gerenciais + 6 fluxos operacionais + sync | **G** (maior módulo) |
| 3º | Bank | conta, extrato, pagamentos | M |
| 4º | Crédito | ofertas, simulador, propostas | M |
| 5º | Marketplace + Armazém | vitrine/pedidos + estoque/movimentações | M |
| 6º | Login + Onboarding | telas de entrada (artes prontas em `src/images/`) | P |

---

## 2. Esteira de desenvolvimento

Marcação `[ ]` a cada etapa concluída, com o PR correspondente. Um PR por unidade lógica.
Cada fase tem **gate de saída (DoD)** — a fase seguinte não abre sem o gate fechado.

### Fase F0 — Fundação do repositório (≈ 1 semana, paralelizável com F1)
Preparar o terreno; nada visual ainda.

- [ ] **F0.1** Criar repo `cerne-app-flutter` (ou monorepo `apps/mobile`), Flutter estável, lint
  (`very_good_analysis` ou `flutter_lints` estrito), CI (analyze + test + build por PR).
- [ ] **F0.2** Estrutura de pastas espelhando o protótipo: `lib/design/`, `lib/ui/` (catálogo),
  `lib/shell/`, `lib/modules/<nome>/`.
- [ ] **F0.3** Pipeline de assets: fonte Outfit, `lucide_icons`, ilustrações e logos copiadas de
  `src/images/` (onboard1-3, login_bg, logo-min-white e variantes).
- [ ] **F0.4** Decisão registrada (ADR curto): Riverpod vs Bloc · fl_chart vs CustomPainter ·
  repo separado vs monorepo.

**DoD F0:** app "hello" buildando em CI para Android e iOS; ADRs commitados.

### Fase F1 — Tokens e tema (≈ 1 semana)
O contrato primeiro. É o espelho da Lei 3/5 no Flutter.

- [ ] **F1.1** Configurar Style Dictionary consumindo `tokens/tokens.json` (DTCG) do repo do
  protótipo (git submodule, package, ou cópia versionada com script de sync).
- [ ] **F1.2** Gerar `app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart`,
  `app_shadows.dart` — arquivos gerados, nunca editados à mão (comentário-guarda no header).
- [ ] **F1.3** Montar `ThemeData` light + `ThemeExtension` GB Mode a partir dos gerados; troca de
  tema em runtime (equivalente ao `data-theme`).
- [ ] **F1.4** Tela interna de auditoria de tema (grid de cores/espaços/tipografia) para validação
  visual com o design.

**DoD F1:** mudança de valor em `tokens.ts` → `npm run tokens:export` → regeneração Dart reflete
no app sem edição manual; validado pelo design nas duas variantes de tema.

### Fase F2 — Catálogo de widgets (≈ 2–3 semanas) ← maior investimento
Reescrever os 43 componentes de `ui/` como package interno, mesmos nomes e props (§1.2).

- [ ] **F2.1** Lote Ações + Superfícies (Button, IconButton, Card, tiles, KPI).
- [ ] **F2.2** Lote Formulário (inputs, selects, checkbox, toggle, stepper, upload).
- [ ] **F2.3** Lote Feedback + Overlay (banners, estados, skeleton, modal, bottom sheets).
- [ ] **F2.4** Lote Dados + Gráficos (list items, badges, avatar, charts, page dots, illustration slot).
- [ ] **F2.5** Galeria de componentes (rota interna tipo storybook: `widgetbook` ou tela própria)
  com todas as variantes de cada widget.
- [ ] **F2.6** Golden tests dos widgets críticos (Button, Card, inputs, list items) nas 2 variantes
  de tema.

**DoD F2:** 43/43 no ar na galeria; goldens verdes em CI; aprovação visual do design comparando
lado a lado com o protótipo React.

### Fase F3 — Shell e navegação (≈ 1 semana)
- [ ] **F3.1** `ShellRoute` com header global (gradiente, saudação, pílula de crédito, sino) +
  module-bar (cantos arredondados sobrepostos, indicador full-width) — réplica do `ShellLayout`.
- [ ] **F3.2** Bottom tab bar por módulo lida de um `moduleConfig` Dart (portar o `moduleConfig.ts`).
- [ ] **F3.3** Reveal menu (app encolhe como cartão, menu verde desliza) com as mesmas curvas/spring
  tokenizadas; respeitar `MediaQuery.disableAnimations`.
- [ ] **F3.4** Stores do shell (usuário, notificações, online/offline, menu) em Riverpod.

**DoD F3:** trocar de módulo preserva header/estado como no protótipo; deep-link `/:module/:tab`
funciona via `go_router`.

### Fase F4 — Módulos por valor (≈ 3–4 semanas)
Ordem do §1.3. Cada módulo é um trilho independente da esteira — com 2 devs, rodar 2 trilhos em
paralelo após o 1º.

- [ ] **F4.1** Início/hub (Banking central, bento de mini-apps).
- [ ] **F4.2** Fazendas — gerencial: 7 dashboards (charts prontos na F2).
- [ ] **F4.3** Fazendas — operacional: 6 fluxos de campo + fila de sync (ainda mock, como no protótipo).
- [ ] **F4.4** Bank (extrato, pagamentos, cartões).
- [ ] **F4.5** Crédito (oferta, simulador, propostas).
- [ ] **F4.6** Marketplace + Armazém.
- [ ] **F4.7** Login + Onboarding (artes e logo já em assets; carrossel com `PageView` + dots).

**DoD F4 (por módulo):** paridade de telas e navegação com o protótipo (checklist por tela);
zero hardcode de estilo (audit de lint próprio); revisão do guardião da spec.

### Fase F5 — Hardening e qualidade (≈ 1 semana)
- [ ] **F5.1** Acessibilidade: semantics, tamanhos de toque ≥ 48dp, contraste nas 2 variantes.
- [ ] **F5.2** Performance: rebuilds (DevTools), imagens (`cacheWidth`), jank nos springs do menu.
- [ ] **F5.3** Testes de fluxo (integration_test): onboarding→login→hub, lançamento de campo,
  simulação de crédito.
- [ ] **F5.4** Build assinado + distribuição interna (TestFlight / Play Internal).

**DoD F5:** paridade total navegável em aparelho físico, aprovada por design + produto.

### Fase F6 — Além do protótipo (backlog pós-paridade)
O que o protótipo apenas simula e vira implementação real no app:

- [ ] **F6.1** Autenticação real (o login é mock).
- [ ] **F6.2** Offline-first de verdade: fila de sync com Isar/Drift + retry/conflitos
  (hoje `isOnline` é um toggle de demonstração).
- [ ] **F6.3** Notificações push (o sino é mock).
- [ ] **F6.4** Integração com APIs de negócio (tudo hoje é mock em `mocks/`).

---

## 3. Governança e anti-divergência

1. **Fonte única de design:** mudança visual entra primeiro em `tokens.ts` (+ export DTCG) e/ou
   no catálogo — nunca direto numa tela Flutter. Mesma disciplina das Leis 1–3, agora nos dois repos.
2. **Protótipo congelado a partir da F2:** ajustes de UX aprovados geram issue espelho no repo
   Flutter; o protótipo só muda para corrigir a spec (e o commit referencia a issue).
3. **Ritual de handoff:** 1 review semanal design + devs comparando galeria Flutter × protótipo.
4. **Definition of Done global:** paridade não é "parecido" — é mesma hierarquia, mesmos tokens,
   mesmos fluxos; divergência intencional exige registro no ADR.

## 4. Resumo executivo de esforço

| Fase | Duração (2 devs) | Acumulado |
|---|---|---|
| F0 Fundação | 1 sem (paralela à F1) | 1ª sem |
| F1 Tokens/tema | 1 sem | 1ª–2ª sem |
| F2 Catálogo | 2–3 sem | 4ª–5ª sem |
| F3 Shell | 1 sem | 5ª–6ª sem |
| F4 Módulos | 3–4 sem | 8ª–10ª sem |
| F5 Hardening | 1 sem | **9ª–11ª sem → paridade** |
| F6 Produção real | contínuo | pós-paridade |

**Riscos principais:** subestimar o catálogo (mitigação: F2 com gate visual duro antes das telas);
divergência protótipo×app (mitigação: §3); fidelidade dos charts custom (mitigação: decidir
CustomPainter × fl_chart na F0 com spike de 1 dia).
