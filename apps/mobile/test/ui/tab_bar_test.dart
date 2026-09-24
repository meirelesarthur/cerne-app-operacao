import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

const _items = [
  AppTabBarItem(id: 'a', label: 'Alfa', icon: AppIcons.home),
  AppTabBarItem(id: 'b', label: 'Beta', icon: AppIcons.pecuaria),
  AppTabBarItem(
    id: 'mais',
    label: 'Adicionar',
    icon: AppIcons.plus,
    isAction: true,
  ),
  AppTabBarItem(id: 'c', label: 'Gama', icon: AppIcons.agricultura),
  AppTabBarItem(id: 'd', label: 'Delta', icon: AppIcons.menu),
];

Widget _bar(String activeId, {bool reduceMotion = false}) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(375, 812),
      disableAnimations: reduceMotion,
    ),
    child: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 375,
          child: AppTabBar(
            items: _items,
            activeId: activeId,
            onSelected: (_) {},
          ),
        ),
      ),
    ),
  ),
);

/// Hexágono ativo = o `AppHexagon` que não é o "+" (o "+" tem um `AppIcon`
/// dentro; o ativo desenha só a forma, o ícone vai por cima).
Finder get _activeHex =>
    find.byWidgetPredicate((w) => w is AppHexagon && w.child == null);

double _centerOf(WidgetTester tester, String label) =>
    tester.getCenter(find.bySemanticsLabel(label)).dx;

void main() {
  group('AppTabBar', () {
    testWidgets('o hexágono termina sobre a aba ativa, acima da barra', (
      tester,
    ) async {
      await tester.pumpWidget(_bar('b'));
      await tester.pumpAndSettle();

      final hex = tester.getRect(_activeHex);
      final bar = tester.getRect(find.byType(AppTabBar));
      expect(
        hex.center.dx,
        moreOrLessEquals(_centerOf(tester, 'Beta'), epsilon: 0.5),
      );
      // Flutua: o topo do hexágono encosta no topo do componente, acima da
      // barra (que começa `tabbarLift` px abaixo).
      expect(hex.top, moreOrLessEquals(bar.top, epsilon: 0.5));
      expect(hex.top, lessThan(bar.top + AppComponentMetrics.tabbarLift));
    });

    testWidgets('trocar de aba desliza o hexágono até a nova', (tester) async {
      await tester.pumpWidget(_bar('a'));
      await tester.pumpAndSettle();
      final inicio = tester.getRect(_activeHex).center.dx;

      await tester.pumpWidget(_bar('d'));
      await tester.pump(const Duration(milliseconds: 150));
      final meio = tester.getRect(_activeHex).center.dx;
      await tester.pumpAndSettle();
      final fim = tester.getRect(_activeHex).center.dx;

      expect(meio, greaterThan(inicio));
      expect(meio, lessThan(fim));
      expect(fim, moreOrLessEquals(_centerOf(tester, 'Delta'), epsilon: 0.5));
    });

    testWidgets('só a aba ativa mostra o nome', (tester) async {
      await tester.pumpWidget(_bar('c'));
      await tester.pumpAndSettle();

      expect(find.text('Gama'), findsOneWidget);
      for (final outro in ['Alfa', 'Beta', 'Delta', 'Adicionar']) {
        expect(find.text(outro), findsNothing, reason: outro);
      }
    });

    testWidgets('o "+" nunca fica ativo', (tester) async {
      await tester.pumpWidget(_bar('mais'));
      await tester.pumpAndSettle();

      expect(_activeHex, findsNothing);
      expect(find.text('Adicionar'), findsNothing);
    });

    testWidgets('sem aba ativa o destaque recolhe', (tester) async {
      await tester.pumpWidget(_bar('b'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_bar(''));
      await tester.pumpAndSettle();

      expect(_activeHex, findsNothing);
      expect(find.text('Beta'), findsNothing);
    });

    testWidgets('com animações reduzidas a troca é imediata', (tester) async {
      await tester.pumpWidget(_bar('a', reduceMotion: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_bar('d', reduceMotion: true));
      await tester.pump();

      expect(
        tester.getRect(_activeHex).center.dx,
        moreOrLessEquals(_centerOf(tester, 'Delta'), epsilon: 0.5),
      );
    });
  });
}
