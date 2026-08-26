import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'pressable.dart';

/// Seletor de seção dentro de uma mesma tela (ex.: abas de um dashboard) sem
/// trocar de rota. Diferente de uma bottom navigation: é um controle local,
/// usado quando várias visões somente-leitura precisam conviver numa única
/// tela em vez de fragmentar em N rotas.
///
/// Usa `AppPressable` para o alvo de toque/foco/semântica de cada segmento
/// (Lei 1 — nenhuma superfície interativa nova fora do catálogo).
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space1),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderSubtle),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.space1),
            Expanded(
              child: AppPressable(
                semanticLabel: labels[i],
                selected: i == selectedIndex,
                onPressed: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? semantic.bgSurface
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: i == selectedIndex ? semantic.shadowCard : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: i == selectedIndex
                          ? AppTypography.weightSemibold
                          : AppTypography.weightMedium,
                      color: i == selectedIndex
                          ? semantic.fgDefault
                          : semantic.fgMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

WidgetbookComponent buildSegmentedTabsWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SegmentedTabs',
    useCases: [
      WidgetbookUseCase(
        name: 'Quatro seções',
        builder: (context) => const _SegmentedTabsPreview(
          labels: ['Visão geral', 'Mapa', 'Nutrição', 'Relatórios'],
        ),
      ),
    ],
  );
}

class _SegmentedTabsPreview extends StatefulWidget {
  const _SegmentedTabsPreview({required this.labels});

  final List<String> labels;

  @override
  State<_SegmentedTabsPreview> createState() => _SegmentedTabsPreviewState();
}

class _SegmentedTabsPreviewState extends State<_SegmentedTabsPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: AppSegmentedTabs(
        labels: widget.labels,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
