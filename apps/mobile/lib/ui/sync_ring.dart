import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Anel de progresso de 360°, para leituras em que só importa "quanto já foi
/// concluído" — diferente de [AppGauge] (arco de 270° com abertura na base,
/// que compara um valor contra um teto/meta). Usado pela sincronização de
/// dados: percentual central + legenda opcional com a fração (`16/80`).
class AppSyncRing extends StatelessWidget {
  const AppSyncRing({
    super.key,
    required this.value,
    this.max = 100,
    this.size = 160,
    this.thickness = 10,
    this.caption,
  });

  final double value;
  final double max;
  final double size;
  final double thickness;

  /// Legenda abaixo do percentual central (ex.: `16/80`).
  final String? caption;

  double get _fraction => max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SyncRingPainter(
          fraction: _fraction,
          thickness: thickness,
          color: semantic.accentDefault,
          trackColor: semantic.chartTrack,
          valueLabel: '${(_fraction * 100).round()}%',
          caption: caption,
          valueColor: semantic.fgDefault,
          captionColor: semantic.fgMuted,
        ),
      ),
    );
  }
}

class _SyncRingPainter extends CustomPainter {
  _SyncRingPainter({
    required this.fraction,
    required this.thickness,
    required this.color,
    required this.trackColor,
    required this.valueLabel,
    required this.caption,
    required this.valueColor,
    required this.captionColor,
  });

  final double fraction;
  final double thickness;
  final Color color;
  final Color trackColor;
  final String valueLabel;
  final String? caption;
  final Color valueColor;
  final Color captionColor;

  /// Começa no topo (12h), sentido horário — leitura padrão de "quanto já
  /// girou" que qualquer indicador circular de progresso usa.
  static const double _startAngle = -math.pi / 2;
  static const double _sweepAngle = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, stroke..color = trackColor);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        _startAngle,
        _sweepAngle * fraction,
        false,
        stroke..color = color,
      );
    }

    final valuePainter = TextPainter(
      text: TextSpan(
        text: valueLabel,
        style: TextStyle(
          fontSize: AppTypography.xl3,
          fontWeight: AppTypography.weightBold,
          color: valueColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    TextPainter? captionPainter;
    if (caption != null) {
      captionPainter = TextPainter(
        text: TextSpan(
          text: caption,
          style: TextStyle(fontSize: AppTypography.sm, color: captionColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    final blockHeight =
        valuePainter.height +
        (captionPainter == null ? 0 : captionPainter.height);
    var top = center.dy - blockHeight / 2;
    valuePainter.paint(canvas, Offset(center.dx - valuePainter.width / 2, top));
    top += valuePainter.height;
    captionPainter?.paint(
      canvas,
      Offset(center.dx - captionPainter.width / 2, top),
    );
  }

  @override
  bool shouldRepaint(covariant _SyncRingPainter old) =>
      old.fraction != fraction ||
      old.thickness != thickness ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.valueLabel != valueLabel ||
      old.caption != caption;
}

WidgetbookComponent buildSyncRingWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SyncRing',
    useCases: [
      WidgetbookUseCase(
        name: 'Em andamento',
        builder: (context) => const Center(
          child: AppSyncRing(value: 20, caption: '16/80'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Início',
        builder: (context) => const Center(
          child: AppSyncRing(value: 0, caption: '0/80'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Concluído',
        builder: (context) => const Center(
          child: AppSyncRing(value: 100, caption: '80/80'),
        ),
      ),
    ],
  );
}
