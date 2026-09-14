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

## Status desta execução (ondas 1-9)

| Onda | Categoria | Status |
|---|---|---|
| 1 | A — obrigatoriedade | ✅ fechada |
| 2 / 2b | B — enum/valor | ✅ fechada (2 `TODO(banco-real)` honestos) |
| 3 | C — FK como texto | ✅ fechada |
| 4 | D — array × escalar / item | ✅ quase completa (`material-reprodutivo.animals[]` fica de fora — contrato não especificado) |
| 5 | D — cardinalidade fechada em coleção | ✅ fechada (`transferencia-animal` fica de fora — conflito com simulação de RFID) |
| 6 | E — condicionalidade | ✅ fechada (4 casos, matriz de `monta-natural` simplificada) |
| 7 | Resíduo estrutural de `pastagens` | ✅ quase completa (coleção de imagens geo fica de fora — motor + câmera simulada) |
| 8 | Fluxos dedicados | ⏸️ não iniciada — ver justificativa na própria onda |
| 9 | `consulta-produtos` | ✅ documentação registrada |

Catálogo ao fim da onda 7: **248 campos de cabeçalho** (187 obrigatórios), **31 coleções** (29
com item real), **118 campos de item**, **5 coleções obrigatórias** — 53 funcionalidades sem
mudança de contagem.

**Verificação real, não só estrutural**: o SDK Flutter (3.44.6, a versão do `CLAUDE.md`) foi
baixado nesta sessão e `npm run lint`/`npm run test`/`npm run quality:functional` rodaram de
verdade. Isso pegou 3 bugs que a checagem estrutural (sem compilar) não via — dois testes que
não preenchiam campo novo, um teste que checava obrigatoriedade por posição em vez de por id —
todos corrigidos. A suíte completa do app (544 testes) tem **10 falhas, nenhuma desta leva**:
6 são golden tests (diferença de renderização de fonte neste ambiente, não têm relação com
`functional_catalog.dart`) e 4 já falham em `main` sem nenhuma mudança desta esteira
(`Bluetooth exige descoberta`, `scanner SISBOV`, `TratoDiarioFlow`, `LoginPage login
sinalizado como operacional`) — confirmado revertendo para `main` e rodando os mesmos testes
lá. `functional_catalog_test.dart` e `functional_journey_engine_test.dart`: **verdes**.

---

## Onda 1 — Categoria A: obrigatoriedade divergente (fechamento direto)

Sem ambiguidade de valor — é inverter `isRequired` ou declarar o campo que falta. Fecha nos
quatro cadastros que o relatório aponta, mais três achados durante a execução (registrado
abaixo do checklist original).

- [x] `marcacao` — 5 required voltam a `isRequired: true`: `safra`, `variedade`,
      `semana-safra`, `quantidade`, `cor`.
- [x] `rebanho-inicial` — required voltam a `isRequired: true`: `data-entrada` (mapeia
      `entry_date` — é o campo de `banco-real` já reconhecido como o candidato certo, distinto
      de `data`, a data de referência do levantamento), `raca` (`breed_id`), `peso-medio`
      (`weight`), `preco-kg` (`price_kilo_alive`). **Não** reverte a decisão da curadoria
      original: `preco-arroba`/`valor-unitario`/`ua` (os três valores recalculados pelo
      servidor) continuam opcionais de propósito.
- [x] `registrar-animal` — `preco-kg` (`price_kilo_alive`) volta a `isRequired: true`, mesma
      correção espelhada de `rebanho-inicial` — achado extra durante a execução, o relatório o
      lista como issue própria (severidade baixa) deste cadastro.
- [ ] `apontamento` — 11 inversões de obrigatoriedade no `ApontamentoFlow` (não no motor
      genérico — ver Onda 8): `operation`, `used_area` e o armazém por item, entre outros.
      Levantamento campo a campo fica para o início da Onda 8.
- [x] `cadastrar-area` — 4 required voltam a `isRequired: true`: `area-produtiva`
      (`productive_area`), `area-nao-produtiva` (`unproductive_area`), `area-recreio`
      (`recreation_area`), `ativo` (`is_enabled`).
