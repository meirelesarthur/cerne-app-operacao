import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/screen_header.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppScreenHeader', () {
    testWidgets('o voltar fica à esquerda do título, na mesma linha', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AppScreenHeader(title: 'Áreas', onBack: () {})),
      );

      final back = tester.getRect(find.byIcon(LucideIcons.arrowLeft));
      final title = tester.getRect(find.text('Áreas'));

      expect(back.right, lessThan(title.left));
      // Mesma linha: as caixas se sobrepõem verticalmente. O padrão antigo
      // punha o voltar numa linha inteiramente acima do título.
      expect(back.top, lessThan(title.bottom));
      expect(back.bottom, greaterThan(title.top));
    });

    testWidgets('sem onBack não renderiza o voltar', (tester) async {
      await tester.pumpWidget(_wrap(const AppScreenHeader(title: 'Cartões')));

      expect(find.byIcon(LucideIcons.arrowLeft), findsNothing);
      expect(find.text('Cartões'), findsOneWidget);
    });

    testWidgets('descrição aparece abaixo do título', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppScreenHeader(
            title: 'Áreas',
            description: 'Cadastrar áreas usadas nos processos da fazenda.',
          ),
        ),
      );

      final title = tester.getRect(find.text('Áreas'));
      final description = tester.getRect(
        find.text('Cadastrar áreas usadas nos processos da fazenda.'),
      );

      expect(description.top, greaterThanOrEqualTo(title.bottom));
    });

    testWidgets('onBack é chamado ao tocar no voltar', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(AppScreenHeader(title: 'Áreas', onBack: () => pressed++)),
      );

      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('backLabel vira o rótulo acessível do voltar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppScreenHeader(
            title: 'Nova área',
            onBack: () {},
            backLabel: 'Voltar aos registros',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Voltar aos registros'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('action fica à direita do título', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppScreenHeader(
            title: 'Fila',
            onBack: () {},
            action: const Icon(LucideIcons.refreshCw),
          ),
        ),
      );

      final title = tester.getRect(find.text('Fila'));
      final action = tester.getRect(find.byIcon(LucideIcons.refreshCw));

      expect(action.left, greaterThan(title.left));
    });
  });
}
