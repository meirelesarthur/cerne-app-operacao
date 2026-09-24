import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/module_config.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(width: 375, child: child),
    ),
  ),
);

void main() {
  group('AppBottomTabBar', () {
    testWidgets('anuncia as 4 abas e o "+", e só a ativa escreve o nome', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            tabs: operationalBottomTabs,
            activeId: 'inicio',
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in [
        'Início',
        'Pecuária',
        'Adicionar',
        'Agricultura',
        'Menu',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Pecuária'), findsNothing);
      expect(find.text('Adicionar'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('devolve a aba tocada e o "+" como ação', (tester) async {
      final tocadas = <BottomTab>[];
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            tabs: operationalBottomTabs,
            activeId: 'inicio',
            onSelected: tocadas.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Pecuária'));
      await tester.tap(find.bySemanticsLabel('Adicionar'));
      await tester.pump();

      expect(tocadas.map((t) => t.id), ['pecuaria', 'adicionar']);
      expect(tocadas.last.action, quickAddAction);
    });
  });
}
