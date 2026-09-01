import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/field_capsule.dart';
import 'package:cerne_app/ui/form_select.dart';
import 'package:cerne_app/ui/search_select.dart';
import 'package:cerne_app/ui/text_input.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);

/// Altura da cápsula **pintada**, não do widget externo. A distinção é o ponto
/// do teste: com a decoração no `InputDecoration`, o `SizedBox` externo media a
/// altura nominal enquanto o pixel visível era uma pílula de 21px (o
/// `InputDecorator` dimensiona `fillColor`/`border` pelo conteúdo, não pelas
/// constraints).
double _paintedHeight(WidgetTester tester) => tester
    .getSize(
      find
          .descendant(
            of: find.byType(AppFieldCapsule),
            matching: find.byType(DecoratedBox),
          )
          .first,
    )
    .height;

void main() {
  group('Cápsula de campo — 52px reais e visíveis', () {
    testWidgets('AppTextInput', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextInput(placeholder: 'E-mail')));

      expect(_paintedHeight(tester), AppSize.controlLg);
    });

    testWidgets('AppTextInput com obscureText', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTextInput(placeholder: 'Senha', obscureText: true)),
      );

      expect(_paintedHeight(tester), AppSize.controlLg);
    });

    testWidgets('AppTextInput com prefixo e sufixo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextInput(
            placeholder: 'Buscar',
            prefixIcon: AppIcon(AppIcons.search, size: 16),
            suffixIcon: AppIcon(AppIcons.x, size: 16),
          ),
        ),
      );

      expect(_paintedHeight(tester), AppSize.controlLg);
    });

    testWidgets('AppFormSelect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppFormSelect(
            options: [AppFormSelectOption(value: 'soja', label: 'Soja')],
            placeholder: 'Selecione a cultura',
          ),
        ),
      );

      expect(_paintedHeight(tester), AppSize.controlLg);
    });

    testWidgets('AppSearchSelect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSearchSelect(
            options: const [AppSearchSelectOption(value: 'a', label: 'Lote A')],
            onChanged: (_) {},
          ),
        ),
      );

      expect(_paintedHeight(tester), AppSize.controlLg);
    });

    testWidgets('o foco não muda a altura nem desloca o conteúdo', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppTextInput(placeholder: 'E-mail')));

      final editorAntes = tester.getRect(find.byType(EditableText));

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      expect(_paintedHeight(tester), AppSize.controlLg);
      expect(tester.getRect(find.byType(EditableText)), editorAntes);
    });
  });
}
