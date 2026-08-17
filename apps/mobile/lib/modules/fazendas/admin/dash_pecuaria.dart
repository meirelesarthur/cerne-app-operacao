import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../mocks/atividades.dart';
import '../mocks/dashboards_mocks.dart';
import '../types.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

const _icons = [LucideIcons.wallet, LucideIcons.package, LucideIcons.beef];

/// Dashboard Pecuária de Corte (spec §4.1). Bloco Financeiro ativo; bloco
/// Produtivo/Reprodutivo DESATIVADO (LACUNA no legado, §7.2). Espelha
/// `DashPecuaria.tsx`.
class DashPecuaria extends StatelessWidget {
  const DashPecuaria({super.key});

  @override
  Widget build(BuildContext context) {
    final recentes = atividades
        .where(
          (a) => [
            ActivityKind.pesagem,
            ActivityKind.evento,
            ActivityKind.venda,
          ].contains(a.kind),
        )
        .take(4)
        .toList();

    return DashboardScreen(
      title: 'Pecuária de Corte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(child: Text('Financeiro')),
          const SizedBox(height: AppSpacing.space2),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.3,
            children: [
              for (var i = 0; i < pecuariaFinanceiro.length; i++)
                AppDashboardCard(
                  icon: _icons[i % _icons.length],
                  label: pecuariaFinanceiro[i].label,
                  value: pecuariaFinanceiro[i].value,
                  delta: pecuariaFinanceiro[i].delta,
                  spark: pecuariaFinanceiro[i].spark,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          const AppSectionTitle(child: Text('Produtivo / Reprodutivo')),
          const SizedBox(height: AppSpacing.space2),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.3,
            children: const [
              AppDashboardCard(
                icon: LucideIcons.heartPulse,
                label: 'Taxa de prenhez',
                value: '—',
                disabled: true,
              ),
              AppDashboardCard(
                icon: LucideIcons.baby,
                label: 'Desmame',
                value: '—',
                disabled: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Builder(
            builder: (context) {
              final semantic = Theme.of(
                context,
              ).extension<AppSemanticColors>()!;
              return Text(
                'Indicadores produtivos/reprodutivos em definição no legado — não exibidos para evitar dado incorreto.',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.fgSubtle,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.space6),
          const AppSectionTitle(child: Text('Atividades recentes do rebanho')),
          const SizedBox(height: AppSpacing.space2),
          AppCard(
            padded: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
              ),
              child: Column(
                children: [
                  for (final a in recentes)
                    ActivityListItem(
                      activity: a,
                      showDivider: a != recentes.last,
                      onTap: () =>
                          showActivityDetailSheet(context, activity: a),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
