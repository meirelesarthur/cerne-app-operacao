import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/card.dart';

Widget _wrap(Widget child) => MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child));

void main() {
  group('AppCard', () {
    testWidgets('renderiza conteúdo sem exceção (variant surface e ink)', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Conteúdo'))));
      expect(find.text('Conteúdo'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_wrap(const AppCard(variant: AppCardVariant.ink, child: Text('Ink'))));
      expect(find.text('Ink'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('interactive dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppCard(interactive: true, onTap: () => tapped = true, child: const Text('Toque aqui'))),
      );

      await tester.tap(find.text('Toque aqui'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem interactive não registra InkWell clicável', (tester) async {
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Estático'))));
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
