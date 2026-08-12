import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/ciclo_rebanho_flow.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('CicloRebanhoFlow', () {
    testWidgets('renderiza a grade de eventos sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const CicloRebanhoFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Nascimento'), findsOneWidget);
      expect(find.text('Desmame'), findsOneWidget);
      expect(find.text('Transferência'), findsOneWidget);
      expect(find.text('Morte / Perda'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: escolher Nascimento mostra o formulário', (tester) async {
      await tester.pumpWidget(_wrap(const CicloRebanhoFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nascimento'));
      await tester.pumpAndSettle();

      expect(find.text('Animal-mãe / lote'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
