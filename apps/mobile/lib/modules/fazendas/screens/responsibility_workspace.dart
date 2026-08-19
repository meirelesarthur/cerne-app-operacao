import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
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
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
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
        // Sem card escuro aqui (pedido do usuário): o cabeçalho da central
        // fica direto sobre o canvas, como no restante das telas da
        // referência Força Agro.
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
          style: TextStyle(color: semantic.fgMuted),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          '${features.length} funcionalidades neste ambiente',
          style: TextStyle(
            color: semantic.fgMuted,
            fontWeight: AppTypography.weightSemibold,
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
                  '/fazendas/$segment/grupo/${groupToSlug(group)}',
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space5),

        // Sem título de seção aqui (pedido do usuário): o grid de módulos já
        // se lê como continuação natural do acesso rápido acima, no mesmo
        // estilo ícone-em-cima/rótulo-embaixo da referência Força Agro.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.space3,
            mainAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final group = groups.keys.elementAt(index);
            return _ModuleGridCard(
              group: group,
              onTap: () =>
                  context.go('/fazendas/$segment/grupo/${groupToSlug(group)}'),
            );
          },
        ),
      ],
    );
  }
}

class _ModuleGridCard extends StatelessWidget {
  const _ModuleGridCard({required this.group, required this.onTap});

  final String group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final radius = BorderRadius.circular(AppRadius.xl3);
    return Container(
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: AppPressable(
        semanticLabel: 'Abrir módulo $group',
        onPressed: onTap,
        borderRadius: radius,
        minTouchTarget: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(groupIcon(group), size: 32, color: semantic.accentDefault),
              const SizedBox(height: AppSpacing.space2),
              Text(
                group,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.accentDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
