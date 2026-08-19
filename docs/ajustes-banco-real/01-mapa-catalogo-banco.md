# Mapa campo a campo — catálogo funcional Flutter × dump Postgres `gbcerne`

> Documento de apoio à decisão de integração. Compara cada `FeatureField` definido em
> `apps/mobile/lib/modules/fazendas/functional_catalog.dart` com as colunas reais do dump
> `init_db.sql` (schema `gbcerne`, 415 tabelas, fornecido em `init_db.zip` em 18/08/2026).
> Não altera código; é insumo para decidir o que troca de mock para dado real.

## Metodologia

1. Extraí as 415 `CREATE TABLE` do dump e a contagem de linhas de cada `COPY` (proxy de
   volume real de dados).
2. Parseei os 54 `FeatureDefinition` do catálogo Dart (12 administração + 41 operacional +
   1 duplicidade de id entre `areas` administrativo e `cadastrar-area` operacional, que
   compartilham a mesma fonte de dados via `dataSourceId`).
3. Para cada `FeatureField`, procurei a coluna equivalente por nome/semântica nas tabelas
   candidatas da mesma funcionalidade.
4. Classifiquei cada campo:
   - ✅ **Direto** — existe coluna equivalente com dado populado.
   - 🟡 **Indireto/derivado** — existe mas via FK para tabela de domínio, enum numérico sem
     dicionário no dump, ou cálculo (ex.: percentual não armazenado, só quantidade).
   - ❌ **Ausente** — não há coluna equivalente; a tela continuaria em mock ou exigiria novo
     campo/tabela.
5. Campos de fluxo controlado por hardware (`FeatureStatus.hardware`) não são reavaliados
   campo a campo — permanecem simulados por regra do protótipo (`CLAUDE.md`), independente
   do dump.

Convenção de tabela: **Campo Dart** | **Coluna(s) candidatas no dump** | **Situação** | **Nota**

---

## Administração (12)

Funcionalidades administrativas são paineis/consultas agregadas, não formulários — a
checagem aqui é por **tabela-fonte**, não por `FeatureField` (o catálogo não define campos
para elas).

| Funcionalidade | Tabela(s)-fonte | Situação | Nota |
|---|---|---|---|
| Financeiro e operacional | `financial_categories`(60.491), `expenses`(205.164), `incomes`(33.492), `balances`(30.611), `cash_books`(32), `cost_centers`(2.294), `budgets`(209) | ✅ | Volume real robusto para consolidar por período/centro de custo. |
| Dashboard pecuário | `animals`(146.496), `batches`(1.295), `stocks`(31.063) | ✅ | |
| Lotação de currais | `feedlot_corrals`(39), `feedlot_corral_batches`(9), `feedlot_yards`(5), `feedlot_sectors`(6) | 🟡 | Estrutura completa (pátio→setor→rua→curral), mas só 1 confinamento populado — suficiente para demo, raso para produção. |
| Ativos e depreciação | `equipments`(4.888), `depreciations`(99.199) | ✅ | `equipments` já traz `vl_acquisition`, `vl_depreciated`, `vl_residual`, `depreciation_type`. |
| Suprimentos | `request_quotations`(16.863), `request_purchases`(19.744), `providers`(21.868) | 🟡 | `quotations` (cotação de preço de mercado) está **vazia** — se o painel comparar cotação de mercado, falta dado; se comparar cotações de fornecedor (`request_quotations`), está ok. |
| Análise de uso | `user_activities`(144.832), `users`(1.333), `farm_user`(2.856) | ✅ | |
| Consultas gerenciais | agrega `batches`/`stocks`/`animal_weighings` | ✅ | Reaproveita fontes de Pecuária/Estoque. |
| Áreas cadastradas | `areas`(5.779) | ✅ | Mesma fonte do operacional `cadastrar-area`. |
| Saldo de estoque | `stocks`(31.063), `warehouses`(1.183) | ✅ | |
| Processamentos pecuários | `processings`(587) | ✅ | Tem `is_stock`, `status`, `arroba_value` — cobre "Pendentes/Concluídos". |
| Exportar log de estoque | `audits`(1.833.695), filtrado por entidade de estoque | ✅ | Volume altíssimo, cobre auditoria real. |
| Exportar log da pecuária | `audits`(1.833.695), filtrado por entidade pecuária | ✅ | |

---

## Operacional — Cadastros

### `cadastrar-area` — Áreas

