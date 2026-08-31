import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';

/// Acima deste tanto de funções num grupo, a rolagem sozinha vira uma busca
/// visual — "Pecuária" no perfil operacional tem 19 (ver plano de UX). Abaixo
/// disso, a lista inteira cabe numa olhada e o campo de busca só ocuparia
/// espaço sem ajudar.
const _searchThreshold = 8;

/// Tela fullscreen com as funções de um único grupo (ex.: "Estoque" →
/// Formulações, Batidas) — destino do acesso rápido e dos cards de módulo em
/// [ResponsibilityWorkspace]. Tocar numa função navega exatamente como antes
/// (rota da própria [FeatureDefinition]); nada muda na jornada de cada uma.
class GroupFeaturesScreen extends StatefulWidget {
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
  State<GroupFeaturesScreen> createState() => _GroupFeaturesScreenState();
}

class _GroupFeaturesScreenState extends State<GroupFeaturesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isAdministration = widget.profile == FeatureProfile.administration;
    final segment = isAdministration ? 'administracao' : 'operacional';
    final centerRoute = '/fazendas/$segment';
    final group = groupFromSlug(widget.groupSlug);
    final allFeatures = group == null
        ? const <FeatureDefinition>[]
        : (isAdministration ? adminFeatures : operationalFeatures)
              .where((f) => f.group == group)
              .toList();
    final showSearch = allFeatures.length > _searchThreshold;
    final query = _query.trim().toLowerCase();
    final features = !showSearch || query.isEmpty
        ? allFeatures
        : allFeatures
              .where((f) => f.title.toLowerCase().contains(query))
              .toList();
    final title = group ?? widget.groupSlug;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        AppScreenHeader(
          title: title,
          description:
              '${allFeatures.length} ${allFeatures.length == 1 ? 'função' : 'funções'} neste módulo',
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
            child: AppIcon(
              groupIcon(title),
              size: 22,
              color: semantic.accentDefault,
            ),
          ),
        ),
        if (showSearch) ...[
          const SizedBox(height: AppSpacing.space4),
          AppTextInput(
            placeholder: 'Buscar função...',
            prefixIcon: const AppIcon(AppIcons.search, size: 18),
            onChanged: (v) => setState(() => _query = v),
          ),
        ],
        const SizedBox(height: AppSpacing.space4),
        if (allFeatures.isEmpty)
          const AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nada por aqui',
            description: 'Este módulo ainda não tem funções mapeadas.',
          )
        else if (features.isEmpty)
          const AppEmptyState(
            icon: AppIcons.searchX,
            title: 'Nenhuma função encontrada',
            description: 'Tente buscar por outro nome.',
          )
        else
          for (final feature in features) ...[
            AppMenuItem(
              icon: groupIcon(feature.group),
              label: feature.title,
              description: feature.objective,
              showShadow: false,
              // `push`, não `go`: `_destination` pode apontar tanto para uma
              // rota irmã fora desta linhagem (`existingRoute`, ex.
              // `/fazendas/campo/pesagem`) quanto para uma rota-irmã do
              // próprio `:featureId` (`/fazendas/$segment/<id>`) — em ambos
              // os casos `go` reconstrói a pilha sem esta tela de grupo, e o
              // voltar do sistema pula direto para a central em vez de
              // retornar à listagem do grupo.
              onTap: () => context.push(_destination(feature, segment)),
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
