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
    testWidgets('renderiza as 4 abas operacionais sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            tabs: operationalBottomTabs,
            activeId: 'inicio',
            onSelected: (_) {},
          ),
        ),
      );

      for (final label in ['Início', 'Pecuária', 'Agricultura', 'Menu']) {
        expect(find.byTooltip(label), findsOneWidget);
      }
      // A aba ativa mostra o rótulo na pílula.
      expect(find.text('Início'), findsOneWidget);
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

      await tester.tap(find.byTooltip('Pecuária'));
      await tester.pump();

      expect(selected?.id, 'pecuaria');
    });
  });
}
