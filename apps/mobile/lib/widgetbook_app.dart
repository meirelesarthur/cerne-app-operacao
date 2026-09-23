import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'design/generated/app_colors.dart';
import 'design/generated/app_radius.dart';
import 'design/generated/app_spacing.dart';
import 'design/generated/app_typography.dart';
import 'design/theme/app_theme.dart';
import 'design/theme/app_theme_extension.dart';
import 'ui/ui.dart';
import 'widgetbook/docs/guide_pages.dart';
import 'widgetbook/patterns/collection_pattern.dart';
import 'widgetbook/patterns/crud_pattern.dart';
import 'widgetbook/patterns/empty_state_pattern.dart';
import 'widgetbook/patterns/listing_pattern.dart';
import 'widgetbook/patterns/login_pattern.dart';
import 'widgetbook/patterns/menu_pattern.dart';
import 'design/generated/app_layout.dart';

/// Ponto de entrada do Widgetbook — catálogo vivo de `lib/ui`, padrões de
/// tela, fundamentos de tema e documentação (Documentação → Guia).
///
/// Rodar: `flutter run -t lib/widgetbook_app.dart -d chrome`.
/// Publicado em `/storybook/` pelo `npm run build`
/// (`scripts/build-flutter-site.mjs`), sem a moldura de celular do app.
/// Conferir o build de release localmente: `flutter build web --release -t
/// lib/widgetbook_app.dart --base-href /storybook/ -o build/widgetbook/storybook`
/// e abrir `/storybook/` pela configuração `widgetbook-static`.
///
/// Diferente do app, o Widgetbook usa a estratégia de URL padrão (hash): o
/// roteador do pacote lê o caso selecionado do fragmento
/// (`/storybook/#/?path=catálogo/...`), o que torna cada caso um link
/// compartilhável. Com `usePathUrlStrategy` o deep link era descartado.
void main() {
  runApp(const CerneWidgetbook());
}

class CerneWidgetbook extends StatelessWidget {
  const CerneWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Tela inicial (sem caso selecionado) = guia "Comece aqui". A home fica
      // fora do addon de tema, então recebe o tema do app explicitamente.
      home: Theme(
        data: buildAppTheme(AppThemeVariant.light),
        child: const Material(child: WidgetbookIntroductionPage()),
      ),
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
      directories: buildWidgetbookDirectories(),
    );
  }
}