Tabela: `gbcerne.areas`

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| nome | `description` | ✅ | |
| tipo | `type` (smallint) | 🟡 | Enum numérico sem tabela de domínio no dump — precisa descobrir de-para (provavelmente 1=Produtiva/2=Reserva etc. via código-fonte legado). |
| area-total | `total_area` | ✅ | |
| unidade | — | ❌ | Não existe seletor de unidade; `total_area` é sempre a mesma unidade (ha) no legado. |
| localizacao | `coordinates`, `kml` | 🟡 | Existe geodado (texto/KML), não um campo "localização" textual simples. |
| cultura | `activity_id` (FK) | 🟡 | Precisa join com tabela de atividades/cultivo; não é texto livre. |
| observacao | `note` | ✅ | |

---

## Operacional — Estoque

### `formulacoes` — Formulações

Tabelas: `diets` (cabeçalho) + `ingredients` (matéria-prima)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `diets.user_id` | ✅ | |
| ativo | — | ❌ | Não há flag "ativo" em `diets` (existe `is_enabled` em outras tabelas de domínio, não aqui). |
| produto | `diets.product_id` / `ingredients.product_id` | ✅ | |
| quantidade | `diets.quantity` / `ingredients.quantity` | ✅ | |
| unidade | `measurement_id` (FK) | ✅ | |
| tipo | `diets.objective`, `diets.type` | ✅ | |
| materia-prima | `ingredients.product_id` | ✅ | |
| porcentagem | — | 🟡 | `ingredients.dry_matter` é % de matéria seca, não % de participação na formulação; participação teria que ser calculada (`quantity` / soma). |

### `batidas` — Batida

Tabelas: `diet_beats` (1 linha!) + `item_diet_beats` (3 linhas) + `food_beats` (682 linhas)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `diet_beats.user_id` | ✅ | |
| tipo | `item_diet_beats.type` | ✅ | |
| armazem | — | ❌ | `item_diet_beats`/`diet_beats` não têm `warehouse_id` direto (só `stock_id`, que referencia estoque específico, não o armazém em si — precisa join `stocks.warehouse_id`). |
| produto | `item_diet_beats.product_id` | ✅ | |
| quantidade | `item_diet_beats.quantity` / `quantity_realized` | ✅ | Inclusive já separa previsto × realizado. |
| unidade | `item_diet_beats.measurement_id` | ✅ | |

⚠️ **Prioridade de gap real**: `diet_beats` tem 1 linha e `item_diet_beats` tem 3 — o dump praticamente não usou esse fluxo. Estrutura pronta, dado insuficiente para popular a tela com histórico relevante.

---

## Operacional — Misturador

### `conexao-aparelhos` (hardware) — ⚪ fora de escopo, simulação obrigatória.

### `carga` — Carga

Tabelas candidatas: `input_entries` / `movement_purchases` (entrada de insumo no armazém)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `input_entries.user_id` | ✅ | |
| formulacao | — | 🟡 | `input_entries` é genérico (não amarra a uma dieta); teria que linkar por `movement_id`. |
| origem (armazém) | — | ❌ | Não há `warehouse_id` direto em `input_entries`; só via `movement_id` → outra tabela. |
| equipamento | — | ❌ | Sem FK de equipamento/misturador em `input_entries`. |
| quantidade | `input_entries.total_amount` | 🟡 | É valor monetário total, não quantidade física — não corresponde 1:1. |
| unidade | — | ❌ | Ausente. |

⚠️ Este é o gap mais claro do grupo Misturador: o dump modela "carga" como lançamento de entrada de insumo genérico, não como operação de carregamento de misturador vinculada a equipamento.

### `descarga` — Descarga

Tabela candidata: `stock_writeoffs`

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `stock_writeoffs.user_id`/`employee_id` | ✅ | |
| produto | — | 🟡 | Baixa é por `warehouse_id` + `type`, produto individual fica no item relacionado (não capturado nesta tabela-cabeçalho). |
| destino | `stock_writeoffs.center_id` | 🟡 | É centro de custo, não "área/cocho". |
| equipamento | — | ❌ | Sem FK de equipamento. |
| quantidade | — | ❌ | Fica no item relacionado, não no cabeçalho. |
| unidade | — | ❌ | Idem. |

