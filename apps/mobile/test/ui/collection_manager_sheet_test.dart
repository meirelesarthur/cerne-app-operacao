import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

/// Dono dos itens no teste — o gerenciador só lê/remove por callbacks.
class _Harness extends StatefulWidget {
  const _Harness({required this.initial});

  final List<String> initial;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late final items = [...widget.initial];
  int adds = 0;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => AppButton(
        onPressed: () => showAppCollectionManager(
          context,
          title: 'Insumos',
          items: () => [
            for (final item in items) AppCollectionItemView(title: item),
          ],
          summary: () => '${items.length * 10} kg',
          onAdd: () async {
            adds++;
            setState(() => items.add('Novo $adds'));
          },
          onEdit: (index) async =>
              setState(() => items[index] = '${items[index]} (editado)'),
          onRemove: (index) {
            final removed = items.removeAt(index);
            setState(() {});
            return () => setState(() => items.insert(index, removed));
          },
        ),
        child: const Text('Abrir'),
      ),
    );
  }
}

Future<void> _open(WidgetTester tester, List<String> initial) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(
        body: Center(child: _Harness(initial: initial)),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('showAppCollectionManager', () {
    testWidgets('mostra contagem por extenso, resumo e os itens', (
      tester,
    ) async {
      await _open(tester, ['Ração', 'Sal mineral']);

      expect(find.text('Insumos'), findsOneWidget);
      expect(find.text('2 itens incluídos · 20 kg'), findsOneWidget);
      expect(find.text('Ração'), findsOneWidget);
      expect(find.text('Sal mineral'), findsOneWidget);
      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('remover oferece desfazer, que devolve o item ao lugar', (
      tester,
    ) async {
      await _open(tester, ['Ração', 'Sal mineral']);

      await tester.tap(find.byTooltip('Remover item').first);
      await tester.pumpAndSettle();

      expect(find.text('Ração'), findsNothing);
      expect(find.text('"Ração" removido'), findsOneWidget);
      expect(find.text('1 item incluído · 10 kg'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      expect(find.text('Ração'), findsOneWidget);
      expect(find.text('"Ração" removido'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Ração')).dy,
        lessThan(tester.getTopLeft(find.text('Sal mineral')).dy),
      );
    });

    testWidgets('tocar na linha edita e o gerenciador reabre em seguida', (
      tester,
    ) async {
      await _open(tester, ['Ração']);

      await tester.tap(find.text('Ração'));
      await tester.pumpAndSettle();

      expect(find.text('Ração (editado)'), findsOneWidget);
      expect(find.text('1 item incluído · 10 kg'), findsOneWidget);
    });

    testWidgets('adicionar pelo rodapé volta para a lista com o item novo', (
      tester,
    ) async {
      await _open(tester, []);

      expect(find.textContaining('Nenhum item incluído'), findsOneWidget);
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Novo 1'), findsOneWidget);
      expect(find.text('1 item incluído · 10 kg'), findsOneWidget);
    });

    testWidgets('10 itens: lista rola e "Adicionar" segue fixo no rodapé', (
      tester,
    ) async {
      await _open(tester, [for (var i = 1; i <= 10; i++) 'Item $i']);

      expect(find.text('10 itens incluídos · 100 kg'), findsOneWidget);
      final add = find.text('Adicionar');
      expect(add, findsOneWidget);
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(tester.getBottomLeft(add).dy, lessThanOrEqualTo(screen.height));
      expect(tester.takeException(), isNull);
    });
  });
}
