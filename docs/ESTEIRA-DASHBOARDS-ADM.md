# Esteira — Dashboards administrativos (auditoria de decisão + UI)

Referências: `apps/mobile/lib/modules/fazendas/admin/` (7 telas), catálogo em
`functional_catalog.dart` (15 funcionalidades administrativas), `apps/mobile/lib/ui/` (catálogo de
componentes) e a fronteira já fechada em `docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md`.

## Objetivo

O app mobile é **executor**; o ADM no mobile é **leitor de decisão**. Um painel administrativo só se
justifica se responde a uma pergunta que muda uma decisão: *libero o curral? aprovo a cotação? cobro
o atraso? troco a dieta? paro a máquina?* Tela que apenas espelha uma lista não é dashboard — é
consulta, e deve ser tratada como tal.

Esta esteira aplica esse teste às 7 telas de `admin/` e define a Home ADM como torre de controle.

---

## 1. Estado atual — o que cada tela realmente entrega

| Tela | Rota | KPIs | Gráficos | Natureza real |
|---|---|---|---|---|
| Financeiro | `dashboards/financeiro` | 4 | 1 barra | Dashboard raso (62 linhas) |
| Pecuária de Corte | `dashboards/pecuaria` | 3 + 2 desativados | 3 sparklines | **Casca** — bloco produtivo desligado |
| Confinamento | `dashboards/confinamento` | 4 | **0** | Dashboard rico (4 abas), mas sem gráfico |
| Ativos / Depreciação | `dashboards/ativos` | 3 | 0 (barras de progresso) | Lista com cabeçalho de KPI |
| Suprimentos | `dashboards/suprimentos` | **0** | 0 | **Lista filtrável**, não dashboard |
| Análise de Uso | `dashboards/uso` | **0** | 0 | **Lista expansível** de observabilidade |
| Consultas Gerenciais | `dashboards/consultas` | **0** | 0 | **Console de consulta** read-only |

### Achados que motivam a mudança

**A. Duplicação literal entre Home e Pecuária.** `screens/fazendas_home.dart` (`_HomeGerencial`)
exibe Receita `R$ 2,4 mi` / Custo `R$ 1,1 mi` / Margem `R$ 1,3 mi`, com deltas 12/-4/9 e as mesmas
sparklines de `pecuariaFinanceiro` em `mocks/dashboards_mocks.dart`. São os mesmos três números, com
os mesmos valores, em duas telas. Fere o espírito da Lei 2 (fonte única).

**B. Pecuária é uma casca.** Seu bloco financeiro é o item A; seu bloco produtivo/reprodutivo está
`disabled: true` com aviso de LACUNA; sobra uma lista de atividades que já existe em
`/fazendas/atividades`. A tela não tem conteúdo próprio.

**C. O bloco produtivo desativado já tem dado.** `confinamento/models.dart` calcula, por curral,
`gmdKg`, `gmdPrevistoKg`, `indicadorDesempenhoPct`, `pesoPrevistoPosConfinamentoKg`,
`diasConfinamento` e `diasRestantes`. O indicador que a Pecuária declara não ter existe — está no
submódulo ao lado.

**D. O catálogo de gráficos está ocioso.** Uso fora do próprio arquivo de definição:

| Componente | Usos em telas |
|---|---|
| `AppBarChart` | **1** (Financeiro) |
| `AppDonutChart` | **0** |
| `AppChartCard` | **1** |
| `AppSparklineArea` | 2 (ambos dentro de `AppDashboardCard`) |

Sete painéis administrativos sustentados por **um** gráfico.

**E. Não existe série temporal.** Nenhum componente do catálogo plota evolução no tempo com eixo.
`AppSparklineArea` é decorativa (36 px, sem eixo, sem escala). Para decisão administrativa — "o custo
está subindo há quantos meses?" — essa é a lacuna mais cara do catálogo.

**F. `AppBarChart` distorce valores pequenos.** Em `ui/bar_chart.dart` a barra aplica
`barWidthPct = pct < 14 ? 14 : pct`: qualquer valor abaixo de 14% do máximo é desenhado como 14%. Um
centro de custo de R$ 5 mil ganha quase a mesma barra de um de R$ 59 mil. É erro de integridade de
dado, não de estética, e precisa cair.

