import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

const Map<AtivoEstado, ({String label, AppChipTone tone, IconData icon})> _estadoMeta = {
  AtivoEstado.ativo: (label: 'Ativo', tone: AppChipTone.brand, icon: LucideIcons.checkCircle2),
  AtivoEstado.manutencao: (label: 'Em manutenção', tone: AppChipTone.amber, icon: LucideIcons.wrench),
};

/// Dashboard de Ativos / Depreciação (spec §4.5). Espelha `DashAtivos.tsx`.
class DashAtivos extends StatelessWidget {
  const DashAtivos({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(
      title: 'Ativos / Depreciação',
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
            children: const [
              AppKpiStatCard(label: 'Total', value: AtivosResumo.total),
              AppKpiStatCard(label: 'Depreciação', value: AtivosResumo.depreciacao, tone: AppKpiStatTone.negative),
              AppKpiStatCard(label: 'Líquido', value: AtivosResumo.liquido, tone: AppKpiStatTone.positive),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Equipamentos')),
          const SizedBox(height: AppSpacing.space2),
          Column(
            children: [
              for (final a in ativos) ...[
                _AtivoCard(ativo: a),
                if (a != ativos.last) const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AtivoCard extends StatelessWidget {
  const _AtivoCard({required this.ativo});

  final Ativo ativo;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showAtivoDetail(context, ativo),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ativo.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, color: semantic.fgDefault),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      AppTag(child: Text(ativo.categoria)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ativo.aquisicao, style: TextStyle(fontWeight: FontWeight.w600, color: semantic.fgDefault)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.wrench, size: 11, color: semantic.fgSubtle),
                        const SizedBox(width: 4),
                        Text(ativo.proximaManutencao, style: TextStyle(fontSize: 11, color: semantic.fgSubtle)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(child: AppProgressBar(value: ativo.depreciado.toDouble(), tone: AppProgressBarTone.amber)),
                const SizedBox(width: AppSpacing.space2),
                Text('${ativo.depreciado}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: semantic.fgMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showAtivoDetail(BuildContext context, Ativo ativo) {
  final estado = _estadoMeta[ativo.estado]!;

  showAppBottomSheet<void>(
    context,
    title: 'Detalhe do ativo',
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTag(child: Text(ativo.categoria)),
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        ativo.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: semantic.fgDefault),
                      ),
                    ],
                  ),
                ),
                AppChip(tone: estado.tone, icon: Icon(estado.icon, size: 12), child: Text(estado.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(color: semantic.bgSubtle, borderRadius: BorderRadius.circular(AppRadius.xl2)),
              child: Column(
                children: [
                  _DetailRow(label: 'Ano de aquisição', value: '${ativo.ano}'),
                  _DetailRow(label: 'Valor de aquisição', value: ativo.aquisicao),
                  _DetailRow(label: 'Valor residual', value: ativo.valorResidual),
                  _DetailRow(label: 'Próxima manutenção', value: ativo.proximaManutencao),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Depreciação acumulada', style: TextStyle(color: semantic.fgMuted)),
                Text('${ativo.depreciado}%', style: TextStyle(fontWeight: FontWeight.w600, color: semantic.fgDefault)),
              ],
            ),
            const SizedBox(height: AppSpacing.space1),
            AppProgressBar(value: ativo.depreciado.toDouble(), tone: AppProgressBarTone.amber),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Ficha completa do ativo, histórico de manutenções e anexos ficam no sistema web GB CERNE.',
              style: TextStyle(fontSize: 13, color: semantic.fgSubtle),
            ),
          ],
        );
      },
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: semantic.fgMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: semantic.fgDefault),
            ),
          ),
        ],
      ),
    );
  }
}
