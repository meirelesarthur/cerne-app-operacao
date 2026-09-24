import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import '../module_config.dart';

/// Dock do "+" da navbar: as rotinas de lançamento mais usadas
/// ([operationalQuickAdds]) numa grade de atalhos — a mesma
/// [AppModuleTileGrid] dos atalhos da tela inicial. Tocar num atalho fecha a
/// dock e devolve o item; quem abriu navega.
Future<ModuleMenuItem?> showQuickAddSheet(
  BuildContext context, {
  required List<ModuleMenuItem> items,
}) {
  return showAppBottomSheet<ModuleMenuItem>(
    context,
    title: 'O que você quer lançar?',
    child: AppModuleTileGrid(
      columns: 3,
      tiles: [
        for (final item in items)
          AppModuleTile(
            icon: item.icon,
            label: item.label,
            dense: true,
            onTap: () => Navigator.of(context, rootNavigator: true).pop(item),
          ),
      ],
    ),
  );
}
