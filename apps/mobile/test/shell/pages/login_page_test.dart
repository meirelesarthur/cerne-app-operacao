import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/router/app_router.dart';

import '../../support/test_viewport.dart';

Widget _wrap() => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: appRouter,
  ),
);

void main() {
  // appRouter é uma instância global — reseta o ponto de partida a cada teste.
  setUp(() => appRouter.go('/login'));

  group('LoginPage', () {
    testWidgets('renderiza marca e formulário sem exceção', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('GB CERNE'), findsOneWidget);
      expect(find.text('Bem-vindo!'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Conhecer o app" navega para o onboarding', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conhecer o app'));
      await tester.pumpAndSettle();

      expect(find.text('Sua fazenda na palma da mão'), findsOneWidget);
    });

    testWidgets('alterna "Manter conectado" ao tocar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manter conectado'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('"Entrar" navega para o hub (Início)', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      // SimulatedLoad/RiseIn da HubHomeScreen usam Future.delayed isolado —
      // avança o relógio antes de deixar pumpAndSettle assentar (ver app_router_test.dart).
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Seus apps'), findsOneWidget);
    });
  });
}
