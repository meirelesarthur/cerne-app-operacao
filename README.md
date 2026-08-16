# GB CERNE — Superapp (protótipo frontend)

Protótipo navegável de alta fidelidade do **superapp corporativo GB CERNE**, com foco no módulo
**Fazendas** (ex-"Cerne"/agro365). Somente frontend, dados mockados, sem backend — feito para validar
fluxo e servir de handoff ao time mobile. Baseado em `spec-cerne-app.md`.

## Stack

- **React 18 + TypeScript** (strict) · **Vite 5**
- **Tailwind CSS 3** derivado dos tokens · fonte **Outfit** self-hospedada (`@fontsource`)
- **react-router-dom** (roteamento em 2 níveis) · **zustand** (estado)
- **lucide-react** (ícones) · gráficos **SVG próprios** (sem lib de charting)

## Como rodar

```bash
npm install
npm run dev            # http://localhost:5173
npm run build          # typecheck (tsc -b) + build de produção
npm run quality:functional # valida as 53 funções e bloqueia regressões do catálogo
npm run tokens:export  # regenera tokens/tokens.json (DTCG) a partir de src/design/tokens.ts
```

No app, um **botão flutuante de dev** (canto inferior direito) alterna **offline** (banners de sync) e
**tema** (light / GB Mode escuro).

## Arquitetura

Roteamento em dois níveis (spec §7.3): `/:moduleId/*` → o **Shell** escolhe o módulo e injeta seu
bottom tab bar; cada módulo tem suas rotas internas.

```
src/
  design/tokens.ts        # fonte única de tokens (Lei 3/5) → export DTCG em tokens/tokens.json
  styles/tokens.css       # CSS vars light/gbMode (data-theme)
  context/ThemeContext     # tema light | gbMode
  components/ui/           # biblioteca de componentes (Lei 1) — tudo consome t.*
  shell/                   # Header global, ModuleSwitcher, BottomTabBar genérico, DevToolbar,
                           #   moduleConfig (registro de módulos), shellStore, páginas do Shell
  modules/
    fazendas/              # módulo completo: components, admin/ (7 dashboards), operacional/ (6 fluxos),
                           #   screens/, state/fazendasStore, mocks/
    PlaceholderModule      # casca genérica (Bank/Crédito/Marketplace/Armazém)
```

### Design system (Leis do projeto)

- **Lei 1** — todo elemento é um componente de `src/components/ui/`; nada de `<button>/<input>/<table>/<h1-6>` cru em telas.
- **Lei 2** — componentes são fonte única; extensão via props, sem `style` inline sobrescrevendo.
- **Lei 3** — todo valor de design vem de `src/design/tokens.ts` (via `t.*` ou CSS vars); fonte Outfit apenas.
- **Lei 5** — `tokens.ts` é a fonte; `npm run tokens:export` gera `tokens/tokens.json` (W3C DTCG).

## Módulo Fazendas

- **Dois ambientes protegidos por perfil**: Administração (leitura/decisão) e Operacional (entrada/campo).
- **Farm switcher** (multi-tenant) no header do módulo; badge "Lançando em: {fazenda}" nos formulários.
- **12 funções administrativas** e **41 operacionais** cobertas pelo catálogo normalizado, com
  46 jornadas frontend prontas e 7 integrações de hardware funcionalmente simuladas.

### Regras de negócio refletidas na UI (§7.2)

- Bloco produtivo/reprodutivo do Dashboard Pecuária **sempre desativado** (cadeado).
- Transferência de lote **exige pesagem do dia** — bloqueio funcional real (versão correta, sem o bug do legado).
- Venda de animais: **mês congelado bloqueia edição** (cadeado + tooltip); total > 0 e contagem devem bater.
- Consultas Gerenciais **100% read-only**; localização de animais como placeholder de mapa.
- Dados PARCIAL/LACUNA marcados com selo "Dados de exemplo" ou bloco "Indisponível".

## Checklist de aceite (spec §9)

- [x] Shell funcional: Barra de Módulos troca header, conteúdo e bottom tab bar dos 5 módulos.
- [x] Cores/spacing/radius/shadow vêm de tokens; sem valores hardcoded no JSX.
- [x] Módulo Fazendas: duas visões (Gerencial/Campo) via switch, com farm switcher (mock).
- [x] 7 telas administrativas + fluxos operacionais implementados com mock, dentro do módulo Fazendas.
- [x] Bank/Crédito/Marketplace/Armazém navegáveis como cascas, cada um com seu bottom tab bar.
- [x] Itens PARCIAL/LACUNA com selo/placeholder, sem dado fictício "real".
- [x] Trava de pesagem do dia bloqueando transferência funciona no protótipo.
- [x] Banner de offline/sync demonstrável via toggle de dev, restrito ao módulo Fazendas.
- [x] Tema light 100% funcional; GB Mode com cores base aplicadas.
- [x] Nenhum uso de localStorage/sessionStorage (estado em memória).
- [x] Estrutura `shell/` + `modules/<nome>/`, pronta para mapeamento 1:1 no mobile.
- [x] Sessão demonstrativa obrigatória, logout efetivo e redirecionamento de rotas internas para o login.
- [x] Gate automatizado garantindo 12 funções administrativas, 41 operacionais, IDs únicos,
  zero itens apenas `Mapeado` e simulação presente em toda dependência de hardware.
- [x] Controles primários e secundários do design system com alvo mínimo de toque de 44 px,
  foco visível, rótulos acessíveis e ausência de rolagem horizontal em 390 px.

## Notas de handoff (mobile)

- A estrutura `modules/<nome>/` já nasce como feature-modules — mapeável 1:1 para módulos nativos.
- Gráficos são SVG próprios tokenizados; no mobile, indicar equivalente nativo mantendo os tokens.
- Estado em memória (zustand). Em app real, a fila de sync e a visão/fazenda ativa podem ser persistidas.
- Fora do escopo desta fase (não exigidos pelo spec): Storybook, testes automatizados e Chakra UI.
