import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';
import 'package:cerne_app/ui/module_tile.dart';
import 'package:cerne_app/ui/search_field.dart';

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
      await setTallSurface(tester);
      harness.router.go('/');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Conta GB Banking'), findsOneWidget);
      expect(find.text('Acesso rápido'), findsOneWidget);
      expect(find.byType(AppContextTabs), findsOneWidget);
      expect(find.byType(AppBottomTabBar), findsOneWidget);
    });

    testWidgets('tocar a busca da home administrativa abre a descoberta otimizada', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppSearchField));
      await tester.pumpAndSettle();

      expect(find.text('Seus Produtos'), findsOneWidget);
      expect(find.text('Mais acessados'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
      expect(find.text('Boa tarde,'), findsNothing);
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

        // Abas administrativas de Fazendas — a central agora entrega cada
        // domínio no primeiro toque, sem a camada intermediária de grupos.
        final contextTabs = find.byType(AppContextTabs);
        expect(
          find.descendant(of: contextTabs, matching: find.text('Gestão')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Consultas')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Atividades')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Fazendas')),
          findsNothing,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Financeiro')),
          findsNothing,
        );
        expect(find.text('Central de gestão'), findsOneWidget);
        expect(find.text('Painéis de decisão'), findsOneWidget);
        expect(find.text('Resultado'), findsOneWidget);
        // Abas do Início não devem aparecer.
        expect(find.text('Apps'), findsNothing);
        expect(find.text('Carteira'), findsNothing);
      },
    );

    testWidgets(
      'aba Consultas entrega consultas e auditoria e abre a consulta gerencial',
      (tester) async {
        await setTallSurface(tester);
        harness.router.go('/fazendas/administracao');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        final contextTabs = find.byType(AppContextTabs);
        await tester.tap(
          find.descendant(of: contextTabs, matching: find.text('Consultas')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Consultas e auditoria'), findsOneWidget);
        expect(find.text('Consultas gerenciais'), findsOneWidget);
        expect(find.text('Exportar log de estoque'), findsOneWidget);
        expect(find.byType(AppModuleTile), findsNWidgets(9));

        await tester.tap(find.text('Consultas gerenciais'));
        await tester.pumpAndSettle();

        expect(find.text('Consultas Gerenciais'), findsOneWidget);
        expect(find.byType(AppContextTabs), findsNothing);
        expect(tester.takeException(), isNull);
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
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Crédito'), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Armazém'), findsOneWidget);
      expect(find.text('CONTA'), findsOneWidget);
    });

    testWidgets(
      'central interna mantém fazenda e navbar, mas remove o perfil e as abas',
      (tester) async {
        harness.dispose();
        harness = RouterTestHarness(profile: UserAccessProfile.operational);
        harness.router.go('/fazendas/operacional/grupo/confinamento');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.byType(AppBottomTabBar), findsOneWidget);
        expect(find.text('Fazenda São Pedro'), findsOneWidget);
        expect(find.byType(AppSearchField), findsOneWidget);
        expect(find.byType(AppModuleTile), findsNWidgets(5));
        expect(find.text('Boa tarde,'), findsNothing);
        expect(find.byType(AppContextTabs), findsNothing);
      },
    );

    testWidgets('cadastro profundo remove navbar e contexto da fazenda', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/campo/trato-diario');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomTabBar), findsNothing);
      expect(find.byType(ContextBadge), findsNothing);
      expect(find.byTooltip('Mais opções'), findsOneWidget);
    });

    testWidgets(
      'trocar de aba administrativa preserva o header (Silvio Ventura continua visível)',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);

        await tester.tap(find.text('Carteira').first);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);
        expect(find.text('Resumo da sua conta GB Bank.'), findsOneWidget);
        expect(find.byType(AppBottomTabBar), findsOneWidget);
      },
    );

    testWidgets('tocar em "Menu" abre o RevealMenu operacional', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/operacional');
      await tester.pumpWidget(harness.buildApp());
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets(
      'tocar em um item do RevealMenu (Modo GB) alterna o tema — não fecha o menu por engano',
      (tester) async {
        // Regressão: um overlay "tocar fora fecha o menu" cobrindo a tela inteira
        // por cima do RevealMenu bloqueava os toques nos próprios itens do menu.
        harness.dispose();
        harness = RouterTestHarness(profile: UserAccessProfile.operational);
        harness.router.go('/fazendas/operacional');
        await tester.pumpWidget(harness.buildApp());
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Menu'));
        await tester.pumpAndSettle();
        expect(harness.container.read(shellStoreProvider).menuOpen, isTrue);

        // "Modo GB" pode estar abaixo do fold do painel rolável.
        await tester.scrollUntilVisible(
          find.text('Modo GB'),
          200,
          scrollable: find.descendant(
            of: find.byKey(const ValueKey('reveal-menu-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.text('Modo GB'));
        await tester.pumpAndSettle();

        expect(
          harness.container.read(themeVariantProvider),
          AppThemeVariant.gbMode,
        );
      },
    );

    testWidgets('deep link sem sessão retorna à seleção de ambiente (não ao login)', (
      tester,
    ) async {
      // Regressão: a seleção de ambiente (`/desktop/crn-app`) é a porta de
      // entrada real do protótipo — sem sessão, qualquer rota protegida cai
      // nela, não direto no formulário de login.
      harness.dispose();
      harness = RouterTestHarness();
      harness.router.go('/fazendas/dashboards/financeiro');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CRN ADM'), findsOneWidget);
      expect(find.text('CRN Operação'), findsOneWidget);
      expect(find.text('Login Administração'), findsNothing);
    });

    testWidgets('rota inicial sem navegação explícita é a seleção de ambiente', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness();

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CRN ADM'), findsOneWidget);
      expect(find.text('CRN Operação'), findsOneWidget);
    });

    testWidgets(
      'sessão autenticada em "/desktop" é redirecionada para a central do perfil',
      (tester) async {
        harness.router.go('/desktop');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Conta GB Banking'), findsOneWidget);
      },
    );

    testWidgets('operador não acessa dashboard administrativo', (tester) async {
      harness.dispose();
      harness = RouterTestHarness(profile: UserAccessProfile.operational);
      harness.router.go('/fazendas/dashboards/financeiro');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Fazenda São Pedro'), findsOneWidget);
      expect(find.text('Resumo financeiro'), findsNothing);
    });

    testWidgets('administrador não acessa fluxo de entrada operacional', (
      tester,
    ) async {
      harness.router.go('/fazendas/campo/pesagem');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Conta GB Banking'), findsOneWidget);
      expect(find.text('Nova pesagem'), findsNothing);
    });
  });
}
