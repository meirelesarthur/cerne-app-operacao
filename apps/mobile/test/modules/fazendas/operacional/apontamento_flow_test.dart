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

/// fidelidade-campos (onda 2): o apontamento passou a ter três etapas
/// (Identificação, Operação, Lançamentos) — cada teste que precisa das
/// coleções atravessa as duas primeiras antes.
Future<void> _avancar(WidgetTester tester) async {
  await tester.tap(findCta('Continuar'));
  await tester.pumpAndSettle();
}

Future<void> _preencherIdentificacao(WidgetTester tester) async {
  await _selectOption(tester, 'Responsável', 'João Oliveira');
  await _selectOption(tester, 'Área', 'Talhão 01');
  await _selectOption(tester, 'Operação', 'Colheita');
  await _selectOption(tester, 'Atividade', 'Colheita Mecanizada');
  await _enterText(tester, 'Data do apontamento', '10/03/2026');
}

Future<void> _preencherOperacao(WidgetTester tester) async {
  await _enterText(tester, 'Área total', '120');
  await _enterText(tester, 'Área utilizada', '120');
  await _selectOption(tester, 'Armazém de produção', 'Armazém A');
}

Future<void> _irParaLancamentos(WidgetTester tester) async {
  await _preencherIdentificacao(tester);
  await _avancar(tester);
  await _preencherOperacao(tester);
  await _avancar(tester);
}

Future<void> _adicionarInsumo(WidgetTester tester) async {
  // Insumos é o terceiro grupo da etapa: Mão de obra(0), Máquinas(1),
  // Insumos(2), Produção(3), Ocorrências(4).
  await tester.tap(_addButtonForGroup(2));
  await tester.pumpAndSettle();
  await _selectOption(tester, 'Produto', 'Ração Engorda 18%');
  await _selectOption(tester, 'Unidade', 'kg');
  await tester.tap(find.text('Adicionar').last);
  await tester.pumpAndSettle();
}

void main() {
  group('ApontamentoFlow', () {
    testWidgets('a primeira etapa identifica o apontamento', (tester) async {
      await setTallSurface(tester, height: 2000);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Apontamento agrícola'), findsWidgets);
      expect(find.text('Responsável'), findsOneWidget);
      expect(find.text('Operação'), findsOneWidget);
      expect(find.text('Atividade'), findsOneWidget);
      expect(find.text('Data do apontamento'), findsOneWidget);
      // A régua de etapas do arquétipo `Cadastro steps` — três segmentos.
      expect(find.byType(AppStepProgress), findsOneWidget);
      // Dimensão da operação e lançamentos ficam nas etapas seguintes.
      expect(find.text('Área total'), findsNothing);
      expect(find.text('Insumos'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bloqueia o avanço sem os obrigatórios da identificação', (
      tester,
    ) async {
      await setTallSurface(tester, height: 2000);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _avancar(tester);

      expect(find.text('Selecione o responsável.'), findsOneWidget);
      expect(find.text('Selecione a operação.'), findsOneWidget);
      expect(find.text('Área total'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Operação e Atividade são dropdowns reais — não mais campo livre',
      (tester) async {
        await setTallSurface(tester, height: 2000);
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

    testWidgets('a terceira etapa traz as cinco coleções do contrato', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);

      // Grupos reais (`appropriation_employee/equipment/stock/production/
      // occurrences`), não uma tabela plana — cada um é coleção própria.
      expect(find.text('Mão de obra / Serviços'), findsOneWidget);
      expect(find.text('Máquinas / Implementos'), findsOneWidget);
      expect(find.text('Insumos'), findsOneWidget);
      expect(find.text('Produção'), findsOneWidget);
      expect(find.text('Ocorrências'), findsOneWidget);
      expect(find.text('Nenhum item adicionado'), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('voltar recua a etapa e preserva o que foi preenchido', (
      tester,
    ) async {
      await setTallSurface(tester, height: 2400);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _preencherIdentificacao(tester);
      await _avancar(tester);
      expect(find.text('Área total'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Data do apontamento'), findsOneWidget);
      expect(find.text('10/03/2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adicionar um insumo abre formulário real e soma ao grupo', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await tester.tap(_addButtonForGroup(2));
      await tester.pumpAndSettle();

      expect(find.text('Insumo'), findsOneWidget);
      expect(find.text('Produto'), findsOneWidget);
      expect(find.text('Unidade'), findsOneWidget);
      // `appropriation_stock.warehouse_uuid` é do item, não do cabeçalho.
      expect(find.text('Armazém de origem'), findsOneWidget);

      await _selectOption(tester, 'Produto', 'Ração Engorda 18%');
      await _selectOption(tester, 'Unidade', 'kg');
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();

      expect(find.text('1 item(ns) adicionado(s)'), findsOneWidget);
      expect(find.text('Ração Engorda 18%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a coleção de produção registra o que a operação gerou', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await tester.tap(_addButtonForGroup(3));
      await tester.pumpAndSettle();

      expect(find.text('Produto colhido'), findsOneWidget);
      expect(find.text('Armazém de destino'), findsOneWidget);

      await _selectOption(tester, 'Produto colhido', 'Semente de Braquiária');
      await _selectOption(tester, 'Unidade', 'Saco');
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();

      expect(find.text('1 item(ns) adicionado(s)'), findsOneWidget);
      expect(find.text('Semente de Braquiária'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('apontamento sem nenhum lançamento não salva', (tester) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await tester.tap(findCta('Salvar apontamento'));
      await tester.pumpAndSettle();

      // O contrato `/appropriations` exige ao menos um item entre as cinco
      // coleções — um apontamento vazio não registra nada.
      expect(
        find.text('Adicione ao menos um lançamento para salvar'),
        findsOneWidget,
      );
      expect(find.text('Apontamento registrado'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cabeçalho completo e um insumo concluem o apontamento', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3600);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await _adicionarInsumo(tester);

      await tester.tap(findCta('Salvar apontamento'));
      await tester.pumpAndSettle();

      expect(find.text('Apontamento registrado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
