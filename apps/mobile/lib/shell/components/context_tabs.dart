import 'package:flutter/material.dart';

import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../module_config.dart';

/// Abas de contexto do módulo ativo (Nova UI): chips-pílula roláveis no topo —
/// espelha `ContextTabs.tsx`. A ativa vira cápsula ink com texto verde vibrante.
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
  });

  final ModuleDef module;
  final String activePath;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final tabs = module.bottomTabs.where((tab) => tab.action == null).toList();

    return Semantics(
      container: true,
      label: 'Navegação do módulo ${module.label}',
      child: ColoredBox(
        color: semantic.bgCanvas,
        child: SizedBox(
          height: AppSpacing.space10 + AppSpacing.space6,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
            itemCount: tabs.length,
            separatorBuilder: (context, i) => const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, i) {
              final tab = tabs[i];
              final active = tab.path == activePath;

              return Container(
                decoration: !active
                    ? BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), boxShadow: semantic.shadowCard)
                    : null,
                child: Material(
                  color: active ? semantic.inkBg : semantic.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: InkWell(
                    onTap: () => onTabSelected(tab.path),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: Semantics(
                      button: true,
                      selected: active,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                        child: Center(
                          child: Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: AppTypography.md,
                              fontWeight: AppTypography.weightSemibold,
                              color: active ? semantic.ctaBg : semantic.fgMuted,
                            ),
                          ),
                        ),
                      ),
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