**G. Nenhum painel é responsivo.** `crossAxisCount` é fixo (2, 3 ou 4) e `childAspectRatio` é
constante. Com a entrada do desktop (`shell/pages/android_home_page.dart` e `crn_app_folder_page.dart`,
commit 983a333), os painéis seguem em duas colunas numa viewport larga, e o `childAspectRatio` fixo
estoura com escala de texto grande.

**H. `chartSeries` não é temático.** `design/generated/app_colors.dart` traz 8 cores fixas fora do par
claro/escuro — todas as demais cores do app passam por `AppSemanticColors`. Em tema escuro a série
mantém `#059669`/`#14532D`, que colidem com o fundo.

---

## 2. Decisão — 7 telas viram 5 painéis + 1 console

O corte segue as perguntas do administrador, não a organização do menu legado.

| # | Painel proposto | Origem | Pergunta que responde |
|---|---|---|---|
| D1 | **Resultado** | Financeiro ⊕ bloco financeiro da Pecuária | O ciclo está dando dinheiro? Onde vaza custo? O que está vencido? |
| D2 | **Rebanho & Confinamento** | Confinamento ⊕ bloco produtivo da Pecuária (agora com dado) | Quantas arrobas produzo, a que custo, e quando libero curral? |
| D3 | **Suprimentos** | Suprimentos, reestruturado | Aprovo esta cotação? Quanto economizei? Qual fornecedor está caro? |
| D4 | **Ativos & Manutenção** | Ativos, reestruturado | Qual máquina consome patrimônio e quando ela para? |
| D5 | **Adoção & Governança** | Uso ⊕ `exportar-log-estoque` ⊕ `exportar-log-pecuaria` | O app está sendo usado? Quem mexeu no quê? |
| — | **Consultas Gerenciais** | inalterada, reclassificada | Não é painel: é console de consulta read-only |

### Por que Financeiro + Pecuária viram um só (D1)

O próprio catálogo já chama `painel-financeiro` de *"Financeiro e operacional"*. Receita, custo e
margem são o mesmo P&L do bloco financeiro da Pecuária. Juntar elimina a duplicação (achado A),
esvazia a casca (achado B) e devolve à Home o papel de resumo, em vez de terceira cópia.

### Por que Pecuária não some, migra (D2)

O que a Pecuária prometia e não entregava — desempenho produtivo — passa a ser servido pelos
indicadores de Confinamento (achado C): GMD observado × previsto, desempenho %, curva de peso e
previsão de saída. O painel deixa de dizer "—" e passa a decidir liberação de curral.

### Por que Uso ganha as exportações (D5)

`exportar-log-estoque` e `exportar-log-pecuaria` existem no catálogo (`auditExport`) sem casa visual
própria. Adoção e auditoria são a mesma pergunta de governança; ficam sob o mesmo selo "Acesso
restrito" que a Análise de Uso já carrega.

### Por que Consultas sai da gaveta de dashboards

É 100% leitura, sem nenhum indicador e sem nenhuma ação — declarado no próprio cabeçalho da tela.
Mantê-la sob "Dashboards gerenciais" no `mais_screen.dart` ensina errado o que é painel.

**Nenhum painel novo é criado.** A resposta a "precisamos de mais um?" é não: o que falta não é tela,
é densidade de informação nas que já existem.

---

## 3. Home ADM — torre de controle

Hoje a Home gerencial é: título, 5 atalhos, banner de crédito, 3 cards duplicados e lista de
atividades. Passa a ser o melhor gráfico de cada painel, em ordem de urgência decrescente.

| Ordem | Bloco | Componente | Vem de | Toque leva a |
|---|---|---|---|---|
| 1 | Faixa de contexto | fazenda · safra · período | sessão | seletor |
| 2 | **Faixa de alertas** | chips acionáveis: vencidos, ocorrências abertas, currais > 90%, manutenção vencida | D1/D2/D4 | painel de origem, já filtrado |
| 3 | **Resultado — 6 meses** | `AppLineChart` (receita × custo, área de margem) | D1 | D1 |
| 4 | **Ocupação & GMD** | `AppGauge` de ocupação + GMD real × meta | D2 | D2 |
| 5 | **Despesa por centro de custo** | `AppBarChart` corrigido | D1 | D1 |
| 6 | **Patrimônio por categoria** | `AppDonutChart` (primeiro uso real) | D4 | D4 |
| 7 | **Economia em cotações** | `AppBulletChart` realizado × meta | D3 | D3 |
| 8 | **Adoção por fazenda** | barras compactas | D5 | D5 |
| 9 | Atividades recentes | lista existente | — | `/fazendas/atividades` |

