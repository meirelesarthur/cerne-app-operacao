import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_consultas.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: Scaffold(body: child)),
    );

void main() {
  group('DashConsultas', () {
    testWidgets('renderiza sem exceção com Lotes selecionado por padrão', (tester) async {
      await tester.pumpWidget(_wrap(const DashConsultas()));
      await tester.pumpAndSettle();

      expect(find.text('Consultas Gerenciais'), findsWidgets);
      expect(find.text('Somente leitura — dados espelhados do web.'), findsOneWidget);
      expect(find.text('Lote 42'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('troca para a seção de Localização (placeholder de mapa)', (tester) async {
      await tester.pumpWidget(_wrap(const DashConsultas()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Localização'));
      await tester.pumpAndSettle();

      expect(find.text('Mapa de localização'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
