import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../ordem_servico/models.dart';
import '../ordem_servico/state/ordem_servico_store.dart';
import '../ordem_servico/widgets.dart';

/// "Minhas OS" (Operacional) — consulta as ordens de serviço atribuídas ao
/// funcionário e conduz o ciclo de execução: iniciar, pausar/retomar e
/// encerrar (entregue, ou refeita com justificativa). A OS em si nasce no
/// app web (fonte única do cadastro); aqui só se lança o andamento em campo,
/// mesmo padrão de Confinamento (`operacional/meus_currais_screen.dart`).
///
/// Também é a tela inicial do perfil Operacional (primeira aba da navbar,
/// "OSs", em `/fazendas/operacional`): ali roda com [embedded], dentro da
/// folha de conteúdo do shell, que já traz saudação, busca e fazenda ativa.
class MinhasOsScreen extends ConsumerStatefulWidget {
  const MinhasOsScreen({super.key, this.embedded = false});

  /// `true` quando montada dentro do `AppContentSheet` do shell (tela
  /// inicial): sem a faixa de "Voltar" e sem uma segunda folha — o título
  /// vira cabeçalho de seção. O padrão mantém a tela autocontida para a rota
  /// funda `/fazendas/campo/minhas-os` (busca global e catálogo).
  final bool embedded;

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

    // Título à esquerda, filtro discreto à direita: o status escolhido abre
    // na dock inferior, sem um trilho de abas ocupando uma faixa inteira.
    final filterRow = Row(
      children: [
        const Expanded(child: AppHeading(child: Text('Ordens de serviço'))),
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
                onTap: () => _abrirDetalhe(context, os),
              );
            },
          );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              0,
            ),
            child: filterRow,
          ),
          Expanded(child: list),
        ],
      );
    }

    return Column(
      children: [
        const SubPageHeader(title: 'Minhas OS'),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space4,
            AppSpacing.space4,
            0,
          ),
          child: filterRow,
        ),
        Expanded(child: AppContentSheet(padded: false, child: list)),
      ],
    );
  }

  void _abrirDetalhe(BuildContext context, OrdemServico os) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);

    showAppBottomSheet<void>(
      context,
      title: 'Detalhe da OS',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final atual = notifier.byId(os.id);
          final actions = <Widget>[];

          if (atual.status == OrdemServicoStatus.aguardando) {
            actions.add(
              AppButton(
                onPressed: () {
                  notifier.iniciar(atual.id, autor: atual.responsavelExecucao);
                  setSheetState(() {});
                },
                child: const Text('Iniciar execução'),
              ),
            );
          }
          if (atual.status == OrdemServicoStatus.emExecucao) {
            actions.add(
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: () => _abrirPausar(context, atual.id),
                child: const Text('Pausar'),
              ),
            );
          }
          if (atual.status == OrdemServicoStatus.pausada) {
            actions.add(
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  notifier.retomar(atual.id, autor: atual.responsavelExecucao);
                  setSheetState(() {});
                },
                child: const Text('Retomar execução'),
              ),
            );
          }
          if (atual.status == OrdemServicoStatus.emExecucao ||
              atual.status == OrdemServicoStatus.pausada) {
            actions.add(
              AppButton(
                onPressed: () {
                  notifier.marcarEntregue(
                    atual.id,
                    autor: atual.responsavelExecucao,
                  );
                  setSheetState(() {});
                },
                child: const Text('Marcar como entregue'),
              ),
            );
            actions.add(
              AppButton(
                variant: AppButtonVariant.dangerOutline,
                onPressed: () => _abrirRefazer(context, atual.id),
                child: const Text('Marcar como refeita'),
              ),
            );
          }

          return OsDetailBody(os: atual, actions: actions);
        },
      ),
    );
  }

  void _abrirPausar(BuildContext context, String osId) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final controller = TextEditingController();

    showAppBottomSheet<void>(
      context,
      title: 'Pausar execução',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Motivo da pausa',
            required: true,
            child: AppTextarea(
              controller: controller,
              placeholder: 'Ex.: falta de insumo, condição climática...',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            fullWidth: true,
            onPressed: () {
              final motivo = controller.text.trim();
              if (motivo.isEmpty) return;
              final atual = notifier.byId(osId);
              notifier.pausar(
                osId,
                autor: atual.responsavelExecucao,
                motivo: motivo,
              );
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text('Confirmar pausa'),
          ),
        ],
      ),
    );
  }

  void _abrirRefazer(BuildContext context, String osId) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final controller = TextEditingController();

    showAppBottomSheet<void>(
      context,
      title: 'Marcar como refeita',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Justificativa',
            required: true,
            hint: 'Explique por que o serviço precisa ser refeito.',
            child: AppTextarea(
              controller: controller,
              placeholder: 'Descreva o que impediu a conclusão...',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.danger,
            onPressed: () {
              final justificativa = controller.text.trim();
              if (justificativa.isEmpty) return;
              final atual = notifier.byId(osId);
              notifier.marcarRefeita(
                osId,
                autor: atual.responsavelExecucao,
                justificativa: justificativa,
              );
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text('Confirmar retrabalho'),
          ),
        ],
      ),
    );
  }
}
