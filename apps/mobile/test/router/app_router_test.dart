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
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Agricultura'), findsWidgets);
      expect(find.text('Sincronizar aplicativo'), findsOneWidget);
    });

    testWidgets(
      'grupo com uma única funcionalidade pula direto para o destino',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // "Sincronização" só tem uma funcionalidade — a tela de listagem do
        // grupo (que mostraria só esse card) fica de fora da navegação.
        await tester.tap(find.text('Sincronizar aplicativo'));
        await tester.pumpAndSettle();

        expect(find.text('Sincronização de dados'), findsNothing);
        expect(find.text('SINCRONIZAR'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'navbar operacional de Fazendas troca o Menu por Confinamento (uso mais frequente)',
      (tester) async {
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // fidelidade-esteira: o Menu (RevealMenu) saiu da navbar operacional
        // de Fazendas — redundante com a grade de módulos da própria Home —
        // e deu lugar a Confinamento, o grupo de uso diário mais frequente.
        expect(find.byTooltip('Menu'), findsNothing);
        expect(find.byTooltip('Confinamento'), findsOneWidget);

        await tester.tap(find.byTooltip('Confinamento'));
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

    testWidgets(
      'deep link sem sessão retorna à seleção de ambiente (não ao login)',
      (tester) async {
        // Regressão: a seleção de ambiente (`/desktop/cerne-app`) é a porta de
        // entrada real do protótipo — sem sessão, qualquer rota protegida cai
        // nela, não direto no formulário de login.
        harness.dispose();
        harness = RouterTestHarness();
        harness.router.go('/fazendas/operacional');

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Operacional'), findsOneWidget);
        expect(find.text('Login Administração'), findsNothing);
      },
    );

    testWidgets(
      'rota inicial sem navegação explícita é a seleção de ambiente',
      (tester) async {
        harness.dispose();
        harness = RouterTestHarness();

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Operacional'), findsOneWidget);
        expect(find.text('Entrar no CERNE Operação'), findsOneWidget);
      },
    );

    testWidgets(
      'sessão autenticada em "/desktop" é redirecionada para a central do perfil',
      (tester) async {
        harness.router.go('/desktop');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Boa tarde,'), findsOneWidget);
      },
    );
  });
}
