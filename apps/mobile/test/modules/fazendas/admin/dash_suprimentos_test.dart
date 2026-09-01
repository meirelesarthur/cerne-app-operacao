import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../support/test_viewport.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_suprimentos.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashSuprimentos', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashSuprimentos()));
      await tester.pumpAndSettle();

      expect(find.text('Suprimentos'), findsWidgets);
      expect(find.text('Aguardando decisão'), findsOneWidget);
      expect(find.text('Valor cotado por tipo'), findsOneWidget);
      expect(find.text('Preço unitário × cotação anterior'), findsOneWidget);
      expect(find.text('Agropecuária Vale'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra por tipo', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashSuprimentos()));
      await tester.pumpAndSettle();

      // "Frete" agora aparece duas vezes na tela: na pílula de filtro e na
      // legenda do donut por tipo. Só a pílula é pressionável.
      final pilula = find.widgetWithText(AppPressable, 'Frete');
      await tester.ensureVisible(pilula);
      await tester.pumpAndSettle();
      await tester.tap(pilula);
      await tester.pumpAndSettle();

      expect(find.text('TransBoi Logística'), findsOneWidget);
      expect(find.text('Agropecuária Vale'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre o detalhe de uma cotação ao tocar', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashSuprimentos()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agropecuária Vale'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da cotação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
