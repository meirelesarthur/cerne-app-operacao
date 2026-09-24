import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
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
/// 1. **Ordens de serviço** — no máximo [maxOrdens]: a primeira (a que está
///    em execução, quando houver) em card de destaque com a ação rápida; logo
///    abaixo, a próxima a fazer em card compacto. O que sobra aparece só como
///    contagem ("+ 3 ordens para fazer"), que leva — como o "Ver todas" — à
///    lista completa com filtros. Some quando não há OS em andamento: a home
///    vira só o menu.
/// 2. **Menu** — as rotinas do menu lateral em ladrilhos de três colunas
///    ([AppModuleTileGrid]), ícone no topo e nome na base. A lista vem de
///    [operationalMenuSections] (fonte única com o menu), sem o próprio
///    "Início".
///
/// A ordem das OS fica **estável sob o dedo**: iniciar uma OS pelo botão do
/// card faria ela subir para o topo na hora, e um card que muda de lugar logo
/// depois do toque parece erro. A ordem é calculada ao abrir a tela; depois
/// só saem as que encerraram e entram as novas no fim. Na próxima visita a
/// tela volta a ordenar do zero.
class OperacionalHomeScreen extends ConsumerStatefulWidget {
  const OperacionalHomeScreen({super.key});

  static const int maxOrdens = 2;

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
    final ordens = ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final agora = ref.watch(osRelogioProvider)();
    final emAndamento = _ordemEstavel(ordens);
    final restantes = emAndamento.length - OperacionalHomeScreen.maxOrdens;
    final atalhos = [
      for (final section in operationalMenuSections()) ...section.items,
    ].where((item) => item.route != operationalHomeRoute).toList();
    void verTodas() => context.push(OperacionalHomeScreen.todasAsOrdensRoute);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        if (emAndamento.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(
                child: AppHeading(child: Text('Ordens de serviço')),
              ),
              AppButton(
                variant: AppButtonVariant.soft,
                size: AppButtonSize.sm,
                rightIcon: const AppIcon(
                  AppIcons.chevronRight,
                  size: AppSize.iconXs,
                ),
                onPressed: verTodas,
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          OsSummaryCard(
            variant: AppStatusCardVariant.featured,
            os: emAndamento.first,
            agora: agora,
            onTap: () => abrirDetalheOs(context, ref, emAndamento.first),
            onAcaoRapida: () =>
                executarAcaoRapidaOs(context, ref, emAndamento.first),
          ),
          if (emAndamento.length > 1) ...[
            const SizedBox(height: AppSpacing.space3),
            OsSummaryCard(
              variant: AppStatusCardVariant.compact,
              os: emAndamento[1],
              agora: agora,
              onTap: () => abrirDetalheOs(context, ref, emAndamento[1]),
            ),
          ],
          if (restantes > 0) ...[
            const SizedBox(height: AppSpacing.space3),
            AppLabeledDivider(label: 'Ver mais', onTap: verTodas),
          ],
          const SizedBox(height: AppSpacing.space4),
        ] else ...[
          // Sem OS a seção não some: a pessoa precisa saber que não tem nada
          // para ela hoje, e não achar que a tela não carregou.
          const AppHeading(child: Text('Ordens de serviço')),
          const SizedBox(height: AppSpacing.space3),
          const AppEmptyState(
            size: AppEmptyStateSize.compact,
            icon: AppIcons.fileText,
            tone: AppEmptyStateTone.brand,
            title: 'Nenhuma ordem para você agora',
            description:
                'Quando o escritório mandar uma ordem de serviço, ela aparece aqui.',
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
        AppModuleTileGrid(
          columns: 3,
          tiles: [
            for (final item in atalhos)
              AppModuleTile(
                icon: item.icon,
                label: item.label,
                dense: true,
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