- [x] `sanitario` — `controle-por-tempo` (`time_control`) volta a `isRequired: true`.
- [x] `monta-natural` (acasalamento) — `bull_seed_season_uuid` estava ausente por completo;
      entra como campo novo `bull-seed-season` (select sobre os códigos `BSS-*` do próprio
      catálogo de `material-reprodutivo`), distinto do texto livre `material-reprodutivo`
      (que documenta o insumo, não o vínculo à estação).
- [x] `material-reprodutivo` — `products.*.armazem` tinha o sentido invertido: a leva anterior
      o travou `isRequired: true`, mas o contrato real o marca opcional. Reverte para opcional
      (é a única correção desta onda que **remove** um `isRequired`, não adiciona).

## Onda 2 — Categoria B: enum/valor incompatível (onde o relatório dá o domínio inteiro)

- [x] `acasalamento` (`monta-natural`) — campo `tipo`: novo domínio
      `['Monta natural', 'IATF', 'FIV']` — `Inseminação artificial`/`Transferência de embrião`
      não existiam no enum real; `estacao-monta.metodo` **não** foi tocado (a auditoria não o
      aponta como divergente).
- [x] `desmama` — campo `tipo`: novo domínio `['Recria', 'Venda']` (`WeaningTypeEnum`).
- [x] `cadastrar-area` — campo `tipo`: novo domínio `['Produtiva', 'Reserva']` (`AreaType`) — a
      classificação setorial (agricultura/pecuária/…) já mora em "Atividade", campo distinto.
      Amostras semeadas (`area-1`/`area-2`) atualizadas.
- [x] `sanitario` — `labor.func_type`: novo domínio `['Empregado', 'Função', 'Prestador']`.
      **TODO(banco-real) permanece**: rótulos em português não confirmados pelo time web —
      anotado no ponto.

### Onda 2b — Categoria B com domínio incompleto (`TODO(banco-real)`, não fecha nesta leva)

- [x] `cadastrar-area` — campo `cor`: removido `Roxo` (confirmado inexistente); os 5 restantes
      ficam com `TODO(banco-real)` pedindo a lista completa de 14 cores/hex ao time web.
- [x] `formulacoes` — campo `tipo`: valores **não alterados** (`Estoque`/`Formulação`) —
      `TODO(banco-real)` anotado no ponto pedindo o rótulo real de `P`/`U` antes de trocar.

## Onda 3 — Categoria C: FK como texto livre → `select` sobre domínio

- [x] `lote-animais` — item da coleção "Animais do lote": ganha `tipo-identificacao` (select
      sobre `catalogoIdentificacaoAnimal`) ao lado da `identificacao` (número/brinco em texto)
      — mesmo padrão de `identifications[]` de `registrar-animal` (modo + número, não um UUID
      sintético de uma lista fechada de animais, que misrepresentaria a realidade pior do que
      o texto livre).
- [x] `transferencia-animal` — **não** convertido: `identificacao` é o campo-alvo da simulação
      de RFID (`simulationTargetField`) — virar `select` quebraria a captura por hardware
      simulado. `lote-atual`/`novo-lote` migraram para `select` sobre `catalogoLotes` (ver
      abaixo); a cardinalidade de `identificacao` (escalar → `animal_uuids[]`) fica para a
      Onda 5.
- [x] `desmama` — campo `lote` e `lote-destino`: `select` sobre o novo domínio compartilhado
      `catalogoLotes` (nasce aqui, critério da onda 8: reusado por `desmama`, `apartacao` e
      `transferencia-animal`).
- [x] `apartacao` — campos `lote-origem` e `lote-destino`: mesma migração para `catalogoLotes`.
- [x] `compras-animais` — campos `fornecedor`/`vendedor`: migram de texto livre para `select`
      sobre novo domínio `catalogoFornecedores` (sintético, mesmo critério de dado de exemplo
      da leva anterior — nunca copiado de produção; inclui `Fazenda Boa Vista`, já usado na
      amostra semeada como `fornecedor`).

## Onda 4 — Categoria D: array × escalar / campo por item

