import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/pesagem_flow.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('PesagemFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem'), findsWidgets);
      expect(find.text('Lote / carga'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: selecionar lote habilita o campo de peso', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote 42'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Depósito de destino'), findsOneWidget);
    });

    testWidgets('campo Animal só aparece depois de selecionar o lote', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Animal'), findsNothing);

      await tester.tap(find.text('Lote 42'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Animal'), findsOneWidget);
      expect(find.text('Brinco 4201'), findsOneWidget);
    });

    testWidgets('trocar o lote limpa o animal selecionado', (tester) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote 42'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brinco 4201'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote 19'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Brinco 4201'), findsNothing);
      expect(find.text('Brinco 1901'), findsOneWidget);
    });
  });
}
