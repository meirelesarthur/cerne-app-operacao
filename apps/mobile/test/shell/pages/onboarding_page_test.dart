import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/ui/ui.dart';

import '../../support/router_test_harness.dart';

/// Toques em "Próximo" até o último slide (3 slides).
const _slidesMenosUm = 2;

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness();
    addTearDown(harness.dispose);
    harness.router.go('/onboarding');
  });

  group('OnboardingPage', () {
    testWidgets('mostra o primeiro slide e as ações, sem dots de step', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sua fazenda na palma da mão'), findsOneWidget);
      expect(find.text('Próximo'), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);
      expect(find.byType(AppPageDots), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Próximo" avança os 3 slides até "Começar" no último', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      expect(find.text('Suas ordens de serviço em dia'), findsOneWidget);

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      expect(find.text('Tudo registrado, nada se perde'), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
      expect(find.text('Pular'), findsNothing);
      // Nada de banco, crédito ou marketplace no app de campo.
      expect(find.textContaining('banco'), findsNothing);
    });

    testWidgets('"Pular" leva direto para o login', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    });

    testWidgets('"Começar" no último slide também leva ao login', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      for (var i = 0; i < _slidesMenosUm; i++) {
        await tester.tap(find.text('Próximo'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    });
  });
}
