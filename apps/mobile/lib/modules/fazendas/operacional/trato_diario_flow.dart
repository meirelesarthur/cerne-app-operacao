import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../cadastros_vinculados.dart';
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

/// Trato Diário (spec §4.4): distribui uma Batelada já produzida entre os
/// currais elegíveis — situação Ocupado **e** dieta vigente igual à dieta da
/// batida (regra de elegibilidade cruzada, spec §4.4).
class TratoDiarioFlow extends ConsumerStatefulWidget {
  const TratoDiarioFlow({super.key});

  @override
  ConsumerState<TratoDiarioFlow> createState() => _TratoDiarioFlowState();
}

class _TratoDiarioFlowState extends ConsumerState<TratoDiarioFlow> {
  String? _bateladaId;
  final Map<String, num> _fornecida = {};
  final Map<String, bool> _concluido = {};
  bool? _queued;

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Trato diário finalizado',
        queued: _queued!,
        effects: 'O saldo restante no vagão será atualizado.',
      );
    }

    final confinamento = ref.watch(confinamentoStoreProvider);
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final batelada = _bateladaId == null
        ? null
        : confinamento.bateladas.firstWhere((b) => b.id == _bateladaId);

    final elegiveis = batelada == null
        ? const <CurralInfo>[]
        : confinamento.currais
              .where(
                (c) =>
                    c.situacao == CurralSituacao.ocupado &&
                    c.dietaAtualId == batelada.dietaId,
              )
              .toList();

    // Simplificação assumida no protótipo: sem tabela real de rateio por
    // lote, a quantidade planejada divide o peso da batida igualmente entre
    // os currais elegíveis (spec só confirma que o cálculo é automático a
    // partir do lote alocado — fórmula completa é ponto em aberto, §7).
    final planejadaPorCurral = elegiveis.isEmpty
        ? 0.0
        : batelada!.quantidadeProduzida / elegiveis.length;

    final totalFornecido = _fornecida.values.fold<num>(0, (s, v) => s + v);
    final faltante = batelada == null
        ? 0
        : (batelada.quantidadeProduzida - totalFornecido).clamp(
            0,
            batelada.quantidadeProduzida,
          );
    final progresso = elegiveis.isEmpty
        ? 0
        : ((totalFornecido / batelada!.quantidadeProduzida) * 100).round();
    final concluidos = _concluido.values.where((v) => v).length;

    return FlowShell(
      title: 'Trato diário',
      actionIcon: AppIcons.moreVertical,
      actionLabel: 'Mais opções',
      onAction: () => _showDetails(context),
      primaryLabel: elegiveis.isEmpty ? null : 'Finalizar trato',
      onPrimary: elegiveis.isEmpty
          ? null
          : () => _confirmarFinalizar(elegiveis, batelada!, faltante),
      summary: batelada == null
          ? null
          : AppActionBarSummary(
              leadingLabel: 'Fornecido',
              leadingValue: '${formatarNumero(totalFornecido, casas: 0)} kg',
              trailingLabel: 'Faltam',
              trailingValue: '${formatarNumero(faltante, casas: 0)} kg',
              value: totalFornecido.toDouble(),
              max: batelada.quantidadeProduzida.toDouble(),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Batida de dieta',
            required: true,
            child: AppFormSelect(
              options: [
                for (final b in confinamento.bateladas)
                  AppFormSelectOption(
                    value: b.id,
                    label:
                        '${b.vagaoDestino} · ${b.quantidadeProduzida.toStringAsFixed(0)} kg',
                  ),
              ],
              value: _bateladaId,
              placeholder: 'Selecione a batida',
              onChanged: (v) => setState(() {
                _bateladaId = v;
                _fornecida.clear();
                _concluido.clear();
              }),
            ),
          ),
          if (batelada != null) ...[
            const SizedBox(height: AppSpacing.space4),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space2,
              crossAxisSpacing: AppSpacing.space2,
              childAspectRatio: 1.2,
              children: [
                AppKpiStatCard(label: 'Progresso', value: '$progresso%'),
                AppKpiStatCard(
                  label: 'Fornecido',
                  value: '${totalFornecido.toStringAsFixed(0)} kg',
                ),
                AppKpiStatCard(
                  label: 'Currais concluídos',
                  value: '$concluidos/${elegiveis.length}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            if (elegiveis.isEmpty)
              const AppEmptyState(
                icon: AppIcons.barns,
                badgeIcon: AppIcons.x,
                tone: AppEmptyStateTone.warning,
                size: AppEmptyStateSize.compact,
                title: 'Nenhum curral elegível',
                description:
                    'Nenhum curral ocupado está, hoje, na fase que corresponde a esta dieta.',
              )
            else ...[
              const AppSectionTitle(child: Text('Currais elegíveis')),
              const SizedBox(height: AppSpacing.space2),
              for (final c in elegiveis)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                  child: AppCard(
                    variant: AppCardVariant.inset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.nome,
                              style: TextStyle(
                                fontWeight: AppTypography.weightSemibold,
                                color: semantic.fgDefault,
                              ),
                            ),
                            Text(
                              'Capacidade ${c.capacidade}',
                              style: TextStyle(
                                fontSize: AppTypography.sm,
                                color: semantic.fgMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Planejado: ${formatarNumero(planejadaPorCurral, casas: 1)} kg',
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        AppFormField(
                          label: 'Quantidade fornecida',
                          child: AppStepper(
                            value: _fornecida[c.id] ?? 0,
                            onChanged: (v) =>
                                setState(() => _fornecida[c.id] = v),
                            step: 10,
                            suffix: 'kg',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        AppCheckbox(
                          checked: _concluido[c.id] ?? false,
                          label: 'Marcar como concluído',
                          onChanged: (v) =>
                              setState(() => _concluido[c.id] = v),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showAppBottomSheet<void>(
      context,
      title: 'Trato diário',
      child: const Text(
        'Selecione a batida de dieta e informe quanto foi fornecido em cada curral. '
        'O resumo no rodapé mostra o saldo restante antes de finalizar.',
      ),
    );
  }

  /// Finalizar grava o trato do dia: confirma antes, com o saldo do vagão —
  /// é aqui que o erro de "esqueci um curral" aparece.
  Future<void> _confirmarFinalizar(
    List<CurralInfo> elegiveis,
    Batelada batelada,
    num faltante,
  ) async {
    final ok = await showAppConfirm(
      context,
      title: 'Finalizar o trato de hoje?',
      message: faltante > 0
          ? 'Ainda faltam ${formatarNumero(faltante, casas: 0)} kg no vagão. '
                'Se já terminou, finalize mesmo assim.'
          : 'Todo o vagão foi distribuído nos currais.',
      confirmLabel: 'Finalizar trato',
      cancelLabel: 'Voltar e conferir',
    );
    if (ok && mounted) _finalizar(elegiveis, batelada);
  }

  void _finalizar(List<CurralInfo> elegiveis, Batelada batelada) {
    final trato = TratoDiario(
      id: 'td-${DateTime.now().microsecondsSinceEpoch}',
      bateladaId: batelada.id,
      lancamentos: [
        for (final c in elegiveis)
          LancamentoCurral(
            curralId: c.id,
            quantidadePlanejada:
                batelada.quantidadeProduzida / elegiveis.length,
            quantidadeFornecida: (_fornecida[c.id] ?? 0).toDouble(),
            concluido: _concluido[c.id] ?? false,
          ),
      ],
    );
    ref.read(confinamentoStoreProvider.notifier).iniciarTratoDiario(trato);

    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: trato.id,
              label: 'Trato diário',
              detail: '${elegiveis.length} currais',
              kind: ActivityKind.arracoamento,
            ),
          );
    }
    setState(() => _queued = queued);
  }
}
