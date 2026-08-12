import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';

/// Placeholder de seção interna ainda não construída — espelha `EmSection.tsx`.
/// Usado pelos dispatchers-stub (`admin/admin_dashboard.dart`,
/// `operacional/campo_flow.dart`) até as Fases 3/4 (outros processos) entregarem
/// as telas reais.
class EmSection extends StatelessWidget {
  const EmSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ColoredBox(
      color: semantic.bgCanvas,
      child: Column(
        children: [
          SubPageHeader(title: title),
          const Expanded(
            child: Center(
              child: AppEmptyState(
                icon: LucideIcons.construction,
                title: 'Em desenvolvimento',
                description:
                    'Esta tela será construída na próxima fase da esteira.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
