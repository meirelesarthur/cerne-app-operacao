import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um item de dado do [AppBarChart] — espelha `BarDatum` de `BarChart.tsx`.
class AppBarDatum {
  const AppBarDatum({required this.label, required this.value, this.color});

  final String label;
  final double value;

  /// Cor da barra; sem valor, usa `AppColors.chartSeries[i % length]` (mesmo fallback do React).
  final Color? color;
}

/// Espelha `BarChart.tsx` — gráfico de barras horizontal, tokenizado.
/// Pintado via [CustomPainter] (ADR do projeto: os 3 gráficos usam Canvas em vez
/// de lib de charting), reproduzindo a mesma matemática de proporção do SVG/DOM original.
class AppBarChart extends StatelessWidget {
  const AppBarChart({super.key, required this.data, this.height = 160, this.formatValue});

  final List<AppBarDatum> data;
  final double height;

  /// Formata o valor exibido dentro da barra; padrão: `value.toStringAsFixed(0)`.
  final String Function(double value)? formatValue;

  // w-24 (96px) do React, expresso como múltiplo de token de espaçamento.
  static const double _labelWidth = AppSpacing.space4 * 6;
  static const double _rowHeight = AppSpacing.space6; // h-6 (24px)
  static const double _rowGap = AppSpacing.space2; // gap-2 (8px)

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final fmt = formatValue ?? (v) => v.toStringAsFixed(0);
    final rowTotal = _rowHeight + _rowGap;
    final minHeight = data.isEmpty ? height : (data.length * rowTotal - _rowGap);

    return SizedBox(
      height: minHeight > height ? minHeight : height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarChartPainter(
          data: data,
          formatValue: fmt,
          trackColor: semantic.bgSubtle,
          labelColor: semantic.fgMuted,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.formatValue,
    required this.trackColor,
    required this.labelColor,
  });

  final List<AppBarDatum> data;
  final String Function(double value) formatValue;
  final Color trackColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final max = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final maxVal = max <= 0 ? 1.0 : max;
    const labelWidth = AppBarChart._labelWidth;
    const rowHeight = AppBarChart._rowHeight;
    const rowGap = AppBarChart._rowGap;
    const rowTotal = rowHeight + rowGap;
    const trackGap = AppSpacing.space2;

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final top = i * rowTotal;

      final labelPainter = TextPainter(
        text: TextSpan(text: d.label, style: TextStyle(fontSize: AppTypography.md, color: labelColor)),
        maxLines: 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth);
      labelPainter.paint(canvas, Offset(0, top + (rowHeight - labelPainter.height) / 2));

      final trackLeft = labelWidth + trackGap;
      final trackWidth = size.width - trackLeft;
      if (trackWidth <= 0) continue;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(trackLeft, top, trackWidth, rowHeight), const Radius.circular(AppRadius.md)),
        Paint()..color = trackColor,
      );

      final pct = (d.value / maxVal) * 100;
      final barWidthPct = pct < 14 ? 14 : pct;
      final barWidth = trackWidth * (barWidthPct / 100);
      final barColor = d.color ?? AppColors.chartSeries[i % AppColors.chartSeries.length];

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(trackLeft, top, barWidth, rowHeight), const Radius.circular(AppRadius.md)),
        Paint()..color = barColor,
      );

      final valuePainter = TextPainter(
        text: TextSpan(
          text: formatValue(d.value),
          style: const TextStyle(fontSize: AppTypography.xs, fontWeight: AppTypography.weightSemibold, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final rawValueX = trackLeft + barWidth - valuePainter.width - AppSpacing.space2;
      final valueX = rawValueX < trackLeft ? trackLeft : rawValueX;
      valuePainter.paint(canvas, Offset(valueX, top + (rowHeight - valuePainter.height) / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.labelColor != labelColor;
  }
}

WidgetbookComponent buildBarChartWidgetbookComponent() {
  const sample = [
    AppBarDatum(label: 'Jan', value: 42),
    AppBarDatum(label: 'Fev', value: 68),
    AppBarDatum(label: 'Mar', value: 55),
    AppBarDatum(label: 'Abr', value: 91),
    AppBarDatum(label: 'Mai', value: 30),
    AppBarDatum(label: 'Jun', value: 76),
  ];

  return WidgetbookComponent(
    name: 'BarChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: AppBarChart(data: sample),
        ),
      ),
      WidgetbookUseCase(
        name: 'Formatação de valor',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: AppBarChart(data: sample, formatValue: (v) => 'R\$ ${v.toStringAsFixed(0)}k'),
        ),
      ),
    ],
  );
}
