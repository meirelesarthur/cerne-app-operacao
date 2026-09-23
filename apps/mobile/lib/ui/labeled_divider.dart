import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'pressable.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Linha fina com um rótulo curto no meio — separa um bloco resumido do que
/// vem depois e diz o que ficou de fora ("+ 3 ordens para fazer"). Com
/// [onTap], o rótulo inteiro vira atalho para a lista completa.
class AppLabeledDivider extends StatelessWidget {
  const AppLabeledDivider({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final line = Expanded(child: Divider(color: semantic.borderDefault));
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          line,
          const SizedBox(width: AppSpacing.space3),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.base,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          line,
        ],
      ),
    );
    if (onTap == null) return row;
    return AppPressable(semanticLabel: label, onPressed: onTap, child: row);
  }
}

WidgetbookComponent buildLabeledDividerWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'LabeledDivider',
    useCases: [
      WidgetbookUseCase(
        name: 'Resto da fila',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppLabeledDivider(
            label: '+ 3 ordens para fazer',
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}
