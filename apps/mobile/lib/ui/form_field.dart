import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'text_input.dart';

/// Espelha `FormField.tsx` — wrapper de campo: label + controle (`child`) + hint/erro.
/// O controle é sempre um widget do catálogo (`AppTextInput`, `AppFormSelect`, etc.),
/// nunca um `TextField` cru — a tela só compõe.
///
/// Desvio do React: não existe `htmlFor`/`id` de DOM no Flutter; associe rótulo e
/// controle usando o mesmo `FocusNode`/`Semantics` no widget filho, se necessário.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.error,
    this.required = false,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? error;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: AppColors.red500,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space2),
        child,
        if (error != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 12,
                color: AppColors.red600,
              ),
              const SizedBox(width: AppSpacing.space1),
              Flexible(
                child: Text(
                  error!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.weightMedium,
                    color: AppColors.red600,
                  ),
                ),
              ),
            ],
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            hint!,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.xs,
              color: semantic.fgSubtle,
            ),
          ),
        ],
      ],
    );
  }
}

WidgetbookComponent buildFormFieldWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'FormField',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFormField(
                  label: 'Nome da fazenda',
                  required: true,
                  hint: 'Como aparece nos relatórios',
                  child: AppTextInput(placeholder: 'Fazenda Boa Vista'),
                ),
                SizedBox(height: AppSpacing.space6),
                AppFormField(
                  label: 'CNPJ',
                  required: true,
                  error: 'CNPJ inválido',
                  child: AppTextInput(
                    placeholder: '00.000.000/0000-00',
                    invalid: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
