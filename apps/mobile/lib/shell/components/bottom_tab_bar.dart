import 'dart:ui';

import 'package:flutter/material.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/theme/app_theme_extension.dart';
import '../module_config.dart';

/// Dock de módulos (Nova UI): cápsula flutuante icon-only — os 6 módulos
/// sempre visíveis (sem rolagem nem corte em viewports estreitos), o ativo
/// vira círculo ink com ícone verde vibrante. Espelha `BottomTabBar.tsx`.
///
/// Autocontido (`Row`/`Container`) — este widget NÃO se posiciona sozinho de
/// forma absoluta na base da tela (diferente do React, que usa
/// `absolute inset-x-0 bottom-0`), para ser reutilizável em testes/Widgetbook
/// sem depender de um `Stack` ancestral. Quem usa (o futuro `ShellLayout`)
/// deve envolver este widget em `Stack` + `Positioned`/`Align` na base,
/// somando `MediaQuery.of(context).padding.bottom` (safe area) ao respiro.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({super.key, required this.activeId, required this.onModuleSelected});

  final String activeId;

  /// Recebe o `module.id` do módulo tocado.
  final ValueChanged<String> onModuleSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      container: true,
      label: 'Módulos do superapp',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppComponentMetrics.tabbarBlur,
            sigmaY: AppComponentMetrics.tabbarBlur,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppComponentMetrics.tabbarInset / 2),
            decoration: BoxDecoration(
              color: semantic.navBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: semantic.navBorder),
              boxShadow: semantic.shadowModal,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in modules)
                  _ModuleButton(
                    label: m.label,
                    icon: m.icon,
                    active: m.id == activeId,
                    onTap: () => onModuleSelected(m.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({required this.label, required this.icon, required this.active, required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        selected: active,
        child: Material(
          color: active ? semantic.inkBg : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppComponentMetrics.tabbarItemSize,
              height: AppComponentMetrics.tabbarItemSize,
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: active ? semantic.navActive : semantic.navFg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
