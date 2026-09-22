# Handoff — Efeitos sistêmicos da Ordem de Serviço (backend/web)

> **Documento de handoff entre repositórios.** Foi produzido no repositório do protótipo
> mobile (`cerne-app-operacao`, Flutter, frontend puro) e destina-se ao repositório do
> **backend/web do GB CERNE**. Data: 22/09/2026.
>
> **Para o agente (Claude Code) que for executar isto:** leia a seção
> [Como usar este documento](#como-usar-este-documento) antes de qualquer coisa. Este
> documento descreve um **gap confirmado no mobile** e um **conjunto de hipóteses a
> verificar no backend**. Nada aqui foi verificado no código do backend — não houve acesso
> a ele a partir do repositório de origem. Trate toda afirmação sobre o backend como
> hipótese a confirmar, nunca como fato.

---

## Como usar este documento

1. **Execute a [Fase 0](#fase-0--investigação-obrigatória-bloqueante) primeiro e pare.**
   Ela é investigação pura, sem alteração de código. O resultado dela decide se as fases
   seguintes são necessárias, parcialmente necessárias ou já estão implementadas.
2. Reporte o resultado da Fase 0 ao solicitante **antes** de abrir qualquer PR.
3. Só então execute as fases seguintes, uma por vez, cada uma como unidade lógica própria
   com commit Conventional Commit.

### Fora de escopo — não altere

- **A interface Desktop/web (Operacional > Lista de OS e telas relacionadas).** Decisão
  explícita do solicitante: o Desktop será ajustado em fase futura, com base no que for
  confirmado aqui.
- **O repositório do protótipo mobile Flutter.** Ele é frontend simulado e será ajustado
  separadamente.
- O escopo deste documento é: **modelo de dados, serviços de domínio e endpoints de API.**

---

## Contexto

O módulo de Ordem de Serviço tem, no Desktop, 6 abas (Identificação, Mão de Obra,
Equipamentos, Insumos, Produção, Proteções/EPIs) e um ciclo de status
(Aberta → Em Execução → Concluída → Avaliada → Cancelada), além de blocos de "Execução" e
"Avaliação" que só aparecem preenchidos após a execução em campo.

A pergunta que originou este handoff: **quando a OS é concluída, o sistema produz os efeitos
sistêmicos que a tela promete?** Especificamente: baixa de insumo do armazém, entrada de
produção no armazém de destino, evidências de execução, confirmação item a item, e eventual
escrita em cadastros-mestre vinculados.

### O que já está confirmado (lado mobile)

Investigação completa do repositório `cerne-app-operacao` (Flutter):

- O app mobile é um **protótipo frontend sem backend**: zero dependências de rede
  (`http`/`dio`/`supabase`) ou persistência (`sqflite`/`hive`/`shared_preferences`) no
  `pubspec.yaml`; zero ocorrências de `Uri.parse`/`HttpClient` em `lib/`.
- Todo o estado é Riverpod **em memória**, recriado a partir de mocks a cada `build()`.
- A OS mobile **não cria, não transmite e não persiste nada**. As 7 ações do store
  (`iniciar`, `pausar`, `retomar`, `marcarEntregue`, `marcarRefeita`, `avaliar`, `cancelar`)
  mutam apenas a própria lista em memória.
- `insumos`, `maoDeObra`, `maquinas` e `epis` são `List<String>` de texto formatado — sem
  id de produto, quantidade numérica, unidade ou armazém. **Não existe aba Produção** no
  modelo mobile.
- Não há captura de foto/assinatura: o componente de upload é simulado e devolve um nome de
  arquivo fixo.

**Conclusão:** o mobile não é a causa de nenhum efeito ausente, porque ele não emite nada.
Se a baixa de estoque existe hoje, ela existe no backend. Se não existe, precisa nascer lá.

### Fonte de referência do schema

O repositório de origem contém uma análise campo a campo do dump de produção
(`docs/ajustes-banco-real/`, schema `gbcerne`, 415 tabelas, dump de 18/08/2026, revisado com
dump de homologação em 07/09/2026). As tabelas citadas abaixo vêm dessa análise.

> ⚠️ **Os nomes e contagens abaixo refletem um dump de agosto/setembro de 2026. Confirme
> contra o schema atual antes de escrever qualquer migration.**

| Domínio | Tabelas |
|---|---|
| OS (cabeçalho) | `service_orders` (30+ colunas: `deadline`, `expected_result_description`, `success_criteria_description`, `minimum_temperature`, `maximum_temperature`, restrição ambiental, avaliação, feedback, `user_id`, `executor_id`, `area_id`, `category`, `status`) |
| OS — Mão de Obra | `employee_service_order` |
| OS — Equipamentos | `equipment_service_order` |
| OS — Insumos | `product_service_order` |
| OS — Produção | `production_service_order` |
| OS — Proteções/EPIs | `protection_service_order` |
| Estoque | `stocks`, `warehouses`, `stock_movements` (`type`, `classification`), `opening_balances`, `stock_writeoffs`, `input_entries` |
| Catálogo | `products`, `measurements` |
| Apontamento (modelo irmão) | `appropriations` + `appropriation_employee` / `_equipment` / `_stock` / `_production` / `_occurrences` / `_movements` |
| Auditoria | `audits` |

Nota relevante: a família `appropriation_*` tem **exatamente a mesma forma** que a OS
(cabeçalho + listas de recurso por tipo) e inclui `appropriation_movements` como histórico de
status. Se já existir serviço de movimentação de estoque ligado a `appropriations`, **ele é o
candidato natural a ser reusado pela OS** — verifique isso na Fase 0 antes de escrever
qualquer serviço novo.

---

## Fase 0 — Investigação obrigatória (bloqueante)

Não altere código nesta fase. Responda cada pergunta com referência a
**arquivo:linha / função / endpoint / migration**.

### 0.1 — Movimentação de estoque

- Existe um serviço de movimentação de estoque no backend? Onde? Qual sua assinatura?
- Ele é chamado a partir da conclusão de uma OS? Rastreie o caminho do endpoint que muda o
  status da OS até (ou não até) esse serviço.
- Ele é chamado a partir de `appropriations` (Apontamento)? Se sim, **esse é o padrão a
  reusar** — documente a assinatura.
- A movimentação é síncrona com a transação da conclusão, ou assíncrona (fila/job/cron)?
  Se assíncrona, identifique a fila e o worker.
- Existe idempotência? (Concluir a OS duas vezes baixa o estoque duas vezes?)

### 0.2 — Ciclo de status

- Qual é o dicionário real de `service_orders.status`? (Levantado como **enum sem dicionário
  confirmado** na análise do dump.) Liste os valores e o significado de cada um.
- Qual endpoint/serviço executa cada transição? Existe máquina de estados explícita ou são
  updates soltos de coluna?
- Há hook/observer/evento de domínio disparado na transição para "Concluída"?

> **Divergência já detectada, precisa de decisão:** o ciclo do Desktop
> (Aberta/Em Execução/Concluída/Avaliada/Cancelada) **não é** o do mobile
> (aguardando/emExecucao/**pausada**/**entregue**/**refeita**/cancelada). O mobile tem estado
> de pausa e desdobra a conclusão em "entregue" vs. "refeita" (retrabalho com justificativa
> obrigatória); e trata avaliação como campo paralelo aceito apenas **antes** do
> encerramento, enquanto o Desktop a trata como status **posterior** à conclusão. Isso
> precisa ser reconciliado no backend antes de qualquer efeito ser construído sobre
> "conclusão", ou o efeito será reescrito.

### 0.3 — Anexos e evidências

- Existe tabela ou storage de anexo vinculável a `service_orders`? (Na análise do dump não
  foi identificada contrapartida.)
- Existe infraestrutura de upload já usada por outro módulo (bucket, S3, disco local)? Qual?

### 0.4 — Confirmação por item

- As tabelas `employee_service_order`, `equipment_service_order`, `product_service_order`,
  `production_service_order`, `protection_service_order` têm colunas de **realizado**
  (confirmado, quantidade realizada, observação, timestamp, usuário que confirmou), ou só de
  **planejado**?
- Existe endpoint que atualize um item individual dessas tabelas durante a execução?

### 0.5 — Escrita em cadastro-mestre

- Existe hoje algum caminho pelo qual a conclusão de uma OS escreva em um cadastro-mestre
  (Talhão, Pasto, Bebedouro, Cocho, Equipamento)? Busque por triggers de banco, observers,
  event listeners e jobs, não só por chamadas diretas.
- Existe tabela de domínio de Atividade (`activities`, 148 linhas distintas no dump) com
  alguma coluna de configuração/comportamento? Isso determina onde a configuração de efeito
  da Fase 5 deve morar.

### Entregável da Fase 0

Um relatório por tópico: **"hoje funciona assim" (com referência) + "o gap é este"**.
Pare aqui e reporte.

---

## Fase 1 — Baixa de insumo e entrada de produção

**Executar apenas se a Fase 0 confirmar que a movimentação não acontece.**

### Requisito

Ao concluir uma OS:

- cada item de **Insumos** debita a quantidade do saldo do **armazém selecionado no item**;
- cada item de **Produção** credita a quantidade no **armazém de destino**;
- ambos geram registro em `stock_movements` (ou no equivalente confirmado na Fase 0),
  rastreável de volta à OS.

### Regras de negócio a confirmar com o solicitante antes de codificar

1. **Quantidade planejada ou realizada?** Se a Fase 2 (confirmação por item) for
   implementada, a baixa deve usar a **quantidade realizada**, com fallback para a
   planejada. Sem a Fase 2, só existe a planejada — o que produz baixa incorreta sempre que
   o campo consumir diferente do previsto. Sinalize esse acoplamento.
2. **"Refeita" / retrabalho.** Se o backend adotar o desdobramento do mobile: uma OS
   encerrada como retrabalho provavelmente **deve** baixar o insumo consumido, mas **não**
   deve creditar produção. Decisão de produto, não técnica — pergunte.
3. **Saldo negativo.** Bloquear, permitir com alerta, ou permitir silenciosamente? Verifique
   como os módulos existentes tratam isso e siga o mesmo padrão.
4. **Estorno.** Se uma OS concluída for reaberta ou cancelada depois, a movimentação deve ser
   estornada. Definir o comportamento agora evita inconsistência de saldo.

### Implementação sugerida (menor blast radius)

- **Reusar** o serviço de movimentação já existente (Fase 0.1), não criar um paralelo.
- Acoplar a chamada **na transição para "Concluída"**, dentro da mesma transação de banco,
  com chave de idempotência derivada de `(service_order_id, item_id)`.
- Se a arquitetura já usa eventos de domínio, emitir `ServiceOrderCompleted` e tratar os
  efeitos em listener — isso é pré-requisito natural da Fase 5.
- Gravar a referência inversa: cada movimento aponta para a OS e o item que o originou
  (auditoria e estorno dependem disso).

### Critério de aceite

- Concluir uma OS com 1 insumo (10 un., Armazém A) e 1 produção (5 un., Armazém B) reduz o
  saldo de A em 10 e aumenta o de B em 5, em uma única transação.
- Repetir a chamada de conclusão não duplica a movimentação.
- A movimentação é rastreável até a OS de origem e vice-versa.

---

## Fase 2 — Confirmação por item (planejado × realizado)

**Executar apenas se a Fase 0.4 confirmar que as colunas de realizado não existem.**

### Requisito

Cada item das 5 abas de recurso (Mão de Obra, Equipamentos, Insumos, Produção,
Proteções/EPIs) ganha contraparte de **realizado**:

| Coluna | Tipo | Aplica-se a |
|---|---|---|
| `confirmed_at` | timestamp nullable | todas |
| `confirmed_by` | FK usuário/colaborador, nullable | todas |
| `note` | text nullable | todas |
| `actual_quantity` | numeric nullable | Insumos, Produção, Mão de Obra |
| `actual_hourmeter_start` / `_end` | numeric nullable | Equipamentos |

### Decisão pendente — confirmação individual vs. flag único

A pergunta original era se "Confirmado" é por pessoa ou um flag único que qualquer envolvido
marca. **Recomendação: individual.** `employee_service_order` já é tabela de vínculo por
colaborador, então o modelo suporta naturalmente `confirmed_by` por linha. Um flag único
perde a informação de quem confirmou o quê, que é justamente o valor do campo para auditoria.
Confirme com o solicitante — é decisão de produto.

### Implementação sugerida

- Migration aditiva, todas as colunas nullable. **Nenhum item existente muda de
  comportamento**; blast radius mínimo.
- Endpoint `PATCH /service-orders/{id}/items/{tipo}/{itemId}` para confirmação durante a
  execução, não só na conclusão.
- Regra: só aceita confirmação enquanto a OS está "Em Execução".

### Critério de aceite

- É possível confirmar um item isoladamente durante a execução, com observação e quantidade
  realizada diferente da planejada.
- A OS concluída expõe, por item, planejado e realizado lado a lado.
- OS antigas (sem confirmação) continuam legíveis e concluíveis.

---

## Fase 3 — Evidências de execução

**Executar apenas se a Fase 0.3 confirmar que não há anexo vinculável à OS.**

### Requisito

Registrar evidência visual durante a execução: foto, assinatura ou documento, vinculada
à OS e — opcionalmente — a um item específico.

### Implementação sugerida

Tabela `service_order_attachments`:

| Coluna | Observação |
|---|---|
| `service_order_id` | FK obrigatória |
| `item_type` / `item_id` | nullable — vínculo opcional a um item de recurso |
| `kind` | `photo` \| `signature` \| `document` |
| `storage_path` / `url` | usar a infraestrutura de storage já existente (Fase 0.3) |
| `caption` | text |
| `captured_at` | timestamp do **momento da captura em campo**, distinto de `created_at` (o upload pode ser muito posterior — o app de campo opera offline) |
| `created_by` | FK usuário |

- Endpoint de upload: `POST /service-orders/{id}/attachments` (multipart).
- **Trate o offline desde já:** o app de campo sincroniza depois. O endpoint precisa aceitar
  `captured_at` no passado e uma chave de deduplicação fornecida pelo cliente, para o mesmo
  anexo não entrar duas vezes quando a sincronização for repetida.
- Respeitar as regras de acesso já vigentes no módulo — anexo herda a visibilidade da OS.

### Critério de aceite

- Upload de foto durante a execução, recuperável na consulta da OS.
- `captured_at` preservado mesmo com upload tardio.
- Reenvio do mesmo anexo não duplica o registro.

---

## Fase 4 — Reconciliação do ciclo de status

**Depende de 0.2. Recomenda-se executar antes da Fase 1**, porque a Fase 1 acopla efeito à
transição de conclusão.

### Requisito

Um enum de status único e documentado, acordado entre backend, Desktop e app de campo.

Pontos a decidir (todos são decisão de produto — levá-los ao solicitante):

1. Existe estado de **pausa**? O app de campo tem; o Desktop não.
2. A conclusão se desdobra em **entregue vs. refeita** (retrabalho com justificativa
   obrigatória)? O app de campo desdobra; o Desktop não.
3. **"Avaliada" é status ou campo?** O Desktop trata como status posterior à conclusão; o app
   de campo trata como campo paralelo aceito apenas **antes** do encerramento. As duas regras
   são mutuamente exclusivas.
4. **Cancelamento** é permitido depois da conclusão? (No app de campo, não.)

### Implementação sugerida

- Máquina de estados explícita no backend, com transições válidas declaradas em um único
  lugar, em vez de updates de coluna espalhados.
- Toda transição gera registro de auditoria (autor, timestamp, motivo quando aplicável).
  `appropriation_movements` é o precedente desse padrão no próprio banco.
- Emitir evento de domínio por transição — base das Fases 1 e 5.

### Critério de aceite

- Transição inválida é rejeitada pelo backend, não só pela UI.
- Todo histórico de status é auditável.
- O dicionário de status está documentado no repositório.

---

## Fase 5 — Efeito genérico em cadastro-mestre

**Fase mais ambiciosa. Só executar após 1, 2 e 4, e com aprovação explícita do solicitante.**

### Problema

Hoje a OS apenas **referencia** cadastros (Área, Cultura, Lote, Categoria Animal,
Equipamento, Produto, EPI) — nunca os cria ou altera. Isso está correto para a maioria dos
casos e **deve continuar sendo o padrão**.

Mas há casos em que a conclusão da OS deveria escrever: uma OS de "Reparo de Bebedouro"
poderia atualizar o estado de conservação do bebedouro; uma de "Demarcação de Talhão"
poderia criar/atualizar o talhão.

### Requisito

Um mecanismo **genérico e declarativo** — não um `if` por nome de Atividade. Código com
regra hardcoded por atividade vira dívida no primeiro cadastro novo.

### Implementação sugerida

Tabela de configuração `activity_effects`, ligada à **Atividade** (não à OS):

| Coluna | Observação |
|---|---|
| `activity_id` | FK — qual atividade dispara este efeito |
| `effect_type` | `update_record` \| `create_record` |
| `target_entity` | entidade-alvo (bebedouro, talhão, equipamento…) |
| `target_field_map` | JSON: de qual campo da OS vem qual campo do alvo |
| `requires_confirmation` | boolean — se true, o operador confirma em campo antes de aplicar |

Execução:

- Um `ServiceOrderEffectRunner` lê os efeitos configurados para a Atividade da OS no momento
  da conclusão e os aplica via um **registry de handlers por `effect_type`**.
- **Atividade sem efeito configurado = nenhum efeito.** É o caso da esmagadora maioria e
  preserva o comportamento atual byte a byte. Essa é a garantia de blast radius.
- `effect_type` desconhecido é ignorado com log, nunca derruba a conclusão da OS. Isso
  permite que clientes antigos convivam com configuração nova.
- Todo efeito aplicado gera registro de auditoria apontando para a OS de origem.
- Efeito **nunca** deve falhar silenciosamente nem abortar a conclusão da OS: defina a
  política (transação separada com retry, ou tudo-ou-nada) junto com o solicitante.

Se a Fase 1 for implementada como listener de evento de domínio, a baixa de estoque e a
entrada de produção são apenas dois `effect_type` a mais nesse mesmo registry — **um único
mecanismo cobre as Fases 1 e 5.** Vale considerar esse desenho desde a Fase 1.

### Critério de aceite

- Uma Atividade sem configuração de efeito conclui exatamente como conclui hoje.
- Uma Atividade com efeito `update_record` atualiza o cadastro-alvo na conclusão, com
  auditoria.
- Com `requires_confirmation`, o efeito só é aplicado após confirmação explícita.
- Adicionar um novo tipo de efeito não exige alterar o fluxo de conclusão da OS.

---

## Checklist de entrega

- [ ] Fase 0 concluída e reportada ao solicitante **antes de qualquer alteração de código**
- [ ] Decisões de produto das Fases 1, 2 e 4 confirmadas com o solicitante
- [ ] Cada fase entregue como unidade lógica própria, com commit Conventional Commit
- [ ] Migrations aditivas e reversíveis; nenhuma coluna existente alterada sem necessidade
- [ ] Nenhuma alteração na interface Desktop/web
- [ ] Idempotência verificada em toda operação que movimenta saldo
- [ ] Auditoria gravada em toda transição de status e todo efeito aplicado

---

## Perguntas abertas para o solicitante

1. A baixa de estoque deve usar quantidade planejada ou realizada? (Acopla Fase 1 à Fase 2.)
2. "Refeita"/retrabalho baixa insumo? Credita produção?
3. Saldo negativo: bloquear, alertar ou permitir?
4. Confirmação de item é individual por colaborador ou flag único da OS?
5. "Avaliada" é status ou campo paralelo? Antes ou depois da conclusão?
6. A Fase 5 (efeito em cadastro-mestre) entra agora ou fica para uma leva posterior?
