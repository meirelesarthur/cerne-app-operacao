import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/bento_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppBentoTile', () {
    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppBentoTile(
            icon: LucideIcons.landmark,
            label: 'Fazendas',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Fazendas'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renderiza variante accent com seta sem exceções', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppBentoTile(
            icon: LucideIcons.wallet,
            label: 'Banking',
            caption: 'Conta digital',
            variant: AppBentoTileVariant.accent,
            iconSize: AppBentoTileIconSize.lg,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.arrowRight), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza variante surface sem seta', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppBentoTile(icon: LucideIcons.landmark, label: 'Fazendas'),
        ),
      );

      expect(find.byIcon(LucideIcons.arrowRight), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
