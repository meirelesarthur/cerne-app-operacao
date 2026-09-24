import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/models.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/state/ordem_servico_store.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/widgets.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/components/reveal_menu.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/module_tile.dart';
import 'package:cerne_app/ui/page_scaffold.dart';
import 'package:cerne_app/ui/search_field.dart';
import 'package:cerne_app/ui/status_card.dart';

import '../support/router_test_harness.dart';
import '../support/test_viewport.dart';

late RouterTestHarness harness;

/// Rótulo dentro do menu lateral — os atalhos da tela inicial repetem os
/// mesmos nomes atrás dele.
Finder _noMenu(String label) =>
    find.descendant(of: find.byType(AppRevealMenu), matching: find.text(label));

void main() {
  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.operational);
    addTearDown(() => harness.dispose());
    harness.router.go('/fazendas/operacional');
  });

  group('appRouter', () {
    testWidgets('entrada operacional usa o chrome e a navegação de campo', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Boa tarde,'), findsOneWidget);
      expect(find.text('Fazenda São Pedro'), findsOneWidget);
      expect(find.text('Procurando por algo?'), findsOneWidget);
      expect(find.text('O que fazer hoje'), findsNothing);
      // Tela inicial: até duas OS no topo, o resto como contagem, e o menu
      // em ladrilhos logo abaixo.
      expect(find.text('Ver todas'), findsOneWidget);
      expect(find.text('+ 4 ordens aguardando'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBottomTabBar),
          matching: find.bySemanticsLabel('Início'),
        ),
        findsOneWidget,
      );
      expect(find.byType(AppModuleTile), findsWidgets);
    });

    testWidgets(
      'tela inicial mostra até 2 OS: a em execução em destaque e a próxima',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        final cards = tester
            .widgetList<OsSummaryCard>(find.byType(OsSummaryCard))
            .toList();
        expect(cards, hasLength(2));
        expect(cards.first.os.status, OrdemServicoStatus.emExecucao);
        expect(cards.first.variant, AppStatusCardVariant.featured);
        expect(cards.last.variant, AppStatusCardVariant.compact);
      },
    );

    testWidgets('sem OS em andamento, a seção some e ficam só os atalhos', (
      tester,
    ) async {
      final store = harness.container.read(ordemServicoStoreProvider.notifier);
      for (final os
          in harness.container.read(ordemServicoStoreProvider).ordens) {
        store.cancelar(os.id, autor: 'Teste', motivo: 'Sem OS na fazenda');
      }
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Ver todas'), findsNothing);
      expect(find.byType(OsSummaryCard), findsNothing);
      expect(find.byType(AppModuleTile), findsWidgets);
    });

    testWidgets('tocar numa OS abre o detalhe em tela cheia com as ações', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OsSummaryCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(AppPageScaffold), findsOneWidget);
      expect(find.text('Ordem de serviço'), findsOneWidget);
      // Em execução: entregar é o CTA; pausar e refazer ficam no rodapé.
      expect(find.text('ENTREGAR SERVIÇO'), findsOneWidget);
      expect(find.text('PAUSAR EXECUÇÃO'), findsOneWidget);
      // Tela cheia cobre a navbar.
      expect(find.byType(AppBottomTabBar), findsNothing);

      await tester.tap(find.text('ENTREGAR SERVIÇO'));
      await tester.pumpAndSettle();

      // Encerrar exige confirmação explícita.
      expect(find.text('Entregar a OS #2198?'), findsOneWidget);
      await tester.tap(find.text('Entregar serviço'));
      await tester.pumpAndSettle();

      // Continua na tela, agora sem ações (OS encerrada).
      expect(find.text('Ordem de serviço'), findsOneWidget);
      expect(find.text('ENTREGAR SERVIÇO'), findsNothing);
    });

    testWidgets(
      'botão Iniciar do card pede confirmação, e cancelar não registra nada',
      (tester) async {
        harness.dispose();
        harness = RouterTestHarness(
          profile: UserAccessProfile.operational,
          overrides: [
            osRelogioProvider.overrideWithValue(
              () => DateTime(2026, 9, 23, 10),
            ),
          ],
        );
        harness.router.go('/fazendas/operacional');
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // Sem a em execução e a pausada, a primeira da fila é a aguardando
        // mais urgente — em destaque, com o botão Iniciar.
        final store = harness.container.read(
          ordemServicoStoreProvider.notifier,
        );
        for (final id in ['os-2198', 'os-2185']) {
          store.cancelar(id, autor: 'Teste', motivo: 'Fora do teste');
        }
        await tester.pumpAndSettle();

        OrdemServicoStatus status() => store.byId('os-2207').status;
        List<String> ordem() => [
          for (final card in tester.widgetList<OsSummaryCard>(
            find.byType(OsSummaryCard),
          ))
            card.os.id,
        ];

        // Situação e ação rápida do card em destaque.
        expect(find.text('Vence amanhã'), findsOneWidget);
        final antes = ordem();
        expect(antes, ['os-2207', 'os-2201']);

        await tester.tap(find.text('Iniciar'));
        await tester.pumpAndSettle();
        expect(find.text('Iniciar a OS #2207?'), findsOneWidget);

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(status(), OrdemServicoStatus.aguardando);

        await tester.tap(find.text('Iniciar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Iniciar execução'));
        await tester.pumpAndSettle();
        expect(status(), OrdemServicoStatus.emExecucao);

        // A OS iniciada não pula para o topo sob o dedo.
        expect(ordem(), antes);
        expect(find.text('Iniciar'), findsNothing);
        expect(find.text('Pausar'), findsOneWidget);
      },
    );

    testWidgets('botão Pausar do card abre a dock do motivo', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      expect(find.text('Pausar a OS #2198?'), findsOneWidget);
      expect(find.text('Por que vai pausar?'), findsOneWidget);
      expect(find.text('Confirmar pausa'), findsOneWidget);

      // Confirmar sem motivo explica o que falta em vez de não fazer nada.
      await tester.tap(find.text('Confirmar pausa'));
      await tester.pumpAndSettle();
      expect(
        find.text('Escolha o motivo da pausa para continuar.'),
        findsOneWidget,
      );

      // Motivo pronto: um toque e confirma, sem digitar.
      await tester.tap(find.text('Chuva ou tempo ruim'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar pausa'));
      await tester.pumpAndSettle();
      expect(find.text('Pausar a OS #2198?'), findsNothing);
      expect(
        harness.container
            .read(ordemServicoStoreProvider)
            .ordens
            .firstWhere((o) => o.codigo == 'OS #2198')
            .status,
        OrdemServicoStatus.pausada,
      );
    });

    testWidgets(
      'filtro de status da OS abre a dock inferior e filtra a lista',
      (tester) async {
        harness.router.go('/fazendas/campo/minhas-os');
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.textContaining('OS #2201'), findsOneWidget);

        await tester.tap(find.text('Todas'));
        await tester.pumpAndSettle();

        expect(find.text('Status da OS'), findsOneWidget);
        expect(find.text('Aguardando'), findsWidgets);
        expect(find.text('Em andamento'), findsWidgets);

        await tester.tap(find.text('Encerradas'));
        await tester.pumpAndSettle();

        expect(find.text('Status da OS'), findsNothing);
        expect(find.text('Encerradas'), findsOneWidget);
        expect(find.textContaining('OS #2201'), findsNothing);
        expect(find.textContaining('OS #2170'), findsOneWidget);
      },
    );

    testWidgets(
      'grupo com uma única funcionalidade abre direto pelo menu lateral',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Menu'));
        await tester.pumpAndSettle();

        // "Sincronização" só tem uma funcionalidade — a tela de listagem do
        // grupo (que mostraria só esse card) fica de fora da navegação.
        await tester.tap(_noMenu('Sincronizar aplicativo'));
        await tester.pumpAndSettle();

        expect(find.text('Sincronização de dados'), findsNothing);
        expect(find.text('SINCRONIZAR'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Empilhada: o "Voltar" da funcionalidade retorna à tela inicial.
        expect(harness.router.canPop(), isTrue);
      },
    );

    testWidgets(
      'navbar operacional: Início, Pecuária, Agricultura, Confinamento e Menu',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        Finder aba(String label) => find.descendant(
          of: find.byType(AppBottomTabBar),
          matching: find.bySemanticsLabel(label),
        );
        expect(aba('Pecuária'), findsOneWidget);
        expect(aba('Agricultura'), findsOneWidget);
        // Confinamento voltou a ser aba, depois de Agricultura, e continua
        // também no menu lateral.
        expect(aba('Confinamento'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Menu'));
        await tester.pumpAndSettle();

        expect(find.text('MENU'), findsOneWidget);
        await tester.tap(_noMenu('Confinamento'));
        await tester.pumpAndSettle();
        expect(find.byType(AppModuleTile), findsNWidgets(7));
      },
    );

    testWidgets(
      'central interna mantém fazenda e navbar, mas remove o perfil e as abas',
      (tester) async {
        harness.router.go('/fazendas/operacional/grupo/confinamento');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.byType(AppBottomTabBar), findsOneWidget);
        expect(find.text('Fazenda São Pedro'), findsOneWidget);
        expect(find.byType(AppSearchField), findsOneWidget);
        // confinamento (onda 2): o Confinamento absorveu `conexao-aparelhos`
        // e `configuracoes-misturador` do extinto grupo Misturador — 5+2=7.
        expect(find.byType(AppModuleTile), findsNWidgets(7));
        expect(find.text('Boa tarde,'), findsNothing);
      },
    );

    testWidgets('cadastro profundo remove navbar e contexto da fazenda', (
      tester,
    ) async {
      harness.router.go('/fazendas/campo/trato-diario');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomTabBar), findsNothing);
      expect(find.byType(ContextBadge), findsNothing);
      expect(find.byTooltip('Mais opções'), findsOneWidget);
    });

    testWidgets('deep link sem sessão retorna ao login', (tester) async {
      // Regressão: o login é a porta de entrada real do protótipo — sem
      // sessão, qualquer rota protegida cai nele.
      harness.dispose();
      harness = RouterTestHarness();
      harness.router.go('/fazendas/operacional');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    });

    testWidgets('rota inicial sem navegação explícita é o login', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness();

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
    });
  });
}
