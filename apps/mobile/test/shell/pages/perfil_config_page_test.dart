import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../support/router_test_harness.dart';
import '../../support/test_viewport.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.operational);
    addTearDown(harness.dispose);
    harness.router.go('/perfil');
  });

  group('PerfilConfigPage', () {
    testWidgets('mostra o usuário do shellStore sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(find.text('Informações pessoais'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar em "Tema" alterna o themeVariantProvider', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(
        harness.container.read(themeVariantProvider),
        AppThemeVariant.light,
      );

      await tester.tap(find.text('Tema'));
      await tester.pump();

      expect(
        harness.container.read(themeVariantProvider),
        AppThemeVariant.gbMode,
      );
    });

    testWidgets('"Sair" pergunta antes e, confirmado, navega para o login', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.text('Sair do aplicativo?'), findsOneWidget);
      await tester.tap(find.text('Sair').last);
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).isAuthenticated,
        isFalse,
      );
    });

    testWidgets('tocar em "Notificações" navega para a tela de notificações', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem registrada'), findsOneWidget);
    });
  });
}