Regra: **cada bloco da Home é o mesmo widget do painel de origem, com `compact: true`** — nunca uma
segunda implementação (Lei 2). Se o gráfico mudar no painel, muda na Home.

---

## 4. Lacunas de catálogo (Lei 1 — nascem em `lib/ui/`)

| Componente | Por que | Prioridade |
|---|---|---|
| `AppLineChart` | série temporal com eixo, grade e 2+ séries — achado E | **Alta** |
| `AppGauge` | ocupação %, GMD × meta, precisão de batelada | Alta |
| `AppChartCard` (extensão) | `period`, `footnote`, `compact`, `onExpand` — por props, não por cópia | Alta |
| `AppBulletChart` | realizado × meta num traço só (economia, GMD, precisão) | Média |
| `AppStackedBar` | composição de custo por período | Média |
| `AppChartLegend` | legenda reutilizável; hoje só o donut tem, embutida | Média |

Correções nos existentes:

- `AppBarChart`: remover o piso de 14% (achado F); grade, eixo de valor e rótulo fora da barra quando
  ela for curta demais para contê-lo.
- `AppDonutChart`: percentual na legenda e estado vazio.
- `AppSparklineArea`: permanece decorativa — documentar que não substitui `AppLineChart`.

Cada componente novo entra no barrel `ui.dart` **e** no `widgetbook_app.dart` na mesma unidade
lógica — o gate `component_first_test.dart` reprova exportação sem caso.

## 5. Tokens (Lei 5 — `design/tokens.ts` primeiro)

Adicionar em `design/tokens.ts` e regenerar DTCG + Dart na mesma unidade lógica:

- série de gráfico com par claro/escuro (achado H), consumida por `AppSemanticColors`;
- `chart.grid`, `chart.axis`, `chart.track` — hoje improvisados com `bgSubtle`/`borderDefault`;
- `chart.positive` / `chart.negative` semânticos para leitura financeira.

## 6. Responsividade

As grades dos painéis passam a derivar colunas da largura (`LayoutBuilder`), com `mainAxisExtent` em
vez de `childAspectRatio` fixo (achado G). Alvo: 2 colunas em telefone, 3 em tablet, 4 no desktop CRN
ADM — sem tela nova, mesmo widget.

---

## 7. Impacto de código

| Arquivo | Ação |
|---|---|
| `admin/dash_financeiro.dart` + `admin/dash_pecuaria.dart` | fundem em `admin/dash_resultado.dart` |
| `admin/dash_confinamento.dart` | ganha bloco de desempenho produtivo e gráficos |
| `admin/dash_suprimentos.dart`, `dash_ativos.dart`, `dash_uso.dart` | ganham topo de KPI + gráfico |
| `admin/admin_dashboard.dart` | switch de `dashId`, com alias das rotas antigas para não quebrar link |
| `router/app_router.dart` | rota de Consultas sai de `dashboards/` |
| `screens/mais_screen.dart` | grupos "Painéis de decisão" × "Consultas e auditoria" |
| `screens/fazendas_home.dart` | `_HomeGerencial` vira torre de controle |
| `functional_catalog.dart` | `painel-pecuario` funde em `painel-financeiro`; rotas atualizadas |
| `lib/ui/` + `widgetbook_app.dart` | 6 componentes (5 novos + extensão) e 3 correções |
| `design/tokens.ts` → DTCG → Dart | tokens de gráfico |
| `test/modules/fazendas/admin/` | `dash_financeiro_test` + `dash_pecuaria_test` → `dash_resultado_test` |
| `test/modules/fazendas/functional_catalog_test.dart` | contagens congeladas: 15 → 14 admin, 58 → 57 total |

Os números do catálogo são congelados de propósito; esta alteração é deliberada e fica registrada
aqui.