### `balanca` (hardware) — ⚪ simulação obrigatória; porém `module_weighings` (2.497 linhas, com `gross_weight`/`tare_weight`/`final_weight`) já modela o **resultado pós-captura** com dado real, caso a tela queira mostrar histórico de pesagens do misturador sem simular a captura em si.

### `nota-cocho` — Nota de cocho

Tabelas: `troughs`(608) / `area_trough`(0) / `troughs_area`(0)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | — | ❌ | `troughs` não tem `user_id`/`employee_id`. |
| data | — | ❌ | `troughs` não tem data de evento (só `created_at`). |
| lote / curral | `troughs.area_id`, `item_nutritions.trough_id`/`feedlot_corral_id` | 🟡 | Vínculo existe via `item_nutritions`, não direto em `troughs`. |
| nota | — | ❌ | Não há campo de classificação/nota de cocho. |
| observacao | — | ❌ | Ausente. |

⚠️ **Gap real**: as tabelas de vínculo área↔cocho (`area_trough`, `troughs_area`) estão **vazias**. "Nota de cocho" como conceito de avaliação/observação de consumo não tem representação direta no schema — provável que essa tela continue como mock/heurística de frontend.

### `configuracoes-misturador` — Configurações

Tabela candidata: `diets` (parcial, via `type`/`objective`) — **sem tabela dedicada a "configuração de tolerância/alerta sonoro do misturador"**.

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | — | ❌ | |
| nome | — | ❌ | |
| unidade | `measurement_id` (genérico, não específico de config) | 🟡 | |
| tolerancia | — | ❌ | Não existe no schema. |
| alerta | — | ❌ | Não existe no schema. |

⚠️ Esta tela é 100% configuração local de UI/hardware — não há e provavelmente não deveria haver tabela no ERP para isso. Permanece mock por natureza, não por lacuna de dado.

---

## Operacional — Agricultura

### `apontamento` — Apontamento agrícola

Tabelas: `planning_activities`(29) + `operation_activities`(729.730, mas é tabela de associação simples)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | — | ❌ | Nem `planning_activities` nem `operation_activities` têm `user_id`/`employee_id` — provavelmente está em `service_orders` (que tem `user_id`, `executor_id`) para o apontamento real de execução. |
| area | `service_orders.area_id` | ✅ | Via `service_orders`, não via `planning_activities`. |
| operacao | `operation_id` | ✅ | |
| atividade | `activity_id` | ✅ | |
| area-total / area-utilizada | — | 🟡 | `areas.total_area` existe; "área utilizada" no apontamento pontual não tem coluna própria. |
| armazem-insumo / armazem-producao | `pastures.inputs_warehouse_id` / `productions_warehouse_id` (padrão similar em outras tabelas de operação) | ✅ | Padrão existe em `pastures`; para agricultura de lavoura teria equivalente em `production_cycles`/`planning_cultivations` (não inspecionado em detalhe). |

⚠️ Recomendo trocar a tabela-fonte primária desta tela de `planning_activities` para `service_orders`, que é onde o dump de fato guarda responsável, execução e resultado.

### `marcacao` — Marcação

Tabelas: `markings`(4.498) + `marking_dones`(1.077) + `marking_forecasts`(2.358) + `markers`(20)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `markings.employee_id`/`user_id` | ✅ | |
| area | `markings.area_id` | ✅ | |
| tipo | `markers.type`, `markings.color` | ✅ | |
| descricao | `markers.description` | ✅ | |
| referencia | — | 🟡 | Não há campo de "referência de localização" livre; teria que compor a partir de `area_id`. |

Boa cobertura — inclusive com sub-registro de previsão (`marking_forecasts`) e realizado (`marking_dones`), mais rico que o mock atual.

### `colheita-frutas` — Colheita de frutas

Tabelas: `harvest_products`(1) + `harvest_product_boxes`(1)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| placa | `harvest_products.plate` | ✅ | |
| motorista | `harvest_products.driver_name` | ✅ | |
| cpf | `harvest_products.driver_nif` | ✅ | |
| caixas (kg) | `harvest_product_boxes` (1 linha) | 🔴 | Estrutura pronta e nomes de campo batem quase perfeitamente, **mas o dump tem só 1 registro em cada tabela** — dado insuficiente para popular a tela com histórico. |

---

## Operacional — Pecuária

### `rebanho-inicial` — Rebanho inicial

