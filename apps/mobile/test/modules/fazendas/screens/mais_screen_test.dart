import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/mais_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child));

void main() {
  group('MaisScreen', () {
    testWidgets('renderiza os grupos e itens de navegação sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const MaisScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Mais'), findsOneWidget);
      expect(find.text('Dashboards gerenciais'), findsOneWidget);
      expect(find.text('Fila de sincronização'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
