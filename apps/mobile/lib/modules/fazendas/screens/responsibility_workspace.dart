import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../operational_groups.dart';
import '../state/fazendas_store.dart';

/// "O que fazer hoje" (operacional) / central de gestão (administração) —
/// espelha `ResponsibilityWorkspace.tsx`.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o título operacional
/// trocou de "Central de rotinas" (vocabulário de sistema) para "O que fazer
/// hoje" — mais concreto para quem chega para executar uma tarefa, não para
/// administrar um "ambiente". A aba de contexto acima continua dizendo
/// "Rotinas" (rótulo curto de navegação). Administração entra direto nos
/// painéis e nas consultas, sem repetir um título de contexto.
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
  const ResponsibilityWorkspace({
    super.key,
    required this.profile,
    this.showLocalContext = true,
    this.focusGroup,
  });

  final FeatureProfile profile;

  /// O shell monta fazenda, saudação e busca globalmente. O valor `true` fica
  /// como padrão para preservar o uso isolado desta tela no Widgetbook/testes.
  final bool showLocalContext;

  /// Quando informado, a central abre diretamente as funções deste grupo em
  /// vez de mostrar os grupos como uma segunda camada de navegação. A
  /// Administração usa isso para que as abas Gestão e Consultas entreguem
  /// conteúdo acionável no primeiro toque.
  final String? focusGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFarm = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm),
    );
    final allFeatures = operationalFeatures;
    final features = focusGroup == null
        ? allFeatures
        : allFeatures.where((feature) => feature.group == focusGroup).toList();
    // Ordem e destino de cada grupo vêm da fonte única compartilhada com o
    // menu lateral (`operational_groups.dart`).
    final groupEntries = operationalGroupEntries(features: features);
    final isFocusedGroup = focusGroup != null;

    final content = <Widget>[
      if (showLocalContext) ...[
        AppFarmSelector(
          farmName: activeFarm.name,
          onTap: () => openFarmPicker(context, ref),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppSearchField(onTap: () => context.push('/busca')),
        const SizedBox(height: AppSpacing.space4),
        const AppHeading(child: Text('O que fazer hoje')),
        const SizedBox(height: AppSpacing.space4),
      ],
      if (isFocusedGroup) ...[
        AppSectionTitle(child: Text(focusGroup!)),
        const SizedBox(height: AppSpacing.space2),
        AppModuleTileGrid(
          lastTileFullWidth: false,
          tiles: [
            for (final feature in features)
              AppModuleTile(
                icon: featureIcon(feature.id, feature.group),
                label: feature.title,
                description: feature.objective,
                layout: AppModuleTileLayout.module,
                onTap: () => context.push(operationalFeatureRoute(feature)),
              ),
          ],
        ),
      ] else
        AppModuleTileGrid(
          tiles: [
            for (final entry in groupEntries)
              AppModuleTile(
                icon: groupIcon(entry.group),
                label: entry.label,
                // Grupo com uma única funcionalidade (ex.: Sincronização): a
                // tela de listagem do grupo não teria nada além do próprio
                // card — pula direto para o destino, sem a camada
                // intermediária que só repetiria a mesma informação.
                onTap: () => entry.isFeature
                    ? context.push(entry.route)
                    : context.go(entry.route),
              ),
          ],
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: content,
    );
  }
}
