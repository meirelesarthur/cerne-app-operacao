import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';

/// Busca global de funcionalidades — destino do `AppSearchField` do cabeçalho.
///
/// Tela cheia, fora do `ShellRoute`: sem header global, sem abas e sem dock,
/// como `/perfil` e `/notificacoes`. Quem busca está procurando **uma** coisa;
/// o cromo do app só competiria com a lista.
///
/// **Procura nos dois perfis**, por decisão de produto: o catálogo funcional é
/// um só e a pessoa não deveria precisar saber em qual ambiente uma função
/// mora para encontrá-la. Mas a política de acesso do protótipo continua
/// valendo — uma função do outro perfil aparece marcada e **não é tocável**,
/// porque abri-la só levaria a um desvio silencioso de volta para a home
/// (`redirectForSession`). Achar é diferente de poder abrir, e a tela diz qual
/// dos dois está acontecendo.
class BuscaGlobalScreen extends ConsumerStatefulWidget {
  const BuscaGlobalScreen({super.key});

  @override
  ConsumerState<BuscaGlobalScreen> createState() => _BuscaGlobalScreenState();
}

class _BuscaGlobalScreenState extends ConsumerState<BuscaGlobalScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final sessionProfile = ref.watch(prototypeSessionProvider).profile;
    final results = searchFeatures(_query, sessionProfile: sessionProfile);
    final hasQuery = normalizeForSearch(_query).isNotEmpty;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            SubPageHeader(
              title: 'Buscar',
              onBack: () => _voltar(context, sessionProfile),
            ),
            Expanded(
              child: AppContentSheet(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space4,
                  ),
                  children: [
                    AppTextInput(
                      placeholder: 'Procurando por algo?',
                      autofocus: true,
                      prefixIcon: const AppIcon(
                        AppIcons.aiSearch,
                        size: AppSize.iconMd,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    if (!hasQuery)
                      AppEmptyState(
                        icon: AppIcons.aiSearch,
                        title: 'O que você precisa fazer?',
                        description:
                            'Busque entre as ${allFeatures.length} funções dos dois '
                            'ambientes pelo nome, pelo objetivo ou pelo módulo.',
                      )
                    else if (results.isEmpty)
                      const AppEmptyState(
                        icon: AppIcons.searchX,
                        title: 'Nenhuma função encontrada',
                        description:
                            'Tente outro termo — o nome do módulo também vale.',
                      )
                    else ...[
                      Text(
                        '${results.length} '
                        '${results.length == 1 ? 'resultado' : 'resultados'}',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      for (final result in results) ...[
                        AppMenuItem(
                          icon: groupIcon(result.feature.group),
                          label: result.feature.title,
                          description: result.feature.objective,
                          showShadow: false,
                          trailing: result.openable
                              ? null
                              : AppTag(
                                  child: Text(_profileLabel(result.feature)),
                                ),
                          onTap: result.openable
                              ? () => context.push(
                                  featureDestination(result.feature),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.space2),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A busca é aberta por `push` a partir de qualquer tela, mas também pode ser
  /// o primeiro destino de um link direto — aí não há pilha para desempilhar e
  /// o voltar precisa ter para onde ir.
  void _voltar(BuildContext context, UserAccessProfile? profile) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(profile?.homeRoute ?? '/desktop');
  }

  String _profileLabel(FeatureDefinition feature) =>
      feature.profile == FeatureProfile.administration
      ? 'Administração'
      : 'Operação';
}

/// Uma linha do resultado: a função encontrada e se a sessão atual pode abri-la.
class FeatureSearchResult {
  const FeatureSearchResult({required this.feature, required this.openable});

  final FeatureDefinition feature;

  /// Falso quando a função pertence ao outro perfil — a política de acesso
  /// impediria a navegação.
  final bool openable;
}

/// Normaliza para comparação: minúsculas e sem acento.
///
/// Sem isso, "pecuaria" não acharia "Pecuária" e "orgao" não acharia "órgão" —
/// e ninguém digita acento numa busca com pressa, de bota, no meio do curral.
String normalizeForSearch(String value) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = comAcento.indexOf(char);
    buffer.write(index == -1 ? char : semAcento[index]);
  }
  return buffer.toString();
}

/// Busca no catálogo inteiro — os dois perfis.
///
/// Casa por nome, objetivo e módulo. Resultados que a sessão pode abrir vêm
/// primeiro: quem está no chão de fazenda não deveria rolar por funções
/// administrativas para chegar à sua.
///
/// [sessionProfile] é obrigatório de propósito — `null` é uma resposta válida
/// (sessão sem perfil, em que nada é abrível), e não um descuido de chamada.
List<FeatureSearchResult> searchFeatures(
  String query, {
  required UserAccessProfile? sessionProfile,
}) {
  final termo = normalizeForSearch(query);
  if (termo.isEmpty) return const [];

  final abertos = <FeatureSearchResult>[];
  final bloqueados = <FeatureSearchResult>[];

  for (final feature in allFeatures) {
    final alvo = normalizeForSearch(
      '${feature.title} ${feature.objective} ${feature.group}',
    );
    if (!alvo.contains(termo)) continue;

    final openable =
        sessionProfile != null &&
        featureProfileOf(sessionProfile) == feature.profile;
    final result = FeatureSearchResult(feature: feature, openable: openable);
    (openable ? abertos : bloqueados).add(result);
  }

  return [...abertos, ...bloqueados];
}

/// Perfil do catálogo correspondente ao perfil da sessão.
FeatureProfile featureProfileOf(UserAccessProfile profile) =>
    profile == UserAccessProfile.administration
    ? FeatureProfile.administration
    : FeatureProfile.operational;

/// Rota de uma funcionalidade — mesma regra de [GroupFeaturesScreen]: a função
/// mapeada mora sob o segmento do seu próprio perfil, salvo quando já tem rota
/// própria (`existingRoute`, ex. `/fazendas/campo/pesagem`).
String featureDestination(FeatureDefinition feature) {
  if (feature.existingRoute case final route?) return route;
  final segment = feature.profile == FeatureProfile.administration
      ? 'administracao'
      : 'operacional';
  return '/fazendas/$segment/${feature.id}';
}
