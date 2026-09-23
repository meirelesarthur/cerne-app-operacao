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
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

/// `AppSearchSelect` (campos Produto — fidelidade-esteira: dropdown com
/// busca) abre um dock em bottom sheet: toca o campo para abrir e só então
/// toca a opção já visível na lista.
Future<void> _selectSearchOption(WidgetTester tester, String option) async {
  final field = find.byType(AppSearchSelect).last;
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  // O dock só constrói os itens dentro da área visível (lista virtualizada) —
  // filtrar pela própria busca do dock garante que a opção esteja visível,
  // em vez de depender da altura/rolagem da superfície de teste.
  await tester.enterText(find.byType(TextField).last, option);
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

/// A etapa de lançamentos é uma grade de cards-gaveta — um por grupo (Mão de
/// obra, Máquinas, Insumos, Produção, Ocorrências), cada um com a chave
/// `square-group-<grupo>` do `AppSquareGroupGrid`.
Finder _cardForGroup(String group) =>
    find.byKey(ValueKey('square-group-$group'));

/// No card vazio, o "Adicionar" é só visual (`IgnorePointer`) — o alvo é o
/// card inteiro, então o toque vai no nome do grupo dentro do card.
Finder _addButtonForGroup(String group) =>
    find.descendant(of: _cardForGroup(group), matching: find.text(group));

/// Card com itens: tocar em qualquer lugar abre o gerenciador (listar,
/// editar, remover com desfazer), sem expor o item solto na tela.
Future<void> _abrirGerenciador(WidgetTester tester, String group) async {
  final card = _cardForGroup(group);
  await tester.ensureVisible(card);
  await tester.tap(find.descendant(of: card, matching: find.text(group)));
  await tester.pumpAndSettle();
}

/// fidelidade-campos (onda 2): o apontamento passou a ter três etapas
/// (Identificação, Operação, Lançamentos) — cada teste que precisa das
/// coleções atravessa as duas primeiras antes.
Future<void> _avancar(WidgetTester tester) async {
  await tester.tap(findCta('Continuar'));
  await tester.pumpAndSettle();
}

const _loteSoja = '0001 — Soja Verão 25/26';

/// Texto dentro do campo (controle desabilitado ou não) de rótulo [label].
String _valorDoCampo(WidgetTester tester, String label) {
  final editable = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editable.first).controller.text;
}

Future<void> _preencherIdentificacao(WidgetTester tester) async {
  await _selectOption(tester, 'Responsável', 'João Oliveira');
  // banco-real (onda 5): o lote (ciclo de produção) substitui a "Área" solta
  // — ele traz cultura, safra, centro de custo e os talhões.
  await _selectSearchOption(tester, _loteSoja);
  await _selectOption(tester, 'Talhão', 'Talhão 01');
  await _selectOption(tester, 'Operação', 'Colheita');
  await _selectOption(tester, 'Atividade', 'Colheita Mecanizada');
  await _enterText(tester, 'Data do apontamento', '10/03/2026');
}

/// Área total, área utilizada, cultura e safra vêm do lote/talhão — sobra só
/// o armazém de produção para escolher.
Future<void> _preencherOperacao(WidgetTester tester) async {
  await _selectOption(tester, 'Armazém de produção', 'Armazém A');
}

Future<void> _irParaLancamentos(WidgetTester tester) async {
  await _preencherIdentificacao(tester);
  await _avancar(tester);
  await _preencherOperacao(tester);
  await _avancar(tester);
}

