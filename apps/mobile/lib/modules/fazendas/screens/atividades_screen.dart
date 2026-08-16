import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../mocks/atividades.dart';

/// Aba "Atividades" — lista cronológica completa (spec §6.7). Espelha
/// `AtividadesScreen.tsx`.
class AtividadesScreen extends StatelessWidget {
  const AtividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const RiseIn(child: AppHeading(child: Text('Atividades'))),
        const SizedBox(height: AppSpacing.space3),
        RiseIn(
          index: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
              border: Border.all(color: semantic.borderDefault),
            ),
            child: Column(
              children: [
                for (final a in atividades)
                  ActivityListItem(
                    activity: a,
                    showDivider: a != atividades.last,
                    onTap: () => showActivityDetailSheet(context, activity: a),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
