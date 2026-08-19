import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';

/// Central de rotinas (operacional) / central de gestão (administração) —
/// espelha `ResponsibilityWorkspace.tsx`.
///
/// Nova UI (referência Força Agro): em vez de expandir cada funcionalidade
/// como um card solto (lia como uma lista longa e poluída), a home agrupa por
/// `feature.group` — um acesso rápido horizontal no topo + um card por grupo
/// abaixo. Tocar em qualquer um dos dois leva para a mesma tela fullscreen
/// com as funções daquele grupo ([GroupFeaturesScreen]); a navegação para a
/// funcionalidade em si não muda.
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
    final segment = isAdministration ? 'administracao' : 'operacional';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        AppCard(
          variant: AppCardVariant.ink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppChip(
                tone: isAdministration ? AppChipTone.blue : AppChipTone.brand,
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
                  isAdministration ? 'Central de gestão' : 'Central de rotinas',
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

        const AppSectionTitle(child: Text('Acesso rápido')),
        const SizedBox(height: AppSpacing.space3),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.space4),
            itemBuilder: (context, index) {
              final group = groups.keys.elementAt(index);
              return AppQuickAction(
                icon: groupIcon(group),
                label: group,
                onPressed: () => context.go(
                  '/fazendas/$segment/grupo/${Uri.encodeComponent(group)}',
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space5),

        const AppSectionTitle(child: Text('Funcionalidades por módulo')),
        const SizedBox(height: AppSpacing.space3),
        for (final entry in groups.entries) ...[
          _GroupAccessCard(
            group: entry.key,
            features: entry.value,
            onTap: () => context.go(
              '/fazendas/$segment/grupo/${Uri.encodeComponent(entry.key)}',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
      ],
    );
  }
}

class _GroupAccessCard extends StatelessWidget {
  const _GroupAccessCard({
    required this.group,
    required this.features,
    required this.onTap,
  });

  final String group;
  final List<FeatureDefinition> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final preview = features.map((f) => f.title).take(3).join(' · ');

    return Semantics(
      button: true,
      label: 'Abrir módulo $group',
      child: AppCard(
        interactive: true,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: AppSpacing.space12,
              height: AppSpacing.space12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.accentSubtle,
              ),
              alignment: Alignment.center,
              child: Icon(
                groupIcon(group),
                size: 22,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppHeading(level: AppHeadingLevel.h3, child: Text(group)),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    '${features.length} ${features.length == 1 ? 'função' : 'funções'} · $preview',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: semantic.fgMuted),
                  ),
                ],
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
      ),
    );
  }
}
