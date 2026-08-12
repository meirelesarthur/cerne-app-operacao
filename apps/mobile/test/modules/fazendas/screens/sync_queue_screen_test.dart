import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/sync_queue_screen.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

void main() {
  group('SyncQueueScreen', () {
    testWidgets('mostra estado vazio quando não há fila', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: SyncQueueScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhum lançamento pendente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lista os itens pendentes e sincroniza ao tocar no botão', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            const SyncItem(
              id: 's1',
              label: 'Pesagem do Lote 42',
              detail: '120 kg',
              kind: ActivityKind.pesagem,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: SyncQueueScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pesagem do Lote 42'), findsOneWidget);

      await tester.tap(find.text('Sincronizar agora'));
      await tester.pump();

      expect(container.read(fazendasStoreProvider).syncQueue, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
