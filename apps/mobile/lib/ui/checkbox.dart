import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Checkbox.tsx` — controle `role="checkbox"` acessível, componente
/// controlado (`checked`/`onChanged`), encapsulando o toque para cumprir a Lei 1.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label,
    this.semanticLabel,
  }) : assert(
         label != null || semanticLabel != null,
         'Informe label ou semanticLabel para acessibilidade.',
       );

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      checked: checked,
      label: semanticLabel ?? label,
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSize.control,
            minHeight: AppSize.control,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: AppSpacing.space5,
                  height: AppSpacing.space5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: checked
                        ? semantic.accentDefault
                        : semantic.bgSurface,
                    border: Border.all(
                      color: checked
                          ? semantic.accentDefault
                          : semantic.borderStrong,
                    ),
                  ),
                  child: checked
                      ? const Icon(
                          LucideIcons.check,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (label != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  Text(
                    label!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.md,
                      color: semantic.fgDefault,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildCheckboxWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Checkbox',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const _CheckboxUseCase(),
      ),
    ],
  );
}

class _CheckboxUseCase extends StatefulWidget {
  const _CheckboxUseCase();

  @override
  State<_CheckboxUseCase> createState() => _CheckboxUseCaseState();
}

class _CheckboxUseCaseState extends State<_CheckboxUseCase> {
  bool _a = false;
  bool _b = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCheckbox(
            checked: _a,
            onChanged: (v) => setState(() => _a = v),
            label: 'Aceito os termos',
          ),
          const SizedBox(height: AppSpacing.space3),
          AppCheckbox(
            checked: _b,
            onChanged: (v) => setState(() => _b = v),
            label: 'Receber notificações',
          ),
        ],
      ),
    );
  }
}
