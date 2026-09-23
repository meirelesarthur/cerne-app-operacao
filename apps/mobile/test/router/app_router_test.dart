import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/models.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/state/ordem_servico_store.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/widgets.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/components/reveal_menu.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/app_icon_tile.dart';
import 'package:cerne_app/ui/module_tile.dart';
import 'package:cerne_app/ui/page_scaffold.dart';
import 'package:cerne_app/ui/search_field.dart';

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
      expect(find.byType(AppContextTabs), findsNothing);
      // Tela inicial: OS em andamento no topo e atalhos logo abaixo.
      expect(find.text('Minhas OS'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);
      expect(find.text('Atalhos'), findsOneWidget);
      expect(find.byTooltip('Início'), findsOneWidget);
      expect(find.byType(AppModuleTile), findsNothing);
    });

    testWidgets('tela inicial mostra até 3 OS, a em execução primeiro', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(OsSummaryCard), findsNWidgets(3));
      final primeira = tester.widget<OsSummaryCard>(
        find.byType(OsSummaryCard).first,
      );
      expect(primeira.os.status, OrdemServicoStatus.emExecucao);
    });

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

      expect(find.text('Minhas OS'), findsNothing);
      expect(find.byType(OsSummaryCard), findsNothing);
      expect(find.text('Atalhos'), findsOneWidget);
      expect(find.byType(AppAppIconTile), findsWidgets);
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
      expect(find.text('Detalhe da OS'), findsOneWidget);
      // Em execução: entregar é o CTA; pausar e refazer ficam no rodapé.
      expect(find.text('MARCAR COMO ENTREGUE'), findsOneWidget);
      expect(find.text('Pausar execução'), findsOneWidget);
      // Tela cheia cobre a navbar.
      expect(find.byType(AppBottomTabBar), findsNothing);

      await tester.tap(find.text('MARCAR COMO ENTREGUE'));
      await tester.pumpAndSettle();

      // Encerrar exige confirmação explícita.
      expect(find.text('Marcar a OS #2198 como entregue?'), findsOneWidget);
      await tester.tap(find.text('Marcar como entregue'));
      await tester.pumpAndSettle();

      // Continua na tela, agora sem ações (OS encerrada).
      expect(find.text('Detalhe da OS'), findsOneWidget);
      expect(find.text('MARCAR COMO ENTREGUE'), findsNothing);
    });

    testWidgets(
      'botão Iniciar do card pede confirmação, e cancelar não registra nada',
      (tester) async {
        harness.dispose();
        harness = RouterTestHarness(
          profile: UserAccessProfile.operational,
          overrides: [
            osRelogioProvider.overrideWithValue(
              () => DateTime(2026, 9, 15, 10),
            ),
          ],
        );
        harness.router.go('/fazendas/operacional');
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        OrdemServicoStatus status() => harness.container
            .read(ordemServicoStoreProvider.notifier)
            .byId('os-2201')
            .status;
        List<String> ordem() => [
          for (final card in tester.widgetList<OsSummaryCard>(
            find.byType(OsSummaryCard),
          ))
            card.os.id,
        ];

        // Situação e ação rápida de cada card.
        expect(find.text('Liberada há 2 dias'), findsOneWidget);
        expect(find.text('Em execução há 1 dia'), findsOneWidget);
        final antes = ordem();
        expect(antes.last, 'os-2201');

        await tester.tap(find.text('Iniciar'));
        await tester.pumpAndSettle();
        expect(find.text('Iniciar a OS #2201?'), findsOneWidget);

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
        expect(find.text('Pausar'), findsNWidgets(2));
      },
    );

    testWidgets('botão Pausar do card abre a dock do motivo', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      expect(find.text('Pausar a OS #2198?'), findsOneWidget);
      expect(find.text('Motivo da pausa'), findsOneWidget);
      expect(find.text('Confirmar pausa'), findsOneWidget);
    });

    testWidgets(
      'filtro de status da OS abre a dock inferior e filtra a lista',
      (tester) async {
        harness.router.go('/fazendas/campo/minhas-os');
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('OS #2201'), findsOneWidget);

        await tester.tap(find.text('Todas'));
        await tester.pumpAndSettle();

        expect(find.text('Status da OS'), findsOneWidget);
        expect(find.text('Aguardando'), findsWidgets);
        expect(find.text('Em execução'), findsWidgets);

        await tester.tap(find.text('Finalizadas'));
        await tester.pumpAndSettle();

        expect(find.text('Status da OS'), findsNothing);
        expect(find.text('Finalizadas'), findsOneWidget);
        expect(find.text('OS #2201'), findsNothing);
        expect(find.text('OS #2170'), findsOneWidget);
      },
    );

    testWidgets(
      'grupo com uma única funcionalidade abre direto pelo menu lateral',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Menu'));
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
      'navbar operacional: Início, Pecuária, Agricultura e Menu lateral',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.byTooltip('Confinamento'), findsNothing);
        expect(find.byTooltip('Pecuária'), findsOneWidget);
        expect(find.byTooltip('Agricultura'), findsOneWidget);

        // O Menu abre o menu lateral com os grupos que saíram da tela
        // inicial; Confinamento, antes aba própria, agora vive ali.
        await tester.tap(find.byTooltip('Menu'));
        await tester.pumpAndSettle();

        expect(find.text('MENU'), findsOneWidget);
        await tester.tap(_noMenu('Confinamento'));
        await tester.pumpAndSettle();

        expect(find.byType(AppContextTabs), findsNothing);
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
        expect(find.byType(AppContextTabs), findsNothing);
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
      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
