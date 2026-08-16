import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';

class ResponsibilityWorkspace extends StatelessWidget {
  const ResponsibilityWorkspace({super.key, required this.profile});

  final FeatureProfile profile;

  @override
  Widget build(BuildContext context) {
    final features = profile == FeatureProfile.administration
        ? adminFeatures
        : operationalFeatures;
    final groups = <String, List<FeatureDefinition>>{};
    for (final feature in features) {
      groups.putIfAbsent(feature.group, () => []).add(feature);
    }
    final isAdministration = profile == FeatureProfile.administration;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > AppSize.phone * 2;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - AppSpacing.space3) / 2
            : constraints.maxWidth;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppCard(
              variant: AppCardVariant.ink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppChip(
                    tone: isAdministration
                        ? AppChipTone.blue
                        : AppChipTone.brand,
                    icon: Icon(
                      isAdministration
                          ? LucideIcons.layoutDashboard
                          : LucideIcons.clipboardList,
                    ),
                    child: Text(
                      isAdministration
                          ? 'AMBIENTE ADMINISTRAÇÃO'
                          : 'AMBIENTE OPERACIONAL',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppHeading(
                    child: Text(
                      isAdministration
                          ? 'Central de gestão'
                          : 'Central de rotinas',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    isAdministration
                        ? 'Indicadores, consultas e auditoria para supervisão e tomada de decisão.'
                        : 'Cadastros e lançamentos executados pelos funcionários da operação.',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text('${features.length} funcionalidades neste ambiente'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            for (final entry in groups.entries) ...[
              AppSectionTitle(child: Text(entry.key)),
              const SizedBox(height: AppSpacing.space2),
              Wrap(
                spacing: AppSpacing.space3,
                runSpacing: AppSpacing.space3,
                children: [
                  for (final feature in entry.value)
                    SizedBox(
                      width: itemWidth,
                      child: _FeatureAccessCard(
                        feature: feature,
                        onTap: () => context.go(_destination(feature)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space5),
            ],
          ],
        );
      },
    );
  }

  String _destination(FeatureDefinition feature) {
    if (feature.existingRoute case final route?) return route;
    final segment = profile == FeatureProfile.administration
        ? 'administracao'
        : 'operacional';
    return '/fazendas/$segment/${feature.id}';
  }
}

class _FeatureAccessCard extends StatelessWidget {
  const _FeatureAccessCard({required this.feature, required this.onTap});

  final FeatureDefinition feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final available = feature.existingRoute != null;
    final hardware = feature.status == FeatureStatus.hardware;

    return Semantics(
      button: true,
      label: 'Abrir ${feature.title}',
      child: AppCard(
        interactive: true,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppHeading(
                    level: AppHeadingLevel.h3,
                    child: Text(feature.title),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Icon(
                  LucideIcons.chevronRight,
                  size: AppSpacing.space5,
                  color: semantic.fgSubtle,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              feature.objective,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: semantic.fgMuted),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppChip(
              tone: hardware
                  ? AppChipTone.amber
                  : available
                  ? AppChipTone.brand
                  : AppChipTone.neutral,
              child: Text(
                hardware
                    ? 'Hardware simulado'
                    : available
                    ? 'Disponível'
                    : 'Contrato portado',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
