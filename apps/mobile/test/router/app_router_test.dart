import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

Widget _wrap([ProviderContainer? container]) {
  final child = MaterialApp.router(theme: buildAppTheme(AppThemeVariant.light), routerConfig: appRouter);
  if (container == null) return ProviderScope(child: child);
  return UncontrolledProviderScope(container: container, child: child);
}

/// `pumpAndSettle` só continua pumpando enquanto frames são agendados — um
/// `Future.delayed` isolado (SimulatedLoad/RiseIn da HubHomeScreen, renderizada
/// por padrão em `/inicio`) não agenda frame algum até disparar, então pode
/// ficar pendente se não avançarmos o relógio explicitamente antes. Chamar
/// sempre que o teste passar por `/inicio`.
Future<void> _settleHubTimers(WidgetTester tester) => tester.pump(const Duration(seconds: 1));

void main() {
  // appRouter é uma instância global (top-level) — cada teste navega a partir
  // de onde o anterior parou. Reseta explicitamente para o ponto de partida.
  setUp(() => appRouter.go('/inicio'));

  group('appRouter', () {
    testWidgets('"/" redireciona para "/inicio" e mostra o módulo Início', (tester) async {
      appRouter.go('/');
      await tester.pumpWidget(_wrap());
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsWidgets);
    });

    testWidgets('deep-link "/bank/extrato" abre o módulo Bank na aba Extrato', (tester) async {
      appRouter.go('/bank/extrato');
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Bank'), findsWidgets);
      expect(find.text('Extrato — módulo chega na F4'), findsOneWidget);
    });

    testWidgets('deep-link "/fazendas" mostra as ContextTabs do módulo correto (não as do Início)', (tester) async {
      // Regressão: o moduleId ativo do ShellLayout era derivado de
      // `state.pathParameters['moduleId']`, que nunca existe (nenhuma rota usa
      // ':moduleId' — todas são segmentos literais) — sempre caía no fallback
      // 'inicio', então header/tabs/dock nunca refletiam o módulo real.
      appRouter.go('/fazendas');
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Abas de Fazendas (moduleConfig) — não existem no módulo Início.
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Financeiro'), findsOneWidget);
      // Abas do Início não devem aparecer.
      expect(find.text('Apps'), findsNothing);
      expect(find.text('Carteira'), findsNothing);
    });

    testWidgets('trocar de módulo pelo dock preserva o header (Silvio Ventura continua visível)', (tester) async {
      await tester.pumpWidget(_wrap());
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      expect(find.text('Silvio Ventura'), findsOneWidget);

      await tester.tap(find.byTooltip('Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(find.text('Bank'), findsWidgets);
    });

    testWidgets('tocar em "Mais" abre o RevealMenu do módulo ativo', (tester) async {
      await tester.pumpWidget(_wrap());
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();

      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('tocar em um item do RevealMenu (Modo GB) alterna o tema — não fecha o menu por engano', (tester) async {
      // Regressão: um overlay "tocar fora fecha o menu" cobrindo a tela inteira
      // por cima do RevealMenu bloqueava os toques nos próprios itens do menu.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await _settleHubTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();
      expect(container.read(shellStoreProvider).menuOpen, isTrue);

      // "Modo GB" pode estar abaixo do fold do painel rolável.
      await tester.scrollUntilVisible(find.text('Modo GB'), 200, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Modo GB'));
      await tester.pumpAndSettle();

      expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
    });
  });
}
