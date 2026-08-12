import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/insumos_flow.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('InsumosFlow', () {
    testWidgets('renderiza sem exceção com tipo Aplicação por padrão', (tester) async {
      await tester.pumpWidget(_wrap(const InsumosFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Insumos / Ocorrências'), findsWidgets);
      expect(find.text('Produto / insumo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: alternar para Ocorrência troca o campo do formulário', (tester) async {
      await tester.pumpWidget(_wrap(const InsumosFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ocorrência'));
      await tester.pumpAndSettle();

      expect(find.text('Descrição da ocorrência'), findsOneWidget);
      expect(find.text('Produto / insumo'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
