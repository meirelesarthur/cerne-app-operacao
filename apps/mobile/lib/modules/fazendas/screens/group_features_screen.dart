import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';

/// Tela fullscreen com as funções de um único grupo (ex.: "Estoque" →
/// Formulações, Batidas) — destino do acesso rápido e dos cards de módulo em
/// [ResponsibilityWorkspace]. Tocar numa função navega exatamente como antes
/// (rota da própria [FeatureDefinition]); nada muda na jornada de cada uma.
class GroupFeaturesScreen extends StatelessWidget {
  const GroupFeaturesScreen({
    super.key,
    required this.profile,
    required this.groupSlug,
  });

  final FeatureProfile profile;

  /// Slug da rota (`grupo/:group`) — ver [groupFromSlug]. Um slug desconhecido
  /// (ex.: link antigo/quebrado) cai no estado vazio abaixo em vez de quebrar
  /// a navegação.
  final String groupSlug;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isAdministration = profile == FeatureProfile.administration;
    final segment = isAdministration ? 'administracao' : 'operacional';
    final centerRoute = '/fazendas/$segment';
    final group = groupFromSlug(groupSlug);
    final features = group == null
        ? const <FeatureDefinition>[]
        : (isAdministration ? adminFeatures : operationalFeatures)
              .where((f) => f.group == group)
              .toList();
    final title = group ?? groupSlug;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        AppScreenHeader(
          title: title,
          description:
              '${features.length} ${features.length == 1 ? 'função' : 'funções'} neste módulo',
          onBack: () => context.go(centerRoute),
          backLabel: 'Voltar à central',
          leading: Container(
            width: AppSpacing.space12,
            height: AppSpacing.space12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: semantic.accentSubtle,
            ),
            alignment: Alignment.center,
            child: Icon(
              groupIcon(title),
              size: 22,
              color: semantic.accentDefault,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        if (features.isEmpty)
          const AppEmptyState(
            icon: LucideIcons.inbox,
            title: 'Nada por aqui',
            description: 'Este módulo ainda não tem funções mapeadas.',
          )
        else
          for (final feature in features) ...[
            AppMenuItem(
              icon: groupIcon(feature.group),
              label: feature.title,
              description: feature.objective,
              showShadow: false,
              onTap: () => context.go(_destination(feature, segment)),
            ),
            const SizedBox(height: AppSpacing.space2),
          ],
      ],
    );
  }

  String _destination(FeatureDefinition feature, String segment) {
    if (feature.existingRoute case final route?) return route;
    return '/fazendas/$segment/${feature.id}';
  }
}
