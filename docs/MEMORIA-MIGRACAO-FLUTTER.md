# Memória de continuidade — extinção do React e corte definitivo para Flutter

> Documento operacional para retomada entre sessões. Leia este arquivo antes de alterar o projeto e atualize-o no mesmo commit de cada onda concluída.

## Objetivo imutável

Transformar o Flutter em `apps/mobile` na única implementação oficial do GB CERNE, portar para Dart toda a cobertura funcional hoje mais recente no React, publicar app + Widgetbook pela mesma pipeline e remover o runtime React somente depois do gate de paridade.

O escopo continua sendo um protótipo exclusivamente frontend, com mocks e simulações. Autenticação real, RBAC de backend, APIs e integrações nativas de hardware não devem ser apresentados como concluídos.

## Checkpoint atual — 16/08/2026

- Branch: `feature/flutter-migration`.
- Baseline antes da criação desta memória: `960fe545b73e7092587a30b746db3ed495c47acd`.
- A branch local estava sincronizada com `origin/feature/flutter-migration` nesse baseline.
- O React continua sendo a versão mais recente para apresentação e deve permanecer publicado até o corte formal.
- M0, M1 e M2 foram enviadas ao remoto até `3021f9c`; M3, M4 e M5 foram concluídas localmente e aguardam push sob demanda.
- O Flutter agora exige sessão demonstrativa, oferece Login Administração/Login Operacional e protege rotas cruzadas por perfil.
- A correção temporária do deploy React foi enviada no commit `0489a2e`: `wrangler.jsonc` publica `dist` como SPA no Cloudflare Worker.
- `AGENTS.md` aparece como arquivo não rastreado e pertence ao usuário: não adicionar, editar ou remover sem autorização explícita.
- `RTK.md`, embora referenciado nas instruções do projeto, não foi encontrado no repositório neste checkpoint.

## Verdade técnica atual

### Flutter existente

- Aplicativo em `apps/mobile/lib`, iniciado por `apps/mobile/lib/main.dart`.
- Seis módulos: Início, Fazendas, Bank, Crédito, Marketplace e Armazém.
- Estado com Riverpod, rotas com `go_router`, tema/tokenização e fonte Outfit local.
- Catálogo Flutter e Widgetbook em `apps/mobile/lib/widgetbook_app.dart`.
- Build combinado disponível em `apps/mobile/tool/cf_pages_build.sh`, gerando:
  - aplicativo em `build/site`;
  - Widgetbook em `build/site/storybook`.
- A migração Flutter existente representa a versão anterior do protótipo, antes das mudanças recentes de perfil e das ondas funcionais A–H.

### React ainda mais recente

- Aplicativo React em `src`, iniciado por Vite.
- O comando raiz `npm run build` executa `tsc -b && vite build` e gera a versão React em `dist`.
- A separação Administração/Operacional, os dois logins e as ondas A–H estão implementados principalmente no React.
- Catálogo funcional canônico atual: `src/modules/fazendas/functionalCatalog.ts`.
- Cobertura atual documentada:
  - 53 funcionalidades;
  - 12 administrativas;
  - 41 operacionais;
  - 46 com jornada frontend pronta;
  - 7 com simulação funcional de hardware;
  - zero item apenas `Mapeado`.

### Commits React que formam a referência de portabilidade

| Entrega | Commit |
|---|---|
| Separação Administração/Operacional | `8cbadb1` |
| Onda A | `874705e` |
| Onda B | `da62f91` |
| Onda C | `22c87d6` |
| Onda D | `047d72a` |
| Onda E | `888fd21` |
| Onda F | `fa73647` |
| Onda G | `5017912` |
| Onda H | `960fe54` |

Esses commits são especificação de comportamento, não código a ser reutilizado diretamente. A implementação Flutter deve ser Dart nativo, component-first e aderente aos tokens.

## Regras de execução

