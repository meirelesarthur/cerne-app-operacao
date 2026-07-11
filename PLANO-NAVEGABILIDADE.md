# Plano de Navegabilidade — Protótipo GB CERNE

**Objetivo:** levar o protótipo de "spec entregue" para **100% navegável** — sem becos-sem-saída
(elementos que parecem clicáveis e não reagem), sem abas-casca cruas e sem telas referenciadas
mas inexistentes.

> **Base:** auditoria de navegabilidade cobrindo 100% dos arquivos de rota (`App.tsx`,
> `ShellLayout.tsx`, 6 `*Module.tsx`), todas as telas e todos os componentes clicáveis.
> **Contra o spec (README §9 / `NEW_UI_SUPERAPP.md`):** o protótipo já está **entregue** — as abas
> de módulo-casca são placeholder por decisão de recorte. Este plano trata do que falta para
> *navegabilidade total*, não de escopo pendente do spec.

---

## 0. Diagnóstico resumido

| Categoria | Qtd | Natureza |
|---|---|---|
| Becos-sem-saída reais | ~13 | elementos aparentam interação, sem `onClick`/handler |
| Abas de módulo-casca em `EmptyState` | 10 | placeholder assumido (Bank×3, Crédito×1, Marketplace×3, Armazém×3) |
| Telas de detalhe inexistentes | ~11 | listas sem tela de destino |
| Dead code arquitetural | 2 | `PlaceholderModule.tsx` + campo `placeholder` em `moduleConfig.ts` |

**Regra de ouro do plano:** primeiro eliminar a *sensação de app quebrado* (Fase A, baixo esforço),
depois preencher conteúdo (Fases B–D). As Leis 1/2/3 do projeto valem para toda tela nova:
componente de `ui/`, sem estilo inline, todo valor via `t.*`.

---

## 1. Inventário de becos-sem-saída (referência)

### 1.1 Elementos mortos (sem `onClick`, mas o componente já suporta)
| Elemento | Local (arquivo:linha) | Correção |
|---|---|---|
| `ActivityListItem` | `modules/fazendas/screens/FazendasHome.tsx:81` | ligar `onClick` → detalhe de atividade |
| `ActivityListItem` | `modules/fazendas/screens/AtividadesScreen.tsx:12` | idem |
| `ActivityListItem` | `modules/fazendas/admin/DashPecuaria.tsx:46` | idem |
| `TransactionListItem` | `modules/bank/screens/ExtratoScreen.tsx:50` | ligar `onClick` → detalhe de transação |
| `TransactionListItem` | `modules/bank/screens/BankHome.tsx:131` | idem |
| `TransactionListItem` | `modules/hub/screens/HubHome.tsx:123` | idem |
| `TransactionListItem` | `modules/hub/screens/CarteiraScreen.tsx:73` | idem |
| item de notificação (`<li>`) | `shell/pages/Notificacoes.tsx:40` | tornar clicável → deep-link `moduleId` de origem |
| `Card` "Meu cartão" | `modules/bank/screens/BankHome.tsx:74` | `interactive` + navegar a `/bank/cartoes` |
| `Card` unidade de armazenagem | `modules/armazem/screens/ArmazemHome.tsx:76` | `interactive` → detalhe de unidade |
| `<div>` movimentação | `modules/armazem/screens/ArmazemHome.tsx:105` | tornar interativo → detalhe de movimentação |
| item de ativo (`<li>`) | `modules/fazendas/admin/DashAtivos.tsx:22` | → detalhe de ativo |
| item de cotação (`<li>`) | `modules/fazendas/admin/DashSuprimentos.tsx:44` | → detalhe de cotação |

### 1.2 Destinos enganosos (clica, mas cai no lugar errado)
| Elemento | Local | Hoje | Deveria |
|---|---|---|---|
| `Card` de produto | `modules/marketplace/screens/MarketplaceHome.tsx:131` | vai a `/marketplace/pedidos` (EmptyState) | PDP do produto |
| `Card` de linha de crédito | `modules/credito/screens/CreditoHome.tsx:148` | vai a `/credito/propostas` genérico | detalhe/simulação da linha |
| tab "Simular" | `modules/credito/CreditoModule.tsx:17` | redirect à home sem rolar | anchor/scroll ao simulador ou tela dedicada |

### 1.3 Saídas ausentes
| Elemento | Local | Falta |
|---|---|---|
| Onboarding | `shell/pages/Onboarding.tsx` | botão "voltar" ao Login (`SubPageHeader`) |

### 1.4 Abas de módulo-casca em `EmptyState`
Bank: `pagamentos`, `cartoes`, `mais` · Crédito: `mais` · Marketplace: `categorias`, `pedidos`, `mais`
· Armazém: `estoque`, `movimentacoes`, `mais` · Fazendas: `mais/sync` (fila de sincronização).

