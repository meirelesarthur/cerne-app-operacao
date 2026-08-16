import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/tooltip.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTooltip', () {
    testWidgets('não mostra o conteúdo antes do toque', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTooltip(
            content: 'Texto do tooltip',
            child: Icon(Icons.info_outline),
          ),
        ),
      );

      expect(find.text('Texto do tooltip'), findsNothing);
    });

    testWidgets('mostra e esconde o conteúdo ao alternar toque', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppTooltip(
            content: 'Texto do tooltip',
            child: Icon(Icons.info_outline),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      expect(find.text('Texto do tooltip'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      expect(find.text('Texto do tooltip'), findsNothing);
    });
  });
}