Tabela: `animals` + `inventoried_animals`(0)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | — | ❌ | `animals` não guarda responsável de entrada inicial diretamente (via `movement_purchases.employee_id` se for compra, mas "rebanho inicial" é lançamento avulso). |
| data | `animals.entry_date` | ✅ | |
| especie | `animals.specie_id` | ✅ | |
| categoria | `animals.category_id` | ✅ | |
| quantidade | `animals.quantity` | ✅ | |
| area | — | 🟡 | Não direto em `animals`; via `batch_animals`/`transfer_animal_farms`. |
| peso-medio | `animals.weight` | ✅ | |

`inventoried_animals` (inventário formal) está **vazia** — se a tela pretende ser um "inventário de abertura" formal, falta dado; se for só carga inicial de animais, `animals` cobre bem.

### `lote-animais` — Lote de animais

Tabela: `batches` + `batch_category_animal`

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `batches.employee_id`/`user_id` | ✅ | |
| especie | `batches.specie_id` | ✅ | |
| descricao | `batches.description` | ✅ | |
| categoria | `batch_category_animal.category_animal_id` | ✅ | |

Cobertura completa.

### `registrar-animal` — Registrar animal

Tabela: `animals`

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| categoria | `category_id` | ✅ | |
| raca | `breed_id` | ✅ | |
| nascimento | `birth_date` | ✅ | |
| peso | `weight` | ✅ | |
| preco-kg | `price_kilo_alive` | ✅ | |

Cobertura completa — inclusive `animals` tem colunas extras de valorização (`value_unitary`, `value_average`, `vl_acquisition`) não usadas hoje pelo Dart, que poderiam enriquecer a tela.

### `pesagem` — Pesagens (sem campos declarados no catálogo; tela dedicada em `/fazendas/campo/pesagem`)

Tabelas: `animal_weighings`(53.964) + `weighings`(1.745) + `module_weighings`(2.497)

Status: ✅ — maior massa de dado real do domínio pecuário; inclusive já separa peso anterior/atual (`last_weight`/`weight`) por evento.

### `transferencia-animal` (hardware — captura RFID) + campos de destino

Tabela: `transfer_animal_farms`

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| identificacao | — | ⚪ | Depende da captura RFID simulada. |
| responsavel | `employee_id`/`user_id` | ✅ | |
| lote-atual | — | ❌ | `transfer_animal_farms` é transferência **entre fazendas**, não entre lotes — para "lote atual/novo lote" o equivalente correto é `transfer_batch_farms`/`batch_animals`. |
| novo-lote | `transfer_batch_farms.batch_id` | ✅ | Via tabela correta. |

⚠️ Atenção: o nome da funcionalidade sugere troca de lote, mas a tabela mais próxima por nome (`transfer_animal_farms`) é troca de fazenda. A tabela correta para "novo lote" é `transfer_batch_farms`. Vale revisar o `dataSourceId` quando for integrar.

### `scanner-sisbov` (hardware) — ⚪; dado de resultado em `id_animals`(8) / `animal_id_animal`(174.362) já existe caso quisesse mostrar histórico de identificações sem simular o scanner.

### `transferencia-lote-area` — Transferência lote/área

Tabela: `transfer_batch_grazing_areas`(991) + `batch_grazing`(160)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `employee_id`/`user_id` | ✅ | |
| lote | `batch_id` | ✅ | |
| local-atual | `area_old_id`/`grazign_old_id` | ✅ | |
| area (nova) | `area_next_id` | ✅ | |
| modulo (novo) | `grazign_next_id`/`feedlot_corral_next_id` | ✅ | |

Cobertura completa, inclusive com histórico de curral (confinamento) além de pasto.

### `nascimentos` / `mortes` (sem campos declarados — usam rota dedicada `/fazendas/campo/ciclo`)

- Nascimentos → `birth_animals`(4.622) + `birth_notes`(8) + `birth_animal_id_animal`(5.089): ✅ volume bom.
- Mortes → `death_animals`(320) + `death_losses`(46 causas): ✅.

### `perdas` (hardware) — campos de contexto

Tabela: `loss_animals`(26)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| identificacao | ⚪ RFID simulado | — | |
| responsavel | precisa checar `loss_animals` (não extraída em detalhe) | 🟡 | |
| data | idem | 🟡 | |
| lote | idem | 🟡 | |
| causa | `death_losses`/similar dicionário de causa | ✅ | |
| observacao | idem | 🟡 | |

Volume baixo (26 linhas) — suficiente para smoke, raso para demonstrar histórico rico.