1. React fica congelado: nenhuma funcionalidade nova deve ser criada nele.
2. Não apagar React antes de todos os gates de corte estarem verdes.
3. Criar o widget reutilizável em `apps/mobile/lib/ui` antes da tela que o consome.
4. Estado compartilhado ou de sessão deve usar Riverpod; não criar globais ou `setState` para estado de domínio.
5. Usar `LayoutBuilder`/constraints quando o layout precisar se adaptar.
6. Interações devem ter `Semantics`, foco e alvo de toque mínimo de 44dp.
7. Fonte Outfit e valores gerados dos tokens continuam obrigatórios; não aceitar cores, fontes, espaços ou raios literais nas telas.
8. Cada onda concluída recebe seu próprio commit Conventional Commit imediatamente.
9. Atualizar este arquivo no mesmo commit da onda, marcando o checkbox e registrando hash, testes e pendências.
10. Push somente mediante solicitação explícita do usuário.

## Esteira de migração

### M0 — Congelamento e contrato de paridade

- [x] Marcar o React como referência congelada na documentação.
- [x] Criar matriz verificável das 53 funcionalidades React → Flutter.
- [x] Registrar rota, perfil, maturidade e destino de cada item; campos, validações e dependências permanecem vinculados por ID ao catálogo React congelado até a porta Dart de M1.
- [x] Registrar as jornadas críticas que serão usadas no aceite visual.

Gate: não existe item do Markdown sem uma linha de rastreabilidade.

Commit planejado: `docs(mobile): formaliza matriz de paridade para extincao do React`.

### M1 — Catálogo funcional em Dart

- [x] Criar o contrato Dart equivalente ao `functionalCatalog.ts`.
- [x] Portar as 12 funcionalidades administrativas e 41 operacionais.
- [x] Representar campos, grupos, opções, obrigatoriedade, tipo de entrada, status e dependências.
- [x] Criar gate/teste que valide 53 itens, divisão 12/41, IDs únicos, zero `Mapped` e sete itens de hardware simulável.

Gate: o catálogo Dart passa a ser a fonte funcional do app Flutter.

Commit planejado: `feat(mobile): porta catalogo funcional AGRO365 para Dart`.

### M2 — Motor de jornadas e componentes

- [x] Criar motor reutilizável para lista → formulário → validação → sucesso, com rascunho de detalhe consumido pelo armazenamento; a composição visual da tela entra em M3.
- [x] Criar armazenamento de registros de protótipo com Riverpod.
- [x] Criar equivalentes Flutter de grupos adicionáveis, superfície pressionável, preparação de exportação de auditoria e simulador de hardware.
- [x] Publicar componentes e variantes no Widgetbook antes de usá-los em telas.

Gate: uma funcionalidade dirigida pelo catálogo completa a jornada inteira e possui testes.

Commit planejado: `feat(mobile): cria motor funcional reutilizavel AGRO365`.

### M3 — Separação de responsabilidades

- [x] Criar botões Login Administração e Login Operacional no Flutter.
- [x] Persistir o perfil da sessão demonstrativa em Riverpod.
- [x] Proteger o shell e deep links sem sessão.
- [x] Criar central de gestão e central de rotinas.
- [x] Restringir rotas, abas, menus e ações por perfil.
- [x] Remover do Flutter a alternância local Gerencial/Campo; o perfil define a responsabilidade durante a sessão.

Gate: operador não acessa dashboards; administrador não cria entradas; logout invalida a sessão.

Commit planejado: `feat(mobile): separa ambientes administrativo e operacional`.

### M4 — Onda A Flutter

- [x] Áreas.
- [x] Formulações.
- [x] Batidas.
- [x] Apontamento agrícola.
- [x] Abastecimento e Manutenção de Frota.

Gate: lista, criação, validação, sucesso e consulta compartilham os mesmos registros em memória.

Commit planejado: `feat(mobile): conclui onda A funcional AGRO365`.

### M5 — Onda B Flutter

- [x] Rebanho Inicial, Lotes e Animais.
- [x] Transferência Lote/Área, Sanitário, Desmama e Pastagens.
- [x] Estação de Monta, Lotes/Reprodução, Material Reprodutivo, Protocolos, Monta Natural e Diagnóstico de Gestação.

Gate: todas as jornadas possuem validação explícita e premissas de domínio sinalizadas.

