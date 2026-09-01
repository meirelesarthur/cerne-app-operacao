import 'package:flutter_test/flutter_test.dart';

import '../../support/router_test_harness.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness();
    addTearDown(harness.dispose);
    harness.router.go('/desktop');
  });

  group('AndroidHomePage', () {
    testWidgets('renderiza a área de trabalho com o ícone CRN App', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CRN App'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar em "CRN App" abre a pasta com CRN ADM/CRN Operação', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CRN App'));
      await tester.pumpAndSettle();

      expect(find.text('CRN ADM'), findsOneWidget);
      expect(find.text('CRN Operação'), findsOneWidget);
    });
  });

  group('CrnAppFolderPage', () {
    testWidgets(
      'tocar em "CRN ADM" empilha um único login administrativo',
      (tester) async {
        harness.router.go('/desktop/crn-app');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('CRN ADM'));
        await tester.pumpAndSettle();

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Acesso administrativo'), findsOneWidget);
        expect(find.text('Login Administração'), findsNothing);
        expect(find.text('Login Operacional'), findsNothing);
      },
    );

    testWidgets(
      'tocar em "CRN Operação" empilha o login (voltar retorna à pasta)',
      (tester) async {
        harness.router.go('/desktop/crn-app');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('CRN Operação'));
        await tester.pumpAndSettle();

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Acesso operacional'), findsOneWidget);

        // `push`, não `go` — a pasta continua na pilha do Navigator.
        expect(harness.router.canPop(), isTrue);
      },
    );
  });
}
