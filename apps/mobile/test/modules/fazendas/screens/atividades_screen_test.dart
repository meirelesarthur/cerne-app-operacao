import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/atividades_screen.dart';

void main() {
  group('AtividadesScreen', () {
    testWidgets('lista as atividades e abre o detalhe ao tocar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: const Scaffold(body: AtividadesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atividades'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsOneWidget);

      await tester.tap(find.text('Pesagem do Lote 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da atividade'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
