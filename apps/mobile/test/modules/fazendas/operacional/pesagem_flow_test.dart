import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/pesagem_flow.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

/// `AppSearchSelect` abre um dock em bottom sheet: toca o campo (localizado
/// pelo rótulo, já que Lote/Animal convivem na mesma tela) para abrir e só
/// então toca a opção já visível na lista.
Future<void> _selectSearchField(
  WidgetTester tester,
  String fieldLabel,
  String option,
) async {
  final field = find.descendant(
    of: find.ancestor(
      of: find.text(fieldLabel),
      matching: find.byType(AppFormField),
    ),
    matching: find.byType(AppSearchSelect),
  );
  await tester.tap(field);
  await tester.pumpAndSettle();
  // O dock só constrói os itens dentro da área visível (lista virtualizada) —
  // filtrar pela própria busca do dock garante que a opção esteja visível.
  await tester.enterText(find.byType(TextField).last, option);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

/// Abre o dock do campo (localizado pelo rótulo) sem selecionar nada — usado
/// para inspecionar a lista de opções sem fechar o dock.
Future<void> _openSearchField(WidgetTester tester, String fieldLabel) async {
  final field = find.descendant(
    of: find.ancestor(
      of: find.text(fieldLabel),
      matching: find.byType(AppFormField),
    ),
    matching: find.byType(AppSearchSelect),
  );
  await tester.tap(field);
  await tester.pumpAndSettle();
}

void main() {
  group('PesagemFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem'), findsWidgets);
      expect(find.text('Lote / carga'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avança um passo: selecionar lote habilita o campo de peso', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      await _selectSearchField(tester, 'Lote / carga', 'Lote 42');

      expect(tester.takeException(), isNull);
      expect(find.text('Depósito de destino'), findsOneWidget);
    });

    testWidgets('campo Animal só aparece depois de selecionar o lote', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Animal'), findsNothing);

      await _selectSearchField(tester, 'Lote / carga', 'Lote 42');

      expect(tester.takeException(), isNull);
      expect(find.text('Animal'), findsOneWidget);

      // O dock abre fechado por padrão — confere a opção dentro da lista.
      await _openSearchField(tester, 'Animal');
      expect(find.text('Brinco 4201'), findsOneWidget);
    });

    testWidgets('trocar o lote limpa o animal selecionado', (tester) async {
      await tester.pumpWidget(_wrap(const PesagemFlow()));
      await tester.pumpAndSettle();

      await _selectSearchField(tester, 'Lote / carga', 'Lote 42');
      await _selectSearchField(tester, 'Animal', 'Brinco 4201');
      await _selectSearchField(tester, 'Lote / carga', 'Lote 19');

      expect(tester.takeException(), isNull);
      // O campo fechado volta ao placeholder — o animal do lote antigo some.
      expect(find.text('Brinco 4201'), findsNothing);

      // A lista do dock passa a refletir os animais do novo lote.
      await _openSearchField(tester, 'Animal');
      expect(find.text('Brinco 1901'), findsOneWidget);
      expect(find.text('Brinco 4201'), findsNothing);
    });
  });
}
