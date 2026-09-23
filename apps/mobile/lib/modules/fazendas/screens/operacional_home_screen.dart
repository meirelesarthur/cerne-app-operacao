import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/module_config.dart';
import '../../../ui/ui.dart';
import '../ordem_servico/models.dart';
import '../ordem_servico/os_actions.dart';
import '../ordem_servico/state/ordem_servico_store.dart';
import '../ordem_servico/widgets.dart';

/// Tela inicial do Operacional (aba "Início" da navbar, `/fazendas/operacional`).
///
/// Duas seções, de cima para baixo:
///
/// 1. **Minhas OS** — até [maxOrdens] ordens em andamento, a que está sendo
///    executada primeiro, e "Ver todas" para a lista completa com filtro.
///    Some quando não há OS em andamento: fazendas que quase não usam OS
///    abrem direto nos atalhos, sem uma lista vazia no topo.
/// 2. **Atalhos** — as rotinas do menu lateral em grade de quatro colunas,
///    ícone em quadrado com o nome embaixo, como ícones de aplicativo no
///    celular. A lista vem de [operationalMenuSections] (fonte única com o
///    menu), sem o próprio "Início".
///
/// A ordem das OS fica **estável sob o dedo**: iniciar uma OS pelo botão do
/// card faria ela subir para o topo na hora, e um card que muda de lugar logo
/// depois do toque parece erro. A ordem é calculada ao abrir a tela; depois
/// só saem as que encerraram e entram as novas no fim. Na próxima visita a
/// tela volta a ordenar do zero.
class OperacionalHomeScreen extends ConsumerStatefulWidget {
  const OperacionalHomeScreen({super.key});

  static const int maxOrdens = 3;

  static const String todasAsOrdensRoute = '/fazendas/campo/minhas-os';

  /// Ordem do "o que fazer agora": em execução, pausada, aguardando; dentro
  /// de cada uma, a prioridade mais alta e depois o prazo mais próximo.
  static List<OrdemServico> emDestaque(List<OrdemServico> ordens) {
    int peso(OrdemServicoStatus status) => switch (status) {
      OrdemServicoStatus.emExecucao => 0,
      OrdemServicoStatus.pausada => 1,
      _ => 2,
    };
    return ordens.where((o) => o.status.emAndamento).toList()..sort((a, b) {
      final byStatus = peso(a.status).compareTo(peso(b.status));
      if (byStatus != 0) return byStatus;
      final byPrioridade = b.prioridade.index.compareTo(a.prioridade.index);
      if (byPrioridade != 0) return byPrioridade;
      return a.prazo.compareTo(b.prazo);
    });
  }

  @override
  ConsumerState<OperacionalHomeScreen> createState() =>
      _OperacionalHomeScreenState();
}

class _OperacionalHomeScreenState extends ConsumerState<OperacionalHomeScreen> {
  /// Ordem fixada dos ids em destaque (ver doc da classe).
  List<String>? _ordem;

  List<OrdemServico> _ordemEstavel(List<OrdemServico> ordens) {
    final destaque = OperacionalHomeScreen.emDestaque(ordens);
    final porId = {for (final os in destaque) os.id: os};
    final anterior = _ordem;
    final ids = anterior == null
        ? destaque.map((os) => os.id).toList()
        : [
            ...anterior.where(porId.containsKey),
            ...destaque
                .map((os) => os.id)
                .where((id) => !anterior.contains(id)),
          ];
    _ordem = ids;
    return [for (final id in ids) porId[id]!];
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ordens = ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final agora = ref.watch(osRelogioProvider)();
    final emAndamento = _ordemEstavel(ordens);
    final atalhos = [
      for (final section in operationalMenuSections()) ...section.items,
    ].where((item) => item.route != operationalHomeRoute).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        if (emAndamento.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(child: AppHeading(child: Text('Minhas OS'))),
              AppButton(
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                rightIcon: const AppIcon(
                  AppIcons.arrowRight,
                  size: AppSize.iconXs,
                ),
                onPressed: () =>
                    context.push(OperacionalHomeScreen.todasAsOrdensRoute),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          for (final os in emAndamento.take(
            OperacionalHomeScreen.maxOrdens,
          )) ...[
            OsSummaryCard(
              os: os,
              agora: agora,
              onTap: () => abrirDetalheOs(context, ref, os),
              onAcaoRapida: () => executarAcaoRapidaOs(context, ref, os),
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
          const SizedBox(height: AppSpacing.space3),
        ],
        const AppHeading(child: Text('Atalhos')),
        const SizedBox(height: AppSpacing.space4),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.space4,
          crossAxisSpacing: AppSpacing.space2,
          // Quadrado de 64 + rótulo de até duas linhas.
          childAspectRatio: 0.72,
          children: [
            for (final item in atalhos)
              AppAppIconTile(
                icon: item.icon,
                label: item.label,
                labelColor: semantic.fgDefault,
                labelMaxLines: 2,
                onTap: () => item.push
                    ? context.push(item.route)
                    : context.go(item.route),
              ),
          ],
        ),
      ],
    );
  }
}
