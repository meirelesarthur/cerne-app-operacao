import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/text_input.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Center(child: child)),
);

bool _obscured(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).obscureText;

void main() {
  group('AppTextInput — senha', () {
    testWidgets('campo de senha tem o olho e alterna mostrar/ocultar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppTextInput(obscureText: true)));

      expect(_obscured(tester), isTrue);
      expect(find.byTooltip('Mostrar senha'), findsOneWidget);

      await tester.tap(find.byTooltip('Mostrar senha'));
      await tester.pump();
      expect(_obscured(tester), isFalse);
      expect(find.byTooltip('Ocultar senha'), findsOneWidget);

      await tester.tap(find.byTooltip('Ocultar senha'));
      await tester.pump();
      expect(_obscured(tester), isTrue);
    });

    testWidgets('campo comum não ganha o olho', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextInput()));

      expect(find.byTooltip('Mostrar senha'), findsNothing);
    });
  });
}