### `compras-animais` — Compra de animais

Tabela: `movement_purchases`(438) + `item_movement_purchases`(520)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `movement_purchases.employee_id`/`user_id` | ✅ | |
| fornecedor | `provider_id` | ✅ | |
| data | `dt_sale` (nome de coluna herdado, é a data da operação) | ✅ | |
| especie | `item_movement_purchases` não tem specie_id direto | 🟡 | Via `category_id`/`animal_id` → `animals.specie_id`. |
| categoria | `item_movement_purchases.category_id` | ✅ | |
| quantidade | `item_movement_purchases.quantity` | ✅ | |
| valor-total | `movement_purchases.total` | ✅ | |
| documento | `movement_purchases.code`/`chave`/`number` | ✅ | |

### `vendas` (sem campos — rota `/fazendas/campo/venda`)

`sales`(1.262) + `sale_items`(2.070) + `movement_sales`(466) + `sale_contracts`(36): ✅ — o mais completo do domínio comercial, com NFe (`nfe_id`, `chave`), contrato e item.

### `nutricoes` (sem campos — rota `/fazendas/campo/arracoamento`)

`nutritions`(2.133) + `item_nutritions`(6.011) + `nutrition_employee`(326): ✅.

### `sanitario` — Sanitário

Tabela: `sanitaries`(248) + `sanitary_animals`(9.413) + `item_sanitaries`(438) + `vaccines`(10)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `sanitaries` não tem employee_id direto (checar; provável estar em `item_sanitaries` ou herdado de `batch_id`) | 🟡 | |
| lote | `sanitaries.batch_id` | ✅ | |
| data | `sanitaries.date` | ✅ | |
| tipo | `item_sanitaries` + `item_sanitary_vaccines`(1 linha!) | 🟡 | Vacina como tipo específico está quase vazia — reforça uso de "tipo" genérico via `item_sanitaries.product_id`. |
| produto | `item_sanitaries.product_id` | ✅ | |
| observacao | `item_sanitaries.note_item` | ✅ | |

### `desmama` — Desmama

Tabela: `weanings`(54) + `animals_weanings`(776)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `weanings.employee_id`/`user_id` | ✅ | |
| tipo | `weanings.type` | ✅ | |
| lote | `weanings.batch_id` | ✅ | |
| identificacao (vacas paridas) | `animals_weanings.birth_animal_id` | ✅ | |

### `apartacao` — Apartação

Tabela: `batches_separations`(53) + `separations`(42)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `separations.employee_id`/`user_id` | ✅ | |
| data | `separations.date` | ✅ | |
| lote-origem | `batches_separations.batch_id` | ✅ | |
| criterio | — | ❌ | Não existe coluna de critério de apartação — só o vínculo lote↔separação, sem o motivo/regra. |
| lote-destino | — | 🟡 | Modelo não deixa explícito "lote destino" separado de "lote origem" — pode exigir segunda linha em `batches_separations`. |
| quantidade | — | ❌ | Não há contagem na própria tabela; teria que contar via `batch_animals`. |

### `localizar-animal` (hardware) — dado de apoio em `traceabilities`(2.110)/`traceability_galeries`(1.957): ⚪ simulação de captura, mas rastreio de origem já tem massa real caso vire tela de consulta.

### `pastagens` — Pastagens

Tabela: `pastures`(362) + `grazings`(424) + `grazing_areas`(840) + `pasture_inputs`(288)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `pastures.employee_id`/`user_id` | ✅ | |
| armazem-insumos | `pastures.inputs_warehouse_id` | ✅ | |
| armazem-producao | `pastures.productions_warehouse_id` | ✅ | |

Cobertura completa, com bom volume auxiliar (`pasture_inputs`, `pasture_services`, `pasture_occurrences`).

---

## Operacional — Reprodução

### `estacao-monta` — Estação de monta

Tabela: `breeding_seasons`(48)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `employee_id`/`user_id` | ✅ | |
| nome | `description` | ✅ | |
| inicio / fim | `start_date`/`end_date` | ✅ | |
| metodo | — | ❌ | Não há coluna de método principal (IATF, monta natural, etc.) na própria estação — método fica implícito no tipo de `breeding_matings`. |
| observacao | — | ❌ | Ausente. |

### `lotes-reproducao` — Lotes/reprodução