Commit planejado: `feat(mobile): conclui onda B de pecuaria e reproducao`.

### M6 — Onda C Flutter

- [ ] Descoberta e conexão Bluetooth simuladas.
- [ ] Balança e captura de peso simuladas.
- [ ] RFID e alternativa manual.
- [ ] Scanner SISBOV.
- [ ] Transferência de animal, Localização e Perdas.

Gate: os sete itens têm simulação navegável e permanecem identificados como dependentes de hardware real.

Commit planejado: `feat(mobile): conclui onda C de simulacoes de hardware`.

### M7 — Onda D Flutter

- [ ] Saldo de Estoque e Processamentos Pecuários.
- [ ] Logs e exportação local de auditoria.
- [ ] Carga, Descarga, Nota de Cocho e Configurações do Misturador.
- [ ] Marcação agrícola.
- [ ] Compra de Animais, Apartação e Minhas OS.

Gate: 46 itens `Ready`, sete `Hardware` simulados e nenhum item apenas mapeado.

Commit planejado: `feat(mobile): conclui onda D de cobertura funcional`.

### M8 — Onda E Flutter

- [ ] Sessão demonstrativa obrigatória.
- [ ] Logout efetivo.
- [ ] Proteção de deep links e rotas cruzadas.
- [ ] Gate funcional incorporado ao CI Flutter.

Gate: tentativa de acesso direto sem sessão retorna ao login correto.

Commit planejado: `fix(mobile): conclui onda E de endurecimento frontend`.

### M9 — Onda F Flutter

- [ ] Alvos de toque mínimos de 44dp.
- [ ] `Semantics` e rótulos contextuais.
- [ ] Foco/teclado na web.
- [ ] Auditoria em 390×844 e layouts adaptativos sem overflow.

Gate: testes de semântica e inspeção das jornadas críticas aprovados.

Commit planejado: `fix(mobile): conclui onda F de acessibilidade`.

### M10 — Onda G Flutter

- [ ] Auditar component-first em todas as telas novas.
- [ ] Bloquear controles visíveis reimplementados fora de `lib/ui` quando houver equivalente no catálogo.
- [ ] Garantir que todos os novos componentes apareçam no Widgetbook.

Gate: zero duplicação local de widgets do design system.

Commit planejado: `refactor(mobile): conclui onda G component first`.

### M11 — Onda H Flutter

- [ ] Auditar cores, tipografia, espaçamento, raio, sombra e movimento.
- [ ] Sincronizar `tokens.ts` → DTCG → Dart gerado quando necessário.
- [ ] Criar/verificar guardrails contra hardcode visual.

Gate: tokens DTCG e arquivos Dart gerados não divergem.

Commit planejado: `refactor(mobile): conclui onda H de integridade de tokens`.

### M12 — Pipeline oficial e corte Cloudflare

- [ ] Fixar Flutter `3.44.6` no CI e no build Cloudflare.
- [ ] Fazer o CI compilar o app e o entrypoint real do Widgetbook.
- [ ] Gerar exclusivamente `apps/mobile/build/site`.
- [ ] Configurar Cloudflare Pages ou Worker Static Assets de acordo com o produto real do dashboard.
- [ ] Se for Worker, adicionar Wrangler e fallback separado para `/storybook/*` e para o app.
- [ ] Executar smoke tests em `/`, `/login`, deep links dos dois perfis e `/storybook/`.
- [ ] Aprovar preview Flutter antes de trocar o ambiente público.

Gate: a URL pública entrega Flutter e o Widgetbook sem depender do build React.

Commit planejado: `ci: torna Flutter a unica pipeline oficial`.

### M13 — Extinção do React

- [ ] Criar tag de rollback do último estado React.
- [ ] Remover componentes, módulos, shell, imagens duplicadas e entrypoints React.
- [ ] Remover Vite, Tailwind, Zustand, react-router e dependências React.
- [ ] Remover `dist` e configurações exclusivas do aplicativo React.
- [ ] Manter temporariamente somente o tooling TypeScript neutro necessário à Lei 5, ou migrá-lo em mudança própria aprovada.
- [ ] Atualizar README, arquitetura, comandos e instruções para refletirem Flutter.
- [ ] Confirmar por busca que não existe runtime React restante.

