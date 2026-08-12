import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'design/generated/app_colors.dart';
import 'design/generated/app_radius.dart';
import 'design/generated/app_spacing.dart';
import 'design/generated/app_typography.dart';
import 'design/theme/app_theme.dart';
import 'design/theme/app_theme_extension.dart';
import 'shared/url_strategy.dart';
import 'ui/ui.dart';

/// Ponto de entrada da galeria de componentes (F2.5) e da auditoria de tema (F1.4).
/// Rodar: `flutter run -t lib/widgetbook_app.dart -d chrome`.
/// Hospedado no Cloudflare Pages em `/storybook` (ver `tool/cf_pages_build.sh`).
void main() {
  configureUrlStrategy();
  runApp(const CerneWidgetbook());
}

class CerneWidgetbook extends StatelessWidget {
  const CerneWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: buildAppTheme(AppThemeVariant.light),
            ),
            WidgetbookTheme(
              name: 'GB Mode',
              data: buildAppTheme(AppThemeVariant.gbMode),
            ),
          ],
        ),
      ],
      directories: [
        WidgetbookComponent(
          name: 'Tema',
          useCases: [
            WidgetbookUseCase(
              name: 'Cores',
              builder: (context) => const _ColorAuditPage(),
            ),
            WidgetbookUseCase(
              name: 'Espaçamento e raio',
              builder: (context) => const _SpacingAuditPage(),
            ),
            WidgetbookUseCase(
              name: 'Tipografia',
              builder: (context) => const _TypographyAuditPage(),
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Catálogo',
          children: [
            WidgetbookFolder(
              name: 'Ações',
              children: [
                buildButtonWidgetbookComponent(),
                buildIconButtonWidgetbookComponent(),
                buildQuickActionWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Superfícies',
              children: [
                buildCardWidgetbookComponent(),
                buildDashboardCardWidgetbookComponent(),
                buildBentoTileWidgetbookComponent(),
                buildMiniAppTileWidgetbookComponent(),
                buildChartCardWidgetbookComponent(),
                buildKpiStatCardWidgetbookComponent(),
                buildBalanceCardWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Formulário',
              children: [
                buildTextInputWidgetbookComponent(),
                buildTextareaWidgetbookComponent(),
                buildFormFieldWidgetbookComponent(),
                buildFormSelectWidgetbookComponent(),
                buildSearchSelectWidgetbookComponent(),
                buildCheckboxWidgetbookComponent(),
                buildToggleSwitchWidgetbookComponent(),
                buildFileUploadWidgetbookComponent(),
                buildStepperWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Feedback',
              children: [
                buildBannerWidgetbookComponent(),
                buildEmptyStateWidgetbookComponent(),
                buildErrorStateWidgetbookComponent(),
                buildSuccessPanelWidgetbookComponent(),
                buildSkeletonWidgetbookComponent(),
                buildSpinnerWidgetbookComponent(),
                buildTooltipWidgetbookComponent(),
                buildProgressBarWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Overlay',
              children: [
                buildModalWidgetbookComponent(),
                buildBottomSheetWidgetbookComponent(),
                buildTransactionDetailSheetWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Dados',
              children: [
                buildTransactionListItemWidgetbookComponent(),
                buildMenuItemWidgetbookComponent(),
                buildBadgeWidgetbookComponent(),
                buildChipWidgetbookComponent(),
                buildTagWidgetbookComponent(),
                buildAvatarWidgetbookComponent(),
                buildHeadingWidgetbookComponent(),
                buildPageDotsWidgetbookComponent(),
                buildIllustrationSlotWidgetbookComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Gráficos',
              children: [
                buildBarChartWidgetbookComponent(),
                buildDonutChartWidgetbookComponent(),
                buildSparklineAreaWidgetbookComponent(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _AuditScaffold extends StatelessWidget {
  const _AuditScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      color: semantic.bgCanvas,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.space4),
          ...children,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      width: 96,
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ColorAuditPage extends StatelessWidget {
  const _ColorAuditPage();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final brandScale = [
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900,
    ].map((s) => _Swatch(label: 'brand$s', color: _brandShade(s)));

    final semanticColors = <String, Color>{
      'fgDefault': semantic.fgDefault,
      'fgMuted': semantic.fgMuted,
      'bgCanvas': semantic.bgCanvas,
      'bgSurface': semantic.bgSurface,
      'bgSubtle': semantic.bgSubtle,
      'borderDefault': semantic.borderDefault,
      'accentDefault': semantic.accentDefault,
      'accentHover': semantic.accentHover,
      'ctaBg': semantic.ctaBg,
      'navBg': semantic.navBg,
    };

    return _AuditScaffold(
      title: 'Cores',
      children: [
        Text(
          'Escala brand (core, fixa nas 2 variantes)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: brandScale.toList(),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text(
          'Semânticas (variam por tema — troque no addon "Theme")',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: semanticColors.entries
              .map((e) => _Swatch(label: e.key, color: e.value))
              .toList(),
        ),
      ],
    );
  }

  Color _brandShade(int shade) => switch (shade) {
    50 => AppColors.brand50,
    100 => AppColors.brand100,
    200 => AppColors.brand200,
    300 => AppColors.brand300,
    400 => AppColors.brand400,
    500 => AppColors.brand500,
    600 => AppColors.brand600,
    700 => AppColors.brand700,
    800 => AppColors.brand800,
    _ => AppColors.brand900,
  };
}

class _SpacingAuditPage extends StatelessWidget {
  const _SpacingAuditPage();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final spacings = <String, double>{
      'space1': AppSpacing.space1,
      'space2': AppSpacing.space2,
      'space3': AppSpacing.space3,
      'space4': AppSpacing.space4,
      'space6': AppSpacing.space6,
      'space8': AppSpacing.space8,
      'space12': AppSpacing.space12,
      'space16': AppSpacing.space16,
      'space20': AppSpacing.space20,
    };
    final radii = <String, double>{
      'sm': AppRadius.sm,
      'md': AppRadius.md,
      'base': AppRadius.base,
      'lg': AppRadius.lg,
      'xl': AppRadius.xl,
      'xl2': AppRadius.xl2,
      'xl3': AppRadius.xl3,
      'xl4': AppRadius.xl4,
      'full': 32,
    };

    return _AuditScaffold(
      title: 'Espaçamento e raio',
      children: [
        Text('Espaçamento', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        ...spacings.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(e.key)),
                Container(
                  width: e.value,
                  height: 16,
                  color: semantic.accentDefault,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text('Raio', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: radii.entries
              .map(
                (e) => Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: semantic.bgSurface,
                    border: Border.all(color: semantic.borderDefault),
                    borderRadius: BorderRadius.circular(e.value),
                  ),
                  child: Text(
                    e.key,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TypographyAuditPage extends StatelessWidget {
  const _TypographyAuditPage();

  @override
  Widget build(BuildContext context) {
    final sizes = <String, double>{
      'xs': AppTypography.xs,
      'sm': AppTypography.sm,
      'base': AppTypography.base,
      'md': AppTypography.md,
      'lg': AppTypography.lg,
      'xl': AppTypography.xl,
      'xl2': AppTypography.xl2,
      'xl3': AppTypography.xl3,
      'xl4': AppTypography.xl4,
    };
    final weights = <String, FontWeight>{
      'normal (400)': AppTypography.weightNormal,
      'medium (500)': AppTypography.weightMedium,
      'semibold (600)': AppTypography.weightSemibold,
      'bold (700)': AppTypography.weightBold,
      'extrabold (800)': AppTypography.weightExtrabold,
    };

    return _AuditScaffold(
      title: 'Tipografia (${AppTypography.fontFamily})',
      children: [
        Text('Tamanhos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        ...sizes.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Text(
              '${e.key} (${e.value}px) — GB CERNE',
              style: TextStyle(fontSize: e.value),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text('Pesos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        ...weights.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Text(
              '${e.key} — GB CERNE',
              style: TextStyle(fontSize: AppTypography.xl, fontWeight: e.value),
            ),
          ),
        ),
      ],
    );
  }
}
