import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/router/app_router.dart';

Widget _wrap() => ProviderScope(
      child: MaterialApp.router(theme: buildAppTheme(AppThemeVariant.light), routerConfig: appRouter),
    );

void main() {
  setUp(() => appRouter.go('/onboarding'));

  group('OnboardingPage', () {
    testWidgets('mostra o primeiro slide, os dots e as ações', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Sua fazenda na palma da mão'), findsOneWidget);
      expect(find.text('Próximo'), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Próximo" avança os slides até "Começar" no último', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      expect(find.text('Banco e crédito do produtor'), findsOneWidget);

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      expect(find.text('Compre, venda e armazene'), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
      expect(find.text('Pular'), findsNothing);
    });

    testWidgets('"Pular" leva direto para o login', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo!'), findsOneWidget);
    });

    testWidgets('"Começar" no último slide também leva ao login', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo!'), findsOneWidget);
    });
  });
}