/// Árvore do Widgetbook — função própria para o inventário
/// ([WidgetbookInventoryPage]) e os testes lerem exatamente o que está
/// registrado, sem lista paralela para manter.
List<WidgetbookNode> buildWidgetbookDirectories() => [
  WidgetbookFolder(
    name: 'Documentação',
    children: [
      WidgetbookComponent(
        name: 'Guia',
        useCases: [
          WidgetbookUseCase(
            name: 'Comece aqui',
            builder: (context) => const WidgetbookIntroductionPage(),
          ),
          WidgetbookUseCase(
            name: 'Inventário do catálogo',
            builder: (context) =>
                WidgetbookInventoryPage(nodes: buildWidgetbookDirectories()),
          ),
          WidgetbookUseCase(
            name: 'Novidades (v$kWidgetbookVersion)',
            builder: (context) => const WidgetbookChangelogPage(),
          ),
        ],
      ),
      buildCodePreviewWidgetbookComponent(),
    ],
  ),
  WidgetbookFolder(
    name: 'Fundamentos',
    children: [
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
    ],
  ),
  WidgetbookFolder(
    name: 'Padrões',
    children: [
      buildLoginPatternWidgetbookComponent(),
      buildListingPatternWidgetbookComponent(),
      buildMenuPatternWidgetbookComponent(),
      buildCrudPatternWidgetbookComponent(),
      buildCollectionPatternWidgetbookComponent(),
      buildEmptyStatePatternWidgetbookComponent(),
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
          buildAppIconTileWidgetbookComponent(),
          buildPressableWidgetbookComponent(),
          buildSegmentedTabsWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Superfícies',
        children: [
          buildCardWidgetbookComponent(),
          buildChartCardWidgetbookComponent(),
          buildKpiStatCardWidgetbookComponent(),
          buildStatusCardWidgetbookComponent(),
          buildNotificationTileWidgetbookComponent(),
          buildDetailSectionWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Formulário',
        children: [
          buildTextInputWidgetbookComponent(),
          buildDateInputWidgetbookComponent(),
          buildColorInputWidgetbookComponent(),
          buildTextareaWidgetbookComponent(),
          buildFormFieldWidgetbookComponent(),
          buildFormSelectWidgetbookComponent(),
          buildInlineSelectWidgetbookComponent(),
          buildSearchSelectWidgetbookComponent(),
          buildCheckboxWidgetbookComponent(),
          buildToggleSwitchWidgetbookComponent(),
          buildFileUploadWidgetbookComponent(),
          buildStepperWidgetbookComponent(),
          buildAddableGroupListWidgetbookComponent(),
          buildCollectionListWidgetbookComponent(),
          buildCollectionManagerWidgetbookComponent(),
          buildSquareGroupGridWidgetbookComponent(),
          buildReviewListWidgetbookComponent(),
          buildReviewTabsWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Padrão global',
        children: [
          buildContentSheetWidgetbookComponent(),
          buildPageScaffoldWidgetbookComponent(),
          buildBrandLogoWidgetbookComponent(),
          buildTopBarWidgetbookComponent(),
          buildGreetingHeaderWidgetbookComponent(),
          buildFarmSelectorWidgetbookComponent(),
          buildSearchFieldWidgetbookComponent(),
          buildDiscoveryTileWidgetbookComponent(),
          buildModuleTileWidgetbookComponent(),
          buildActionBarWidgetbookComponent(),
          buildStepProgressWidgetbookComponent(),
          buildLeaveGuardWidgetbookComponent(),
          buildLabeledDividerWidgetbookComponent(),
          buildPaginationWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Feedback',
        children: [
          buildAppIconWidgetbookComponent(),
          buildBannerWidgetbookComponent(),
          buildEmptyStateWidgetbookComponent(),
          buildErrorStateWidgetbookComponent(),
          buildSuccessPanelWidgetbookComponent(),
          buildSkeletonWidgetbookComponent(),
          buildSpinnerWidgetbookComponent(),
          buildTooltipWidgetbookComponent(),
          buildProgressBarWidgetbookComponent(),
          buildHardwareSimulatorWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Overlay',
        children: [
          buildModalWidgetbookComponent(),
          buildBottomSheetWidgetbookComponent(),
        ],
      ),
      WidgetbookFolder(
        name: 'Dados',
        children: [
          buildMenuItemWidgetbookComponent(),
          buildAuditExportPanelWidgetbookComponent(),
          buildBadgeWidgetbookComponent(),
          buildChipWidgetbookComponent(),
          buildTagWidgetbookComponent(),
          buildAvatarWidgetbookComponent(),
          buildScreenHeaderWidgetbookComponent(),
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
          buildLineChartWidgetbookComponent(),
          buildStackedBarWidgetbookComponent(),
          buildGaugeWidgetbookComponent(),
          buildBulletChartWidgetbookComponent(),
          buildChartLegendWidgetbookComponent(),
          buildSparklineAreaWidgetbookComponent(),
        ],
      ),
    ],
  ),
];

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

/// Amostra de cor no audit do Widgetbook. [code] é a referência Dart
/// totalmente qualificada (ex.: `AppColors.brand600`) — toque para copiar,
/// igual ao painel [AppCodePreview] usado nos demais componentes.
class _Swatch extends StatefulWidget {
  const _Swatch({required this.label, required this.code, required this.color});

  final String label;
  final String code;
  final Color color;

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  String get _hex =>
      '#${widget.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return AppPressable(
      semanticLabel: 'Copiar ${widget.code}',
      onPressed: _copy,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 128,
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
            Stack(
              children: [
                Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                if (_copied)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: AppIcon(
                      AppIcons.check,
                      size: AppSize.iconXs,
                      color: semantic.fgDefault,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              widget.code,
              style: TextStyle(
                fontFamily: kCodeFontFamily,
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
            Text(
              _hex,
              style: TextStyle(
                fontFamily: kCodeFontFamily,
                fontSize: AppTypography.sm,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorAuditPage extends StatelessWidget {
  const _ColorAuditPage();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final brandScale = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900].map(
      (s) => _Swatch(
        label: 'brand$s',
        code: 'AppColors.brand$s',
        color: _brandShade(s),
      ),
    );

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
              .map(
                (e) => _Swatch(
                  label: e.key,
                  code: 'semantic.${e.key}',
                  color: e.value,
                ),
              )
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
      // exibido com raio visual limitado a 32 (o real é 9999 — cápsula/pílula)
      'full': 32,
    };
    const radiusLabelOverride = {'full': '9999px (cápsula)'};

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
                SizedBox(
                  width: 190,
                  child: Text(
                    'AppSpacing.${e.key}  (${e.value.toInt()}px)',
                    style: const TextStyle(
                      fontFamily: kCodeFontFamily,
                      fontSize: AppTypography.sm,
                    ),
                  ),
                ),
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
                  width: 96,
                  height: 84,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(AppSpacing.space1),
                  decoration: BoxDecoration(
                    color: semantic.bgSurface,
                    border: Border.all(color: semantic.borderDefault),
                    borderRadius: BorderRadius.circular(e.value),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AppRadius.${e.key}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: kCodeFontFamily,
                          fontSize: AppTypography.sm,
                        ),
                      ),
                      Text(
                        radiusLabelOverride[e.key] ?? '${e.value.toInt()}px',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
      'xs': AppTypography.sm,
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
      'weightNormal (400)': AppTypography.weightNormal,
      'weightMedium (500)': AppTypography.weightMedium,
      'weightSemibold (600)': AppTypography.weightSemibold,
      'weightBold (700)': AppTypography.weightBold,
      'weightExtrabold (800)': AppTypography.weightExtrabold,
    };

    return _AuditScaffold(
      title: 'Tipografia (${AppTypography.fontFamily})',
      children: [
        Text('Tamanhos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        ...sizes.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    'AppTypography.${e.key}',
                    style: const TextStyle(
                      fontFamily: kCodeFontFamily,
                      fontSize: AppTypography.sm,
                    ),
                  ),
                ),
                Text(
                  'GB CERNE (${e.value}px)',
                  style: TextStyle(fontSize: e.value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text('Pesos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space2),
        ...weights.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 190,
                  child: Text(
                    'AppTypography.${e.key.split(' ').first}',
                    style: const TextStyle(
                      fontFamily: kCodeFontFamily,
                      fontSize: AppTypography.sm,
                    ),
                  ),
                ),
                Text(
                  'GB CERNE',
                  style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: e.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
