import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Uma fatia do [AppDonutChart] — espelha `DonutSlice` de `DonutChart.tsx`.
class AppDonutSlice {
  const AppDonutSlice({required this.label, required this.value, this.color});

  final String label;
  final double value;

  /// Cor da fatia; sem valor, usa `AppColors.chartSeries[i % length]` (mesmo fallback do React).
  final Color? color;
}

/// Espelha `DonutChart.tsx` — donut SVG próprio com legenda.
/// Pintado via [CustomPainter] (ADR do projeto): os arcos reproduzem os
/// `<circle stroke-dasharray>` do SVG original usando `canvas.drawArc`.
class AppDonutChart extends StatelessWidget {
  const AppDonutChart({
    super.key,
    required this.data,
    this.size = 140,
    this.thickness = 20,
    this.centerLabel,
    this.centerValue,
  });

  final List<AppDonutSlice> data;
  final double size;
  final double thickness;
  final String? centerLabel;
  final String? centerValue;

  // h-2.5 w-2.5 (10px) no React não tem token exato (space2=8, space3=12);
  // usamos space2 para permanecer 100% tokenizado (desvio documentado no relatório).
  static const double _dotSize = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutChartPainter(
              data: data,
              thickness: thickness,
              centerLabel: centerLabel,
              centerValue: centerValue,
              valueColor: semantic.fgDefault,
              labelColor: semantic.fgMuted,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < data.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == data.length - 1 ? 0 : AppSpacing.space1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          color: data[i].color ?? AppColors.chartSeries[i % AppColors.chartSeries.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        data[i].label,
                        style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.data,
    required this.thickness,
    required this.centerLabel,
    required this.centerValue,
    required this.valueColor,
    required this.labelColor,
  });

  final List<AppDonutSlice> data;
  final double thickness;
  final String? centerLabel;
  final String? centerValue;
  final Color valueColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    final safeTotal = total <= 0 ? 1.0 : total;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2;
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.value / safeTotal) * 2 * math.pi;
      final paint = Paint()
        ..color = d.color ?? AppColors.chartSeries[i % AppColors.chartSeries.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    if (centerValue != null) {
      final valuePainter = TextPainter(
        text: TextSpan(
          text: centerValue,
          // 16px no React (fontSize="16") == token AppTypography.xl.
          style: TextStyle(fontSize: AppTypography.xl, fontWeight: AppTypography.weightBold, color: valueColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(canvas, Offset(center.dx - valuePainter.width / 2, center.dy - valuePainter.height));
    }
    if (centerLabel != null) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: centerLabel,
          // 9px no React não tem token exato; AppTypography.xs (11) é o mais próximo.
          style: TextStyle(fontSize: AppTypography.xs, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(center.dx - labelPainter.width / 2, center.dy + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.thickness != thickness ||
        oldDelegate.centerLabel != centerLabel ||
        oldDelegate.centerValue != centerValue ||
        oldDelegate.valueColor != valueColor ||
        oldDelegate.labelColor != labelColor;
  }
}

WidgetbookComponent buildDonutChartWidgetbookComponent() {
  const sample = [
    AppDonutSlice(label: 'Soja', value: 45),
    AppDonutSlice(label: 'Milho', value: 30),
    AppDonutSlice(label: 'Algodão', value: 15),
    AppDonutSlice(label: 'Outros', value: 10),
  ];

  return WidgetbookComponent(
    name: 'DonutChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(child: AppDonutChart(data: sample)),
      ),
      WidgetbookUseCase(
        name: 'Com valor central',
        builder: (context) => const Center(
          child: AppDonutChart(data: sample, centerValue: '450 ha', centerLabel: 'total'),
        ),
      ),
    ],
  );
}
