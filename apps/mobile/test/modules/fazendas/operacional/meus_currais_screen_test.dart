import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/meus_currais_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('MeusCurraisScreen', () {
    testWidgets('renderiza sem exceção e mostra o aviso de ordem pendente', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MeusCurraisScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Meus currais'), findsOneWidget);
      expect(find.text('Curral 01'), findsOneWidget);
      expect(
        find.text('1 ordem pendente do ADM para este curral'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('altera a situação do curral pelo bottom sheet', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MeusCurraisScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alterar situação').first);
      await tester.pumpAndSettle();

      expect(find.text('Salvar situação'), findsOneWidget);
      await tester.tap(find.text('Salvar situação'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
