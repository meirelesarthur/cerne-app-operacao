import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

const Map<AtivoEstado, ({String label, AppChipTone tone, AppIconData icon})>
_estadoMeta = {
  AtivoEstado.ativo: (
    label: 'Ativo',
    tone: AppChipTone.brand,
    icon: AppIcons.checkCircle2,
  ),
  AtivoEstado.manutencao: (
    label: 'Em manutenção',
    tone: AppChipTone.amber,
    icon: AppIcons.wrench,
  ),
};

/// Painel **Ativos & Manutenção** (spec §4.5).
///
/// Era uma lista de equipamentos com três KPIs no topo e nenhum gráfico. Ganhou
/// a leitura que sustenta a decisão: onde o patrimônio está concentrado
/// (categoria) e quais máquinas já consumiram a maior parte da própria vida
/// útil. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
class DashAtivos extends StatelessWidget {
  const DashAtivos({super.key});

  /// Valor de aquisição somado por categoria, do maior para o menor.
  Map<String, double> get _porCategoria {
    final total = <String, double>{};
    for (final a in ativos) {
      total[a.categoria] = (total[a.categoria] ?? 0) + a.aquisicaoMil;
    }
    final ordenado = total.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(ordenado);
  }

  @override
  Widget build(BuildContext context) {
    final emManutencao = ativos
        .where((a) => a.estado == AtivoEstado.manutencao)
        .length;
    final maisDepreciados = [...ativos]
      ..sort((a, b) => b.depreciado.compareTo(a.depreciado));

    return DashboardScreen(
      title: 'Ativos & Manutenção',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMetricGrid(
            children: [
              AppKpiStatCard(label: 'Aquisição', value: AtivosResumo.total),
              AppKpiStatCard(
                label: 'Depreciação',
                value: AtivosResumo.depreciacao,
                tone: AppKpiStatTone.negative,
              ),
              AppKpiStatCard(
                label: 'Líquido',
                value: AtivosResumo.liquido,
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(
                label: 'Em manutenção',
                value: '$emManutencao',
                tone: emManutencao > 0
                    ? AppKpiStatTone.warning
                    : AppKpiStatTone.neutral,
                caption: 'de ${ativos.length} ativos',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Patrimônio por categoria',
            footnote:
                'Valor de aquisição; o líquido desconta a depreciação acumulada.',
            child: Center(
              child: AppDonutChart(
                centerValue: AtivosResumo.total,
                centerLabel: 'aquisição',
                data: [
                  for (final entry in _porCategoria.entries)
                    AppDonutSlice(label: entry.key, value: entry.value),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Vida útil consumida',
            subtitle: 'Depreciação acumulada por ativo',
            child: AppBarChart(
              data: [
                for (final a in maisDepreciados)
                  AppBarDatum(label: a.nome, value: a.depreciado.toDouble()),
              ],
              formatValue: (v) => '${v.toStringAsFixed(0)}%',
            ),
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
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
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
                    Text(
                      ativo.aquisicao,
                      style: TextStyle(
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.wrench,
                          size: 11,
                          color: semantic.fgSubtle,
                        ),
                        const SizedBox(width: AppSpacing.space1),
                        Text(
                          ativo.proximaManutencao,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    value: ativo.depreciado.toDouble(),
                    tone: AppProgressBarTone.amber,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  '${ativo.depreciado}%',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.fgMuted,
                  ),
                ),
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
                        style: TextStyle(
                          fontSize: AppTypography.xl,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                  ),
                ),
                AppChip(
                  tone: estado.tone,
                  icon: AppIcon(estado.icon, size: 12),
                  child: Text(estado.label),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Ano de aquisição', value: '${ativo.ano}'),
                  _DetailRow(
                    label: 'Valor de aquisição',
                    value: ativo.aquisicao,
                  ),
                  _DetailRow(
                    label: 'Valor residual',
                    value: ativo.valorResidual,
                  ),
                  _DetailRow(
                    label: 'Próxima manutenção',
                    value: ativo.proximaManutencao,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Depreciação acumulada',
                  style: TextStyle(color: semantic.fgMuted),
                ),
                Text(
                  '${ativo.depreciado}%',
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space1),
            AppProgressBar(
              value: ativo.depreciado.toDouble(),
              tone: AppProgressBarTone.amber,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Ficha completa do ativo, histórico de manutenções e anexos ficam no sistema web GB CERNE.',
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
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.base,
              color: semantic.fgMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.base,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
