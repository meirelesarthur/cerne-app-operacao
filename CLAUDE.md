# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# GB CERNE — Instruções para Claude Code

## Roteamento de Modelos (Orquestração Multi-Model)

Opus é o orquestrador deste projeto. Ao spawnar subagentes via Agent tool, use o modelo adequado à tarefa:

### Haiku — tarefas leves e rápidas
Use `model: "haiku"` para:
- Busca de arquivos (Glob, Grep, exploração de estrutura)
- Leitura de arquivos isolados
- Verificações rápidas (existe arquivo? qual o conteúdo de X?)
- Tarefas de listagem e indexação
- Subagentes do tipo `Explore` com escopo pequeno (`quick`)

### Sonnet — implementação e análise
Use `model: "sonnet"` para:
- Geração e edição de código (componentes, hooks, utilitários)
- Refatoração de arquivos existentes
- Análise de código com múltiplos arquivos
- Subagentes do tipo `Explore` com escopo médio/amplo
- Subagentes do tipo `general-purpose` para tarefas de implementação
- Criação de testes

### Opus — reservado para o orquestrador
Não spawne subagentes com `model: "opus"` — Opus já é você (o orquestrador). Use sua própria capacidade para:
- Planejamento de arquitetura e decisões de design
- Integração e revisão dos resultados dos subagentes
- Tarefas que exigem raciocínio profundo sobre múltiplos contextos

---

## Stack do Projeto

- **React 18 + TypeScript** (strict mode)
- **Vite 5** — build tool, dev server em `http://localhost:5173`
- **Tailwind CSS 3** com tokens customizados (fonte Outfit, paleta emerald)
- **Chakra UI 3** + Emotion (peer deps instalados)
- **Storybook 10** em `http://localhost:6006`
- **Vitest + Playwright** para testes

## Comandos principais

```bash
npm run dev        # Dev server → http://localhost:5173
npm run storybook  # Storybook → http://localhost:6006
npm run build      # Build de produção (TS check + Vite)
```

## Estrutura src/

- `components/layout/` — AppLayout, Sidebar, Topbar, SecondaryNav
- `components/ui/` — componentes reutilizáveis (Badge, FormField, DataTable…)
- `components/*.stories.tsx` — stories do Storybook

---

## Leis do Projeto

Estas políticas são invioláveis e se aplicam a toda geração de código neste projeto.
Referência visual completa: `UI_WEB_GUIDE.html` na raiz do projeto.

### Lei 1 — Component-First (Componentização Obrigatória)

Todo elemento visível na tela é um componente de `src/components/ui/`.

**Proibido usar diretamente em páginas:** `<button>`, `<input>`, `<select>`, `<table>`, `<thead>`, `<tr>`, `<td>`, `<h1>`–`<h6>`.

- Ao criar uma nova tela, apenas **importar e chamar** componentes existentes
- Se o componente necessário não existe no catálogo, criá-lo em `src/components/ui/` **antes** de usá-lo na tela
- Catálogo atual: `Avatar`, `Badge`, `Breadcrumb`, `BulkActionBar`, `Button`, `Card`, `ChartCard`, `Checkbox`, `CollapsibleSection`, `ConfirmDialog`, `DataTable`, `Divider`, `DropdownMenu`, `EmptyState`, `FilterDrawer`, `FormField`, `FormPageHeader`, `FormSection`, `FormSelect`, `Heading`, `HeatmapChart`, `IconButton`, `KpiStatCard`, `ListToolbar`, `MapView`, `Modal`, `PageCard`, `PageContainer`, `PageHeader`, `Pagination`, `ProgressBar`, `SankeyFunnel`, `SearchSelect`, `SectionDividers`, `Skeleton`, `SortHeader`, `SparklineArea`, `Spinner`, `SSOButton`, `StepFooter`, `StepHeader`, `Stepper`, `TableToolbar` (exporta `TableSearchInput`, `FilterChip`, `FilterButton`), `Tabs`, `Tag`, `Toast` (`useToast`/`ToastContainer`), `ToggleSwitch`, `Tooltip`

