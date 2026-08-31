import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';

/// "O que fazer hoje" (operacional) / central de gestão (administração) —
/// espelha `ResponsibilityWorkspace.tsx`.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o título operacional
/// trocou de "Central de rotinas" (vocabulário de sistema) para "O que fazer
/// hoje" — mais concreto para quem chega para executar uma tarefa, não para
/// administrar um "ambiente". A aba de contexto acima continua dizendo
/// "Rotinas" (rótulo curto de navegação); administração mantém "Central de
/// gestão", que já é direto o suficiente para esse perfil.
///
/// Nova UI (referência Força Agro): em vez de expandir cada funcionalidade
/// como um card solto (lia como uma lista longa e poluída), a home agrupa por
/// `feature.group` num grid ícone-em-cima/rótulo-embaixo. Tocar num card leva
/// para a tela fullscreen com as funções daquele grupo
/// ([GroupFeaturesScreen]); a navegação para a funcionalidade em si não muda.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o cabeçalho da
/// central foi reduzido ao título — o chip "AMBIENTE X" já é redundante com o
/// header global e as `AppContextTabs` (que dizem a mesma coisa), e a lista
/// "Acesso rápido" acima do grid apontava exatamente para os mesmos destinos
/// do grid logo abaixo, duplicada. O primeiro card tocável, que antes ficava a
/// ~53% da altura da tela, sobe para logo abaixo do título.
///
/// Padrão global (`docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md`, E7): esta é a tela
/// que o frame `operacao-home` do Figma descreve — os grupos do catálogo são,
/// um a um e na mesma ordem, os ladrilhos desenhados lá. Duas mudanças vieram
/// daí:
///
/// - O cartão de módulo era `_ModuleGridCard`, reimplementado aqui: ícone
///   centralizado, raio `xl3`, proporção fixa. Passou a ser `AppModuleTile` do
///   catálogo, com a anatomia medida no Figma (Lei 1 — o controle reutilizável
///   nasce em `lib/ui/`).
/// - O contexto de fazenda passa a abrir a tela, como no Figma. É o único bloco
///   que Operação e Administração compartilham (§4 da esteira).
class ResponsibilityWorkspace extends ConsumerWidget {
  const ResponsibilityWorkspace({super.key, required this.profile});

  final FeatureProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFarm = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm),
    );
    final features = profile == FeatureProfile.administration
        ? adminFeatures
        : operationalFeatures;
    final groups = <String, List<FeatureDefinition>>{};
    for (final feature in features) {
      groups.putIfAbsent(feature.group, () => []).add(feature);
    }
    // A ordem do grid é decisão de produto (`groupOrder`), não a ordem de
    // inserção no catálogo. O desempate pela posição original mantém o
    // resultado determinístico: `List.sort` não é estável em Dart, então
    // grupos ainda não listados em `_groupDisplayOrder` embaralhariam entre si.
    final insertionOrder = groups.keys.toList();
    final orderedGroups = [...insertionOrder]
      ..sort((a, b) {
        final byOrder = groupOrder(a).compareTo(groupOrder(b));
        if (byOrder != 0) return byOrder;
        return insertionOrder.indexOf(a).compareTo(insertionOrder.indexOf(b));
      });
    final isAdministration = profile == FeatureProfile.administration;
    final segment = isAdministration ? 'administracao' : 'operacional';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        AppFarmSelector(
          farmName: activeFarm.name,
          onTap: () => openFarmPicker(context, ref),
        ),
        const SizedBox(height: AppSpacing.space4),

        // Só o título: o chip de ambiente e a descrição saíram daqui — o
        // header global e as abas de contexto já dizem em que ambiente a
        // pessoa está, repetir isso na tela custava ~90px de rolagem antes do
        // primeiro toque possível.
        AppHeading(
          child: Text(
            isAdministration ? 'Central de gestão' : 'O que fazer hoje',
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        AppModuleTileGrid(
          tiles: [
            for (final group in orderedGroups)
              AppModuleTile(
                icon: groupIcon(group),
                label: group,
                onTap: () => context.go(
                  '/fazendas/$segment/grupo/${groupToSlug(group)}',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