- [x] `manutencao-frota` — nova coleção "Mão de obra" (`tipo` Empregado/Prestador, `executor`,
      `quantidade` em horas, `total`) — o form só tinha `horas-mao-de-obra` no cabeçalho, um
      total sem executor. `hour_meter`/`mileage` (`horimetro`/`hodometro`) migraram para
      dentro de "Peças / Insumos" (`equipment_uuid` por item já tinha entrado na onda 9).
- [x] `batidas` — `items.*.measurement_uuid` (`unidade`) entrou na coleção "Itens da batida";
      os 3 required por item (`materia-seca`, `custo`, `porcentagem`) voltam a
      `isRequired: true`.
- [x] `diagnostico-gestacao` — `provider_uuid` (`veterinario`) required por item entrou na
      coleção "Animais diagnosticados". **Não fechado por completo**: os campos planos do
      topo (`veterinario`/`lote`/`quantidade`) continuam — removê-los exigiria redesenhar
      `recordTitleField` (hoje `lote`, um campo de cabeçalho) e as etapas, fora do escopo desta
      onda. Nuance registrada, não é pattern ③ (não são inventados, duplicam algo real).
- [x] `lotes-reproducao` — nova coleção obrigatória "Lotes vinculados" (`batch_uuids[]`,
      min:1, select sobre `catalogoLotes`). O escalar `lote` **permanece** pelo mesmo motivo de
      `diagnostico-gestacao`: é o `recordTitleField` desta consulta. Amostras semeadas
      atualizadas.
- [ ] `material-reprodutivo` — coleção `animals[]` do contrato continua **ausente**: o
      relatório não lista os campos reais de `animals.*` em `/bull-seed-season`, e inventá-los
      seria advinhar contrato, não documentá-lo. Fica para quando alguém puxar o Form Request
      real.
- [x] `protocolos-estacao` — `items.*.service` (`servico`, texto — `TODO(banco-real)`: enum
      real não confirmado) e `items.*.measurement_uuid` (`unidade`) entraram na coleção "Etapas
      do protocolo"; `items.*.quantity` volta a `isRequired: true`.

## Onda 5 — Categoria D (continuação): cardinalidade de identificação/lote em array

Decisão de arquitetura tomada nesta onda: **nenhum componente novo**. Um `category_uuids[]`/
`batches[]` (array de valores de um domínio fechado, min:1) é modelado como uma
`FeatureCollection` de um campo só — o mesmo motor de coleção da onda 8, reaproveitado. Não é
um multi-select disfarçado; é literalmente a mesma forma de dado (`array<FK>`) que o resto do
catálogo já representa como coleção.

- [x] `lote-animais` — nova coleção obrigatória "Categorias do lote" (`category_uuids[]`,
      min:1). O escalar `categoria` permanece (usado em `recordDescriptionFields`), mesma
      nuance de duplicação da Onda 4.
- [x] `apartacao` — nova coleção obrigatória "Lotes de origem" (`batches[]`, min:1). O escalar
      `lote-origem` permanece (é o `recordTitleField`); os outros 4 campos
      (`criterio`/`lote-destino`/`quantidade`/`responsavel`) continuam como inventados mantidos
      (padrão ③, decisão 1).
- [ ] `transferencia-animal` — **não fechado, de propósito**. `identificacao` é o campo-alvo
      da simulação de RFID (`simulationTargetField`): a captura por hardware simulado hoje é
      "escaneie um, preencha um campo", não "escaneie vários, monte uma lista". Converter para
      `animal_uuids[]` de verdade (mesmo truque de coleção acima) exigiria também redesenhar a
      simulação de captura para adicionar itens a uma coleção a cada "leitura" — trabalho de
      fluxo de UI, não só de catálogo, mesmo tipo de esforço da Onda 8. O par correlacionado
      `batch_uuids[]` por índice (quando `same_batch = Não`) tem o mesmo problema e fica junto.
      Registrado como pendência (ver seção de Pendências).

## Onda 6 — Categoria E: condicionalidade não modelada

Estende `isFeatureFieldRequired`/`featureFieldError` em `functional_journey_engine.dart` para os
casos de cabeçalho, mesmo padrão do XOR de `pastagens.destino`. Para os dois casos de **item de
coleção** (produto⊕serviço, executor), nasceram duas funções irmãs — `isCollectionItemFieldRequired`/
`collectionItemFieldError` — porque `featureItemFieldError` não recebe `feature`/`collection` no
contexto; `mapped_feature_screen.dart` passou a usá-las nas duas coleções afetadas.