Tabela: `breeding_batch`(59) + `batch_breeding_batch`(64)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `breeding_batch.employee_id`/`user_id` | ✅ | |
| estacao | `breeding_batch.breeding_season_id` | ✅ | |
| lote | `batch_breeding_batch.batch_id` | ✅ | |
| finalidade | — | ❌ | Sem coluna de finalidade — só `description` livre. |
| quantidade | — | 🟡 | Via contagem de `batch_animals` do lote vinculado, não coluna própria. |

### `material-reprodutivo` — Touros/sêmen/embrião

Tabela: `bull_seed_season`(27) + `bull_seed_season_product`(51) + `animal_bull_seed_season`(19)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `bull_seed_season.employee_id`/`user_id` | ✅ | |
| tipo | — | 🟡 | Tipo (sêmen/embrião/touro) não é coluna explícita — inferido pela tabela de origem (`animal_bull_seed_season` = touro vivo vs. `bull_seed_season_product` = sêmen/produto). |
| identificacao | `bull_seed_season.code` | ✅ | |
| raca | — | ❌ | Não está na tabela de estação — vem de `animals.breed_id` se for touro vivo. |
| fornecedor | — | ❌ | Ausente nesta tabela (existiria em `providers` se for produto comprado). |
| quantidade | `bull_seed_season_product.quantity` | ✅ | |

### `protocolos-estacao` — Protocolos/estação

Tabela: `protocols_season`(41) + `mating_protocol_animals`(3.146) + `mating_protocol_animal_products`(6.687)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `protocols_season.employee_id`/`user_id` | ✅ | |
| nome | `protocols_season.name` | ✅ | |
| estacao | `breeding_season_id` | ✅ | |
| tipo | — | 🟡 | Sem coluna de tipo explícita em `protocols_season` (`description` livre). |
| inicio | `protocols_season.date` | ✅ | |

Bom volume auxiliar (`mating_protocol_animals` 3.146 linhas).

### `monta-natural` — Monta natural

Tabela: `breeding_matings`(35) + `breeding_mating_cows`(70) + `breeding_mating_bulls`(3)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `breeding_matings.employee_id`/`user_id` | ✅ | |
| data | `breeding_matings.date` | ✅ | |
| lote | `breeding_matings.breeding_batch_id` | ✅ | |
| touro | `breeding_mating_bulls.animal_id` | ✅ | |
| quantidade | — | 🟡 | Via contagem de `breeding_mating_cows` vinculadas, não coluna própria. |
| observacao | — | ❌ | Ausente. |

`breeding_mating_bulls` com só 3 linhas — dado raso para "monta natural" especificamente (o grosso de 35 `breeding_matings` provavelmente é IATF via `type`).

### `diagnostico-gestacao` — Diagnóstico de gestação

Tabela: `pregnancy_diagnosis`(26) + `pregnancy_diagnosis_animals`(477) + `diagnostic_techniques`(2) + `ultrasounds`(0)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `pregnancy_diagnosis.employee_id`/`user_id` | ✅ | |
| data | `pregnancy_diagnosis.date` | ✅ | |
| lote | `pregnancy_diagnosis_animals.batch_id` | ✅ | |
| resultado | — | 🟡 | Não achei coluna de resultado direto em `pregnancy_diagnosis_animals` — provável estar em `diagnosis_pregnancies` (dicionário, 3 linhas) como categoria, não valor por animal. |
| quantidade | — | 🟡 | Via contagem de `pregnancy_diagnosis_animals`. |
| veterinario | `pregnancy_diagnosis_animals.provider_id` | ✅ | |

`ultrasounds` **vazia** — se a tela depende de imagem/laudo de ultrassom, falta dado.

---

## Operacional — Gestão de frota

### `abastecimentos` — Abastecimentos

Tabela: `appropriation_supply`(16.226) + `supply_status_slas`(187)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `responsible_id` | ✅ | |
| data | — | 🟡 | Não há `date` direta em `appropriation_supply` — herda da `appropriation` pai (`appropriation_id`), não inspecionada em detalhe. |
| veiculo | `equipment_id` | ✅ | |
| combustivel | `product_id` | ✅ | |
| quantidade | `quantity` | ✅ | |
| medidor (hodômetro/horômetro) | `hour_meter`, `mileage` | ✅ | |
| origem | `warehouse_id` | ✅ | |

Ótima cobertura e maior volume do grupo (16.226 linhas reais).

### `manutencao-frota` — Manutenção

