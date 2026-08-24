import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_confinamento.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashConfinamento', () {
    testWidgets('renderiza sem exceção e abre a aba Mapa', (tester) async {
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      expect(find.text('Confinamento'), findsOneWidget);
      expect(find.text('Visão geral'), findsOneWidget);

      await tester.tap(find.text('Mapa'));
      await tester.pumpAndSettle();

      expect(find.text('Curral 01'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre o detalhe de um curral ao tocar', (tester) async {
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mapa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Curral 01'));
      await tester.pumpAndSettle();

      expect(find.text('Situação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
