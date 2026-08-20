import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Tom do rótulo/ícone — espelha `MenuItemTone` (`'default' | 'danger'`) de
/// `MenuItem.tsx`. `default` é palavra reservada em Dart, por isso o valor
/// neutro chama-se [AppMenuItemTone.standard].
enum AppMenuItemTone { standard, danger }

/// Espelha `MenuItemVariant` (`'light' | 'onDark'`) de `MenuItem.tsx`.
enum AppMenuItemVariant { light, onDark }

/// Item de menu/navegação (Nova UI): linha-cápsula com bolha de ícone à
/// esquerda, título + descrição e chevron em círculo à direita.
/// Touch target ≥ 56px (`AppSpacing.space14`), espelhando `min-h-14` do React.
class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    super.key,
    this.icon,
    required this.label,
    this.description,
    this.trailing,
    this.active = false,
    this.tone = AppMenuItemTone.standard,
    this.variant = AppMenuItemVariant.light,
    this.showShadow = true,
    this.onTap,
  });

  final IconData? icon;
  final String label;
  final String? description;
  final Widget? trailing;
  final bool active;
  final AppMenuItemTone tone;
  final AppMenuItemVariant variant;

  /// Sombra do card quando `light`/inativo (`shadowCard`). Telas com muitos
  /// itens em sequência (ex.: `GroupFeaturesScreen`) podem desligar para uma
  /// lista mais plana, sem repetir a mesma sombra a cada linha.
  final bool showShadow;
  final VoidCallback? onTap;

  bool get _isDanger => tone == AppMenuItemTone.danger;
  bool get _isOnDark => variant == AppMenuItemVariant.onDark;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final containerColor = active
        ? (_isOnDark
              ? AppColors.neutral0.withValues(alpha: 0.15)
              : semantic.accentSubtle)
        : (_isOnDark ? semantic.inkBubble : semantic.bgSurface);

    final labelColor = _isDanger
        ? (_isOnDark ? AppColors.red400 : AppColors.red600)
        : active
        ? (_isOnDark ? semantic.inkFg : semantic.accentDefault)
        : (_isOnDark ? semantic.inkFg : semantic.fgDefault);

    final descriptionColor = _isOnDark ? semantic.inkMuted : semantic.fgMuted;
    final iconBubbleColor = _isDanger
        ? AppColors.red500.withValues(alpha: 0.1)
        : (_isOnDark ? semantic.inkBubble : semantic.bgSubtle);
    final iconColor = _isDanger
        ? AppColors.red500
        : (_isOnDark ? semantic.inkFg : semantic.fgMuted);
    final chevronBubbleColor = _isOnDark
        ? semantic.inkBubble
        : semantic.bgSubtle;
    final chevronColor = _isOnDark ? semantic.inkMuted : semantic.fgMuted;

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.space14),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: !active && !_isOnDark && showShadow
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                  boxShadow: semantic.shadowCard,
                )
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  height: AppSpacing.space10,
                  width: AppSpacing.space10,
                  decoration: BoxDecoration(
                    color: iconBubbleColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightSemibold,
                        color: labelColor,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: descriptionColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space2),
                  child: trailing,
                )
              else if (onTap != null)
                Container(
                  height: AppSpacing.space8,
                  width: AppSpacing.space8,
                  margin: const EdgeInsets.only(left: AppSpacing.space2),
                  decoration: BoxDecoration(
                    color: chevronBubbleColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 15,
                    color: chevronColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildMenuItemWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'MenuItem',
    useCases: [
      WidgetbookUseCase(
        name: 'Light — padrão',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMenuItem(
                icon: LucideIcons.user,
                label: 'Perfil',
                description: 'Dados pessoais e documentos',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: LucideIcons.bell,
                label: 'Notificações',
                active: true,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: LucideIcons.logOut,
                label: 'Sair',
                tone: AppMenuItemTone.danger,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'onDark',
        builder: (context) => Container(
          color: Theme.of(context).extension<AppSemanticColors>()!.inkBg,
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMenuItem(
                icon: LucideIcons.settings,
                label: 'Configurações',
                variant: AppMenuItemVariant.onDark,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: LucideIcons.shield,
                label: 'Segurança',
                active: true,
                variant: AppMenuItemVariant.onDark,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
