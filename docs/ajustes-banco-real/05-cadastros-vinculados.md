# Onda 5 — Cadastros vinculados: o que o registro escolhido já responde

> Análise do dump `init_db.sql` (schema `gbcerne`, 415 tabelas, 1,9 GB) feita em
> 23/09/2026. Continua as ondas 1–4 (`00-ESTEIRA-AJUSTES-BANCO-REAL.md`,
> `04-apontamento-appropriations.md`).

## Problema

O protótipo pedia de novo dados que o sistema real já conhece. No Apontamento
agrícola, área total, área utilizada, cultura e safra eram digitadas à mão,
embora venham do **lote**. O mesmo acontecia com produto (unidade), item de
estoque (armazém), equipamento (medidor, leitura, custo) e mão de obra
(função e custo-hora).

## Evidência no dump

| Regra | Onde está no banco | Confirmação nos dados |
|---|---|---|
| Lote agrícola = ciclo de produção | `production_cycles` (`cultivation_id`, `harvest_id`, `center_id`) + `production_cycle_areas` → `areas` | 249 de 264 apontamentos com ciclo no talhão usam a cultura do ciclo |
| Área total do talhão | `areas.total_area` | — |
| Área utilizada sugerida | `appropriations.used_area` × `areas.productive_area` | `used_area` = área produtiva em 268 casos contra 62 = área total; 1.791 de 1.855 abaixo da área total (trabalho parcial é comum → campo continua editável) |
| Cultura → variedade | `cultivations.parent_id` | ex.: `SOJA VALENTE` → `SOJA`, `Milho DKB 358PRO4` → `Milho` |
| Operação → atividades | `operation_activities` | 1.854 de 1.855 apontamentos respeitam o par |
| Insumo: dose por hectare | `appropriation_stock.total_quantity` = `quantity` × `used_area`; `total_amount` = `amount` × `total_quantity` | amostras conferidas (0,5 × 61,44 ha = 30,72) |
| Insumo: custo do estoque | `appropriation_stock.amount` = `stocks.average_cost` | 3.227 de 6.267 (o restante é custo médio recalculado depois) |
| Insumo: armazém do estoque | `stocks.warehouse_id` | `appropriation_supply.warehouse_id` = `stocks.warehouse_id` em 15.519 de 15.522 |
| Máquina: quantidade = medidor | `appropriation_equipment.quantity` = `end_hour_meter` − `start_hour_meter` | 1.172 de 1.172 linhas com horímetro |
| Máquina: custo-hora | `amount` = `equipments.vl_time_productive` (ou da família) | 798 de 1.224 batem com o equipamento; 357 com a família |
| Veículo × máquina | `equipments.plate` | com placa → hodômetro; sem placa → horímetro |
| Combustível habitual | `appropriation_supply` por equipamento | 89% dos abastecimentos repetem o combustível do equipamento → **sugestão**, não trava |
| Mão de obra: custo-hora | `employees.vl_time_productive`, `functions.vl_time_productive`, `providers.hour_value` | 459 de 760 lançamentos por funcionário usam o custo do cadastro → **sugestão** |
| Unidade do produto | `products.measurement_id` | — |

Nenhum dado real saiu do dump: nomes, códigos e valores do protótipo são
fictícios; o dump informou apenas a **forma** dos cadastros e as regras.

## O que mudou

### Fonte única — `lib/modules/fazendas/cadastros_vinculados.dart`

Catálogos de opções e atributos moram juntos: `catalogoProdutos`,
`catalogoItensEstoque` e `catalogoEquipamentos` saíram de
`functional_catalog.dart` (que os reexporta) para ficar ao lado de
`unidadePorProduto`, `armazemPorItemEstoque`, `estoquesPorProduto`,
`combustivelPorEquipamento`, `horimetroAtualPorEquipamento`,
`cadastroLotesAgricolas`, `atividadesPorOperacao` e dos cadastros de
funcionário/função/prestador. `cadastros_vinculados_test.dart` garante que
nenhuma opção exista sem o cadastro que ela carrega.

### Motor genérico — duas extensões de `FeatureField`

- `derivedFrom: FeatureFieldDerivation(source, values, locked)` — ao mudar a
  fonte, o motor preenche o campo. `locked: true` (padrão) trava o controle
  (“Preenchido pelo cadastro de …”); `locked: false` é sugestão editável
  (“Sugerido pelo cadastro de … — ajuste se necessário”). Encadeia (veículo →
  combustível → unidade).
- `optionsFrom: FeatureOptionsFilter(source, options)` — restringe as opções
  pelo valor de outro campo e limpa o valor que deixou de ser válido.

| Funcionalidade | Derivações aplicadas |
|---|---|
| Abastecimentos (cabeçalho e itens) | veículo → combustível (sugestão), horímetro/hodômetro (sugestão); combustível → unidade (travada); só equipamentos motorizados |
| Manutenção (cabeçalho e itens) | equipamento → horímetro/hodômetro (sugestão); produto → unidade (travada), armazém e valor (sugestão) |
| Manejo sanitário — itens de estoque | produto → filtra itens de estoque, unidade (travada); estoque → armazém (travado) |
| Pastagens | equipamento → unidade (travada), horímetro inicial (sugestão); estoque filtrado pelo produto → unidade e armazém (travados); produção: produto → unidade (travada), armazém (sugestão) |
| Formulações / Batidas | produto/matéria-prima → unidade (travada), custo e armazém (sugestão) |
| Protocolos / Material reprodutivo / Monta natural | produto → unidade (travada) e armazém (sugestão); estoque → armazém e unidade (travados) |

### Apontamento agrícola (`ApontamentoFlow`)

- **Etapa 1**: “Área” solta vira **Lote** (busca) + **Talhão** (só os talhões do
  lote; lote de talhão único já seleciona). Atividade filtrada pela operação.
  Data usa `AppDateInput`.
- **Etapa 2**: cultura/variedade, safra, centro de custo e área total aparecem
  travados, vindos do lote/talhão. Área utilizada nasce com a área produtiva
  do talhão, editável, e não aceita valor acima da área total.
- **Insumos**: produto → item de estoque (só lotes daquele produto, com saldo e
  validade) → armazém e unidade travados; a pessoa informa só a **dose por
  hectare**; o formulário mostra quantidade total (dose × área utilizada) e
  custo estimado, e bloqueia quando o total passa do saldo.
- **Máquinas**: equipamento → medidor, custo por hora/km e leitura inicial;
  quantidade = leitura final − inicial (implemento sem medidor informa as
  horas); custo total calculado.
- **Mão de obra**: funcionário/função/prestador escolhidos do cadastro; a função
  do funcionário aparece travada; valor unitário sugerido pelo custo-hora (dia
  = 8 h), editável; total calculado.
- **Produção**: unidade travada pelo produto; produtividade (un/ha) calculada.

## Fora desta onda

- Validação de dose por ha contra a recomendação agronômica do produto (não há
  tabela de recomendação no dump).
- Derivar o centro de custo dos itens de manejo sanitário a partir do lote de
  animais (`category_animal_cost_centers`) — exige inspeção própria.
- Filtro de “Item de estoque” por armazém do cabeçalho no motor genérico
  (o apontamento dedicado já prioriza o armazém de insumo).

## Gates

`flutter analyze --fatal-infos` limpo; `quality:functional` verde (39); suíte
completa 457 verdes. As 2 falhas restantes (`button_golden_test.dart`,
variantes Windows/CI) já existem no `main` sem esta mudança — diferença de
renderização de fonte entre plataformas.
