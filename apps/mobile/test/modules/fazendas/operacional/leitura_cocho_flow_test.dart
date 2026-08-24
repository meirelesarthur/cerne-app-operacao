import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/leitura_cocho_flow.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('LeituraCochoFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const LeituraCochoFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Leitura de cocho'), findsWidgets);
      expect(find.text('Responsável'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adicionar um curral revela o card de avaliação', (
      tester,
    ) async {
      await setTallSurface(tester, height: 4000);
      await tester.pumpWidget(_wrap(const LeituraCochoFlow()));
      await tester.pumpAndSettle();

      final selects = find.byType(DropdownButtonFormField<String>);
      await tester.tap(selects.last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Curral 01').last);
      await tester.pumpAndSettle();

      expect(find.text('Escore'), findsOneWidget);
      expect(find.text('Ocorrências'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
