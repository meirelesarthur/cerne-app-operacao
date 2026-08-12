import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('ContextBadge', () {
    testWidgets('mostra o nome da fazenda ativa sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const ContextBadge()));

      expect(find.textContaining('Lançando em:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('atualiza o nome ao trocar a fazenda ativa', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final secondFarm = container.read(fazendasStoreProvider).farms[1];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: ContextBadge()),
          ),
        ),
      );

      container
          .read(fazendasStoreProvider.notifier)
          .setActiveFarm(secondFarm.id);
      await tester.pump();

      expect(find.textContaining(secondFarm.name), findsOneWidget);
    });
  });
}
