import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_spacing.dart';

/// Espelha `IconButton.tsx` do protótipo React — bolha circular com touch target
/// generoso. `label` é obrigatório (acessibilidade: vira `Semantics`/`Tooltip`).
enum AppIconButtonSize { sm, md, lg }

enum AppIconButtonVariant { ghost, solid, onDark }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = AppIconButtonSize.md,
    this.variant = AppIconButtonVariant.ghost,
  });

  /// Conteúdo do botão — tipicamente `Icon(LucideIcons.xxx)`.
  final Widget icon;

  /// Rótulo acessível obrigatório (equivalente a `aria-label`/`title` no React).
  final String label;
  final VoidCallback? onPressed;
  final AppIconButtonSize size;
  final AppIconButtonVariant variant;

  double get _dimension => switch (size) {
    AppIconButtonSize.sm => AppSize.iconBtnSm,
    AppIconButtonSize.md => AppSize.iconBtnMd,
    AppIconButtonSize.lg => AppSize.iconBtnLg,
  };

  ({Color bg, Color fg, List<BoxShadow> shadow}) _colors(AppSemanticColors s) =>
      switch (variant) {
        AppIconButtonVariant.ghost => (
          bg: AppColors.transparent,
          fg: s.fgDefault,
          shadow: const <BoxShadow>[],
        ),
        AppIconButtonVariant.solid => (
          bg: s.bgSurface,
          fg: s.fgDefault,
          shadow: s.shadowCard,
        ),
        AppIconButtonVariant.onDark => (
          bg: s.inkBubble,
          fg: s.inkFg,
          shadow: const <BoxShadow>[],
        ),
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final colors = _colors(semantic);

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        enabled: onPressed != null,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: colors.shadow,
          ),
          child: Material(
            color: colors.bg,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: _dimension,
                height: _dimension,
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.fg),
                  child: Center(child: icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildIconButtonWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'IconButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Variantes',
        builder: (context) => Center(
          child: Wrap(
            spacing: 12,
            children: [
              AppIconButton(
                icon: const Icon(LucideIcons.menu),
                label: 'Menu',
                onPressed: () {},
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.bell),
                label: 'Notificações',
                variant: AppIconButtonVariant.solid,
                onPressed: () {},
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                color: AppColors.black,
                child: AppIconButton(
                  icon: const Icon(LucideIcons.x),
                  label: 'Fechar',
                  variant: AppIconButtonVariant.onDark,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tamanhos',
        builder: (context) => Center(
          child: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppIconButton(
                icon: const Icon(LucideIcons.plus),
                label: 'Pequeno',
                size: AppIconButtonSize.sm,
                onPressed: () {},
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.plus),
                label: 'Médio',
                onPressed: () {},
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.plus),
                label: 'Grande',
                size: AppIconButtonSize.lg,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
