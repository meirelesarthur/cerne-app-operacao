import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import '../module_config.dart';

/// Navbar do app: as abas de `operationalBottomTabs` (`module_config.dart`)
/// desenhadas pelo [AppTabBar] do catálogo — só ícones, o item ativo
/// flutuando num hexágono verde com o nome embaixo, e o "+" de adição rápida
/// no centro ([quickAddAction]).
///
/// Não se posiciona sozinha: o `ShellLayout` a coloca na base da tela,
/// somando a safe area inferior ao respiro.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.onSelected,
    this.quickAddOpen = false,
  });

  final List<BottomTab> tabs;
  final String activeId;
  final ValueChanged<BottomTab> onSelected;

  /// A dock de adição rápida está aberta: o "+" vira "×".
  final bool quickAddOpen;

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      activeId: activeId,
      actionOpen: quickAddOpen,
      items: [
        for (final tab in tabs)
          AppTabBarItem(
            id: tab.id,
            label: tab.label,
            icon: tab.icon,
            isAction: tab.action == quickAddAction,
          ),
      ],
      onSelected: (item) => onSelected(tabs.firstWhere((t) => t.id == item.id)),
    );
  }
}
