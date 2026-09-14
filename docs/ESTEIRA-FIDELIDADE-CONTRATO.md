# Esteira — Fidelidade de contrato dos formulários (leva "fidelidade-contrato")

> Leia este arquivo antes de mexer em qualquer item desta leva e atualize-o no mesmo commit
> de cada onda concluída — mesmo padrão de continuidade de
> `docs/ESTEIRA-FIDELIDADE-CAMPOS.md` e `docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md`.

## Origem e objetivo

Esta leva nasce da auditoria **"Fidelidade de contrato dos formulários do protótipo"**
(14/09/2026, 53 agentes paralelos): as 53 funcionalidades do catálogo, uma a uma, contra o
`rules()` real da API (`GB.Cerne.Api/app/Http/Requests`) — não perguntando só *"o campo
aparece?"* (isso a leva `fidelidade-campos` já fechou quase por completo), mas
**"o formulário submeteria e seria aceito?"**: obrigatoriedade, enum/valor, FK (UUID × rótulo),
cardinalidade (array × escalar / campo por item) e condicionalidade (`required_if`/XOR).

O resultado é mais rigoroso que o da leva anterior de propósito: dos 27 formulários com
contrato de entrada auditável, **nenhum é 100% fiel sob este critério** — 16 de alta
divergência, 9 de média, 2 de baixa (quase fiéis). Presença de campo não é fidelidade de
contrato: um campo pode estar na tela, com o rótulo certo, e o `rules()` ainda assim rejeitar
a submissão com **422** — por um `isRequired:false` onde é `required`, por um enum de rótulos
que não bate com o código do contrato, por um texto livre onde o contrato exige UUID de
catálogo, ou por uma coleção achatada num escalar.

