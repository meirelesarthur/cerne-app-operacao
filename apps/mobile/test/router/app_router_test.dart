import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../support/router_test_harness.dart';
import '../support/test_viewport.dart';

late RouterTestHarness harness;

/// `pumpAndSettle` só continua pumpando enquanto frames são agendados — um
/// `Future.delayed` isolado (SimulatedLoad/RiseIn da HubHomeScreen, renderizada
/// por padrão em `/inicio`) não agenda frame algum até disparar, então pode
/// ficar pendente se não avançarmos o relógio explicitamente antes. Chamar
/// sempre que o teste passar por `/inicio`.
Future<void> _settleHubTimers(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 1));

void main() {
  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.administration);
    addTearDown(() => harness.dispose());
    harness.router.go('/inicio');
  });

  group('appRouter', () {
    testWidgets('"/" redireciona para a central do perfil autenticado', (
      tester,
    ) async {
      harness.router.go('/');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Central de gestão'), findsOneWidget);
    });

    testWidgets('deep-link "/bank/extrato" abre o módulo Bank na aba Extrato', (
      tester,
    ) async {
      await setTallSurface(tester);
      harness.router.go('/bank/extrato');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Tela real do módulo Bank (F4.4) — a versão placeholder (F3) mostrava
      // apenas "$tabLabel — módulo chega na F4". "Extrato" sozinho é ambíguo
      // (também é o rótulo da aba em AppContextTabs).
      expect(find.text('Extrato'), findsWidgets);
      expect(find.textContaining('Saldo disponível'), findsOneWidget);
    });

    testWidgets(
      'deep-link "/fazendas" mostra as ContextTabs do módulo correto (não as do Início)',
      (tester) async {
        // Regressão: o moduleId ativo do ShellLayout era derivado de
        // `state.pathParameters['moduleId']`, que nunca existe (nenhuma rota usa
        // ':moduleId' — todas são segmentos literais) — sempre caía no fallback
        // 'inicio', então header/tabs/dock nunca refletiam o módulo real.
        await setTallSurface(tester);
        harness.router.go('/fazendas');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // Abas de Fazendas (moduleConfig) — não existem no módulo Início.
        // Escopo em AppContextTabs: a home do módulo (F4.2) também tem um atalho
        // "Financeiro" no grid, então `find.text('Financeiro')` sozinho é ambíguo.
        final contextTabs = find.byType(AppContextTabs);
        expect(
          find.descendant(of: contextTabs, matching: find.text('Gestão')),
          findsOneWidget,
        );
        expect(find.text('Central de gestão'), findsOneWidget);
        // Abas do Início não devem aparecer.
        expect(find.text('Apps'), findsNothing);
        expect(find.text('Carteira'), findsNothing);
      },
    );

    testWidgets('entrada operacional usa o chrome e a navegação de campo', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/operacional');
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

    testWidgets('menu operacional lista módulos-pai e a seção de conta', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/operacional');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();

      expect(find.text('MÓDULOS'), findsOneWidget);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Armazém'), findsOneWidget);
      expect(find.text('CONTA'), findsOneWidget);
    });

    testWidgets(
      'trocar de módulo pelo dock preserva o header (Silvio Ventura continua visível)',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);

        await tester.tap(find.byTooltip('Bank'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);
        // Tela real do módulo Bank (F4.4) — o dock é icon-only (só tooltip/Semantics).
        expect(find.text('Meu cartão'), findsOneWidget);
      },
    );

    testWidgets('tocar em "Mais" abre o RevealMenu do módulo ativo', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();

      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets(
      'tocar em um item do RevealMenu (Modo GB) alterna o tema — não fecha o menu por engano',
      (tester) async {
        // Regressão: um overlay "tocar fora fecha o menu" cobrindo a tela inteira
        // por cima do RevealMenu bloqueava os toques nos próprios itens do menu.
        await tester.pumpWidget(harness.buildApp());
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Mais'));
        await tester.pumpAndSettle();
        expect(harness.container.read(shellStoreProvider).menuOpen, isTrue);

        // "Modo GB" pode estar abaixo do fold do painel rolável.
        await tester.scrollUntilVisible(
          find.text('Modo GB'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Modo GB'));
        await tester.pumpAndSettle();

        expect(
          harness.container.read(themeVariantProvider),
          AppThemeVariant.gbMode,
        );
      },
    );

    testWidgets('deep link sem sessão retorna à home Android (não ao login)', (
      tester,
    ) async {
      // Regressão: a home Android (`/desktop`) é a porta de entrada real do
      // protótipo — sem sessão, qualquer rota protegida cai lá, não direto no
      // formulário de login (ver `redirectForSession`).
      harness.dispose();
      harness = RouterTestHarness();
      harness.router.go('/fazendas/dashboards/financeiro');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CRN App'), findsOneWidget);
      expect(find.text('Login Administração'), findsNothing);
    });

    testWidgets('rota inicial sem navegação explícita é a home Android', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness();

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CRN App'), findsOneWidget);
    });

    testWidgets(
      'sessão autenticada em "/desktop" é redirecionada para a central do perfil',
      (tester) async {
        harness.router.go('/desktop');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Central de gestão'), findsOneWidget);
      },
    );

    testWidgets('operador não acessa dashboard administrativo', (tester) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/dashboards/financeiro');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('O que fazer hoje'), findsOneWidget);
      expect(find.text('Resumo financeiro'), findsNothing);
    });

    testWidgets('administrador não acessa fluxo de entrada operacional', (
      tester,
    ) async {
      harness.router.go('/fazendas/campo/pesagem');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Central de gestão'), findsOneWidget);
      expect(find.text('Nova pesagem'), findsNothing);
    });
  });
}
