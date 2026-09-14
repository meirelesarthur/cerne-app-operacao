import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/trato_diario_flow.dart';

import '../../../support/test_viewport.dart';
import '../../../helpers/cta_finder.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('TratoDiarioFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const TratoDiarioFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Trato diário'), findsWidgets);
      expect(find.text('Batida de dieta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('escolher a batida mostra os currais elegíveis', (
      tester,
    ) async {
      await setTallSurface(tester, height: 4000);
      await tester.pumpWidget(_wrap(const TratoDiarioFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Vagão Misturador').last);
      await tester.pumpAndSettle();

      expect(find.text('Currais elegíveis'), findsOneWidget);
      expect(findCta('Finalizar trato'), findsOneWidget);
      // `AppActionBarSummary` funde rótulo e valor num só `Text.rich`
      // ("Faltam 500kg"), não um `Text('Faltam')` isolado — `find.text`
      // exato só bate por coincidência com o KPI "Fornecido" (que tem
      // rótulo e valor em widgets separados). `textContaining` é o que
      // reflete a renderização de verdade dos dois.
      expect(find.text('Fornecido'), findsOneWidget);
      expect(find.textContaining('Faltam'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
