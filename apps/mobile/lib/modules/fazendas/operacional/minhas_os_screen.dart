import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../ordem_servico/models.dart';
import '../ordem_servico/state/ordem_servico_store.dart';
import '../ordem_servico/os_actions.dart';
import '../ordem_servico/widgets.dart';

/// "Minhas OS" (Operacional) — consulta as ordens de serviço atribuídas ao
/// funcionário e conduz o ciclo de execução: iniciar, pausar/retomar e
/// encerrar (entregue, ou refeita com justificativa). A OS em si nasce no
/// app web (fonte única do cadastro); aqui só se lança o andamento em campo,
/// mesmo padrão de Confinamento (`operacional/meus_currais_screen.dart`).
///
/// É o destino do "Ver todas" da tela inicial (`OperacionalHomeScreen`), que
/// mostra só as OS em andamento mais urgentes.
class MinhasOsScreen extends ConsumerStatefulWidget {
  const MinhasOsScreen({super.key});

  @override
  ConsumerState<MinhasOsScreen> createState() => _MinhasOsScreenState();
}

class _MinhasOsScreenState extends ConsumerState<MinhasOsScreen> {
  String _filtro = 'todas';

  /// "Todas" abre a tela com o panorama do dia; os demais filtros separam
  /// por andamento (pausada conta como em execução — ainda é trabalho aberto).
  static const _filtros = [
    AppFormSelectOption(value: 'todas', label: 'Todas'),
    AppFormSelectOption(value: 'aguardando', label: 'Aguardando'),
    AppFormSelectOption(value: 'execucao', label: 'Em execução'),
    AppFormSelectOption(value: 'finalizadas', label: 'Finalizadas'),
  ];

  List<OrdemServico> _filtrar(List<OrdemServico> ordens) {
    return switch (_filtro) {
      'aguardando' =>
        ordens.where((o) => o.status == OrdemServicoStatus.aguardando).toList(),
      'execucao' =>
        ordens
            .where(
              (o) =>
                  o.status == OrdemServicoStatus.emExecucao ||
                  o.status == OrdemServicoStatus.pausada,
            )
            .toList(),
      'finalizadas' => ordens.where((o) => o.status.encerrada).toList(),
      _ => ordens,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ordens = ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final filtradas = _filtrar(ordens);

    // Contagem à esquerda, filtro discreto à direita: o status escolhido
    // abre na dock inferior, sem um trilho de abas ocupando uma faixa inteira.
    final filterRow = Row(
      children: [
        Expanded(
          child: Text(
            filtradas.length == 1
                ? '1 ordem de serviço'
                : '${filtradas.length} ordens de serviço',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        AppInlineSelect(
          sheetTitle: 'Status da OS',
          options: _filtros,
          value: _filtro,
          onChanged: (v) => setState(() => _filtro = v),
        ),
      ],
    );
    final list = filtradas.isEmpty
        ? const Center(
            child: AppEmptyState(
              icon: AppIcons.fileText,
              title: 'Nenhuma OS neste filtro',
              description:
                  'Ordens de serviço atribuídas ao funcionário e à fazenda ativa aparecem aqui.',
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: filtradas.length,
            separatorBuilder: (context, _) =>
                const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final os = filtradas[index];
              return OsSummaryCard(
                os: os,
                onTap: () => abrirDetalheOs(context, ref, os),
              );
            },
          );

    return Column(
      children: [
        const SubPageHeader(title: 'Ordens de serviço'),
        Expanded(
          child: AppContentSheet(
            padded: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space4,
                    AppSpacing.space3,
                    AppSpacing.space4,
                    0,
                  ),
                  child: filterRow,
                ),
                Expanded(child: list),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
