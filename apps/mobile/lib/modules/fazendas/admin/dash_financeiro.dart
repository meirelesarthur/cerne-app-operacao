import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

/// Dashboard Financeiro (spec §4.3): posição por centro de custo, atrasos e
/// investimentos. Espelha `DashFinanceiro.tsx`.
class DashFinanceiro extends StatelessWidget {
  const DashFinanceiro({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(
      title: 'Financeiro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.6,
            children: const [
              AppKpiStatCard(
                label: 'A Receber',
                value: FinanceiroKpis.aReceber,
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(label: 'A Pagar', value: FinanceiroKpis.aPagar),
              AppKpiStatCard(
                label: 'Atrasados',
                value: FinanceiroKpis.atrasados,
                tone: AppKpiStatTone.negative,
                caption: 'Vencidos > 0',
              ),
              AppKpiStatCard(
                label: 'Investimentos',
                value: FinanceiroKpis.investimentos,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Despesas por centro de custo',
            subtitle: 'Valores em milhares (R\$)',
            child: AppBarChart(
              data: [
                for (final c in centrosCusto)
                  AppBarDatum(label: c.label, value: c.value),
              ],
              formatValue: (v) => '${v.toStringAsFixed(0)}k',
            ),
          ),
        ],
      ),
    );
  }
}
