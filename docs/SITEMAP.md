# GB CERNE Operação — Mapa do app

Mapa do protótipo navegável do **CERNE Operação** (perfil único: Operacional). Fonte das rotas:
`apps/mobile/lib/router/app_router.dart`, `apps/mobile/lib/modules/fazendas/fazendas_module.dart`
e o catálogo `apps/mobile/lib/modules/fazendas/functional_catalog.dart`.

**Legenda:** `[rota]` tela com URL · `[dock]` folha inferior (sem rota) · `[tela cheia]`
visualização empilhada sem URL própria · `[menu]` menu lateral.

---

## Entrada e shell

```
/login          [rota]  login mock → /fazendas/operacional · "Tour pelo app" → onboarding
/onboarding     [rota]  3 telas de campo · "Pular"/"Começar" → login
/               [rota]  redirect → /fazendas/operacional
/notificacoes   [rota]  cada item leva ao módulo de origem
/perfil         [rota]  configurações · Modo GB · sair
/busca          [rota]  busca global no catálogo funcional (tela cheia)
```

Shell das telas rasas: seletor de fazenda no topo, saudação, campo de busca e a navbar flutuante
**Início · Pecuária · Agricultura · Menu**. Telas fundas (cadastros e fluxos) escondem a navbar e
mostram só a faixa de 64 px com título e "Voltar".

**Menu lateral** `[menu]` (aba Menu): grupo único **MENU** — Início, Ordens de serviço,
Confinamento, Pecuária, Agricultura, Reprodução, Consultas, Gestão de Frota, Sincronizar
aplicativo — e a seção **CONTA** (Notificações, Configurações, Modo GB, Conexão, Sair).

---

## Início — `/fazendas/operacional`

- **Minhas OS**: até 3 OS em andamento (em execução primeiro), com linha de situação (atrasada,
  pausada há X, vence hoje, em execução há X…) e ação rápida (Iniciar, Pausar, Retomar), sempre
  com confirmação. Some quando não há OS em andamento. "Ver todas" → `/fazendas/campo/minhas-os`.
- **Atalhos**: grade 4 colunas com os mesmos itens do menu lateral.
- Tocar numa OS abre o **detalhe da OS** `[tela cheia]` com as ações no rodapé.

## Grupos — `/fazendas/operacional/grupo/:slug`

Grupos com mais de uma função abrem a central do grupo; grupos de uma função só abrem a
funcionalidade direto.

| Grupo | Funcionalidades (rota) |
|---|---|
| **Confinamento** | Trato diário (`/fazendas/campo/trato-diario`) · Leitura de cocho (`campo/leitura-cocho`) · Meus currais (`campo/meus-currais`) · Produzir batelada (`campo/batelada`) · Ordens pendentes (`campo/ordens-pendentes`) · Configurações do misturador · Conexão de aparelhos |
| **Pecuária** | Pesagens (`campo/pesagem`) · Sanitário · Arraçoamento (`campo/arracoamento`) · Transferência animal/lote · Transferência lote/área · Localizar animal · Pastagens · Apartação · Nascimentos e Mortes (`campo/ciclo`) · Desmama · Registrar animal · Perdas · Rebanho inicial · Scanner SISBOV · Conexão de aparelhos |
| **Agricultura** | Apontamento agrícola (`campo/apontamento`) · Marcação |
| **Ordem de serviço** | Minhas OS (`campo/minhas-os`): lista completa com filtro de status em dock (Todas, Aguardando, Em execução, Finalizadas) |
| **Reprodução** | Acasalamento · Diagnóstico de gestação |
| **Consultas** (somente leitura) | Lote de animais · Áreas · Formulações · Batida · Estação de monta · Protocolos/estação · Touros/sêmen/embrião |
| **Gestão de frota** | Abastecimentos · Manutenção |
| **Sincronização** | Sincronização de dados (`campo/sincronizacao`) |

Funcionalidades sem rota própria abrem no motor genérico em `/fazendas/operacional/:featureId`.

---

## Fora do escopo deste repositório

Perfil Administração, Bank, Crédito, Marketplace, Armazém e o hub "Início"/"Seus apps" foram
removidos. Cadastros estruturantes (pátios, currais, dietas, OS) nascem no app web do escritório;
o mobile só lança o que acontece em campo.
