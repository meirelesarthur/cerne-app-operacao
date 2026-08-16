import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Heading.tsx` — evita uso de `<h1>`–`<h6>` cru em páginas (Lei 1).
/// `level` equivale à prop `level: 1 | 2 | 3 | 4` do React; o próprio widget
/// se anuncia como cabeçalho via `Semantics(header: true)`.
enum AppHeadingLevel { h1, h2, h3, h4 }

class AppHeading extends StatelessWidget {
  const AppHeading({
    super.key,
    this.level = AppHeadingLevel.h2,
    required this.child,
    this.style,
  });

  final AppHeadingLevel level;
  final Widget child;
  final TextStyle? style;

  double get _fontSize => switch (level) {
    AppHeadingLevel.h1 => AppTypography.xl3,
    AppHeadingLevel.h2 => AppTypography.xl2,
    AppHeadingLevel.h3 => AppTypography.lg,
    AppHeadingLevel.h4 => AppTypography.md,
  };

  FontWeight get _weight => switch (level) {
    AppHeadingLevel.h1 => AppTypography.weightExtrabold,
    AppHeadingLevel.h2 => AppTypography.weightBold,
    AppHeadingLevel.h3 => AppTypography.weightSemibold,
    AppHeadingLevel.h4 => AppTypography.weightSemibold,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      header: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: _weight,
          color: semantic.fgDefault,
        ).merge(style),
        child: child,
      ),
    );
  }
}

/// Título de seção (Nova UI): bold generoso, ex.: "Announcements", "Quick Actions".
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: AppTypography.xl,
          fontWeight: AppTypography.weightBold,
          color: semantic.fgDefault,
        ),
        child: child,
      ),
    );
  }
}

WidgetbookComponent buildHeadingWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Heading',
    useCases: [
      WidgetbookUseCase(
        name: 'Níveis',
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(
                level: AppHeadingLevel.h1,
                child: Text('Título nível 1'),
              ),
              SizedBox(height: 12),
              AppHeading(child: Text('Título nível 2')),
              SizedBox(height: 12),
              AppHeading(
                level: AppHeadingLevel.h3,
                child: Text('Título nível 3'),
              ),
              SizedBox(height: 12),
              AppHeading(
                level: AppHeadingLevel.h4,
                child: Text('Título nível 4'),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'SectionTitle',
        builder: (context) =>
            const Center(child: AppSectionTitle(child: Text('Quick Actions'))),
      ),
    ],
  );
}
