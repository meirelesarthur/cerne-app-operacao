import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/module_tile.dart';
import 'package:cerne_app/ui/search_field.dart';

import '../support/router_test_harness.dart';
import '../support/test_viewport.dart';

late RouterTestHarness harness;

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
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Boa tarde,'), findsOneWidget);
      expect(find.text('Fazenda São Pedro'), findsOneWidget);
      expect(find.text('Procurando por algo?'), findsOneWidget);
      expect(find.text('O que fazer hoje'), findsNothing);
      expect(find.byType(AppContextTabs), findsNothing);
      // A tela inicial é a de ordens de serviço, separada por andamento.
      expect(find.text('Ordens de serviço'), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('OSs'), findsOneWidget);
      expect(find.byType(AppModuleTile), findsNothing);
    });

    testWidgets(
      'filtro de status da OS abre a dock inferior e filtra a lista',
      (tester) async {
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
        await tester.tap(find.text('Sincronizar aplicativo'));
        await tester.pumpAndSettle();

        expect(find.text('Sincronização de dados'), findsNothing);
        expect(find.text('SINCRONIZAR'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Empilhada: o "Voltar" da funcionalidade retorna à tela inicial.
        expect(harness.router.canPop(), isTrue);
      },
    );

    testWidgets(
      'navbar operacional: OSs, Pecuária, Agricultura e Menu lateral',
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

        expect(find.text('LANÇAMENTOS'), findsOneWidget);
        await tester.tap(find.text('Confinamento'));
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
