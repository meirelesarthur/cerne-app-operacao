import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';

Widget _wrap(Widget child, {AppThemeVariant variant = AppThemeVariant.light}) =>
    MaterialApp(
      theme: buildAppTheme(variant),
      home: Scaffold(body: Center(child: child)),
    );

HugeIcon _rendered(WidgetTester tester) =>
    tester.widget<HugeIcon>(find.byType(HugeIcon));

void main() {
  group('AppIcon', () {
    testWidgets('aplica o traço 1.2 do token a todo ícone', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.tractor)));

      expect(_rendered(tester).strokeWidth, AppSize.iconStroke);
      expect(AppSize.iconStroke, 1.2);
    });

    testWidgets('cai em 24 px quando nada define tamanho', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.wallet)));

      expect(_rendered(tester).size, AppSize.iconLg);
    });

    testWidgets('herda tamanho e cor do IconTheme do contexto', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const IconTheme(
            data: IconThemeData(size: AppSize.iconXs, color: Color(0xFFAA0000)),
            child: AppIcon(AppIcons.bell),
          ),
        ),
      );

      final icon = _rendered(tester);
      expect(icon.size, AppSize.iconXs);
      expect(icon.color, const Color(0xFFAA0000));
    });

    testWidgets('parâmetros explícitos vencem o IconTheme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const IconTheme(
            data: IconThemeData(size: AppSize.iconXs, color: Color(0xFFAA0000)),
            child: AppIcon(
              AppIcons.bell,
              size: AppSize.iconXl,
              color: Color(0xFF00AA00),
            ),
          ),
        ),
      );

      final icon = _rendered(tester);
      expect(icon.size, AppSize.iconXl);
      expect(icon.color, const Color(0xFF00AA00));
    });

    testWidgets('sem rótulo o ícone permanece decorativo', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(AppIcons.tractor)));

      expect(find.bySemanticsLabel('Trator'), findsNothing);
    });

    testWidgets('semanticLabel chega ao leitor de tela', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(AppIcons.tractor, semanticLabel: 'Trator')),
      );

      expect(find.bySemanticsLabel('Trator'), findsOneWidget);
    });

    testWidgets('renderiza nos dois temas sem exceções', (tester) async {
      for (final variant in AppThemeVariant.values) {
        await tester.pumpWidget(
          _wrap(const AppIcon(AppIcons.confinamento), variant: variant),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('ocupa exatamente a caixa do tamanho pedido', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(AppIcons.barns, size: AppSize.iconMd)),
      );

      expect(
        tester.getSize(find.byType(HugeIcon)),
        const Size(AppSize.iconMd, AppSize.iconMd),
      );
    });

    testWidgets('sem cor explícita, pinta como `Icon` pintaria', (
      tester,
    ) async {
      // O contrato que a migração precisa preservar: onde antes havia
      // `Icon(LucideIcons.x)` herdando a cor do tema, `AppIcon` herda a mesma.
      late Color themeIconColor;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(AppThemeVariant.light),
          home: Builder(
            builder: (context) {
              themeIconColor = IconTheme.of(context).color!;
              return const Scaffold(body: AppIcon(AppIcons.wallet));
            },
          ),
        ),
      );

      expect(_rendered(tester).color, themeIconColor);
    });
  });

  group('AppIcons — catálogo', () {
    test('apelidos de domínio apontam para entradas reais do catálogo', () {
      const aliases = <String, AppIconData>{
        'confinamento': AppIcons.confinamento,
        'pecuaria': AppIcons.pecuaria,
        'agricultura': AppIcons.agricultura,
        'ordemServico': AppIcons.ordemServico,
        'misturador': AppIcons.misturador,
        'reproducao': AppIcons.reproducao,
        'consultas': AppIcons.consultas,
        'gestaoFrota': AppIcons.gestaoFrota,
        'sincronizar': AppIcons.sincronizar,
        'fazenda': AppIcons.fazenda,
        'estoque': AppIcons.estoque,
        'marketplace': AppIcons.marketplace,
        'openFinance': AppIcons.openFinance,
        'banking': AppIcons.banking,
      };

      for (final entry in aliases.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: 'AppIcons.${entry.key} está vazio',
        );
      }
    });

    test('os ícones nomeados pelo Figma são os do Figma', () {
      // Nomes de camada lidos do nó 54300-2458 — ver §3.4 da esteira.
      expect(AppIcons.barns, HugeIcons.strokeRoundedBarns);
      expect(AppIcons.tractor, HugeIcons.strokeRoundedTractor);
      expect(AppIcons.scanHeart, HugeIcons.strokeRoundedScanHeart);
      expect(AppIcons.bookSearch, HugeIcons.strokeRoundedBookSearch);
      expect(AppIcons.landmark, HugeIcons.strokeRoundedBank);
      expect(AppIcons.eyeOff, HugeIcons.strokeRoundedViewOff);
      expect(AppIcons.aiSearch, HugeIcons.strokeRoundedAiSearch);
      expect(AppIcons.filter, HugeIcons.strokeRoundedFilterHorizontal);
      expect(AppIcons.arrowRight, HugeIcons.strokeRoundedArrowRight01);
      expect(AppIcons.store02, HugeIcons.strokeRoundedStore02);
      expect(AppIcons.connect, HugeIcons.strokeRoundedConnect);
      expect(AppIcons.cash, HugeIcons.strokeRoundedCash02);
      expect(
        AppIcons.creditCardAccept,
        HugeIcons.strokeRoundedCreditCardAccept,
      );
    });

    test('o set de origem é stroke-rounded, e não sólido', () {
      // Um ícone sólido não teria atributo de traço para sobrescrever — é o que
      // torna o 1.2 possível. Guarda contra troca silenciosa de estilo.
      final attributes = AppIcons.tractor
          .map((element) => element[1] as Map<String, dynamic>)
          .toList();

      expect(
        attributes.any((a) => a.containsKey('strokeWidth')),
        isTrue,
        reason: 'ícone sem strokeWidth: o override de 1.2 não teria efeito',
      );
    });
  });
}
