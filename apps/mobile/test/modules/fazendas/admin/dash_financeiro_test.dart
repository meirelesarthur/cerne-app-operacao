import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_financeiro.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('DashFinanceiro', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const DashFinanceiro()));
      await tester.pumpAndSettle();

      expect(find.text('Financeiro'), findsWidgets);
      expect(find.text('A Receber'), findsOneWidget);
      expect(find.text('Despesas por centro de custo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
