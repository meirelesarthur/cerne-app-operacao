import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'doc_page.dart';

/// Versão do Widgetbook — sobe junto de cada entrada nova em
/// [widgetbookChangelog] (o teste `widgetbook_catalog_test` confere).
const kWidgetbookVersion = '2.17.0';

/// Uma entrada do changelog do catálogo.
class WidgetbookRelease {
  const WidgetbookRelease({
    required this.version,
    required this.date,
    required this.summary,
    required this.changes,
  });

  final String version;
  final String date;
  final String summary;

  /// `(tipo, descrição)` — tipo: Novo, Mudou, Docs, Removido.
  final List<(String, String)> changes;
}

/// Mais recente primeiro. Toda mudança visível no catálogo entra aqui na
/// mesma unidade lógica (Lei 4) — é o que a equipe lê para saber o que mudou.
const widgetbookChangelog = <WidgetbookRelease>[
  WidgetbookRelease(
    version: '2.17.0',
    date: '2026-09-24',
    summary:
        'Padrão global de listagem: título largo, dados com ícone, tag embaixo.',
    changes: [
      (
        'Novo',
        'RecordTile (AppRecordTile + AppRecordMetaGrid): linha de registro sem '
            'ícone à esquerda, dados de apoio com ícone no tamanho do texto '
            '(no máximo 2 por linha) e a situação embaixo do texto.',
      ),
      (
        'Mudou',
        'StatusCard: título na largura inteira, metas com ícone 2 por linha e '
            'o chip de status embaixo, nas três variantes.',
      ),
      (
        'Mudou',
        'Listagens do app (registros das rotinas, OS, Meus currais, Ordens '
            'pendentes) no padrão novo; recordMetaFromDescription escolhe o '
            'ícone de cada dado (data, lote, local, peso, animais, custo…).',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.16.0',
    date: '2026-09-24',
    summary: 'Navbar só de ícones com item ativo flutuante e adição rápida.',
    changes: [
      (
        'Novo',
        'Hexagon: caixa hexagonal (preenchida, contorno, rotação) e '
            'appHexagonPath como fonte única do formato.',
      ),
      (
        'Novo',
        'TabBar: o item ativo sobe num hexágono verde, a barra ondula sob '
            'ele e o nome aparece embaixo; ao trocar, o hexágono desliza '
            'girando até a nova aba. "+" central de ação (vira "×" aberto).',
      ),
      (
        'Mudou',
        'Navbar do app: Início, Pecuária, +, Agricultura e Menu. O "+" abre '
            'a adição rápida (apontamento, pesagem, trato diário, leitura de '
            'cocho, manejo sanitário); Confinamento segue no menu lateral.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.15.0',
    date: '2026-09-24',
    summary: 'Recursos da OS com detalhe por item, como nas abas do WEB.',
    changes: [
      (
        'Novo',
        'AppDetailList.captions e onItemTap: linha de apoio por item e linhas '
            'tocáveis com chevron — caso "Lista tocável com apoio" em '
            'DetailSection.',
      ),
      (
        'Mudou',
        'Detalhe da OS: mão de obra, máquinas e implementos, insumos, '
            'produção (nova seção), EPI e evidências abrem uma dock com os '
            'campos do WEB — insumo com un. medida, estoque, qtd/ha, qtd '
            'total e armazém; produção com un. medida, qtde, armazém e '
            'observação.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.14.0',
    date: '2026-09-24',
    summary: 'Campos de detalhe tocáveis, com o registro completo em dock.',
    changes: [
      (
        'Novo',
        'AppDetailField.onTap: a linha ganha chevron, valor e apoio ficam em '
            'até duas linhas e o toque abre o conteúdo inteiro — caso '
            '"Campos tocáveis (histórico)" em DetailSection.',
      ),
      (
        'Mudou',
        'Histórico da OS: cada evento abre uma dock com data e hora, quem '
            'registrou e a observação completa.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.13.0',
    date: '2026-09-23',
    summary:
        'Auditoria de UX do operador: contraste AA, piso de 12px e toque 48dp.',
    changes: [
      (
        'Mudou',
        'Tokens: fg.muted/subtle/quiet, erro e aviso (700) e tons âmbar/vermelho '
            'em AA (4,5:1) também sobre o canvas; CTA do modo GB com texto '
            'escuro (7,6:1 no lugar de 2,5:1); borda forte visível nos campos.',
      ),
      (
        'Removido',
        'Tamanhos de fonte 2xs (10px) e xs (11px): 12px é o piso do sistema; '
            'o corpo de leitura fica em 14px.',
      ),
      (
        'Mudou',
        'Ícone oficial de confinamento (contorno vetorizado) em AppIcons.'
            'confinamento.',
      ),
      (
        'Mudou',
        'Ícones autorais de pecuária, agricultura e frota (AppIcons.pecuaria, '
            'agricultura e gestaoFrota), usados na navbar, menu e busca.',
      ),
      (
        'Mudou',
        'SuccessPanel vira a tela de resultado padrão: faixa colorida com '
            'curva, selo animado e AppResultKind (inclusão, alteração, '
            'exclusão, salvo sem internet, aviso, erro, informação), com um '
            'caso no Widgetbook para cada.',
      ),
      (
        'Novo',
        'Button: variante outline (contorno da marca). Ícones checkSquare, '
            'editSquare, deleteSquare, alertSquare, cancelSquare, infoSquare '
            'e cloudSaved.',
      ),
      (
        'Mudou',
        'Alvos de toque: control, btn e iconBtn em 48dp (CTA grande 52); '
            'traço dos ícones em 1.5.',
      ),
      (
        'Mudou',
        'Button: rótulo herda a Outfit (DefaultTextStyle.merge), mínimo 14px, '
            'até 2 linhas com altura mínima, desabilitado com visual próprio, '
            'Semantics de botão e vibração curta no toque.',
      ),
      (
        'Mudou',
        'Tag, Banner, StatusCard, KpiStatCard, FormField, FieldCapsule, '
            'CollectionList, MenuItem, ErrorState, SuccessPanel e FileUpload '
            'usam os tokens de tom theme-aware — sem blocos pastel no modo GB.',
      ),
      (
        'Mudou',
        'FieldCapsule: sem contorno em repouso (verde só com foco, vermelho '
            'com erro). TextInput com obscureText ganha o olho de mostrar/'
            'ocultar senha.',
      ),
      (
        'Novo',
        'SplashScreen (AppSplashScreen + showAppSplash): abertura pós-login '
            'inspirada no CERNE desktop — o "C" se monta gomo a gomo, encolhe '
            'e o nome entra, com anéis orbitais. ~3,8 s, toque pula, respeita '
            'remover animações. Tokens component.splash.{bg,mark}.',
      ),
      (
        'Mudou',
        'SquareGroupGrid (cards-gaveta) vira o padrão de itens vinculados em '
            'todos os cadastros do catálogo e na Leitura de cocho: vazio abre '
            'o formulário, com itens abre o gerenciador (editar, remover com '
            'Desfazer, Adicionar fixo). collectionIcon() dá o ícone por '
            'coleção.',
      ),
      (
        'Novo',
        'Token bg.inset (AppSemanticColors.bgInset): bloco cinza sobre a folha '
            'no claro e verde elevado no Modo GB. DetailSection, Card inset, '
            'StatusCard neutro, EmptyState e MenuItem sutil deixam de sumir '
            'no escuro.',
      ),
      (
        'Novo',
        'LeaveGuard (AppLeaveGuard): pergunta "Sair sem salvar?" ao voltar com '
            'dados preenchidos; PageScaffold/PageBody ganham hasUnsavedChanges; '
            'confirmAppLeave() para saídas dentro da mesma rota.',
      ),
      (
        'Mudou',
        'StepProgress: "Etapa 2 de 4 · Nome" em texto acima da régua (label); '
            'PageScaffold/PageBody repassam stepLabel.',
      ),
      (
        'Mudou',
        'BottomSheet: sobe com o teclado e aceita dismissible: false para '
            'sheets com texto digitado.',
      ),
      (
        'Mudou',
        'Toque: SearchSelect clicável na cápsula inteira, remover arquivo e '
            'calendário em AppIconButton 48dp, Stepper com botões de 56 e sem '
            'saltar para o mínimo ao apagar, respiro entre editar e excluir.',
      ),
      (
        'Mudou',
        'IconButton desabilitado apagado; ToggleSwitch com trilho desligado '
            'visível; FormField mostra erro e dica juntos; MenuItem e título '
            'do StatusCard em até 2 linhas; StatusCard anuncia situação e '
            'metas e mantém a ação rápida acessível.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.12.0',
    date: '2026-09-23',
    summary: 'Tons theme-aware: chips e avisos legíveis no modo GB.',
    changes: [
      (
        'Novo',
        'Tokens tone.{brand,blue,amber,red,neutral}.{bg,border,fg} por tema '
            '(AppSemanticColors.tone*) e o helper appToneColors().',
      ),
      (
        'Mudou',
        'Chip (AppChip): cores dos tokens de tom. Tema claro inalterado; no '
            'modo GB, fundo translúcido do matiz em vez de pastel claro.',
      ),
      (
        'Mudou',
        'DetailSection: tons warning/danger usam os tokens de tom — no modo '
            'GB o bloco deixa de ser creme com texto quase invisível.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.11.0',
    date: '2026-09-23',
    summary: 'ActionBar com ação alternativa acima do CTA.',
    changes: [
      (
        'Novo',
        'ActionBar (AppActionBar): alternativeLabel/onAlternative — botão '
            'secundário lg em caixa alta acima do CTA, como os demais da '
            'barra. Caso "Três ações (com alternativa)".',
      ),
      (
        'Mudou',
        'Detalhe da OS: "Pausar execução" (e "Marcar como entregue" na OS '
            'pausada) usa a alternativa da barra e passa a seguir a caixa '
            'alta e o tamanho dos outros botões.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.10.0',
    date: '2026-09-23',
    summary: 'Estado vazio ilustrado e as variações por cenário.',
    changes: [
      (
        'Mudou',
        'EmptyState (AppEmptyState): arte com halo no tom, ícone Hugeicons de '
            '56 px e selo opcional (badgeIcon); tone (neutral, brand, success, '
            'info, warning, danger); size compact para folhas, seletores e '
            'abas; hint + link de ajuda ("Ver histórico"). Título sobe para h2.',
      ),
      (
        'Novo',
        'Padrões → Estados vazios: uma referência por variação encontrada no '
            'app (notificações, busca, seletor, filtro, concluído, primeiro '
            'uso, somente leitura, regra, coleção, histórico da OS, acesso '
            'restrito) e duas propostas (sem conexão, gráfico sem dados).',
      ),
      (
        'Mudou',
        'SearchSelect e o gerenciador de coleção trocam o texto solto pelo '
            'AppEmptyState compacto; SearchSelect distingue "nada encontrado" '
            'de "sem opções".',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.9.0',
    date: '2026-09-23',
    summary: 'Peças da nova Início do Operacional.',
    changes: [
      (
        'Novo',
        'AppStatusCard ganha variant: featured (título grande, chip e metas '
            'com ícone à direita, situação em faixa tingida ao lado da ação) '
            'e compact (título, uma linha de apoio e chip). AppStatusCardMeta '
            'aceita icon.',
      ),
      (
        'Novo',
        'AppModuleTileGrid aceita columns; com 3 colunas a última linha '
            'incompleta fica centralizada. AppModuleTile dense (respiro de '
            '8 px, rótulo de 13 px) para o ladrilho estreito.',
      ),
      (
        'Novo',
        'LabeledDivider (AppLabeledDivider): linha com rótulo no meio, '
            'opcionalmente tocável ("+ 3 ordens para fazer").',
      ),
      (
        'Novo',
        'AppButton variant soft: cinza bgTrack, visível sobre a folha cinza '
            'das homes ("Ver todas").',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.8.0',
    date: '2026-09-23',
    summary: 'Agrupadores com ícone e bloco cinza para o detalhe da OS.',
    changes: [
      (
        'Novo',
        'DetailSection (AppDetailSection): ícone em bolha, título de 16 px e '
            'bloco cinza sobre a folha branca, com contagem opcional e tons '
            'de atenção (segurança) e perigo (cancelamento, retrabalho).',
      ),
      (
        'Novo',
        'AppDetailFields (rótulo acima, valor grande, data de apoio; uma ou '
            'duas colunas), AppDetailList (um item por linha com marcador) e '
            'AppDetailText (texto corrido) para o conteúdo do bloco.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.7.0',
    date: '2026-09-23',
    summary: 'Notificações com tom e brilho; botão compacto não se estica.',
    changes: [
      (
        'Novo',
        'NotificationTile (AppNotificationTile): bolha com brilho na cor do '
            'tom, título, texto, selo de tempo e ponto de não lida.',
      ),
      (
        'Mudou',
        'AppButton sem fullWidth/width tem só a largura do conteúdo. Antes se '
            'esticava até a largura do pai e cobria os vizinhos (o "Marcar '
            'lidas" tapava o "Voltar" de Notificações).',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.6.0',
    date: '2026-09-23',
    summary: 'Limpeza dos restos do perfil Administração e do superapp.',
    changes: [
      (
        'Removido',
        'BalanceCard, TransactionListItem, TransactionDetailSheet, EntityRow, '
            'MetricGrid, DashboardCard, AlertStrip, MiniAppTile e BentoTile — '
            'só serviam a Bank, Crédito, hub e painéis administrativos.',
      ),
      (
        'Removido',
        'Ícones landmark, creditCard, creditCardAccept, handCoins, '
            'shoppingBag e os apelidos marketplace, openFinance e banking.',
      ),
      (
        'Mudou',
        'Casos de AppIconTile, SegmentedTabs, SectionTitle, Tag, ReviewList, '
            'KpiStatCard, QuickAction, DiscoveryTile e o padrão Menu passam a '
            'usar exemplos de campo.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.5.0',
    date: '2026-09-23',
    summary: 'Login: CTA em caixa alta e ambiente no rodapé.',
    changes: [
      (
        'Mudou',
        'Padrão Login: botão "ENTRAR" em caixa alta (leitor de tela mantém '
            '"Entrar"); a indicação do ambiente sai do card e vai para o '
            'rodapé, abaixo do tour, por ser informação de protótipo.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.4.0',
    date: '2026-09-23',
    summary: 'Situação e ação rápida no StatusCard; confirmação de ação.',
    changes: [
      (
        'Mudou',
        'StatusCard ganha situation (linha com ícone e tom: neutro, info, '
            'alerta, perigo, sucesso) e action (um botão por card, alvo de '
            'toque próprio).',
      ),
      (
        'Novo',
        'showAppConfirm: confirmação explícita com botões grandes e verbo da '
            'ação, para o que gera histórico (iniciar, retomar, entregar).',
      ),
      ('Novo', 'Ícones play e pause no catálogo.'),
    ],
  ),
  WidgetbookRelease(
    version: '2.4.0',
    date: '2026-09-23',
    summary: 'Rodapé fixo sem faixa cinza: botões flutuam sobre a folha.',
    changes: [
      (
        'Mudou',
        'ActionBar (AppActionBar) perde fundo e sombra próprios em todas as '
            'variantes — cadastro, fluxo com resumo e detalhe de OS agora '
            'seguem o CTA flutuante de listagem, com os botões sobre o fundo '
            'da tela.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.3.0',
    date: '2026-09-23',
    summary: 'Atalhos da tela inicial como ícones de aplicativo.',
    changes: [
      (
        'Mudou',
        'AppIconTile ganha labelMaxLines: nomes de rotina em até duas linhas '
            'na grade de quatro colunas de atalhos da tela inicial.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.2.0',
    date: '2026-09-23',
    summary: 'Seletor discreto de filtro com dock inferior.',
    changes: [
      (
        'Novo',
        'InlineSelect (AppInlineSelect): valor atual + chevron, sem borda '
            'nem fundo; abre a dock inferior com as opções e marca a '
            'escolhida. Filtro de status da tela inicial de OS.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.1.0',
    date: '2026-09-23',
    summary: 'Card de status para listas de ordens e filtros roláveis.',
    changes: [
      (
        'Novo',
        'StatusCard (AppStatusCard): chip de status no topo, identificador '
            'em destaque, descrição e legenda, pares rótulo/valor à direita. '
            'Usado na tela inicial de Ordens de Serviço.',
      ),
      (
        'Mudou',
        'SegmentedTabs ganha scrollable: segmentos do tamanho do rótulo num '
            'trilho que rola na horizontal, para filtros de listagem.',
      ),
      (
        'Mudou',
        'MenuItem onDark (menu lateral) vira linha plana: sem cápsula, sem '
            'bolha de ícone e sem chevron, alvo de 48 px.',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '2.0.0',
    date: '2026-09-23',
    summary:
        'Cards-gaveta para coleções, gerenciador de itens e documentação '
        'viva do catálogo.',
    changes: [
      (
        'Novo',
        'CollectionManager (showAppCollectionManager): lista os itens de uma '
            'coleção com linha clicável para editar, lixeira com "Desfazer", '
            '"Adicionar" fixo no rodapé e reabertura automática após salvar.',
      ),
      (
        'Mudou',
        'SquareGroupGrid v2: card inteiro clicável; vazio com borda '
            'tracejada, com itens com "N itens incluídos", resumo agregado e '
            '"Ver itens"; grupo largo (wide); altura estável de 1 a 10 itens. '
            'API passou a receber List<AppSquareGroup>.',
      ),
      (
        'Mudou',
        'CollectionList: lixeira no lugar do "×", linha inteira abre a '
            'edição, showHeader e highlightIndex.',
      ),
      (
        'Mudou',
        'BottomSheet ganha footer fixo; Pressable ganha excludeSemantics para '
            'superfícies clicáveis com botões internos.',
      ),
      (
        'Docs',
        'Pasta Documentação → Guia: "Comece aqui", inventário gerado da '
            'própria árvore do catálogo e este changelog. Tema passou para '
            'Fundamentos.',
      ),
      (
        'Docs',
        'Padrões → Coleções em cadastro: quando usar cada componente de '
            'coleção, com exemplo vivo.',
      ),
      (
        'Mudou',
        'Widgetbook publicado ocupa a tela inteira (sem a moldura de celular '
            'do app) e cada caso tem link direto (/storybook/#/?path=...).',
      ),
    ],
  ),
  WidgetbookRelease(
    version: '1.0.0',
    date: 'antes de 2026-09-23',
    summary:
        'Catálogo component-first inicial (F2.5), sem versionamento formal.',
    changes: [
      (
        'Novo',
        'Catálogo por família (Ações, Superfícies, Formulário, Padrão global, '
            'Feedback, Overlay, Dados, Gráficos), padrões de tela e auditoria '
            'de tema (cores, espaçamento, tipografia).',
      ),
    ],
  ),
];

/// Documentação → Guia → Comece aqui.
class WidgetbookIntroductionPage extends StatelessWidget {
  const WidgetbookIntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DocPage(
      eyebrow: 'GB CERNE · Widgetbook v$kWidgetbookVersion',
      title: 'Comece aqui',
      lead:
          'O catálogo vivo dos componentes do CERNE Operação. Tudo o que '
          'aparece aqui é o widget real de lib/ui — o mesmo código que as '
          'telas do app usam.',
      children: [
        DocSection(
          title: 'Como navegar',
          children: [
            DocBullets([
              (
                'Documentação',
                'este guia, o inventário do catálogo e o changelog.',
              ),
              (
                'Fundamentos',
                'tokens de cor, espaçamento, raio e tipografia (Outfit).',
              ),
              (
                'Padrões',
                'composições de tela prontas: login, listagem, menu, CRUD e '
                    'coleções em cadastro.',
              ),
              (
                'Catálogo',
                'cada componente público, agrupado por família, com um caso '
                    'por estado relevante.',
              ),
            ]),
            DocText(
              'Use o addon de tema no painel lateral para alternar entre '
              'Light e GB Mode. Casos marcados com "(knob)" têm controles '
              'interativos no painel de knobs.',
            ),
          ],
        ),
        DocSection(
          title: 'As leis do catálogo',
          children: [
            DocBullets([
              (
                'Component-first',
                'todo controle visível reutilizável nasce em lib/ui antes de '
                    'ser usado por uma tela.',
              ),
              (
                'Fonte única',
                'variações entram como props do widget compartilhado — nunca '
                    'como cópia ou ajuste local numa tela.',
              ),
              (
                'Tokens e tipografia',
                'cores, espaços, raios, sombras e movimento vêm de '
                    'design/generated; Outfit é a única família.',
              ),
              (
                'Pipeline DTCG',
                'design/tokens.ts → tokens.json → Dart gerado; valor novo '
                    'entra primeiro na fonte.',
              ),
            ]),
          ],
        ),
        DocSection(
          title: 'Checklist para um componente novo',
          children: [
            DocBullets([
              ('1', 'Criar lib/ui/<nome>.dart com o widget App<Nome>.'),
              ('2', 'Exportar no barrel lib/ui/ui.dart.'),
              (
                '3',
                'Escrever build<Nome>WidgetbookComponent() no mesmo arquivo, '
                    'com um caso por estado: vazio, preenchido, limite (ex.: '
                    '10 itens), erro/desabilitado quando existir.',
              ),
              (
                '4',
                'Registrar o builder na família certa em widgetbook_app.dart '
                    '(o teste component_first_test falha se faltar).',
              ),
              ('5', 'Cobrir comportamento em test/ui/<nome>_test.dart.'),
              (
                '6',
                'Adicionar a mudança em widgetbook/docs/guide_pages.dart '
                    '(changelog) e subir kWidgetbookVersion.',
              ),
            ]),
            DocCallout(
              title: 'O inventário se atualiza sozinho',
              text:
                  'Documentação → Guia → Inventário é gerado da própria árvore '
                  'do Widgetbook. Registrou o builder, ele aparece lá — não há '
                  'lista manual para manter.',
              icon: AppIcons.refreshCw,
            ),
          ],
        ),
        DocSection(
          title: 'Como nomear os casos',
          children: [
            DocText(
              'O nome do caso descreve o estado ou o uso, não a '
              'implementação: "Vazio (primeiro acesso)", "Lista longa (10 '
              'itens)", "Somente leitura (revisão/ficha)". Casos interativos '
              'começam com "Interativo".',
            ),
            DocText(
              'Cada caso tem link direto — copie a URL da barra do navegador '
              '(/storybook/#/?path=...) para compartilhar em revisão ou '
              'handoff. Por isso nomes de caso não usam "+", "&", "#", "?" '
              'nem "%".',
            ),
          ],
        ),
      ],
    );
  }
}

/// Documentação → Guia → Novidades: o changelog renderizado.
class WidgetbookChangelogPage extends StatelessWidget {
  const WidgetbookChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return DocPage(
      eyebrow: 'Changelog',
      title: 'Novidades do catálogo',
      lead:
          'O que mudou em cada versão do Widgetbook, da mais recente para a '
          'mais antiga.',
      children: [
        for (final release in widgetbookChangelog)
          DocSection(
            title: 'v${release.version} · ${release.date}',
            children: [
              DocText(release.summary),
              for (final (kind, text) in release.changes)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Largura mínima alinha os textos; "Removido" é mais
                      // largo que a coluna e empurra só a própria linha.
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.space20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AppChip(
                            tone: switch (kind) {
                              'Novo' => AppChipTone.brand,
                              'Removido' => AppChipTone.red,
                              _ => AppChipTone.neutral,
                            },
                            child: Text(kind),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            height: 1.5,
                            color: semantic.fgDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Documentação → Guia → Inventário: gerado da árvore real do Widgetbook,
/// então nunca desatualiza em relação aos componentes registrados.
class WidgetbookInventoryPage extends StatelessWidget {
  const WidgetbookInventoryPage({super.key, required this.nodes});

  final List<WidgetbookNode> nodes;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final catalog = nodes.firstWhere(
      (node) => node.name == 'Catálogo',
      orElse: () => WidgetbookFolder(name: 'Catálogo', children: const []),
    );
    final families = [
      for (final node in catalog.children ?? const <WidgetbookNode>[])
        if (node is WidgetbookFolder) node,
    ];

    List<WidgetbookComponent> componentsOf(WidgetbookNode node) => [
      for (final child in node.children ?? const <WidgetbookNode>[])
        if (child is WidgetbookComponent) child else ...componentsOf(child),
    ];

    final all = componentsOf(catalog);
    final useCases = all.fold<int>(0, (sum, c) => sum + c.useCases.length);
    final single = [
      for (final component in all)
        if (component.useCases.length == 1) component.name,
    ];

    return DocPage(
      eyebrow: 'Inventário',
      title: 'O que existe no catálogo',
      lead:
          'Gerado a partir da árvore registrada em widgetbook_app.dart — '
          'componentes novos aparecem aqui assim que são registrados.',
      children: [
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: [
            _Stat(label: 'Famílias', value: '${families.length}'),
            _Stat(label: 'Componentes', value: '${all.length}'),
            _Stat(label: 'Casos de uso', value: '$useCases'),
            _Stat(label: 'Com um só caso', value: '${single.length}'),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        for (final family in families)
          DocSection(
            title: '${family.name} · ${componentsOf(family).length}',
            children: [
              DocTable(
                header: const ['Componente', 'Casos de uso'],
                rows: [
                  for (final component in componentsOf(family))
                    [
                      component.name,
                      component.useCases.map((u) => u.name).join(' · '),
                    ],
                ],
              ),
            ],
          ),
        if (single.isNotEmpty)
          DocSection(
            title: 'Oportunidades de documentação',
            children: [
              const DocText(
                'Componentes com um único caso de uso — candidatos a ganhar '
                'casos de estado (vazio, limite, erro, desabilitado):',
              ),
              Text(
                single.join(' · '),
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  height: 1.6,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      width: AppSize.drawer / 2,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppTypography.xl2,
              fontWeight: AppTypography.weightBold,
              color: semantic.fgDefault,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: semantic.fgMuted,
            ),
          ),
        ],
      ),
    );
  }
}
