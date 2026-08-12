import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'spinner.dart';

/// Espelha `Button.tsx` do protótipo React (§1.2 do PLANO-MIGRACAO-FLUTTER.md).
/// Mesmos nomes/variantes — screens compõem este widget, nunca `ElevatedButton`/`TextButton`
/// direto (Lei 1 do CLAUDE.md, espelhada aqui: catálogo primeiro).
enum AppButtonVariant { primary, secondary, ghost, danger, link }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
    this.leftIcon,
    this.rightIcon,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final Widget? leftIcon;
  final Widget? rightIcon;

  bool get _disabled => onPressed == null || loading;

  double get _height => switch (size) {
    AppButtonSize.sm => AppSize.btnSm,
    AppButtonSize.md => AppSize.btnMd,
    AppButtonSize.lg => AppSize.btnLg,
  };

  double get _horizontalPadding => switch (size) {
    AppButtonSize.sm => AppSpacing.space4,
    AppButtonSize.md => AppSpacing.space5,
    AppButtonSize.lg => AppSpacing.space6,
  };

  double get _fontSize => switch (size) {
    AppButtonSize.sm => AppTypography.sm,
    AppButtonSize.md => AppTypography.md,
    AppButtonSize.lg => AppTypography.lg,
  };

  double get _spinnerSize => size == AppButtonSize.lg ? 20 : 16;

  ({Color bg, Color fg, Color? border}) _colors(AppSemanticColors s) =>
      switch (variant) {
        AppButtonVariant.primary => (bg: s.ctaBg, fg: s.ctaFg, border: null),
        AppButtonVariant.secondary => (
          bg: s.bgSurface,
          fg: s.fgDefault,
          border: s.borderDefault,
        ),
        AppButtonVariant.ghost => (
          bg: Colors.transparent,
          fg: s.fgDefault,
          border: null,
        ),
        AppButtonVariant.danger => (
          bg: AppColors.red600,
          fg: Colors.white,
          border: null,
        ),
        AppButtonVariant.link => (
          bg: Colors.transparent,
          fg: s.accentDefault,
          border: null,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final colors = _colors(semantic);

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: AppSpinner(size: _spinnerSize, color: colors.fg),
          )
        else if (leftIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: leftIcon,
          ),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: variant == AppButtonVariant.link
                ? AppTypography.sm
                : _fontSize,
            fontWeight: AppTypography.weightSemibold,
            color: colors.fg,
            decoration: variant == AppButtonVariant.link
                ? TextDecoration.underline
                : null,
          ),
          child: child,
        ),
        if (!loading && rightIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.space2),
            child: rightIcon,
          ),
      ],
    );

    if (variant == AppButtonVariant.link) {
      return Opacity(
        opacity: _disabled && !loading ? 0.7 : 1,
        child: GestureDetector(
          onTap: _disabled ? null : onPressed,
          child: content,
        ),
      );
    }

    return Opacity(
      opacity: _disabled && !loading ? 0.7 : 1,
      child: Material(
        color: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: colors.border != null
              ? BorderSide(color: colors.border!)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: _disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: _height,
            width: fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Use-cases da galeria (F2.5) — agregado em `widgetbook_app.dart`.
/// Convenção: toda unidade de `lib/ui/` expõe `buildXxxWidgetbookComponent()`.
WidgetbookComponent buildButtonWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Button',
    useCases: [
      WidgetbookUseCase(
        name: 'Variantes',
        builder: (context) => Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(onPressed: () {}, child: const Text('Primary')),
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Secondary'),
              ),
              AppButton(
                variant: AppButtonVariant.ghost,
                onPressed: () {},
                child: const Text('Ghost'),
              ),
              AppButton(
                variant: AppButtonVariant.danger,
                onPressed: () {},
                child: const Text('Danger'),
              ),
              AppButton(
                variant: AppButtonVariant.link,
                onPressed: () {},
                child: const Text('Link'),
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
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton(
                size: AppButtonSize.sm,
                onPressed: () {},
                child: const Text('Small'),
              ),
              AppButton(onPressed: () {}, child: const Text('Medium')),
              AppButton(
                size: AppButtonSize.lg,
                onPressed: () {},
                child: const Text('Large'),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  const AppButton(child: Text('Disabled')),
                  AppButton(
                    loading: true,
                    onPressed: () {},
                    child: const Text('Loading'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 280,
                child: AppButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Full width'),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
