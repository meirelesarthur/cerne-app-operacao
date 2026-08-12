import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_pecuaria.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('DashPecuaria', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashPecuaria()));
      await tester.pumpAndSettle();

      expect(find.text('Pecuária de Corte'), findsWidgets);
      expect(find.text('Produtivo / Reprodutivo'), findsOneWidget);
      expect(find.text('Atividades recentes do rebanho'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre o detalhe de uma atividade ao tocar', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashPecuaria()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pesagem do Lote 42'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da atividade'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
