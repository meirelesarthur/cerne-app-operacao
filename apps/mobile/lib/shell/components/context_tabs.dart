import 'package:flutter/material.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../module_config.dart';
import '../state/prototype_session_store.dart';

/// Abas de contexto do módulo ativo: o segmented control do padrão global
/// (Figma `54333:417`) — trilho [AppSemanticColors.bgTrack] com raio
/// [AppRadius.tile] (20) e `p 4`, aba ativa com raio [AppRadius.lgPlus] (16),
/// rótulo de contraste, inativas transparentes com rótulo abafado, 14 px
/// SemiBold nos dois estados.
///
/// **Extensão do padrão:** em Fazendas/Administração, as três abas ocupam a
/// mesma largura no trilho fixo. Os demais módulos continuam podendo rolar e
/// cada aba se dimensiona pelo conteúdo — o vocabulário visual é o mesmo, só
/// a regra de largura muda.
///
/// A ação "Mais" não entra (vira bolha no header, ver `AppShellHeader`).
///
/// Sem `useLocation()`/go_router acoplado: quem chama calcula [activePath] a
/// partir da rota atual e recebe o toque em [onTabSelected] (path relativo,
/// ex.: '' ou 'atividades') para navegar.
class AppContextTabs extends StatelessWidget {
  const AppContextTabs({
    super.key,
    required this.module,
    required this.activePath,
    required this.onTabSelected,
    this.profile,
  });

  final ModuleDef module;
  final String activePath;
  final ValueChanged<String> onTabSelected;
  final UserAccessProfile? profile;

  /// Aba de 40 px do Figma mais os 4 px de respiro do trilho em cima e embaixo.
  static const double _trackHeight = AppSpacing.space12;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final tabs = visibleBottomTabs(
      module,
      profile,
    ).where((tab) => tab.action == null).toList();
    final equalWidthTabs =
        module.id == 'fazendas' &&
        profile == UserAccessProfile.administration &&
        tabs.length == 3;

    return Semantics(
      container: true,
      label: 'Navegação do módulo ${module.label}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        child: Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: semantic.bgTrack,
            borderRadius: BorderRadius.circular(AppRadius.tile),
          ),
          padding: const EdgeInsets.all(AppSpacing.space1),
          child: equalWidthTabs
              ? Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.space1),
                      Expanded(
                        child: _ContextTab(
                          tab: tabs[i],
                          activePath: activePath,
                          onTabSelected: onTabSelected,
                        ),
                      ),
                    ],
                  ],
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(width: AppSpacing.space1),
                  itemBuilder: (context, i) => _ContextTab(
                    tab: tabs[i],
                    activePath: activePath,
                    onTabSelected: onTabSelected,
                    horizontalPadding: AppSpacing.space5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ContextTab extends StatelessWidget {
  const _ContextTab({
    required this.tab,
    required this.activePath,
    required this.onTabSelected,
    this.horizontalPadding,
  });

  final BottomTab tab;
  final String activePath;
  final ValueChanged<String> onTabSelected;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final active = tab.path == activePath;

    return AppPressable(
      semanticLabel: tab.label,
      selected: active,
      onPressed: () => onTabSelected(tab.path),
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.lgPlus),
      child: Container(
        alignment: Alignment.center,
        padding: horizontalPadding == null
            ? null
            : EdgeInsets.symmetric(horizontal: horizontalPadding!),
        decoration: BoxDecoration(
          color: active ? semantic.accentDefault : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lgPlus),
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            fontSize: AppTypography.md,
            fontWeight: AppTypography.weightSemibold,
            color: active ? semantic.accentContrast : semantic.fgMuted,
          ),
        ),
      ),
    );
  }
}
