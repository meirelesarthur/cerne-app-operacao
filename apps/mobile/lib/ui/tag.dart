import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Tag.tsx` — rótulo neutro para metadados (categoria, tipo).
/// Diferente do `Chip` (status semântico com cor por estado).
class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.child});

  final Widget child;

  // px-2.5 py-0.5 do React (10px/2px) — sem token exato na escala de espaçamento
  // (space2=8, space3=12); mantidos literais para fidelidade visual ao original.
  static const double _paddingH = 10;
  static const double _paddingV = 2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _paddingH, vertical: _paddingV),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        child: child,
      ),
    );
  }
}

WidgetbookComponent buildTagWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Tag',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTag(child: Text('Grão')),
              AppTag(child: Text('Safra 24/25')),
              AppTag(child: Text('Talhão 12')),
            ],
          ),
        ),
      ),
    ],
  );
}
