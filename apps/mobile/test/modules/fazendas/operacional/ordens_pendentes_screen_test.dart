import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/ordens_pendentes_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('OrdensPendentesScreen', () {
    testWidgets('lista as ordens pendentes mockadas', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const OrdensPendentesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Ordens pendentes'), findsOneWidget);
      expect(find.text('Transferência de lote'), findsOneWidget);
      expect(find.text('Troca de dieta'), findsOneWidget);
      expect(find.text('Confirmar execução'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirma uma ordem e ela deixa de pedir confirmação', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const OrdensPendentesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar execução').first);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar execução'), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