Future<void> _adicionarInsumo(WidgetTester tester) async {
  await tester.tap(_addButtonForGroup('Insumos'));
  await tester.pumpAndSettle();
  // Produto com um único lote de estoque: o item de estoque já vem escolhido
  // e traz armazém e unidade — só a dose por hectare é da pessoa.
  await _selectSearchOption(tester, 'Ração Engorda 18%');
  await tester.ensureVisible(find.text('Adicionar').last);
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
      expect(find.text('Selecione o lote.'), findsOneWidget);
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

    testWidgets(
      'a terceira etapa traz as cinco coleções em cards quadrados 2x2',
      (tester) async {
        await setTallSurface(tester, height: 3200);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        await _irParaLancamentos(tester);

        // Grupos reais (`appropriation_employee/equipment/stock/production/
        // occurrences`), não uma tabela plana — cada um é o seu próprio card.
        expect(find.text('Mão de obra / Serviços'), findsOneWidget);
        expect(find.text('Máquinas / Implementos'), findsOneWidget);
        expect(find.text('Insumos'), findsOneWidget);
        expect(find.text('Produção'), findsOneWidget);
        expect(find.text('Ocorrências'), findsOneWidget);
        expect(find.byType(AppSquareGroupGrid), findsOneWidget);
        expect(find.text('Recursos do apontamento'), findsOneWidget);
        // Tudo vazio: cada card mostra "Nenhum item" e o convite a adicionar,
        // sem atalho de adição rápida (só existe em card com itens).
        expect(find.text('Nenhum item'), findsNWidgets(5));
        expect(find.byTooltip('Adicionar em Insumos'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

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

    testWidgets(
      'adicionar um insumo soma ao card e aparece na listagem de gerenciar',
      (tester) async {
        await setTallSurface(tester, height: 3200);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        await _irParaLancamentos(tester);
        await tester.tap(_addButtonForGroup('Insumos'));
        await tester.pumpAndSettle();

        expect(find.text('Insumo'), findsOneWidget);
        expect(find.text('Produto'), findsOneWidget);
        expect(find.text('Item de estoque'), findsOneWidget);
        // fidelidade-contrato: `stock_items.*` exige `warehouse_uuid` por item
        // — na onda 5 ele vem do item de estoque, então só aparece depois que
        // o estoque é escolhido.
        expect(find.text('Armazém de origem'), findsNothing);

        await _selectSearchOption(tester, 'Ração Engorda 18%');
        // Armazém e unidade vêm do item de estoque/produto — travados.
        expect(_valorDoCampo(tester, 'Armazém de origem'), 'Armazém A');
        expect(_valorDoCampo(tester, 'Unidade'), 'kg');
        await tester.ensureVisible(find.text('Adicionar').last);
        await tester.tap(find.text('Adicionar').last);
        await tester.pumpAndSettle();

        // O item lançado não fica solto na tela — o card diz quantos há, por
        // extenso, e um resumo agregado (custo), nunca o nome do item.
        expect(
          find.descendant(
            of: _cardForGroup('Insumos'),
            matching: find.text('1 item incluído'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: _cardForGroup('Insumos'),
            matching: find.textContaining(r'R$'),
          ),
          findsOneWidget,
        );
        expect(find.text('Ração Engorda 18%'), findsNothing);
        // Com itens, o card ganha o atalho de adição rápida.
        expect(find.byTooltip('Adicionar em Insumos'), findsOneWidget);

        await _abrirGerenciador(tester, 'Insumos');

        expect(find.text('Ração Engorda 18%'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('gerenciar um grupo permite editar e excluir o item lançado', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await _adicionarInsumo(tester);
      await _abrirGerenciador(tester, 'Insumos');

      // Editar reabre o formulário pré-preenchido — troca a dose e salva
      // sem reabrir a busca de produto.
      await tester.tap(find.byTooltip('Editar item'));
      await tester.pumpAndSettle();

      expect(find.text('Editar insumo'), findsOneWidget);
      await _enterText(tester, 'Dose por hectare (kg/ha)', '2');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar'));
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Salvar devolve a pessoa para a lista do grupo, sem reabrir à mão.
      // 2 kg/ha × 41,50 ha (área produtiva do Talhão 01) = 83 kg.
      expect(find.textContaining('2 kg/ha'), findsOneWidget);
      expect(find.textContaining('total 83 kg'), findsOneWidget);

      // Excluir tira o item da listagem, sem fechar o sheet, e oferece
      // desfazer.
      await tester.tap(find.byTooltip('Remover item'));
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda 18%'), findsNothing);
      expect(find.text('0 itens incluídos'), findsOneWidget);
      expect(find.text('"Ração Engorda 18%" removido'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda 18%'), findsOneWidget);
      expect(find.textContaining('1 item incluído'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a coleção de produção registra o que a operação gerou', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await tester.tap(_addButtonForGroup('Produção'));
      await tester.pumpAndSettle();

      expect(find.text('Produto colhido'), findsOneWidget);
      // fidelidade-esteira (onda 14): `appropriation_production` também não
      // tem `warehouse_uuid` próprio — destino é sempre o armazém de
      // produção do cabeçalho.
      expect(find.text('Armazém de destino'), findsNothing);

      await _selectSearchOption(tester, 'Semente de Braquiária');
      // A unidade é do produto (`product_um`), não de quem lança.
      expect(_valorDoCampo(tester, 'Unidade'), 'kg');
      await tester.ensureVisible(find.text('Adicionar').last);
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: _cardForGroup('Produção'),
          matching: find.text('1 item incluído'),
        ),
        findsOneWidget,
      );

      await _abrirGerenciador(tester, 'Produção');
      expect(find.text('Semente de Braquiária'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mão de obra exige o tipo e o alvo do tipo escolhido', (
      tester,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _irParaLancamentos(tester);
      await tester.tap(_addButtonForGroup('Mão de obra / Serviços'));
      await tester.pumpAndSettle();

      // fidelidade-contrato (re-auditoria 3ª avaliação): `labor_items.*.type`
      // é required — o sheet abre pedindo o discriminante.
      expect(find.text('Tipo'), findsOneWidget);

      // Tipo=Função revela o select de função (o alvo required_if do tipo).
      await _selectOption(tester, 'Tipo', 'Função');
      expect(_fieldByLabel('Função exercida'), findsOneWidget);
      await _selectOption(tester, 'Função exercida', 'Tratorista Agrícola');
      await _selectOption(tester, 'Unidade', 'Dia');
      // Valor sugerido pelo custo-hora da função (R$ 26/h × 8 h por dia).
      expect(_valorDoCampo(tester, 'Valor unitário (R\$)'), '208,00');
      await _enterText(tester, 'Valor unitário (R\$)', '150');
      await tester.ensureVisible(find.text('Adicionar').last);
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();

      // O item entra rotulado pelo tipo + alvo, visível na listagem.
      await _abrirGerenciador(tester, 'Mão de obra / Serviços');
      expect(find.text('Função: Tratorista Agrícola'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('o lote preenche cultura, safra, centro de custo e áreas', (
      tester,
    ) async {
      await setTallSurface(tester, height: 2400);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _preencherIdentificacao(tester);
      await _avancar(tester);

      expect(_valorDoCampo(tester, 'Cultura / variedade'), 'Soja — TMG 2383');
      expect(_valorDoCampo(tester, 'Safra'), '2025/2026');
      expect(_valorDoCampo(tester, 'Centro de custo'), 'Centro Agrícola');
      expect(_valorDoCampo(tester, 'Área total'), '42,35 ha');
      // Área utilizada nasce com a área produtiva do talhão, editável.
      expect(_valorDoCampo(tester, 'Área utilizada'), '41,50');

      // Não pode passar da área total do talhão.
      await _enterText(tester, 'Área utilizada', '50');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('não pode passar da área total'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('lote de talhão único já seleciona o talhão', (tester) async {
      await setTallSurface(tester, height: 2000);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _selectSearchOption(tester, '0002 — Milho Safrinha 2026');

      expect(
        find.text('Único talhão do lote — já selecionado.'),
        findsOneWidget,
      );
      expect(find.text('Talhão 03'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a operação restringe as atividades possíveis', (tester) async {
      await setTallSurface(tester, height: 2000);
      await tester.pumpWidget(_wrap(const ApontamentoFlow()));
      await tester.pumpAndSettle();

      await _selectOption(tester, 'Operação', 'Colheita');
      final dropdown = find.descendant(
        of: _fieldByLabel('Atividade'),
        matching: find.byType(DropdownButtonFormField<String>),
      );
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('Colheita Mecanizada'), findsWidgets);
      expect(find.text('Aração'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'o equipamento traz medidor e custo e a quantidade vem da leitura',
      (tester) async {
        await setTallSurface(tester, height: 3200);
        await tester.pumpWidget(_wrap(const ApontamentoFlow()));
        await tester.pumpAndSettle();

        await _irParaLancamentos(tester);
        await tester.tap(_addButtonForGroup('Máquinas / Implementos'));
        await tester.pumpAndSettle();

        await _selectSearchOption(tester, 'Colheitadeira CR7');

        expect(_valorDoCampo(tester, 'Medidor'), 'Horímetro');
        expect(_valorDoCampo(tester, 'Custo por hora'), 'R\$ 620,00');
        expect(_valorDoCampo(tester, 'Horímetro inicial'), '540');
        // Leitura final igual à inicial ainda não é trabalho nenhum.
        expect(find.text('Precisa ser maior que a inicial.'), findsOneWidget);

        final leituraFinal = find.descendant(
          of: _fieldByLabel('Horímetro final'),
          matching: find.byType(EditableText),
        );
        await tester.enterText(leituraFinal, '548');
        await tester.pumpAndSettle();

        expect(_valorDoCampo(tester, 'Quantidade'), '8 Hora');
        expect(find.text('R\$ 4.960,00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

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
