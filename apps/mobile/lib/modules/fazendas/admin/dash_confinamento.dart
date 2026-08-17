import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Dashboard Lotação de Currais / Confinamento (spec §4.2). Espelha
/// `DashConfinamento.tsx`.
class DashConfinamento extends StatelessWidget {
  const DashConfinamento({super.key});

  @override
  Widget build(BuildContext context) {
    final totalCap = currais.fold<int>(0, (s, c) => s + c.max);
    final totalAtual = currais.fold<int>(0, (s, c) => s + c.atual);
    final ocupacao = totalCap == 0
        ? 0
        : ((totalAtual / totalCap) * 100).round();
    final disponiveis = currais.where((c) => c.atual < c.max).length;

    return DashboardScreen(
      title: 'Lotação de Currais',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space2,
            crossAxisSpacing: AppSpacing.space2,
            childAspectRatio: 1.1,
            children: [
              AppKpiStatCard(
                label: 'Ocupação',
                value: '$ocupacao%',
                tone: ocupacao >= 80
                    ? AppKpiStatTone.warning
                    : AppKpiStatTone.positive,
              ),
              AppKpiStatCard(label: 'Disponíveis', value: '$disponiveis'),
              AppKpiStatCard(label: 'Cabeças', value: '$totalAtual'),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Mapa de currais')),
          const SizedBox(height: AppSpacing.space2),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.15,
            children: [for (final c in currais) _CurralTile(curral: c)],
          ),
        ],
      ),
    );
  }
}

class _CurralTile extends StatelessWidget {
  const _CurralTile({required this.curral});

  final Curral curral;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final pct = curral.max == 0
        ? 0
        : ((curral.atual / curral.max) * 100).round();
    final chipTone = pct >= 100
        ? AppChipTone.red
        : (pct >= 80 ? AppChipTone.amber : AppChipTone.brand);

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showCurralDetail(context, curral),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    curral.nome,
                    style: TextStyle(
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ),
                AppChip(tone: chipTone, child: Text('$pct%')),
              ],
            ),
            Text(
              curral.setor,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgDefault,
                ),
                children: [
                  TextSpan(text: '${curral.atual}'),
                  TextSpan(
                    text: '/${curral.max}',
                    style: TextStyle(color: semantic.fgSubtle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            AppProgressBar(
              value: curral.atual.toDouble(),
              max: curral.max.toDouble(),
              colorByOccupancy: true,
            ),
          ],
        ),
      ),
    );
  }
}

void _showCurralDetail(BuildContext context, Curral curral) {
  showAppBottomSheet<void>(
    context,
    title: curral.nome,
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Setor', style: TextStyle(color: semantic.fgMuted)),
                Text(
                  curral.setor,
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ocupação', style: TextStyle(color: semantic.fgMuted)),
                Text(
                  '${curral.atual}/${curral.max} cabeças',
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            AppProgressBar(
              value: curral.atual.toDouble(),
              max: curral.max.toDouble(),
              colorByOccupancy: true,
              showLabel: true,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Histórico de ocupação e movimentações do curral aparecem aqui na versão completa.',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        );
      },
    ),
  );
}
