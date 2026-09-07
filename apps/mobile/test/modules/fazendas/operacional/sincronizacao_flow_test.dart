import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/sincronizacao_flow.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _app({ProviderContainer? container}) => UncontrolledProviderScope(
  container: container ?? ProviderContainer(),
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: const Scaffold(body: SincronizacaoFlow()),
  ),
);

/// O percentual central do medidor é pintado em `CustomPaint` (não é um
/// `Text` widget) — lido pelas propriedades do `AppGauge`, não por
/// `find.text`.
AppGauge _gauge(WidgetTester tester) =>
    tester.widget<AppGauge>(find.byType(AppGauge));

/// Avança tempo suficiente para os 15 itens da amostra padrão terminarem —
/// um item por tique (420ms) — bombeando o widget em vez de `pumpAndSettle`:
/// o progresso roda em `Timer`, não em `AnimationController`.
Future<void> _runSyncToEnd(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 420));
  }
}

void main() {
  group('SincronizacaoFlow', () {
    testWidgets('estado inicial mostra os módulos recolhidos', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Eventos do rebanho'), findsOneWidget);
      expect(find.text('0/3'), findsWidgets);
      // Recolhido: a funcionalidade interna não aparece antes de sincronizar.
      expect(find.text('Pesagem do Lote 12'), findsNothing);
      expect(_gauge(tester).label, '0/15');
      expect(find.text('SINCRONIZAR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'módulo ativo expande e mostra as funcionalidades internas',
      (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        await tester.tap(find.text('SINCRONIZAR'));
        await tester.pump();

        // O primeiro módulo (Pesagem) vira ativo e expande sozinho.
        expect(find.text('Pesagem do Lote 12'), findsOneWidget);
        expect(find.text('Pesagem do Lote 27'), findsOneWidget);

        await _runSyncToEnd(tester);
        await tester.pumpAndSettle();

        // Ao concluir, cada módulo fecha — nenhuma funcionalidade interna
        // fica visível por padrão.
        expect(find.text('Pesagem do Lote 12'), findsNothing);
        expect(find.text('CONCLUÍDO'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'permite reabrir um módulo já concluído para conferir onde parou',
      (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        await tester.tap(find.text('SINCRONIZAR'));
        await _runSyncToEnd(tester);
        await tester.pumpAndSettle();

        expect(find.text('Pesagem do Lote 12'), findsNothing);

        await tester.tap(find.text('Pesagem'));
        await tester.pumpAndSettle();

        expect(find.text('Pesagem do Lote 12'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'usa a fila real quando há lançamentos e esvazia ao concluir',
      (tester) async {
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

        await tester.pumpWidget(_app(container: container));
        await tester.pumpAndSettle();

        expect(_gauge(tester).label, '0/1');

        await tester.tap(find.text('SINCRONIZAR'));
        await tester.pump();
        expect(find.text('Pesagem do Lote 42'), findsOneWidget);

        await _runSyncToEnd(tester);
        await tester.pumpAndSettle();

        expect(container.read(fazendasStoreProvider).syncQueue, isEmpty);
        expect(_gauge(tester).label, '1/1');
        expect(find.text('CONCLUÍDO'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('sincroniza a amostra padrão quando a fila está vazia', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('SINCRONIZAR'));
      await tester.pump();
      expect(find.text('SINCRONIZANDO'), findsOneWidget);

      await _runSyncToEnd(tester);
      await tester.pumpAndSettle();

      expect(_gauge(tester).label, '15/15');
      expect(find.text('MÓDULOS SINCRONIZADOS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
