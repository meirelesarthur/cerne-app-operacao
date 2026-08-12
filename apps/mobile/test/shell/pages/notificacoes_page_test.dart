import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: buildAppTheme(AppThemeVariant.light), routerConfig: appRouter),
    );

void main() {
  setUp(() => appRouter.go('/notificacoes'));

  group('NotificacoesPage', () {
    testWidgets('lista as notificações mock e mostra "Marcar lidas"', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem registrada'), findsOneWidget);
      expect(find.text('Crédito pré-aprovado'), findsOneWidget);
      expect(find.text('Marcar lidas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Marcar lidas" zera as não lidas e some da tela', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(container.read(shellStoreProvider).unreadCount, greaterThan(0));

      await tester.tap(find.text('Marcar lidas'));
      await tester.pumpAndSettle();

      expect(container.read(shellStoreProvider).unreadCount, 0);
      expect(find.text('Marcar lidas'), findsNothing);
    });

    testWidgets('tocar numa notificação navega para o módulo correspondente', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pesagem registrada'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
    });
  });
}
