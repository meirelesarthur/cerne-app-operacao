import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';

/// Busca global de funcionalidades — destino do `AppSearchField` do cabeçalho.
///
/// Tela cheia, fora do `ShellRoute`: conserva apenas o contexto da fazenda,
/// enquanto troca o cabeçalho de perfil pela lista de todas as funcionalidades
/// do menu. Não há API de acessos recentes nem de histórico, então a ordem é
/// curada: o que o operacional mais faz no dia a dia vem primeiro
/// ([featuresByDailyPriority]). Ao digitar, a lista dá lugar aos resultados.
///
/// O app tem só o perfil Operacional, então todo resultado é tocável. A marca
/// de "função de outro perfil" continua no código como rede de segurança
/// caso o catálogo volte a ter perfis, mas não aparece hoje.
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
    final activeFarm = ref.watch(fazendasStoreProvider).activeFarm;
    final results = searchFeatures(_query, sessionProfile: sessionProfile);
    final hasQuery = normalizeForSearch(_query).isNotEmpty;
    final features = featuresByDailyPriority();

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: AppContentSheet(
          padded: false,
          header: AppFarmSelector(
            farmName: activeFarm.name,
            onTap: () => openFarmPicker(context, ref),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space8,
            ),
            children: [
              AppTextInput(
                placeholder: 'Procurando por algo?',
                autofocus: true,
                suffixIcon: Container(
                  width: AppSpacing.space10,
                  height: AppSpacing.space10,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: semantic.bgSurface,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    AppIcons.aiSearch,
                    size: AppSize.iconLg,
                    color: semantic.accentDefault,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.space6),
              if (!hasQuery) ...[
                const _SearchSectionHeader(title: 'Funcionalidades'),
                const SizedBox(height: AppSpacing.space3),
                for (final feature in features) ...[
                  AppMenuItem(
                    icon: groupIcon(feature.group),
                    label: feature.title,
                    description: feature.group,
                    showShadow: false,
                    onTap: () => context.push(featureDestination(feature)),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ] else if (results.isEmpty)
                const AppEmptyState(
                  icon: AppIcons.search,
                  badgeIcon: AppIcons.x,
                  tone: AppEmptyStateTone.info,
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
                        : AppTag(child: Text(_profileLabel(result.feature))),
                    onTap: result.openable
                        ? () => context.push(featureDestination(result.feature))
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _profileLabel(FeatureDefinition feature) => 'Operação';
}

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, child: AppHeading(child: Text(title)));
  }
}

/// Ids das funcionalidades que o operacional mais usa no dia a dia, na ordem
/// em que aparecem no topo da busca. As demais seguem na ordem do catálogo.
const _dailyPriorityIds = <String>[
  'minhas-os',
  'trato-diario',
  'leitura-cocho-confinamento',
  'pesagem',
  'apontamento',
  'sanitario',
  'nutricoes',
  'meus-currais',
  'producao-batelada',
  'sincronizacao',
  'marcacao',
  'transferencia-animal',
  'transferencia-lote-area',
  'localizar-animal',
  'nascimentos',
  'mortes',
  'abastecimentos',
];

/// Todas as funcionalidades do menu, com as de uso diário primeiro.
List<FeatureDefinition> featuresByDailyPriority() {
  final priority = [
    for (final id in _dailyPriorityIds) ?featureById(id),
  ];
  final ids = priority.map((f) => f.id).toSet();
  return [
    ...priority,
    for (final feature in allFeatures)
      if (!ids.contains(feature.id)) feature,
  ];
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

/// Busca no catálogo inteiro.
///
/// Casa por nome, objetivo e módulo. Resultados que a sessão pode abrir vêm
/// primeiro.
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
    FeatureProfile.operational;

/// Rota de uma funcionalidade — mesma regra de [GroupFeaturesScreen]: a função
/// mapeada mora sob o segmento do seu próprio perfil, salvo quando já tem rota
/// própria (`existingRoute`, ex. `/fazendas/campo/pesagem`).
String featureDestination(FeatureDefinition feature) {
  if (feature.existingRoute case final route?) return route;
  return '/fazendas/operacional/${feature.id}';
}
