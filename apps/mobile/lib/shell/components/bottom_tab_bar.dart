import 'package:flutter/material.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../module_config.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_spacing.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Navbar flutuante do app (Nova UI — referência Força Agro): cápsula
/// **opaca** (sem blur); a aba ativa vira pílula expandida (ícone + rótulo)
/// em verde de marca sólido + texto branco, as demais ficam como ícones
/// "ghost". As abas vêm de `operationalBottomTabs` (`module_config.dart`).
///
/// Autocontido (`Row`/`Container`) — este widget NÃO se posiciona sozinho na
/// base da tela, para ser reutilizável em testes/Widgetbook sem depender de
/// um `Stack` ancestral. Quem usa (o `ShellLayout`) envolve em `Stack` +
/// `Positioned` na base, somando `MediaQuery.of(context).padding.bottom`
/// (safe area) ao respiro.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.onSelected,
  });

  final List<BottomTab> tabs;
  final String activeId;
  final ValueChanged<BottomTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      container: true,
      label: 'Navegação principal',
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
        // Rede de segurança: com a pílula ativa expandida, a Row poderia
        // estourar a largura de um Android estreito (360dp) sem avisar.
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tab in tabs) ...[
                _ModuleButton(
                  label: tab.label,
                  icon: tab.icon,
                  active: tab.id == activeId,
                  onTap: () => onSelected(tab),
                ),
                if (tab != tabs.last) const SizedBox(width: AppSpacing.space1),
              ],
            ],
          ),
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
  final AppIconData icon;
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
              child: Center(
                child: AppIcon(
                  icon,
                  size: AppSize.iconMd,
                  color: semantic.navFg,
                ),
              ),
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
                AppIcon(icon, size: AppSize.iconMd, color: semantic.ctaFg),
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
