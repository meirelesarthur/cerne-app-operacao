import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/widgetbook/docs/guide_pages.dart';
import 'package:cerne_app/widgetbook_app.dart';

import '../support/test_viewport.dart';

List<WidgetbookComponent> _components(List<WidgetbookNode> nodes) => [
  for (final node in nodes)
    if (node is WidgetbookComponent)
      node
    else
      ..._components(node.children ?? const []),
];

WidgetbookUseCase _useCase(String component, String useCase) =>
    _components(buildWidgetbookDirectories())
        .firstWhere((c) => c.name == component)
        .useCases
        .firstWhere((u) => u.name == useCase);

Widget _host(WidgetBuilder builder) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Builder(builder: builder)),
);

void main() {
  group('Widgetbook — árvore do catálogo', () {
    test('todo componente registrado tem ao menos um caso de uso', () {
      final empty = [
        for (final component in _components(buildWidgetbookDirectories()))
          if (component.useCases.isEmpty) component.name,
      ];
      expect(empty, isEmpty, reason: 'Componentes sem caso: $empty');
    });

    test('nomes de componente e de caso não se repetem', () {
      final components = _components(buildWidgetbookDirectories());
      final names = components.map((c) => c.name).toList();
      expect(names.toSet().length, names.length, reason: '$names');
      for (final component in components) {
        final cases = component.useCases.map((u) => u.name).toList();
        expect(
          cases.toSet().length,
          cases.length,
          reason: '${component.name}: $cases',
        );
      }
    });

    test('topo da árvore: Documentação, Fundamentos, Padrões, Catálogo', () {
      expect(buildWidgetbookDirectories().map((n) => n.name), [
        'Documentação',
        'Fundamentos',
        'Padrões',
        'Catálogo',
      ]);
    });

    test('nomes de caso não usam caracteres que quebram o deep link', () {
      // O caso selecionado vai na query do fragmento (`#/?path=...`): `+`
      // vira espaço, `&`/`#`/`?`/`%` cortam ou corrompem o parâmetro.
      final unsafe = [
        for (final component in _components(buildWidgetbookDirectories()))
          for (final useCase in component.useCases)
            if (RegExp(r'[+&#?%]').hasMatch('${component.name}${useCase.name}'))
              '${component.name} → ${useCase.name}',
      ];
      expect(unsafe, isEmpty, reason: '$unsafe');
    });

    test('changelog começa pela versão atual do Widgetbook', () {
      expect(widgetbookChangelog.first.version, kWidgetbookVersion);
    });
  });

  group('Widgetbook — páginas e casos novos renderizam', () {
    Future<void> pumpCase(
      WidgetTester tester,
      String component,
      String useCase,
    ) async {
      await setTallSurface(tester, height: 3200);
      await tester.pumpWidget(_host(_useCase(component, useCase).builder));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    testWidgets('Guia → Comece aqui', (tester) async {
      await pumpCase(tester, 'Guia', 'Comece aqui');
      expect(find.text('Checklist para um componente novo'), findsOneWidget);
    });

    testWidgets('Guia → Inventário lista as famílias do catálogo', (
      tester,
    ) async {
      await pumpCase(tester, 'Guia', 'Inventário do catálogo');
      expect(find.textContaining('Formulário · '), findsOneWidget);
      expect(find.text('SquareGroupGrid'), findsOneWidget);
      expect(find.text('CollectionManager'), findsOneWidget);
    });

    testWidgets('Guia → Novidades', (tester) async {
      await pumpCase(tester, 'Guia', 'Novidades (v$kWidgetbookVersion)');
      expect(find.textContaining('v$kWidgetbookVersion'), findsWidgets);
    });

    testWidgets('Padrões → Coleções em cadastro (guia e interativo)', (
      tester,
    ) async {
      await pumpCase(
        tester,
        'Coleções em cadastro',
        'Guia: qual componente usar',
      );
      expect(find.text('Qual componente usar'), findsOneWidget);

      await pumpCase(
        tester,
        'Coleções em cadastro',
        'Interativo: cards-gaveta e gerenciador',
      );
      expect(find.text('2 itens incluídos'), findsOneWidget);
    });

    testWidgets('SquareGroupGrid — estados 0, 1 e 10 itens', (tester) async {
      await pumpCase(tester, 'SquareGroupGrid', 'Estados: 0, 1 e 10 itens');
      expect(find.text('1 item incluído'), findsOneWidget);
      expect(find.text('10 itens incluídos'), findsOneWidget);
      expect(find.text('Nenhum item'), findsNWidgets(2));
    });
  });
}