### Lei 2 — Fonte Única de Verdade (Propagação Global)

Alterações em componentes de `src/components/ui/` refletem automaticamente em todas as telas — esse é o objetivo.

**Proibido em páginas/telas:**
- Sobrescrever estilos com `style={}` inline sobre um componente existente
- Duplicar lógica de estilo que o componente já oferece via prop (ex.: criar spinner manual quando `Button` tem `loading`)
- Clonar/reimplementar um componente UI dentro de uma página

Extensões de comportamento são feitas adicionando props ao componente em `src/components/ui/`, nunca por patch local.

### Lei 3 — Fonte & Tokenização Acima de Tudo

**Tipografia:** única fonte permitida é **Outfit**. Não usar `font-montserrat`, fontes do sistema ou qualquer alternativa como valor de apresentação.

**Tokens:** todo valor de design (cor, espaço, raio, sombra, tamanho de fonte, peso) vem de `src/design/tokens.ts` via `t.*`.

```ts
// Correto
color: t.color.brand[600]
fontSize: t.font.size.sm
padding: t.space[4]

// Violação — hardcoded fora do arquivo de tokens
color: '#059669'
fontSize: '0.875rem'
padding: '16px'
```

Valores hardcoded fora de `src/design/tokens.ts` e `tailwind.config.ts` são violação de política.

### Lei 4 — Commits Obrigatórios, Push sob Demanda

Após toda mudança concluída, um commit **deve ser criado imediatamente** — sem aguardar solicitação.

- O push **nunca é feito automaticamente** — somente quando o usuário solicitar explicitamente
- Mensagens de commit seguem o padrão Conventional Commits (`feat:`, `fix:`, `style:`, `refactor:`, `docs:`, etc.)
- Um commit por unidade lógica de mudança — não acumular alterações não relacionadas no mesmo commit

### Lei 5 — Tokens Interoperáveis no Padrão W3C DTCG

`src/design/tokens.ts` é a **fonte única** dos tokens; sua exportação para o ecossistema de design
(Figma, Supernova) **deve sempre obedecer ao padrão W3C DTCG** (Design Tokens Community Group).
A direção do fluxo é **imutável**: o código define, Figma e Supernova consomem — nunca o contrário.

**Pipeline canônico:**
`tokens.ts` → `npm run tokens:export` → `tokens/tokens.json` (DTCG) → Tokens Studio → Figma Variables → Supernova

- Toda alteração em `tokens.ts` exige rodar `npm run tokens:export` e **commitar o `tokens/tokens.json`
  regenerado** na mesma unidade lógica — o JSON nunca pode divergir do `.ts`.
- O exportador (`scripts/export-tokens-dtcg.ts`) só pode emitir `$type` **válidos no DTCG**:
  `color`, `dimension`, `number`, `fontFamily`, `fontWeight`, `duration`, `cubicBezier`,
  `strokeStyle`, `border`, `transition`, `shadow`, `gradient`, `typography`. **Proibido** inventar
  tipos fora dessa lista (ex.: `borderRadius` → use `dimension`).
- Valores de tipos compostos seguem a forma estrutural do DTCG, **nunca string CSS crua**:
  `cubicBezier` → array `[x1,y1,x2,y2]`; `duration` → `{ value, unit }`; `shadow` →
  `{ color, offsetX, offsetY, blur, spread }` (multicamada → array); `transition` →
  `{ duration, delay, timingFunction }`; `border` → `{ color, width, style }`.
- Ao adicionar um token novo em `tokens.ts`, **mapeie-o no exportador** com o `$type` correto antes
  de concluir a mudança — um token sem mapeamento DTCG é entrega incompleta.
- Ajustes propostos via Figma (Tokens Studio → Push) entram como **PR** que atualiza `tokens.ts`;
  jamais se edita token direto no Figma como fonte.

---