Gate final: Flutter é o único aplicativo, o único build de apresentação e a única pipeline de deploy.

Commit planejado: `refactor: remove aplicacao React apos corte Flutter`.

## Gates obrigatórios antes de M13

- [ ] 53/53 funcionalidades presentes no catálogo Dart.
- [ ] 12 administrativas e 41 operacionais verificadas por teste.
- [ ] Login e rotas protegidas nos dois perfis.
- [ ] Ondas A–H portadas e commitadas separadamente.
- [ ] `dart format` limpo.
- [ ] `flutter analyze --fatal-infos` verde.
- [ ] `flutter test` verde.
- [ ] App Flutter Web compilado.
- [ ] Widgetbook compilado pelo entrypoint `lib/widgetbook_app.dart`.
- [ ] Paridade visual light/GB Mode aprovada nas jornadas críticas.
- [ ] Preview Cloudflare Flutter aprovado.
- [ ] Rollback React etiquetado e identificável no Git.

## Protocolo de retomada para uma nova sessão

1. Ler `AGENTS.md`, este arquivo, `PLANO-MIGRACAO-FLUTTER.md` e `docs/ESTEIRA-PERFIS-AGRO365.md`.
2. Executar `git status --short --branch` e preservar qualquer alteração do usuário.
3. Executar `git log --oneline -20` e localizar o último commit registrado nesta memória.
4. Identificar a primeira etapa M0–M13 ainda não marcada.
5. Inspecionar o commit React de referência da onda antes de escrever o equivalente Dart.
6. Implementar somente uma unidade lógica por vez.
7. Rodar os testes proporcionais à onda e depois os gates Flutter completos antes de fechá-la.
8. Atualizar os checkboxes, registrar o hash e os testes executados neste documento.
9. Criar o commit imediatamente; não fazer push sem pedido explícito.

## Registro de execução

| Etapa | Estado | Commit Flutter | Verificações | Observações |
|---|---|---|---|---|
| Memória inicial | Concluída | preencher pelo histórico Git | Arquivo criado; nenhuma implementação iniciada | React permanece oficial por ora |
| M0 | Concluída | `8e03fad` | Matriz 53/53; contagem 12/41 conferida | React congelado como referência; nenhuma tela alterada |
| M1 | Concluída | `da3c8dd` | Analyze limpo; 7 testes de contrato; 58 testes de Fazendas verdes | 168 campos, 156 obrigatórios, 46 Ready e 7 Hardware; suíte global excedeu 10 min sem falha reportada |
| M2 | Concluída | `3021f9c` | Analyze limpo; 10 testes novos; Widgetbook Web compilado | Catálogo ampliado de 42 para 46 componentes; download físico do arquivo de auditoria será conectado em M7 |
| M3 | Concluída | `f786870` | Analyze limpo; 45 testes focados verdes; Flutter Web compilado | Duas centrais derivadas do catálogo 12/41; rotas cruzadas redirecionam; logout invalida sessão; jornadas sem tela própria permanecem para M4–M7 |
| M4 / A | Concluída | `93f5d58` | Analyze limpo; 25 testes focados verdes; teste ponta a ponta lista → validação → sucesso → consulta | Tela dirigida pelo catálogo reutiliza o motor M2; seis contratos da onda usam os mesmos registros Riverpod e Administração lê Áreas criadas no Operacional |
| M5 / B | Concluída | este commit (`feat(mobile): conclui onda B de pecuaria e reproducao`) | Analyze limpo; 19 testes focados verdes | Treze contratos executáveis; período reprodutivo inválido é bloqueado; grupos de Pastagens aceitam itens vinculados |
| M6 / C | Pendente | — | — | — |
| M7 / D | Pendente | — | — | — |
| M8 / E | Pendente | — | — | — |
| M9 / F | Pendente | — | — | — |
| M10 / G | Pendente | — | — | — |
| M11 / H | Pendente | — | — | — |
| M12 | Pendente | — | — | — |
| M13 | Pendente | — | — | — |
