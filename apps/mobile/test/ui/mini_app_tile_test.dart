import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/mini_app_tile.dart';

Widget _wrap(Widget child) => MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child));

void main() {
  group('AppMiniAppTile', () {
    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppMiniAppTile(
            icon: LucideIcons.landmark,
            name: 'GB Bank',
            description: 'Conta digital',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('GB Bank'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('disabled=true ignora toque', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppMiniAppTile(
            icon: LucideIcons.landmark,
            name: 'GB Bank',
            disabled: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('GB Bank'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('mostra selo "novo" e "em breve"', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppMiniAppTile(
            icon: LucideIcons.handshake,
            name: 'Crédito',
            badge: AppMiniAppTileBadge.novo,
          ),
        ),
      );
      expect(find.text('Novo'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AppMiniAppTile(
            icon: LucideIcons.store,
            name: 'Marketplace',
            badge: AppMiniAppTileBadge.breve,
          ),
        ),
      );
      expect(find.text('Em breve'), findsOneWidget);
    });
  });
}
