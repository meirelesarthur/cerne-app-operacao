import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
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
///
/// É o frame `modulo-confinamento` do Figma (`54349:3009`): folha de conteúdo
/// com campo de busca no topo, cabeçalho de seção com a seta de voltar à
/// esquerda do nome do grupo, e as funções abaixo. O cabeçalho de página com
/// descrição e bolha de ícone saiu — a referência resolve o mesmo com uma
/// linha só.
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

    return AppContentSheet(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
        children: [
          if (showSearch) ...[
            AppTextInput(
              placeholder: 'Buscar função...',
              prefixIcon: const AppIcon(AppIcons.search, size: AppSize.iconMd),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          AppSectionTitle(
            leading: AppIcons.chevronLeft,
            onTap: () => context.go(centerRoute),
            semanticLabel: 'Voltar à central',
            child: Text(title),
          ),
          // A contagem sobrevive à troca de cabeçalho: era a descrição do
          // `AppScreenHeader` e vira o metadado de 12px do padrão global. Saber
          // o tamanho da lista antes de rolar é informação de produto, não
          // enfeite do componente antigo.
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space1),
            child: Text(
              '${allFeatures.length} '
              '${allFeatures.length == 1 ? 'função' : 'funções'} neste módulo',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
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
      ),
    );
  }

  String _destination(FeatureDefinition feature, String segment) {
    if (feature.existingRoute case final route?) return route;
    return '/fazendas/$segment/${feature.id}';
  }
}
