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
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Login Administração'), findsNothing);
      expect(find.text('Login Operacional'), findsNothing);
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

      final keepConnected = find.text('Manter conectado');
      await tester.ensureVisible(keepConnected);
      await tester.pumpAndSettle();
      await tester.tap(keepConnected);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('login padrão inicia sessão administrativa no Banking', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Conta GB Banking'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).profile,
        UserAccessProfile.administration,
      );
    });

    testWidgets('login sinalizado como operacional abre central de rotinas', (
      tester,
    ) async {
      await setTallSurface(tester);
      harness.router.go('/login?ambiente=operacional');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('O que fazer hoje'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).profile,
        UserAccessProfile.operational,
      );
    });

    testWidgets(
      '?ambiente=administracao (vindo da pasta CRN App) mantém o destino administrativo',
      (tester) async {
        harness.router.go('/login?ambiente=administracao');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Acesso administrativo'), findsOneWidget);
        expect(find.text('Login Operacional'), findsNothing);
      },
    );

    testWidgets(
      '?ambiente=operacional (vindo da pasta CRN App) mantém o destino operacional',
      (tester) async {
        harness.router.go('/login?ambiente=operacional');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Acesso operacional'), findsOneWidget);
        expect(find.text('Login Administração'), findsNothing);
      },
    );
  });
}