- [x] `acasalamento` (`monta-natural`) — modelagem mínima: `protocolo` vira obrigatório quando
      `tipo = IATF`; `material-reprodutivo` vira obrigatório quando `tipo-lancamento = Por
      lote`. Não cobre a matriz inteira do relatório (ex.: `estacao-monta` continua sempre
      opcional) — os dois casos mais claros primeiro, resto fica de nota.
- [x] `transferencia-lote-area` — novo campo `destino` (select Área/Módulo/Curral) resolve o
      XOR; `area`/`modulo` deixam de ser `required` fixos.
- [x] `pastagens` — coleção "Serviços" recomposta na Onda 7 (`tipo-executor` + `executor`);
      XOR aqui: `executor` é obrigatório só quando `tipo-executor` é "Empregado" ou
      "Prestador" — "Função" já é a resposta em si.
- [x] `protocolos-estacao` — XOR `produto` ⊕ `servico` por item de "Etapas do protocolo",
      conforme `tipo` do item (`Produto`/`Serviço`).

Testes novos em `functional_journey_engine_test.dart` cobrem o XOR de `transferencia-lote-area`
e o XOR de item de `protocolos-estacao` — os dois com lógica nova, verificados linha a linha
contra a implementação já que a suíte real não roda neste ambiente.

## Onda 7 — Resíduo de coleção mal modelada em `pastagens`

Fora das cinco categorias por ser mais estrutural — a coleção "Serviços" de `/pastures` estava
**quase incompatível** com o contrato real, não só faltando um campo:

- [x] Recomposta a coleção "Serviços": `prestador` (texto livre) virou `tipo-executor` +
      `executor` (Onda 6 cuida do XOR de obrigatoriedade); `servico`/`valor` já cobriam
      nome/valor. Ver commit da Onda 6 — as duas mudanças saíram juntas por dependência direta
      (o XOR de obrigatoriedade não existe sem os campos).
- [x] Inversão `required`↔`nullable` corrigida: `produto` (`product_uuid`) volta a opcional em
      `pastagens."Insumos"` — é `estoque` (`stock_uuid`) o obrigatório, a onda 9 tinha travado
      o sentido errado.
- [ ] Nova coleção de **imagens geo** para `occurrences[]` — `lat`/`long`/`foto`, máximo 3 —
      **não entra nesta leva**. Não existe tipo de campo de imagem no catálogo
      (`FeatureFieldType` só tem `text`/`number`/`date`/`select`/`textarea`); um campo de
      captura de foto se aproxima de "hardware simulado" (câmera), que o próprio `CLAUDE.md`
      lista como limite do protótipo ("Limites do protótipo": não apresentar câmera como
      integração nativa concluída). Decisão de arquitetura — motor + eventual simulação de
      câmera — que pede revisão própria antes de codar, não uma correção de catálogo.

## Onda 8 — Fluxos dedicados (fora do motor genérico)

Cada um é um arquivo Dart próprio, não uma entrada de `functional_catalog.dart` — maior custo
de engenharia por item, e testado por conta.

