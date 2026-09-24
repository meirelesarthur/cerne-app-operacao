import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_layout.dart';
import '../../design/generated/app_motion.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../ui/ui.dart';
import '../module_config.dart';

/// Abre o seletor de lançamentos rápidos sobre a tela atual.
///
/// As opções continuam usando os itens e as rotas de [operationalQuickAdds];
/// o overlay só organiza esses atalhos no arranjo hexagonal.
Future<ModuleMenuItem?> showQuickAddOverlay(
  BuildContext context, {
  required List<ModuleMenuItem> items,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<ModuleMenuItem>(
    context: context,
    barrierLabel: 'Lançamentos rápidos',
    barrierColor: AppColors.transparent,
    transitionDuration: reduceMotion ? Duration.zero : AppMotion.base,
    pageBuilder: (context, animation, secondaryAnimation) =>
        _QuickAddOverlay(items: items, reduceMotion: reduceMotion),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _QuickAddOverlay extends StatefulWidget {
  const _QuickAddOverlay({required this.items, required this.reduceMotion});

  final List<ModuleMenuItem> items;
  final bool reduceMotion;

  @override
  State<_QuickAddOverlay> createState() => _QuickAddOverlayState();
}

class _QuickAddOverlayState extends State<_QuickAddOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _exitController;
  bool _isClosing = false;
  List<double>? _progressAtClose;

  Duration get _entryDuration =>
      widget.reduceMotion ? Duration.zero : AppMotion.slower + AppMotion.base;
  Duration get _exitDuration =>
      widget.reduceMotion ? Duration.zero : AppMotion.slower + AppMotion.fast;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: _entryDuration,
    )..forward();
    _exitController = AnimationController(vsync: this, duration: _exitDuration);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _close(ModuleMenuItem? result, List<int> rankByItemIndex) async {
    if (_isClosing) return;
    if (widget.reduceMotion) {
      Navigator.of(context, rootNavigator: true).pop(result);
      return;
    }

    _progressAtClose = [
      for (final rank in rankByItemIndex) _entryProgress(rank),
    ];
    setState(() => _isClosing = true);
    await _exitController.forward();
    if (mounted) Navigator.of(context, rootNavigator: true).pop(result);
  }

  double _entryProgress(int rank) {
    const firstStart = 0.08;
    const stagger = 0.13;
    const span = 0.53;
    final start = firstStart + rank * stagger;
    final end = math.min(1.0, start + span);
    return Interval(
      start,
      end,
      curve: Curves.easeOutCubic,
    ).transform(_entryController.value);
  }

  double _tileProgress(int itemIndex, int rank) {
    if (!_isClosing) return _entryProgress(rank);
    const stagger = 0.11;
    const span = 0.30;
    final start = rank * stagger;
    final end = math.min(1.0, start + span);
    final returnToPlus = Interval(
      start,
      end,
      curve: Curves.easeInCubic,
    ).transform(_exitController.value);
    return (_progressAtClose?[itemIndex] ?? 0) * (1 - returnToPlus);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final geometry = _QuickAddGeometry.from(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          final arrangedItems = _arrangeItems(widget.items);
          final rankByItemIndex = _leftToRightRanks(geometry.optionCenters);

          return AnimatedBuilder(
            animation: Listenable.merge([_entryController, _exitController]),
            builder: (context, _) {
              final itemProgress = [
                for (var index = 0; index < arrangedItems.length; index++)
                  _tileProgress(index, rankByItemIndex[index]),
              ];
              final entryHubProgress = const Interval(
                0,
                0.22,
                curve: Curves.easeOutBack,
              ).transform(_entryController.value);
              final centerScale = _isClosing
                  ? 1 +
                        0.26 *
                            Curves.easeOutCubic.transform(_exitController.value)
                  : 0.46 + 0.54 * entryHubProgress;

              return Semantics(
                namesRoute: true,
                label: 'Lançamentos rápidos',
                child: IgnorePointer(
                  ignoring: _isClosing,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: AppPressable(
                          semanticLabel: 'Fechar lançamentos rápidos',
                          minTouchTarget: false,
                          showVisualFeedback: false,
                          onPressed: () => _close(null, rankByItemIndex),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                            child: ColoredBox(
                              // Verde escuro e chapado: dá contexto ao overlay
                              // sem acrescentar glow ou competir com as opções.
                              color: AppColors.brand900.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: _QuickAddConnectorPainter(
                          geometry: geometry,
                          color: AppColors.neutral0.withValues(alpha: 0.62),
                          progress: itemProgress,
                        ),
                        child: const SizedBox.expand(),
                      ),
                      _QuickAddHeading(geometry: geometry),
                      for (var index = 0; index < arrangedItems.length; index++)
                        _QuickAddHexTile(
                          item: arrangedItems[index],
                          center: geometry.optionCenters[index],
                          source: geometry.centerButtonCenter,
                          size: geometry.tileSize,
                          progress: itemProgress[index],
                          onTap: () =>
                              _close(arrangedItems[index], rankByItemIndex),
                        ),
                      _QuickAddCloseButton(
                        top:
                            MediaQuery.paddingOf(context).top +
                            AppSpacing.space2,
                        onTap: () => _close(null, rankByItemIndex),
                      ),
                      _QuickAddCenterButton(
                        center: geometry.centerButtonCenter,
                        size: geometry.centerButtonSize,
                        scale: centerScale,
                        onTap: () => _close(null, rankByItemIndex),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// O arranjo dá o primeiro destaque a Pesagem, como no exemplo visual.
  /// A ação atual oferece cinco opções fixas.
  List<ModuleMenuItem> _arrangeItems(List<ModuleMenuItem> items) {
    if (items.length != 5) return items;
    return [items[1], items[0], items[2], items[3], items[4]];
  }

  /// A ordem visual de entrada segue a posição dos cartões, da esquerda para
  /// a direita; em cada coluna, o cartão de cima sai primeiro.
  List<int> _leftToRightRanks(List<Offset> centers) {
    final order = List<int>.generate(centers.length, (index) => index)
      ..sort((a, b) {
        final horizontal = centers[a].dx.compareTo(centers[b].dx);
        return horizontal != 0
            ? horizontal
            : centers[a].dy.compareTo(centers[b].dy);
      });
    final ranks = List<int>.filled(centers.length, 0);
    for (var rank = 0; rank < order.length; rank++) {
      ranks[order[rank]] = rank;
    }
    return ranks;
  }
}

class _QuickAddHeading extends StatelessWidget {
  const _QuickAddHeading({required this.geometry});

  final _QuickAddGeometry geometry;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: geometry.headingTop,
      left: AppLayout.gutter,
      right: AppLayout.gutter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral0.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.neutral0.withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: AppIcon(
                AppIcons.zap,
                size: AppSize.iconXl,
                color: AppColors.neutral0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          const Text(
            'Lançamentos rápidos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.neutral0,
              fontSize: AppTypography.xl3,
              fontWeight: AppTypography.weightSemibold,
              height: AppTypography.lineHeightTight,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            'Escolha o que deseja registrar agora',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.neutral0.withValues(alpha: 0.78),
              fontSize: AppTypography.md,
              height: AppTypography.lineHeightNormal,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddHexTile extends StatelessWidget {
  const _QuickAddHexTile({
    required this.item,
    required this.center,
    required this.source,
    required this.size,
    required this.progress,
    required this.onTap,
  });

  final ModuleMenuItem item;
  final Offset center;
  final Offset source;
  final double size;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: Transform.translate(
        offset: (source - center) * (1 - progress),
        child: Transform.scale(
          scale: 0.42 + progress * 0.58,
          child: Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: AppPressable(
              semanticLabel: 'Adicionar ${item.label}',
              minTouchTarget: false,
              onPressed: progress >= 0.98 ? onTap : null,
              child: AppHexagon(
                size: size,
                color: AppColors.neutral0,
                borderColor: AppColors.neutral0.withValues(alpha: 0.92),
                borderWidth: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        item.icon,
                        size: AppSize.iconXl,
                        color: AppColors.brand700,
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        item.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.neutral800,
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightMedium,
                          height: AppTypography.lineHeightTight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddCloseButton extends StatelessWidget {
  const _QuickAddCloseButton({required this.top, required this.onTap});

  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: AppSpacing.space3,
      width: AppSize.control,
      height: AppSize.control,
      child: AppPressable(
        semanticLabel: 'Fechar lançamentos rápidos',
        minTouchTarget: false,
        onPressed: onTap,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutral0,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(
                AppIcons.x,
                size: AppSize.iconMd,
                color: AppColors.neutral800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddCenterButton extends StatelessWidget {
  const _QuickAddCenterButton({
    required this.center,
    required this.size,
    required this.scale,
    required this.onTap,
  });

  final Offset center;
  final double size;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: AppPressable(
        semanticLabel: 'Fechar opções de lançamento',
        minTouchTarget: false,
        onPressed: onTap,
        child: Transform.scale(
          scale: scale,
          child: AppHexagon(
            size: size,
            color: AppColors.brand700,
            borderColor: AppColors.neutral0.withValues(alpha: 0.9),
            child: const AppIcon(
              AppIcons.plus,
              size: AppSize.iconXxl,
              color: AppColors.neutral0,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddGeometry {
  const _QuickAddGeometry({
    required this.canvasSize,
    required this.tileSize,
    required this.centerButtonSize,
    required this.headingTop,
    required this.optionCenters,
    required this.centerButtonCenter,
  });

  final Size canvasSize;
  final double tileSize;
  final double centerButtonSize;
  final double headingTop;
  final List<Offset> optionCenters;
  final Offset centerButtonCenter;

  factory _QuickAddGeometry.from(Size size) {
    final tileSize = math
        .min(108.0, math.min(size.width * 0.29, size.height * 0.16))
        .toDouble();
    final centerX = size.width / 2;
    final sideOffset = math
        .min(
          size.width * 0.285,
          (size.width - tileSize) / 2 - AppSpacing.space4,
        )
        .toDouble();
    final headingTop = size.height * 0.215;
    final centerButtonSize = math.min(92.0, tileSize * 0.86).toDouble();

    return _QuickAddGeometry(
      canvasSize: size,
      tileSize: tileSize,
      centerButtonSize: centerButtonSize,
      headingTop: headingTop,
      optionCenters: [
        Offset(centerX, size.height * 0.49),
        Offset(centerX - sideOffset, size.height * 0.575),
        Offset(centerX + sideOffset, size.height * 0.575),
        Offset(
          centerX - sideOffset * 0.94,
          size.height * 0.705 + AppSpacing.space4,
        ),
        Offset(
          centerX + sideOffset * 0.94,
          size.height * 0.705 + AppSpacing.space4,
        ),
      ],
      centerButtonCenter: Offset(
        centerX,
        size.height - centerButtonSize / 2 - AppSpacing.space2,
      ),
    );
  }
}

class _QuickAddConnectorPainter extends CustomPainter {
  const _QuickAddConnectorPainter({
    required this.geometry,
    required this.color,
    required this.progress,
  });

  final _QuickAddGeometry geometry;
  final Color color;
  final List<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.optionCenters.length < 5 || progress.length < 5) return;

    final paint = Paint()..color = color;
    final startY =
        geometry.centerButtonCenter.dy - geometry.centerButtonSize / 2 - 3;
    final centerX = geometry.centerButtonCenter.dx;
    final tileHalf = geometry.tileSize / 2;
    final destinations = [
      Offset(
        geometry.optionCenters[0].dx,
        geometry.optionCenters[0].dy + tileHalf,
      ),
      Offset(
        geometry.optionCenters[1].dx + tileHalf * 0.9,
        geometry.optionCenters[1].dy + tileHalf * 0.25,
      ),
      Offset(
        geometry.optionCenters[2].dx - tileHalf * 0.9,
        geometry.optionCenters[2].dy + tileHalf * 0.25,
      ),
      Offset(
        geometry.optionCenters[3].dx + tileHalf * 0.38,
        geometry.optionCenters[3].dy + tileHalf * 0.48,
      ),
      Offset(
        geometry.optionCenters[4].dx - tileHalf * 0.38,
        geometry.optionCenters[4].dy + tileHalf * 0.48,
      ),
    ];
    final starts = [
      Offset(centerX, startY),
      Offset(centerX - geometry.centerButtonSize * 0.18, startY),
      Offset(centerX + geometry.centerButtonSize * 0.18, startY),
      Offset(centerX - geometry.centerButtonSize * 0.25, startY),
      Offset(centerX + geometry.centerButtonSize * 0.25, startY),
    ];

    for (var index = 0; index < destinations.length; index++) {
      final start = starts[index];
      final end = destinations[index];
      final side = end.dx < centerX ? -1.0 : 1.0;
      final verticalDistance = start.dy - end.dy;
      final path = Path()..moveTo(start.dx, start.dy);
      if (index == 0) {
        path.lineTo(end.dx, end.dy);
      } else {
        path.cubicTo(
          start.dx + side * verticalDistance * 0.16,
          start.dy - verticalDistance * 0.38,
          end.dx - side * verticalDistance * 0.12,
          end.dy + verticalDistance * 0.36,
          end.dx,
          end.dy,
        );
      }

      final metric = path.computeMetrics().first;
      final visibleTo = progress[index].clamp(0.0, 1.0);
      for (var t = 0.035; t < visibleTo; t += 0.065) {
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent != null) canvas.drawCircle(tangent.position, 1.15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_QuickAddConnectorPainter oldDelegate) =>
      oldDelegate.geometry.canvasSize != geometry.canvasSize ||
      oldDelegate.geometry.tileSize != geometry.tileSize ||
      oldDelegate.geometry.centerButtonSize != geometry.centerButtonSize ||
      oldDelegate.color != color ||
      oldDelegate.progress != progress;
}
