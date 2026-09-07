# GB CERNE — Instruções para desenvolvimento

O Flutter em `apps/mobile` é a única aplicação oficial deste repositório. O runtime React foi
removido na M13 e existe apenas na tag de rollback `react-rollback-final-2026-08-17`.

## Stack oficial

- Flutter `3.44.6` e Dart 3.
- Riverpod para estado e `go_router` para navegação e política de acesso.
- Widgetbook em `apps/mobile/lib/widgetbook_app.dart`.
- Outfit self-hosted, Hugeicons 1.2 e design tokens gerados.
- Cloudflare Workers Static Assets com app em `/` e Widgetbook em `/storybook/`.

## Comandos principais

```bash
npm run dev                # Flutter Web no Chrome
npm run lint               # flutter analyze --fatal-infos
npm test                   # suíte Flutter completa
npm run quality:functional # gates de arquitetura, acesso e catálogo 52/52
npm run tokens:verify      # design/tokens.ts → DTCG → Dart
npm run build              # app + Widgetbook em apps/mobile/build/site
npm run smoke:deploy       # rotas e fallbacks do Worker
```

## Estrutura

- `apps/mobile/lib/ui/`: catálogo component-first e casos do Widgetbook.
- `apps/mobile/lib/design/`: temas e arquivos Dart gerados.
- `apps/mobile/lib/router/`: roteamento e política de acesso.
- `apps/mobile/lib/shell/`: shell, sessão demonstrativa e navegação global.
- `apps/mobile/lib/modules/`: Início, Fazendas, Bank, Crédito, Marketplace e Armazém.
- `design/tokens.ts`: fonte única neutra dos tokens.
- `tokens/tokens.json`: exportação W3C DTCG.
- `workers/index.js`: fallbacks separados do app e Widgetbook.

## Leis do projeto

### 1 — Component-first

Todo controle visível reutilizável deve nascer em `apps/mobile/lib/ui/` antes de ser consumido por
telas. Componentes públicos entram no barrel `ui.dart` e possuem caso correspondente no Widgetbook.
Não reimplementar localmente controles já existentes no catálogo.

### 2 — Fonte única de componentes

Extensões visuais ou comportamentais são feitas no widget compartilhado por props/parâmetros, não
por cópias ou patches em uma única tela. Estado de domínio ou sessão compartilhado usa Riverpod.

### 3 — Tokens e tipografia

Outfit é a única família tipográfica de apresentação. Cores, espaços, dimensões, raios, sombras e
movimento vêm dos arquivos em `apps/mobile/lib/design/generated`; valores novos entram primeiro em
`design/tokens.ts`.

### 4 — Commits e push

Cada unidade lógica concluída recebe imediatamente um commit Conventional Commit. Push só ocorre
quando solicitado explicitamente pelo usuário.

### 5 — Pipeline W3C DTCG

O fluxo é imutável:

`design/tokens.ts` → `npm run tokens:export` → `tokens/tokens.json` →
`npm run tokens:export:flutter` → `apps/mobile/lib/design/generated`

Toda mudança na fonte exige regenerar e commitar DTCG e Dart na mesma unidade lógica. O exportador
só emite tipos válidos do padrão DTCG, e valores compostos devem usar sua forma estrutural.

## Limites do protótipo

O produto continua exclusivamente frontend: autenticação, RBAC de backend, APIs, persistência e
hardware real são simulados. Não apresentar Bluetooth, RFID, câmera, localização ou balança como
integrações nativas concluídas.
