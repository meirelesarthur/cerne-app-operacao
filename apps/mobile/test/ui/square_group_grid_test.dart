import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

Finder _card(String name) => find.byKey(ValueKey('square-group-$name'));

void main() {
  group('AppSquareGroupGrid', () {
    testWidgets(
      'card vazio: "Nenhum item" e tocar em qualquer lugar adiciona',
      (tester) async {
        String? added;
        String? opened;
        await tester.pumpWidget(
          _wrap(
            AppSquareGroupGrid(
              groups: const [AppSquareGroup(name: 'Insumos')],
              onAdd: (group) => added = group,
              onOpen: (group) => opened = group,
            ),
          ),
        );

        expect(find.text('Nenhum item'), findsOneWidget);
        expect(find.text('Adicionar'), findsOneWidget);
        expect(find.text('Ver itens'), findsNothing);

        await tester.tap(find.text('Insumos'));
        expect(added, 'Insumos');
        expect(opened, isNull);
      },
    );

    testWidgets('card com itens: rótulo por extenso, resumo e toque abre', (
      tester,
    ) async {
      String? added;
      String? opened;
      await tester.pumpWidget(
        _wrap(
          AppSquareGroupGrid(
            groups: const [
              AppSquareGroup(name: 'Insumos', count: 3, summary: r'R$ 30,00'),
            ],
            onAdd: (group) => added = group,
            onOpen: (group) => opened = group,
          ),
        ),
      );

      expect(find.text('3 itens incluídos'), findsOneWidget);
      expect(find.text(r'R$ 30,00'), findsOneWidget);
      expect(find.text('Ver itens'), findsOneWidget);

      await tester.tap(find.text('Insumos'));
      expect(opened, 'Insumos');
      expect(added, isNull);

      // O "+" continua como atalho de adição rápida.
      await tester.tap(find.byTooltip('Adicionar em Insumos'));
      expect(added, 'Insumos');
    });

    testWidgets('singular e plural do rótulo de contagem', (tester) async {
      expect(appItemCountLabel(0), '0 itens incluídos');
      expect(appItemCountLabel(1), '1 item incluído');
      expect(appItemCountLabel(10), '10 itens incluídos');
    });

    testWidgets('1 ou 10 itens não mudam a altura do card', (tester) async {
      Future<double> heightFor(int count) async {
        await tester.pumpWidget(
          _wrap(
            AppSquareGroupGrid(
              groups: [
                AppSquareGroup(
                  name: 'Insumos',
                  icon: AppIcons.package,
                  count: count,
                  summary: r'R$ 1.245,90',
                ),
                const AppSquareGroup(name: 'Produção', icon: AppIcons.wheat),
              ],
              onAdd: (_) {},
              onOpen: (_) {},
            ),
          ),
        );
        return tester.getSize(_card('Insumos')).height;
      }

      final one = await heightFor(1);
      final ten = await heightFor(10);
      expect(ten, one);
      // Os dois cards da linha têm a mesma altura (vazio x com itens).
      expect(
        tester.getSize(_card('Produção')).height,
        tester.getSize(_card('Insumos')).height,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tela estreita (320px) não estoura cards vazios nem cheios', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _wrap(
          AppSquareGroupGrid(
            groups: const [
              AppSquareGroup(
                name: 'Máquinas / Implementos',
                icon: AppIcons.tractor,
                count: 12,
                summary: r'48 h · R$ 4.800,00',
              ),
              AppSquareGroup(name: 'Produção', icon: AppIcons.wheat),
              AppSquareGroup(
                name: 'Ocorrências',
                icon: AppIcons.triangleAlert,
                count: 2,
                summary: 'Prioridade alta',
                wide: true,
              ),
            ],
            onAdd: (_) {},
            onOpen: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('grupo largo ocupa a linha inteira', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSquareGroupGrid(
            groups: const [
              AppSquareGroup(name: 'Insumos'),
              AppSquareGroup(name: 'Produção'),
              AppSquareGroup(name: 'Ocorrências', wide: true),
            ],
            onAdd: (_) {},
            onOpen: (_) {},
          ),
        ),
      );

      final square = tester.getSize(_card('Insumos')).width;
      final wide = tester.getSize(_card('Ocorrências')).width;
      expect(wide, greaterThan(square * 2));
    });

    testWidgets('sem onOpen, card com itens continua adicionando', (
      tester,
    ) async {
      String? added;
      await tester.pumpWidget(
        _wrap(
          AppSquareGroupGrid(
            groups: const [AppSquareGroup(name: 'Etapas', count: 2)],
            onAdd: (group) => added = group,
          ),
        ),
      );

      expect(find.text('2 itens incluídos'), findsOneWidget);
      expect(find.text('Ver itens'), findsNothing);
      await tester.tap(find.text('Etapas'));
      expect(added, 'Etapas');
    });
  });
}
