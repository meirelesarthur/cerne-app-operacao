import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/apontamento_flow.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../helpers/cta_finder.dart';
import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

Finder _fieldByLabel(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(AppFormField));

Future<void> _selectOption(
  WidgetTester tester,
  String label,
  String option,
) async {
  final dropdown = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(DropdownButtonFormField<String>),
  );
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _enterText(WidgetTester tester, String label, String value) async {
  final input = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(input.first, value);
}

/// Cada grupo (Mão de obra, Máquinas, Insumos, Ocorrências) é seu próprio
/// `AppAddableGroupList` — não uma lista combinada — então "Adicionar" só é
/// único dentro do grupo pelo índice de posição na tela (0..3, na ordem em
/// que os grupos aparecem).
Finder _addButtonForGroup(int index) => find.descendant(
  of: find.byType(AppAddableGroupList).at(index),
  matching: find.text('Adicionar'),
);

void main() {
  group('ApontamentoFlow', () {
    testWidgets('renderiza cabeçalho e os quatro grupos de recurso reais', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Apontamento agrícola'), findsWidgets);
      expect(find.text('Responsável'), findsOneWidget);
      expect(find.text('Operação'), findsOneWidget);
      expect(find.text('Atividade'), findsOneWidget);
      // Grupos reais (`appropriation_employee/equipment/stock/occurrences`),
      // não uma tabela plana — cada um é seção própria.
      expect(find.text('Mão de obra / Serviços'), findsOneWidget);
      expect(find.text('Máquinas / Implementos'), findsOneWidget);
      expect(find.text('Insumos'), findsOneWidget);
      expect(find.text('Ocorrências'), findsOneWidget);
      expect(find.text('Nenhum item adicionado'), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('bloqueia o envio sem os campos obrigatórios do cabeçalho', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await tester.tap(findCta('Salvar apontamento'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione o responsável.'), findsOneWidget);
      expect(find.text('Selecione a operação.'), findsOneWidget);
      expect(find.text('Apontamento registrado'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Operação e Atividade são dropdowns reais — não mais campo livre',
      (tester) async {
        await setTallSurface(tester, height: 3200);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        await _selectOption(tester, 'Operação', 'Colheita');
        await _selectOption(tester, 'Atividade', 'Colheita Mecanizada');

        expect(
          find.descendant(
            of: _fieldByLabel('Operação'),
            matching: find.byType(TextFormField),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'adicionar um insumo abre formulário real e soma ao grupo',
      (tester) async {
        await setTallSurface(tester, height: 3200);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        // Insumos é o terceiro grupo na tela: Mão de obra(0), Máquinas(1),
        // Insumos(2), Ocorrências(3).
        await tester.tap(_addButtonForGroup(2));
        await tester.pumpAndSettle();

        expect(find.text('Insumo'), findsOneWidget);
        expect(find.text('Produto'), findsOneWidget);
        expect(find.text('Unidade'), findsOneWidget);

        await _selectOption(tester, 'Produto', 'Ração Engorda 18%');
        await _selectOption(tester, 'Unidade', 'kg');
        await tester.tap(find.text('Adicionar').last);
        await tester.pumpAndSettle();

        expect(find.text('1 item(ns) adicionado(s)'), findsOneWidget);
        expect(find.text('Ração Engorda 18%'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'cabeçalho completo e um insumo concluem o apontamento',
      (tester) async {
        await setTallSurface(tester, height: 3600);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        await _selectOption(tester, 'Responsável', 'João Oliveira');
        await _selectOption(tester, 'Área', 'Talhão 01');
        await _selectOption(tester, 'Operação', 'Colheita');
        await _selectOption(tester, 'Atividade', 'Colheita Mecanizada');
        await _enterText(tester, 'Data do apontamento', '10/03/2026');
        await _enterText(tester, 'Área total', '120');
        await _enterText(tester, 'Área utilizada', '120');
        await _selectOption(tester, 'Armazém de produção', 'Armazém A');

        await tester.tap(findCta('Salvar apontamento'));
        await tester.pumpAndSettle();

        expect(find.text('Apontamento registrado'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
