import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/router/app_router.dart';

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: appRouter,
  ),
);

void main() {
  setUp(() => appRouter.go('/perfil'));

  group('PerfilConfigPage', () {
    testWidgets('mostra o usuário do shellStore sem exceção', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(find.text('Editar perfil'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar em "Tema" alterna o themeVariantProvider', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(container.read(themeVariantProvider), AppThemeVariant.light);

      await tester.tap(find.text('Tema'));
      await tester.pump();

      expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
    });

    testWidgets('tocar em "Sair" navega para o login', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo!'), findsOneWidget);
    });

    testWidgets('tocar em "Notificações" navega para a tela de notificações', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem registrada'), findsOneWidget);
    });
  });
}
