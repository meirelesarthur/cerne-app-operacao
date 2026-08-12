import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/venda_flow.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('VendaFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const VendaFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Venda de animais'), findsWidgets);
      expect(find.text('Mês anterior (fechado)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: selecionar lote preenche a contagem esperada', (tester) async {
      await tester.pumpWidget(_wrap(const VendaFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote 42'));
      await tester.pumpAndSettle();

      expect(find.text('128'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
