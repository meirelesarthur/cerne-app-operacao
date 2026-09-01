import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/recebimento_xml_flow.dart';
import '../../../helpers/cta_finder.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('RecebimentoXmlFlow', () {
    testWidgets('renderiza sem exceção, botão oculto sem arquivo', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const RecebimentoXmlFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Entrada por XML (NF-e)'), findsWidgets);
      expect(findCta('Confirmar entrada'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: selecionar arquivo mostra os itens da nota', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const RecebimentoXmlFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecionar arquivo XML'));
      await tester.pumpAndSettle();

      expect(find.text('Agropecuária Vale Ltda'), findsOneWidget);
      expect(findCta('Confirmar entrada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
