import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../support/router_test_harness.dart';
import '../../support/test_viewport.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness();
    addTearDown(harness.dispose);
    harness.router.go('/login');
  });

  group('LoginPage', () {
    testWidgets('renderiza marca e formulário sem exceção', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('GB CERNE'), findsOneWidget);
      expect(find.text('Bem-vindo!'), findsOneWidget);
      expect(find.text('Login Administração'), findsOneWidget);
      expect(find.text('Login Operacional'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Conhecer o app" navega para o onboarding', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conhecer o app'));
      await tester.pumpAndSettle();

      expect(find.text('Sua fazenda na palma da mão'), findsOneWidget);
    });

    testWidgets('alterna "Manter conectado" ao tocar', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manter conectado'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Login Administração inicia sessão e abre central de gestão', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login Administração'));
      await tester.pumpAndSettle();

      expect(find.text('Central de gestão'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).profile,
        UserAccessProfile.administration,
      );
    });

    testWidgets('Login Operacional inicia sessão e abre central de rotinas', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login Operacional'));
      await tester.pumpAndSettle();

      expect(find.text('Central de rotinas'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).profile,
        UserAccessProfile.operational,
      );
    });
  });
}
