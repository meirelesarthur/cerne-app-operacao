import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/record_meta.dart';
import 'package:cerne_app/ui/ui.dart';

void main() {
  group('recordMetaFromDescription', () {
    test('cada parte vira um dado com o ícone do tipo de informação', () {
      final meta = recordMetaFromDescription(
        'Exame · Lote Matrizes 01 · 02/09/2026',
      );
      expect(meta.map((m) => m.label), [
        'Exame',
        'Lote Matrizes 01',
        '02/09/2026',
      ]);
      expect(meta.map((m) => m.icon), [
        AppIcons.clipboardList,
        AppIcons.layers,
        AppIcons.calendar,
      ]);
    });

    test('reconhece local, quantidade, animais, dinheiro e armazém', () {
      expect(recordMetaIcon('Talhão 02'), AppIcons.mapPin);
      expect(recordMetaIcon('12.400 kg'), AppIcons.scale);
      expect(recordMetaIcon('28 animais'), AppIcons.beef);
      expect(recordMetaIcon(r'custo médio R$ 2,38/kg'), AppIcons.cash);
      expect(recordMetaIcon('Armazém A'), AppIcons.warehouse);
      expect(recordMetaIcon('Fazenda Agro Pillathi'), AppIcons.fazenda);
      expect(recordMetaIcon('atualizado recentemente'), AppIcons.clock);
      expect(recordMetaIcon('Trator John Deere 6110'), AppIcons.tractor);
    });
  });

  testWidgets('AppRecordTile: título largo, 2 dados por linha, tag embaixo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppThemeVariant.light),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AppRecordTile(
                title: 'Exame de casco Lote Matrizes 01',
                meta: recordMetaFromDescription(
                  'Exame · Lote Matrizes 01 · 02/09/2026',
                ),
                status: const AppChip(child: Text('Programado')),
              ),
            ),
          ),
        ),
      ),
    );

    final title = tester.getRect(find.text('Exame de casco Lote Matrizes 01'));
    final exame = tester.getRect(find.text('Exame'));
    final lote = tester.getRect(find.text('Lote Matrizes 01'));
    final data = tester.getRect(find.text('02/09/2026'));
    final tag = tester.getRect(find.text('Programado'));

    // Dois por linha: Exame e Lote na mesma linha, a data na seguinte.
    expect(exame.top, moreOrLessEquals(lote.top, epsilon: 1));
    expect(data.top, greaterThan(exame.bottom));
    // A tag vem abaixo de tudo, alinhada à esquerda como o título.
    expect(tag.top, greaterThan(data.bottom));
    expect(tag.left, lessThan(title.left + 24));
  });
}
