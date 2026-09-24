import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/module_config.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppBottomTabBar', () {
    testWidgets('renderiza as 5 abas operacionais sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            tabs: operationalBottomTabs,
            activeId: 'inicio',
            onSelected: (_) {},
          ),
        ),
      );

      // Todas as abas existem e são anunciadas pelo nome; só a ativa escreve
      // o nome, na pílula ao lado do ícone.
      for (final label in [
        'Início',
        'Pecuária',
        'Agricultura',
        'Confinamento',
        'Menu',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Pecuária'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onSelected com a aba tocada', (tester) async {
      BottomTab? selected;
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            tabs: operationalBottomTabs,
            activeId: 'inicio',
            onSelected: (tab) => selected = tab,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Pecuária'));
      await tester.pump();

      expect(selected?.id, 'pecuaria');
    });
  });
}
