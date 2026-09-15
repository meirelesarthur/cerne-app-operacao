import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/search_select.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _options = [
  AppSearchSelectOption(
    value: 'lote-01',
    label: 'Lote 01',
    detail: '120 sacas',
  ),
  AppSearchSelectOption(value: 'lote-02', label: 'Lote 02', detail: '80 sacas'),
];

void main() {
  group('AppSearchSelect', () {
    testWidgets('mostra o placeholder fechado e abre o dock ao tocar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppSearchSelect(
            options: _options,
            onChanged: (_) {},
            placeholder: 'Selecionar lote',
          ),
        ),
      );

      expect(find.text('Selecionar lote'), findsOneWidget);
      expect(find.text('Lote 01'), findsNothing);

      await tester.tap(find.byType(AppSearchSelect));
      await tester.pumpAndSettle();

      expect(find.text('Lote 01'), findsOneWidget);
      expect(find.text('Lote 02'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra a lista do dock ao digitar na busca', (tester) async {
      await tester.pumpWidget(
        _wrap(AppSearchSelect(options: _options, onChanged: (_) {})),
      );

      await tester.tap(find.byType(AppSearchSelect));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '01');
      await tester.pump();

      expect(find.text('Lote 01'), findsOneWidget);
      expect(find.text('Lote 02'), findsNothing);
    });

    testWidgets('dispara onChanged e fecha o dock ao tocar em uma opção', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppSearchSelect(options: _options, onChanged: (v) => selected = v),
        ),
      );

      await tester.tap(find.byType(AppSearchSelect));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote 02'));
      await tester.pumpAndSettle();

      expect(selected, 'lote-02');
      expect(find.text('Lote 02'), findsNothing);
    });
  });
}
