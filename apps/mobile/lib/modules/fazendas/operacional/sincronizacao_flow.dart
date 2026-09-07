import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/activity_list_item.dart' show kindLabel;
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';

/// Quantidade de itens por categoria quando a fila local está vazia — o
/// protótipo não bloqueia a demonstração do envio por falta de lançamentos
/// reais na sessão. Premissa funcional do protótipo frontend, como as demais
/// distribuições de amostra do catálogo (`functional_catalog.dart`).
const Map<ActivityKind, int> _demoSyncPlan = {
  ActivityKind.pesagem: 20,
  ActivityKind.evento: 15,
  ActivityKind.nfe: 10,
  ActivityKind.venda: 10,
  ActivityKind.insumo: 15,
  ActivityKind.arracoamento: 10,
};

/// Sincronização de dados (feature `sincronizacao`): envia a fila local para
/// a nuvem categoria a categoria (`ActivityKind`, fonte única também usada
/// pelas Atividades) até fechar em 100%.
///
/// Fluxo de campo (`/fazendas/campo/sincronizacao`) como os demais — tela
/// funda, sem navbar, CTA fixo no rodapé — em vez de um passo intermediário
/// de fila com "Sincronizar agora": o próprio botão do rodapé é o disparo.
class SincronizacaoFlow extends ConsumerStatefulWidget {
  const SincronizacaoFlow({super.key});

  @override
  ConsumerState<SincronizacaoFlow> createState() => _SincronizacaoFlowState();
}

enum _SyncPhase { idle, syncing, done }

class _SincronizacaoFlowState extends ConsumerState<SincronizacaoFlow> {
  /// Passos fixos de animação — o tempo total não depende do tamanho da fila,
  /// só a granularidade de cada avanço.
  static const _steps = 24;
  static const _tickInterval = Duration(milliseconds: 140);

  Timer? _timer;
  _SyncPhase _phase = _SyncPhase.idle;
  int _sent = 0;
  int _total = 0;
  Map<ActivityKind, int> _plan = const {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<ActivityKind, int> _planFor(List<SyncItem> queue) {
    if (queue.isEmpty) return _demoSyncPlan;
    final counts = <ActivityKind, int>{};
    for (final item in queue) {
      counts[item.kind] = (counts[item.kind] ?? 0) + 1;
    }
    return counts;
  }

  void _start(List<SyncItem> queue) {
    _timer?.cancel();
    final plan = _planFor(queue);
    final total = plan.values.fold(0, (sum, count) => sum + count);
    final step = (total / _steps).ceil().clamp(1, total);
    setState(() {
      _plan = plan;
      _total = total;
      _sent = 0;
      _phase = _SyncPhase.syncing;
    });
    _timer = Timer.periodic(_tickInterval, (timer) {
      if (_sent >= _total) {
        timer.cancel();
        ref.read(fazendasStoreProvider.notifier).clearSync();
        setState(() => _phase = _SyncPhase.done);
        return;
      }
      setState(() => _sent = (_sent + step).clamp(0, _total));
    });
  }

  /// Itens já enviados de cada categoria — como [_plan] preserva a ordem de
  /// `ActivityKind.values`, cada categoria fecha o check em bloco assim que
  /// sua fatia cumulativa é alcançada por [_sent].
  List<({ActivityKind kind, int done, int total})> get _categories {
    var before = 0;
    final result = <({ActivityKind kind, int done, int total})>[];
    for (final kind in ActivityKind.values) {
      final count = _plan[kind];
      if (count == null) continue;
      final done = (_sent - before).clamp(0, count);
      result.add((kind: kind, done: done, total: count));
      before += count;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));
    final queue = ref.watch(fazendasStoreProvider.select((s) => s.syncQueue));

    final finished = _phase == _SyncPhase.done;
    final syncing = _phase == _SyncPhase.syncing;
    final categories = syncing || finished
        ? _categories
        : [
            for (final entry in _planFor(queue).entries)
              (kind: entry.key, done: 0, total: entry.value),
          ];
    final total = syncing || finished
        ? _total
        : categories.fold(0, (sum, c) => sum + c.total);
    final sent = syncing || finished ? _sent : 0;

    return FlowShell(
      title: 'Sincronização',
      primaryLabel: switch (_phase) {
        _SyncPhase.idle => 'Sincronizar',
        _SyncPhase.syncing => 'Sincronizando',
        _SyncPhase.done => 'Concluído',
      },
      primaryLoading: syncing,
      onPrimary: switch (_phase) {
        _SyncPhase.idle => isOnline ? () => _start(queue) : null,
        _SyncPhase.syncing => null,
        _SyncPhase.done => () => Navigator.of(context).maybePop(),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            finished
                ? 'Todos os lançamentos foram enviados para a nuvem.'
                : 'Mantenha o app aberto até o envio terminar.',
            style: TextStyle(color: semantic.fgMuted),
          ),
          const SizedBox(height: AppSpacing.space5),
          Center(
            child: AppGauge(
              value: sent.toDouble(),
              max: total == 0 ? 1 : total.toDouble(),
              size: 200,
              tone: AppGaugeTone.positive,
              label: '$sent/$total',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              AppIcon(
                finished ? AppIcons.check : AppIcons.uploadCloud,
                size: AppSize.iconSm,
                color: finished ? semantic.chartPositive : semantic.fgMuted,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                finished ? 'MÓDULOS SINCRONIZADOS' : 'ENVIANDO PARA A NUVEM',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  fontWeight: AppTypography.weightSemibold,
                  letterSpacing: 0.4,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
              border: Border.all(color: semantic.borderDefault),
            ),
            child: Column(
              children: [
                for (final category in categories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space3,
                    ),
                    decoration: category == categories.last
                        ? null
                        : BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: semantic.borderSubtle),
                            ),
                          ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            kindLabel[category.kind] ?? '—',
                            style: TextStyle(color: semantic.fgDefault),
                          ),
                        ),
                        if (category.done >= category.total)
                          AppIcon(
                            AppIcons.check,
                            size: AppSize.iconSm,
                            color: semantic.chartPositive,
                          )
                        else if (category.done > 0)
                          AppSpinner(
                            size: AppSize.iconXs,
                            color: semantic.accentDefault,
                          )
                        else
                          AppIcon(
                            AppIcons.circle,
                            size: AppSize.iconSm,
                            color: semantic.borderDefault,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
