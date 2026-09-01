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
/// **Extensão do padrão:** a referência mostra três abas de largura igual num
/// trilho fixo. Os módulos com mais opções continuam podendo rolar e cada aba
/// se dimensiona pelo conteúdo — o vocabulário visual é o mesmo, só a regra de
/// largura muda. Por isso não reusa `AppSegmentedTabs`, que é o controle de
/// largura fixa. Em Fazendas/Administração, o conjunto foi mantido em três
/// abas: Gestão, Consultas e Atividades.
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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            separatorBuilder: (context, i) =>
                const SizedBox(width: AppSpacing.space1),
            itemBuilder: (context, i) {
              final tab = tabs[i];
              final active = tab.path == activePath;

              return AppPressable(
                semanticLabel: tab.label,
                selected: active,
                onPressed: () => onTabSelected(tab.path),
                minTouchTarget: false,
                borderRadius: BorderRadius.circular(AppRadius.lgPlus),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space5,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? semantic.accentDefault
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lgPlus),
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: AppTypography.md,
                      fontWeight: AppTypography.weightSemibold,
                      color: active
                          ? semantic.accentContrast
                          : semantic.fgMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
