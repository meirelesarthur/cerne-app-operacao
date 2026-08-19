import 'package:flutter/material.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../module_config.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_spacing.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Dock de módulos (Nova UI — referência Força Agro): cápsula flutuante
/// **opaca** (sem blur) — os 6 módulos sempre visíveis (sem rolagem nem corte
/// em viewports estreitos); o ativo vira pílula expandida (ícone + rótulo) em
/// verde de marca sólido + texto branco, os demais ficam como ícones "ghost".
/// Espelha `BottomTabBar.tsx`.
///
/// Autocontido (`Row`/`Container`) — este widget NÃO se posiciona sozinho de
/// forma absoluta na base da tela (diferente do React, que usa
/// `absolute inset-x-0 bottom-0`), para ser reutilizável em testes/Widgetbook
/// sem depender de um `Stack` ancestral. Quem usa (o `ShellLayout`) deve
/// envolver este widget em `Stack` + `Positioned`/`Align` na base, somando
/// `MediaQuery.of(context).padding.bottom` (safe area) ao respiro.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.activeId,
    required this.onModuleSelected,
  });

  final String activeId;

  /// Recebe o `module.id` do módulo tocado.
  final ValueChanged<String> onModuleSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      container: true,
      label: 'Módulos do superapp',
      child: Container(
        padding: const EdgeInsets.all(
          AppComponentMetrics.tabbarInset / AppSpacing.half,
        ),
        decoration: BoxDecoration(
          color: semantic.navBg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: semantic.navBorder),
          boxShadow: semantic.shadowModal,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in modules) ...[
              _ModuleButton(
                label: m.label,
                icon: m.icon,
                active: m.id == activeId,
                onTap: () => onModuleSelected(m.id),
              ),
              if (m != modules.last) const SizedBox(width: AppSpacing.space1),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    if (!active) {
      return Tooltip(
        message: label,
        child: Material(
          color: AppColors.transparent,
          shape: const CircleBorder(),
          child: AppPressable(
            semanticLabel: label,
            onPressed: onTap,
            minTouchTarget: false,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              width: AppComponentMetrics.tabbarItemSize,
              height: AppComponentMetrics.tabbarItemSize,
              child: Center(child: Icon(icon, size: 20, color: semantic.navFg)),
            ),
          ),
        ),
      );
    }

    // Item ativo: pílula expandida (ícone + rótulo) em verde sólido de marca —
    // mesmo tratamento do CTA primário (`AppSemanticColors.cta*`).
    return Tooltip(
      message: label,
      child: Material(
        color: semantic.ctaBg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AppPressable(
          semanticLabel: label,
          selected: true,
          onPressed: onTap,
          minTouchTarget: false,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: AppComponentMetrics.tabbarItemSize,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: semantic.ctaFg),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.ctaFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