Tabela: `appropriation_maintenance`(7.538) + `appropriation_maintenance_preventive`(80)

| Campo Dart | Coluna candidata | Situação | Nota |
|---|---|---|---|
| responsavel | `employee_id` | ✅ | |
| equipamento | `equipment_id` | ✅ | |
| tipo | — | 🟡 | Corretiva vs. preventiva é implícito por estar em uma tabela ou outra, não coluna `type`. |
| descricao (serviço) | `note` | ✅ | |
| data prevista | — | ❌ | `appropriation_maintenance` não tem data própria (herda de `appropriation`). |
| oficina | `provider_id` | ✅ | |
| custo | `amount`/`total_amount` | ✅ | |
| observacao | `note` | ✅ | |

---

## Operacional — Ordem de serviço

### `minhas-os` — Minhas OS (sem campos declarados no catálogo)

Tabela: `service_orders`(15) + `equipment_service_order`(5) + `product_service_order`(5) + `employee_service_order`(11) + `production_service_order`(0) + `protection_service_order`(1)

Status: 🟡 — schema é o mais rico do dump para esta funcionalidade (`service_orders` tem 30+
colunas: prazo, clima mínimo/máximo, critério de sucesso, avaliação, feedback), **mas o
volume real é baixíssimo (15 OS)** e duas subtabelas estão vazias/quase vazias
(`production_service_order`=0, `protection_service_order`=1). Estrutura pronta, dado
insuficiente para popular uma lista "Minhas OS" com histórico convincente.

---

## Operacional — Sincronização

### `sincronizacao` — Sincronização de dados

⚪ Não há e não deveria haver tabela — é estado de sincronização do app (frontend), sem
contrapartida no ERP.

---

## Resumo executivo — prioridades de decisão

### Pode trocar mock → dado real com confiança alta (schema + volume batem)
Financeiro, Dashboard pecuário, Ativos, Análise de uso, Saldo de estoque, Processamentos,
logs de auditoria, Áreas, Lote de animais, Registrar animal, Pesagens, Transferência
lote/área, Nascimentos, Mortes, Compra de animais, Vendas, Nutrições, Desmama, Pastagens,
Marcação, Protocolos/estação, Abastecimentos, Manutenção de frota.

### Precisa de decisão de produto antes de integrar (schema ambíguo ou incompleto)
- **Carga/Descarga (misturador)**: o dump não modela "carga de misturador" como conceito
  próprio — é preciso decidir se reaproveita `input_entries`/`stock_writeoffs` genéricos ou
  se o backend real (fora deste dump) terá tabela dedicada.
- **Nota de cocho**: vínculo área↔cocho vazio; conceito de "nota" não existe no schema.
- **Configurações do misturador**: tolerância/alerta são puramente locais — não pertence ao
  banco.
- **Apartação**: falta critério e lote-destino explícitos.
- **Estação de monta / Lotes-reprodução / Material reprodutivo**: faltam campos de método,
  finalidade, raça e fornecedor — hoje "escondidos" em joins não triviais.
- **Transferência animal (hardware)**: o `dataSourceId` correto para "novo lote" é
  `transfer_batch_farms`, não `transfer_animal_farms` (que é entre fazendas) — checar antes
  de ligar o fio.

### Estrutura pronta, mas dado real insuficiente para demo (populado com poucas linhas)
Colheita de frutas (1 linha), Batida do misturador (1–3 linhas), Minhas OS (15), Monta
natural (35 monta / 3 touros), Diagnóstico de gestação (ultrassom = 0), Lotação de currais
(1 confinamento só), Suprimentos (cotações de mercado = 0).

### Permanece mock/simulado independentemente do dump
Todas as `FeatureStatus.hardware` (Bluetooth, balança, RFID, scanner) — regra de produto,
não lacuna de dado. Sincronização de dados (conceito de frontend).

---

## Arquivos de apoio gerados nesta análise (fora do repositório, scratchpad da sessão)

- `schema_only.sql` — todas as 415 `CREATE TABLE` extraídas do dump.
- `row_counts.txt` — contagem de linhas por tabela (proxy de volume real).
- `parsed_features.txt` — catálogo Dart parseado (perfil, grupo, status, campos).

Esses três arquivos não foram commitados; recomendo gerá-los novamente sob demanda a partir
de `init_db.sql` caso outra sessão precise revalidar (o dump em si tem 2 GB e não deve ir
para o repositório Git).