### 1.5 Dead code
- `modules/PlaceholderModule.tsx` — ramo inalcançável em `ShellLayout.tsx:105`.
- campo `placeholder: true` em `shell/moduleConfig.ts` (linhas ~142/156/169/182) — metadado nunca lido.

---

## 2. Esteira de desenvolvimento

Marcação `[x]` a cada etapa concluída, com o commit correspondente (Conventional Commits, Lei 4).
Um commit por unidade lógica. Push somente sob demanda.

### Fase A — Quick wins (elimina a sensação de "app quebrado")  ✅
Baixo esforço, alto impacto. Nenhuma tela nova de conteúdo — plugar navegação e reaproveitar estado.

- [x] **A1.** Fila de sincronização real (`/fazendas/mais/sync`) consumindo `fazendasStore.syncQueue`
  (estado já existe) — substituir `EmSection` por lista de itens com status. — `9d56023`
- [x] **A2.** Deep-link de notificação: `onClick` no item de `Notificacoes.tsx` navegando ao `moduleId`
  de origem. — `2a825ea`
- [x] **A3.** Back no Onboarding: `IconButton` de voltar rumo ao Login (SubPageHeader destoaria do
  layout full-bleed). — `d572084`
- [x] **A4.** "Mais" decente nos 4 módulos-casca: padrão do `MaisScreen` de Fazendas + rotas
  auxiliares (pix, limites, contratos, favoritos, unidades, relatórios, ajuda). — `2f58d16`
- [x] **A5.** Destinos enganosos: `Simular` rola ao simulador (`scrollToSimulador`); cards de produto
  e de linha de crédito abrem `BottomSheet` honesto com dados do mock. — `772d226`
- [x] **A6.** Limpeza de dead code: `PlaceholderModule` deletado, fallback `Navigate /inicio`,
  campo `placeholder` removido do `ModuleDef`. — `b54878c`

### Fase B — Telas de detalhe reaproveitáveis (maior alavancagem)  ✅
Cada uma destrava vários becos de uma vez.

- [x] **B1.** **Detalhe de Atividade** — `ActivityDetailSheet` reutilizando `KIND_ICON`/`STATUS_META`
  da lista (Lei 2); `onClick` nos 3 pontos de uso (FazendasHome, AtividadesScreen, DashPecuaria). — `5db1c10`
- [x] **B2.** **Detalhe de Transação** — `TransactionDetailSheet` no catálogo `ui/` (comprovante com
  direção acessível, `tabular-nums`, prop `hidden` p/ `balanceHidden`, ID de operação com copiar);
  `onClick` nos 4 pontos de uso (HubHome, Carteira, BankHome, Extrato). — `291e99c`

### Fase C — Módulo Bank (o placeholder mais "pisado")  ⬜
`Bank › Pagamentos` recebe o tráfego de 8 `QuickAction` (Pix/Pagar/Transferir/Cobrar).

- [ ] **C1.** **Bank › Pagamentos** — hub de Pix/pagar/transferir/cobrar (mock navegável). `feat: bank pagamentos`
- [ ] **C2.** **Bank › Cartões** — gestão do cartão; tornar o card "Meu cartão" da Home clicável para cá.
  `feat: bank cartoes`

### Fase D — Marketplace, Armazém, Crédito e detalhes secundários  ⬜

- [ ] **D1.** **Marketplace › PDP** (página de produto) + **Categorias** + **Pedidos**. `feat: marketplace pdp e abas`
- [ ] **D2.** **Armazém › Estoque** + **Movimentações** + detalhe de unidade/movimentação. `feat: armazem estoque e movimentacoes`
- [ ] **D3.** **Crédito › Detalhe de Linha** + **Detalhe de Proposta** + `Simular` real. `feat: credito detalhes`
- [ ] **D4.** **Detalhe de Ativo** e **Detalhe de Cotação** (dashboards Fazendas). `feat: detalhes de ativo e cotacao`

### Fase E — Fechamento  ⬜
- [ ] **E1.** Varredura final de navegabilidade: nenhum elemento com aparência clicável sem destino.
- [ ] **E2.** Verificação visual em tema `light` e `gbMode` das telas novas.
- [ ] **E3.** Atualizar `ROADMAP.md` (Fase 8 — Navegabilidade) e este plano com os commits.

---

## 3. Ordem de execução recomendada

```
Fase A (quick wins)  →  Fase B (detalhes reaproveitáveis)  →  Fase C (Bank)  →  Fase D  →  Fase E
```

Fase A e B juntas eliminam **todos** os becos-sem-saída da seção 1.1/1.3 e ~7 pontos de uso de uma vez.
Fases C/D preenchem as abas-casca (seção 1.4) e destinos enganosos (1.2).

## 4. Fora de escopo deste plano
- Integração com backend / API real (mocks permanecem).
- Sincronização offline real (uuid↔id, persistência, retry) — a tela A1 apenas *exibe* a fila mockada.
- Fiscal, RBAC, captura por hardware — dependem de decisão de arquitetura (ver backlog do MVP).
