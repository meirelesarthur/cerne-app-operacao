import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

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
      expect(find.text('Ver perfil'), findsNothing);
      expect(find.text('Perfil completo'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Informações pessoais" abre os dados pessoais', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Informações pessoais'));
      await tester.pumpAndSettle();

      expect(find.text('Dados pessoais'), findsOneWidget);
      expect(find.text('Alterar foto'), findsOneWidget);
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.text('Descartar alterações'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Silvio V. Souza');
      await tester.pump();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(
        harness.container.read(shellStoreProvider).user.name,
        'Silvio V. Souza',
      );
    });

    testWidgets('"Segurança" abre a troca de senha e valida', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Segurança'));
      await tester.pumpAndSettle();

      expect(find.text('Senha atual'), findsOneWidget);
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.text('Confirmar nova senha'), findsOneWidget);

      final campos = find.byType(TextField);
      await tester.enterText(campos.at(0), 'antiga1');
      await tester.enterText(campos.at(1), 'novasenha');
      await tester.enterText(campos.at(2), 'outra');
      await tester.pump();
      await tester.tap(find.text('Alterar senha'));
      await tester.pump();
      expect(find.textContaining('não confere'), findsOneWidget);

      await tester.enterText(campos.at(2), 'novasenha');
      await tester.pump();
      await tester.tap(find.text('Alterar senha'));
      await tester.pump();
      expect(find.text('Senha alterada.'), findsOneWidget);
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
