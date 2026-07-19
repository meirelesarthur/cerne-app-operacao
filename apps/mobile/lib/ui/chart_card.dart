import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'card.dart';
import 'heading.dart';

/// Espelha `ChartCard.tsx` — card contêiner para um gráfico, com título e ação
/// opcional. Compõe `AppCard` + `AppHeading` (nível 4), nunca reimplementa
/// estilo de card/título localmente (Lei 2 do CLAUDE.md).
class AppChartCard extends StatelessWidget {
  const AppChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppHeading(level: AppHeadingLevel.h4, child: Text(title)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.space1),
                          child: Text(
                            subtitle!,
                            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
                          ),
                        ),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

WidgetbookComponent buildChartCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ChartCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Receitas x Despesas',
              subtitle: 'Últimos 6 meses',
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Com ação',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Produção mensal',
              action: Icon(LucideIcons.ellipsis, size: 18),
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
