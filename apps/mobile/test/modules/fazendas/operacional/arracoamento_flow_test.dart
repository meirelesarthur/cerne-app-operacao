import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/arracoamento_flow.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('ArracoamentoFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const ArracoamentoFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Arraçoamento'), findsWidgets);
      expect(find.text('Lote'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: aumentar a quantidade via stepper', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const ArracoamentoFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Aumentar'));
      await tester.pumpAndSettle();

      expect(find.text('550'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