**Decisão desta execução: nenhum dos três foi editado.** A justificativa original (sem SDK
Flutter neste ambiente para compilar depois de editar) deixou de valer — o SDK 3.44.6 foi
baixado durante esta mesma sessão e `flutter test` roda de verdade agora (ver "Verificação
real" no topo deste arquivo). O que continua de pé, e por isso a decisão não muda: boa parte do
que falta em `apontamento_flow.dart`/`batelada_flow.dart` é **semântica de negócio que a
auditoria não detalha** (os valores reais de `percentage`/`difference`/`amount`/`total` de
`feedstocks[]`, as 13 colunas da matriz de
qualidade) — inventar a forma exata seria o mesmo erro que a curadoria já vetou para enums sem
domínio completo (Onda 2b), agora em código de tela em vez de `options`.

- [ ] `apontamento_flow.dart` — as 11 inversões de obrigatoriedade da Onda 1 e o bloco de mão
      de obra (`labor`: hoje função+texto livre; contrato é máquina de estados
      `type → employee/function/provider`, a mesma família de XOR de executor de `sanitario`/
      `pastagens`) e a matriz de qualidade da produção (13 colunas do contrato, reduzida a 4
      campos hoje). Arquivo maior e de maior risco desta onda — pede sessão própria, com
      alguém rodando `flutter test` a cada mudança.
- [ ] `batelada_flow.dart` (`producao-batelada`) — `date` no topo é a única peça
      inequívoca (as demais dependem de fórmula de negócio não confirmada); mesmo assim,
      nenhum fluxo dedicado do módulo hoje tem campo de data (são todos "operação de hoje"
      implícita) — inserir um quebraria esse padrão sem um pedido explícito de UX. `[nenhuma
      mudança]`. Os 5 required de `feedstocks[]`
      (`quantity`/`percentage`/`difference`/`amount`/`total`) e `warehouse_uuid` no topo
      continuam ausentes; `'vagão'` inventado fica (padrão ③). Baixo valor imediato — o fluxo é
      mock local, não chama a API.
- [ ] `leitura_cocho_flow.dart` — fora de escopo de campo: o núcleo da funcionalidade (escore/
      sobras/aspecto/comportamento/ocorrências) não tem endpoint real. Só o bloco consumo/dieta
      é auditável (`diet_id`/`feed_intake`, ambos `required`, ausentes no fluxo) — fechar só
      esse bloco; o resto é gap de backend (ver Pendências). Mesma reserva de risco/verificação
      do item acima.

## Onda 9 — `consulta-produtos` (documentação, sem expandir a tela)

**Correção de premissa**: o relatório descreve `consulta-produtos` como consulta `readOnly`,
mas o catálogo já a declara como criação de verdade desde a onda 2 do banco-real
(`createAction: 'Novo produto'`, sem `readOnly`). O tratamento de "documentar, não expandir"
desta onda vale mesmo assim — a tela é editável, mas o contrato real (~40 campos fiscais) é
grande demais para entrar de uma vez sem decisão de produto.

- [x] Registrado no catálogo, em comentário, os ~40 campos fiscais do contrato de escrita real
      e os 6 required ausentes (`group_uuid`, `has_lot`, `is_equipment`, `is_enabled`,
      `control_stock`, `las_price`) — três deles booleanos, que `FeatureFieldType` não modela
      hoje (mesma lacuna de motor da coleção de imagens da Onda 7). Sem criar os campos nesta
      onda: 4 campos → ~44 é decisão de escopo de produto, não uma correção pontual de
      fidelidade.
- [x] Campos `categoria`/`unidade`: mesma nota de categoria C (FK como rótulo onde o contrato
      quer `category_uuid`/`measurement_uuid`) registrada no ponto — correção real fica para
      quando/se a expansão de campos acontecer.

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
- **`transferencia-animal` continua com identificação escalar.** A Onda 5 fechou
  `category_uuids[]`/`batches[]` reaproveitando o motor de coleção (nenhum componente novo
  necessário — ver a decisão de arquitetura no início da Onda 5), mas `identificacao` é o
  campo-alvo da simulação de RFID: convertê-lo para `animal_uuids[]` exige redesenhar a
  captura por hardware simulado para empilhar leituras numa coleção, não só declarar o campo.
  Mesmo tipo de esforço da Onda 8 (fluxo dedicado), fica para lá ou para uma onda própria.
- **`compras-animais`/`abastecimentos`/`estacao-monta`** têm issues marcadas "revisão manual"
  na tabela — o relatório aponta a divergência mas não dá dado suficiente (enum completo, nome
  exato do campo-destino) para fechar sem olhar o Form Request real; não incluídas em onda
  numerada até essa confirmação.
- ~~**`flutter analyze`/`flutter test` não rodam neste ambiente**~~ — resolvido nesta sessão:
  SDK Flutter 3.44.6 baixado, `npm run lint`/`npm run quality:functional`/`npm test`
  (544 testes) rodaram de verdade. 3 bugs reais corrigidos (ver "Verificação real" no topo).
  10 falhas continuam de pé, nenhuma desta leva — 6 golden tests (fonte do ambiente) e 4 já
  quebradas em `main` sem relação com fidelidade de contrato.