As outras 26 funcionalidades do catálogo (53 no total) não têm contrato de escrita para
auditar sob este critério — são consulta, ponteiro para fluxo sem `fields` próprios, simulação
de hardware, ou gap de backend (endpoint que não existe). Ver [Pendências](#pendências-fora-do-escopo-desta-esteira).

## As cinco categorias de divergência (e o padrão ③ que continua fora)

| # | Categoria | O que é | Onde mora a correção |
|---|---|---|---|
| A | **Obrigatoriedade divergente** | Campo presente, `isRequired:false`, contrato exige `required` | `functional_catalog.dart` — só o flag/campo |
| B | **Enum/valor incompatível** | `options` do select não batem com o enum-código real do contrato | `functional_catalog.dart` — a lista de `options` |
| C | **FK como texto livre** | Contrato exige UUID de catálogo (`exists` tenant-scoped); o campo é texto livre | `functional_catalog.dart` — texto vira `select` sobre um domínio |
| D | **Array × escalar / item no cabeçalho** | Contrato pede coleção (`x[]`) ou campo **por item**; a tela usa escalar único ou achata no cabeçalho | `functional_catalog.dart` — campo migra para dentro de uma `FeatureCollection` |
| E | **Condicionalidade não modelada** | O contrato inverte obrigatoriedade por `required_if`/XOR; a tela trata tudo como obrigatório ou opcional fixo | `functional_journey_engine.dart` — `isFeatureFieldRequired`/`featureFieldError`, mesmo padrão do XOR de `pastagens` |
| ③ | **Inventados** (mantidos) | Campo sem correspondente no contrato — o backend ignora | Nenhuma — decisão de curadoria da leva anterior, reafirmada abaixo |

## Curadoria desta leva

Cinco decisões de escopo, tomadas antes da primeira linha de código — a leitura errada de
qualquer uma delas either sobre-engenheira um protótipo frontend-only, either trava um valor
que ninguém confirmou.

1. **A leva continua aditiva e frontend-only.** Nenhum campo inventado (padrão ③) sai — mesma
   decisão 1 da curadoria de `ESTEIRA-FIDELIDADE-CAMPOS.md`, e pelo mesmo motivo:
   `responsavel` e companhia estão espalhados por `recordTitleField`/`recordDescriptionFields`,
   amostras semeadas e testes congelados de quase todo o catálogo. O produto continua
   exclusivamente frontend (`CLAUDE.md`, "Limites do protótipo") — nada aqui liga a uma API
   real, então "a submissão seria aceita" é sempre contrafactual: o ganho é **fidelidade de
   documentação e de forma**, para quando o backend for ligado, não correção de um bug em
   produção.
2. **Categoria B (enum) só fecha com o código real confirmado.** Trocar rótulos por um enum
   errado é pior do que deixar o enum antigo — documentaria uma mentira nova. Fecho direto
   **só** os casos em que o próprio relatório entrega o enum inteiro (contrato tem N valores e
   diz quais são os N); onde o relatório só diz *"não bate"* sem listar o domínio completo
   (ex.: `AreaColor`, 14 hex), a onda correspondente vira `TODO(banco-real)` — mesmo padrão já
   usado em `areas.type`/`diets.type` no catálogo — com nota do que falta confirmar com o time
   web, e removo só o valor que o relatório afirma **não existir** (ex.: `Roxo`).
3. **Categoria C (FK como texto livre) vira `select` sobre um domínio, não um UUID sintético.**
   O protótipo não tem UUID de verdade (sem persistência real) — inventar um esconderia o
   problema em vez de documentá-lo. A correção é de **forma**: o campo deixa de ser texto livre
   e passa a `type: select` com `options` sobre o catálogo real correspondente
   (`catalogoResponsaveis`-style), a mesma fidelidade que `stock_uuid`/`farm_uuid` já
   receberam na onda 9. Onde o catálogo de opções ainda não existe no arquivo (ex.: fornecedor,
   prestador), a onda cria a constante compartilhada, seguindo o critério da onda 8 (domínio
   usado em mais de uma coleção mora num lugar só).
4. **Categoria D usa exatamente o padrão de item real da onda 8/onda 9** — nenhuma novidade de
   motor: o campo por-item que hoje está achatado no cabeçalho migra para dentro da
   `FeatureCollection` correspondente (ou a coleção nasce, se ainda não existir).
5. **Categoria E generaliza o XOR de `pastagens`.** `isFeatureFieldRequired`/
   `featureFieldError` em `functional_journey_engine.dart` já tratam um caso condicional
   (`area` XOR `piquete`); esta leva acrescenta os outros quatro (`acasalamento`,
   `transferencia-lote-area`, `pastagens.executor`, `protocolos-estacao`) como mais `if
   (feature.id == '...')` no mesmo par de funções — não um motor de regras genérico, que seria
   over-engineering para 5 casos conhecidos.
6. **Fluxos dedicados (`apontamento`, `producao-batelada`, `leitura-cocho-confinamento`) ficam
   fora do escopo de `functional_catalog.dart`.** Os três têm tela própria
   (`apontamento_flow.dart`, `batelada_flow.dart`, `leitura_cocho_flow.dart`), não o motor
   genérico — corrigi-los exige editar Dart de fluxo, não declaração de catálogo. Entram como
   ondas próprias, à parte, depois das ondas do motor genérico (ver Onda 8).
7. **`consulta-produtos` fica documentado, não expandido.** É consulta `readOnly` com 4 campos
   mostrados; o contrato de escrita real tem ~40 campos fiscais. Mesmo critério da leva
   anterior (decisão 2): registrar o gap, sem inflar uma tela de consulta com um formulário de
   criação que o protótipo não oferece.

## Pendências fora do escopo desta esteira

- **Gap de backend real** (`leitura-cocho-confinamento`, `trato-diario`, `sincronizacao`): o
  endpoint ou não cobre a funcionalidade (leitura de cocho) ou não existe (distribuição de
  batelada entre currais, sincronização offline). Nada de campo a ajustar — é arquitetura de
  backend, fora do que este repositório resolve (`CLAUDE.md`, "Limites do protótipo").
- **`producao-batelada`**: o fluxo dedicado nunca chama a API (mock local). Adicionar os
  campos que faltam (`date`, `warehouse_uuid`, os 5 required de `feedstocks[]`) documenta o
  contrato mas não muda o comportamento — entra como onda de baixo valor imediato, priorizada
  por último.
- **Referência "Ver 🚜"** nas notas do relatório: não existe em nenhum arquivo deste
  repositório — é uma referência externa ao rastreador da própria auditoria, não a um doc do
  CERNE. Ignorada aqui.

---

## Onda 1 — Categoria A: obrigatoriedade divergente (fechamento direto)

Sem ambiguidade de valor — é inverter `isRequired` ou declarar o campo que falta. Fecha nos
quatro cadastros que o relatório aponta.

- [ ] `marcacao` — 5 required voltam a `isRequired: true`: `safra`, `variedade`, `semana`,
      `quantidade`, `cor`.
- [ ] `rebanho-inicial` — 7 required voltam a `isRequired: true`: `entry_date` (campo `data` ou
      `data-entrada` — confirmar qual dos dois é o `entry_date` real antes de travar, ver nota
      da onda 3 de `ESTEIRA-FIDELIDADE-CAMPOS.md` sobre a duplicidade), `breed_id` (`raca`),
      `weight` (`peso-medio`), `price_kilo_alive` (`preco-kg`, entrou na onda 9),
      `price_arroba_alive` (`preco-arroba`), `value_unitary` (`valor-unitario`),
      `unity_animal_ua` (`ua`). **Atenção**: os três últimos são os valores recalculados pelo
      servidor que a curadoria original da leva anterior deixou opcionais de propósito — não
      reverter essa decisão sem reabrir a discussão; documentar a divergência no catálogo, no
      ponto, em vez de forçar `isRequired: true` nos três.
- [ ] `apontamento` — 11 inversões de obrigatoriedade no `ApontamentoFlow` (não no motor
      genérico — ver Onda 8): `operation`, `used_area` e o armazém por item, entre outros.
      Levantamento campo a campo fica para o início da Onda 8.
- [ ] `cadastrar-area` — 4 required voltam a `isRequired: true`: `productive_area`
      (`area-produtiva`), `unproductive_area` (`area-nao-produtiva`), `recreation_area`
      (`area-recreio`), `is_enabled` (`ativo`).

## Onda 2 — Categoria B: enum/valor incompatível (onde o relatório dá o domínio inteiro)

- [ ] `acasalamento` (`monta-natural`) — campo `tipo`: contrato tem 3 valores, o form tem 4.
      `Inseminação artificial` e `Transferência de embrião` **não existem** no enum real;
      **falta `FIV`**. Novo domínio: `['Monta natural', 'IATF', 'FIV']`. Confirmar se o rótulo
      de exibição de `FIV` é esse mesmo ou se o time web usa outra grafia antes de travar (é o
      único dos três sem confirmação explícita no relatório).
- [ ] `desmama` — campo `tipo`: `WeaningTypeEnum` real é `{Recria, Venda}`, não
      `Convencional/Precoce/Temporária`. Novo domínio: `['Recria', 'Venda']`.
- [ ] `cadastrar-area` — campo `tipo`: `AreaType` real é `{Produtiva, Reserva}`, não
      `['Agricultura', 'Pecuária', 'Fruticultura', 'Reserva']`. Novo domínio:
      `['Produtiva', 'Reserva']`. **Atenção**: isto estreita bastante o enum de uso da área —
      confirmar com o time web que não há um terceiro valor documentado em outro lugar do
      contrato antes de travar em produção (aqui trava porque o relatório afirma just os 2).
- [ ] `sanitario` — `labor.func_type`: contrato tem 3 valores (`employees`/`functions`/
      `providers`), o form tem 2 (`Própria`/`Terceirizada`). Novo domínio proposto:
      `['Empregado', 'Função', 'Prestador']` — **TODO(banco-real)**: confirmar os rótulos em
      português exatos com o time web (a tradução literal de `functions` como "Função" soa
      estranha para um tipo de mão de obra; pode ser "Função interna" ou nome próprio de
      cargo — não travar sem confirmar).

### Onda 2b — Categoria B com domínio incompleto (`TODO(banco-real)`, não fecha nesta leva)

- [ ] `cadastrar-area` — campo `cor`: `AreaColor` real são 14 hex; o relatório só confirma que
      **`Roxo` não existe**. Ação segura agora: remover `Roxo` das `options` e anotar
      `TODO(banco-real)` pedindo a lista completa de 14 cores/hex ao time web antes de
      recompor o domínio.
- [ ] `formulacoes` — campo `tipo`: `FoodTypeEnum` real é `{P, U}` (códigos, sem rótulo
      confirmado); o form usa `['Estoque', 'Formulação']`. `TODO(banco-real)`: pedir ao time
      web o rótulo em português de `P`/`U` antes de trocar — mapear às cegas arriscaria
      inverter o sentido dos dois.

## Onda 3 — Categoria C: FK como texto livre → `select` sobre domínio

- [ ] `lote-animais` — item da coleção "Animais do lote": identificação livre vira seleção
      sobre `catalogoIdentificacaoAnimal` + UUID simulado, mesmo padrão de `identifications[]`
      de `registrar-animal`.
- [ ] `transferencia-animal` — mesma mudança: identificação por texto vira seleção/coleção
      (ver também Onda 5, é também um problema de cardinalidade aqui).
- [ ] `desmama` — campo `lote`: texto livre vira `select` sobre um novo domínio compartilhado
      `catalogoLotes` (ainda não existe no catálogo — nasce aqui, pelo critério da onda 8:
      usado por `lote-animais`, `desmama`, `sanitario`, `apartacao`, `lotes-reproducao` e
      outros já hoje em campo `lote` livre).
- [ ] `apartacao` — campo `lote-origem`: mesma migração para `catalogoLotes`.
- [ ] `compras-animais` — campo `fornecedor`/`vendedor`: migra de texto livre para `select`
      sobre novo domínio `catalogoFornecedores` (sintético, mesmo critério de dado de exemplo
      da leva anterior — nunca copiado de produção).

## Onda 4 — Categoria D: array × escalar / campo por item

- [ ] `manutencao-frota` — bloco de executor **por item** ausente na coleção "Peças / Insumos"
      (ou numa coleção nova "Mão de obra", espelhando o padrão já usado em `sanitario`):
      `executor_type` + `employee`/`provider` + `quantidade`/`total`. As leituras por item
      (`equipment_uuid`/`hour_meter`/`mileage`) que hoje estão achatadas no cabeçalho migram
      para dentro do item (nota: `equipment_uuid` por item já entrou na onda 9 — falta
      `hour_meter`/`mileage`).
- [ ] `batidas` — `items.*.measurement_uuid` ausente na coleção "Itens da batida"; os 3
      required por item hoje opcionais (`dry_matter`/`materia-seca`, `cost_value`/`custo`,
      `percentage`/`porcentagem`) voltam a `isRequired: true`.
- [ ] `diagnostico-gestacao` — `provider_uuid` required por item ausente na coleção "Animais
      diagnosticados"; os campos planos do topo (`veterinario`/`lote`/`quantidade`) que
      duplicam o que só existe por linha somem do cabeçalho (ficam só no item, evitando a
      dupla fonte de verdade).
- [ ] `lotes-reproducao` — campo `lote` (escalar) vira coleção obrigatória `batch_uuids[]`
      (min:1) — muda de consulta administrativa simples para ter uma `FeatureCollection`
      (primeira vez que uma tela `readOnly` ganha coleção nesta leva; documentação do
      contrato, não formulário editável).
- [ ] `material-reprodutivo` — coleção `animals[]` do contrato está **ausente por completo**;
      nasce como nova `FeatureCollection` (analista deve puxar os campos reais de
      `animals.*` no Form Request antes de declarar, o relatório não lista quais são).
- [ ] `protocolos-estacao` — `items.*.service` (enum) e `items.*.measurement_uuid` ausentes na
      coleção "Etapas do protocolo"; `items.*.quantity` volta a `isRequired: true`.

## Onda 5 — Categoria D (continuação): cardinalidade de identificação/lote em array

- [ ] `lote-animais` — categoria: `select` único vira `category_uuids[]` (array, min:1) — a
      tela precisa de multi-seleção, que hoje não existe como padrão de `FeatureField`; avaliar
      se cabe como coleção sem formulário de item (lista de chips) ou se é caso para um
      controle novo em `lib/ui/` (Lei 1 — component-first: nasce no catálogo de componentes
      antes de ser consumido aqui).
- [ ] `transferencia-animal` — identificação escalar vira `animal_uuids[]` (array, min:1);
      destino por-animal (`batch_uuids[]` alinhado por índice, quando `same_batch = Não`) não
      tem equivalente hoje no motor genérico — avaliar extensão pontual em
      `functional_journey_engine.dart` (mesmo espírito da Onda 6, mas é par de arrays
      correlacionados por índice, não um XOR simples).
- [ ] `apartacao` — `batches[]` (array de UUID, min:1) troca o escalar `lote-origem`; contrato
      só aceita `date` + `batches[]` — os outros 4 campos (`criterio`/`lote-destino`/
      `quantidade`/`responsavel`) continuam como inventados mantidos (padrão ③, decisão 1).

## Onda 6 — Categoria E: condicionalidade não modelada

Estende `isFeatureFieldRequired`/`featureFieldError` em `functional_journey_engine.dart`, uma
`if (feature.id == '...')` por cadastro, mesmo padrão do XOR de `pastagens.destino`.

- [ ] `acasalamento` — matriz `type`/`launch_type` decide quais campos entre
      `estacao-monta`/`material-reprodutivo`/`protocolo`/as duas coleções ficam `required` —
      hoje tudo é obrigatório fixo ou opcional fixo.
- [ ] `transferencia-lote-area` — XOR de três destinos (área, módulo, curral): contrato exige
      **exatamente um**; hoje área e módulo são `required` fixos e o curral, opcional fixo.
- [ ] `pastagens` — coleção "Serviços": `executor` é XOR `employee`/`function`/`provider`
      (mesma família de `sanitario.labor.func_type`, onda 2) — a coleção hoje não tem nem nome
      nem valor do serviço modelados corretamente; ver também Onda 7.
- [ ] `protocolos-estacao` — XOR `product` ⊕ `service` por item da coleção "Etapas do
      protocolo" — hoje os dois campos, quando existirem (ver Onda 4), seriam tratados como
      independentes.

## Onda 7 — Resíduo de coleção mal modelada em `pastagens`

Fora das cinco categorias por ser mais estrutural — a coleção "Serviços" de `/pastures` está
**quase incompatível** com o contrato real, não só faltando um campo:

- [ ] Renomear/recompor os campos da coleção "Serviços" para bater com o contrato real
      (`name`/`value` que hoje não existem como tal) e resolver o executor via XOR (Onda 6).
- [ ] Nova coleção de **imagens geo** para `occurrences[]` — `lat`/`long`/`foto`, máximo 3 —
      sem equivalente hoje em `FeatureField`/`FeatureCollection` (não há tipo de campo de
      imagem no catálogo). Avaliar se entra como tipo de campo novo
      (`FeatureFieldType.image`?) ou fica documentado como `TODO` de motor — decisão de
      arquitetura, não só de dado, então cabe revisão antes de codar.
- [ ] Inversões `required`↔`nullable` já identificadas: `product_uuid` deveria ser opcional
      (é `stock_uuid` o obrigatório, que já entrou na onda 9) — conferir se algum campo de
      insumo ficou `isRequired: true` no lugar errado depois da onda 9.

## Onda 8 — Fluxos dedicados (fora do motor genérico)

Cada um é um arquivo Dart próprio, não uma entrada de `functional_catalog.dart` — maior custo
de engenharia por item, e testado por conta.

- [ ] `apontamento_flow.dart` — as 11 inversões de obrigatoriedade da Onda 1 e o bloco de mão
      de obra (`labor`: hoje função+texto livre; contrato é máquina de estados
      `type → employee/function/provider`, a mesma família de XOR de executor de `sanitario`/
      `pastagens`) e a matriz de qualidade da produção (13 colunas do contrato, reduzida a 4
      campos hoje).
- [ ] `batelada_flow.dart` (`producao-batelada`) — `date` + `warehouse_uuid` no topo e os 5
      required de `feedstocks[]` (`quantity`/`percentage`/`difference`/`amount`/`total`);
      `'vagão'` inventado fica (padrão ③). Baixo valor imediato — o fluxo é mock local, não
      chama a API; prioriza-se por último dentro desta onda.
- [ ] `leitura_cocho_flow.dart` — fora de escopo de campo: o núcleo da funcionalidade (escore/
      sobras/aspecto/comportamento/ocorrências) não tem endpoint real. Só o bloco consumo/dieta
      é auditável (`diet_id`/`feed_intake`, ambos `required`, ausentes no fluxo) — fechar só
      esse bloco; o resto é gap de backend (ver Pendências).

## Onda 9 — `consulta-produtos` (documentação, sem expandir a tela)

- [ ] Registrar no catálogo, em comentário, os ~40 campos fiscais do contrato de escrita real
      e os 6 required (`group_uuid`, `has_lot`, `is_equipment`, `is_enabled`, `control_stock`,
      `las_price`) — mesmo tratamento de documentação que consultas `readOnly` já recebem, sem
      criar formulário de criação nesta tela.
- [ ] Campos `categoria`/`unidade`: mesma categoria C (FK como texto/rótulo onde o contrato
      quer `category_uuid`/`measurement_uuid`) — se e quando a tela virar formulário de
      criação, entra pela Onda 3.

---

## Cadastro a cadastro (referência completa da auditoria de 14/09)

Tabela de trabalho — cada linha é uma issue do relatório, com a onda que a fecha.

| Cadastro | Sev. | Issue | Onda |
|---|---|---|---|
| `leitura-cocho-confinamento` | alta | núcleo sem backend | fora de escopo |
| `leitura-cocho-confinamento` | alta | `diet_id`/`feed_intake` ausentes | 8 |
| `producao-batelada` | alta | `date`/`warehouse_uuid` ausentes | 8 |
| `producao-batelada` | alta | 5 required de `feedstocks[]` ausentes | 8 |
| `acasalamento` | alta | enum `type` 4×3, falta FIV | 2 |
| `acasalamento` | alta | condicionalidade `type`/`launch_type` | 6 |
| `acasalamento` | alta | `bull_seed_season_uuid` ausente | 1 (adicionar campo) |
| `diagnostico-gestacao` | alta | `provider_uuid` por item ausente | 4 |
| `diagnostico-gestacao` | alta | campos planos duplicam a coleção | 4 |
| `apontamento` | alta | 11 inversões de obrigatoriedade | 1 / 8 |
| `apontamento` | alta | modelo de mão de obra | 8 |
| `apontamento` | alta | matriz de qualidade (13 col. → 4) | 8 |
| `pastagens` | alta | coleção "Serviços" incompatível | 7 |
| `pastagens` | alta | imagens geo em `occurrences[]` | 7 |
| `pastagens` | alta | inversões required↔nullable | 7 |
| `sanitario` | alta | `func_type` 2×3 | 2 |
| `sanitario` | alta | `time_control`/`labor.measurement_uuid` | 1 / 6 |
| `rebanho-inicial` | alta | 7 required marcados opcionais | 1 |
| `marcacao` | alta | 5 required marcados opcionais | 1 |
| `cadastrar-area` | alta | `tipo`/`cor` enum errado | 2 / 2b |
| `cadastrar-area` | alta | 4 required marcados opcionais | 1 |
| `manutencao-frota` | alta | executor por item ausente | 4 |
| `manutencao-frota` | alta | leituras por item achatadas | 4 |
| `material-reprodutivo` | alta | coleção `animals[]` ausente | 4 |
| `material-reprodutivo` | alta | estação texto × FK; `products.armazem` | 3 / 1 |
| `protocolos-estacao` | alta | `items.*.service`/`measurement_uuid` ausentes | 4 |
| `protocolos-estacao` | alta | XOR produto⊕serviço | 6 |
| `desmama` | alta | enum `tipo` incompatível | 2 |
| `desmama` | alta | `animal_uuids[]`/`lote` UUID | 3 / 5 |
| `apartacao` | alta | `batches[]` × escalar | 5 |
| `consulta-produtos` | alta | contrato de escrita maior; FK como rótulo | 9 |
| `compras-animais` | media | `fornecedor`/`vendedor` texto × FK | 3 |
| `compras-animais` | media | duplicação cabeçalho×item | revisão manual |
| `compras-animais` | media | fiscais/`has_financial` ausentes | backlog (baixo valor) |
| `batidas` | media | 3 required por item opcionais | 4 |
| `batidas` | media | `items.*.measurement_uuid` ausente | 4 |
| `formulacoes` | media | enum `tipo` P/U | 2b |
| `abastecimentos` | media | `medidor` funde dois campos do contrato | revisão manual |
| `abastecimentos` | media | required de cabeçalho × nullable | revisão manual |
| `lote-animais` | media | categoria escalar × array | 5 |
| `lote-animais` | media | item por texto × `animal_uuids[]` | 3 |
| `transferencia-animal` | media | identificação escalar × array | 5 |
| `transferencia-animal` | media | destino por índice não modelado | 5 |
| `transferencia-lote-area` | media | XOR três destinos | 6 |
| `transferencia-lote-area` | media | curral rótulo × FK | 3 |
| `estacao-monta` | media | `description` mapeado a campo opcional | revisão manual |
| `lotes-reproducao` | media | `lote` escalar × `batch_uuids[]` | 4 |
| `registrar-animal` | baixa | `preco-kg` opcional | 1 |
| `perdas` | baixa | `lote` required no form × nullable no contrato | revisão manual (form mais estrito — ok manter) |

## Contagens de referência (auditoria 14/09)

| | Valor |
|---|---|
| Funcionalidades totais | 53 |
| Formulários com contrato de entrada auditável | 27 |
| Fiéis sob este critério | 0 |
| Alta divergência | 16 |
| Média divergência | 9 |
| Baixa divergência (quase fiéis) | 2 |
| Sem formulário a auditar (leitura/ponteiro/hardware/gap) | 26 |

## Pendências conhecidas desta esteira

- **Enums sem domínio completo no relatório** (`AreaColor` 14 hex, `FoodTypeEnum` P/U) ficam
  `TODO(banco-real)` — não travar rótulo sem confirmar com o time web (Onda 2b).
- **Tipo de campo "imagem" não existe no catálogo** (`FeatureFieldType`) — necessário para a
  coleção geo de `pastagens.occurrences[]` (Onda 7). É decisão de motor, não só de dado;
  revisar antes de codar.
- **Multi-seleção (`category_uuids[]`, `animal_uuids[]` como array real)** não tem componente
  hoje em `lib/ui/` — Lei 1 (component-first) exige nascer no catálogo de componentes antes de
  ser consumido pelas Ondas 4/5.
- **`compras-animais`/`abastecimentos`/`estacao-monta`** têm issues marcadas "revisão manual"
  na tabela — o relatório aponta a divergência mas não dá dado suficiente (enum completo, nome
  exato do campo-destino) para fechar sem olhar o Form Request real; não incluídas em onda
  numerada até essa confirmação.
- **`flutter analyze`/`flutter test` não rodam neste ambiente** (sem SDK Flutter) — mesma
  limitação registrada em `ESTEIRA-FIDELIDADE-CAMPOS.md`. Cada onda desta esteira precisa do
  mesmo tratamento: verificador estrutural equivalente durante o desenvolvimento, e
  `npm run lint && npm test && npm run quality:functional` antes do merge.
