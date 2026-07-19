import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/main.dart';

void main() {
  testWidgets('CerneApp abre com o tema light e alterna para gbMode', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CerneApp()));

    expect(find.text('Variante atual: light'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Variante atual: gbMode'), findsOneWidget);
  });

  test('ThemeVariantNotifier alterna entre light e gbMode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeVariantProvider), AppThemeVariant.light);

    container.read(themeVariantProvider.notifier).toggle();
    expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
  });
}
