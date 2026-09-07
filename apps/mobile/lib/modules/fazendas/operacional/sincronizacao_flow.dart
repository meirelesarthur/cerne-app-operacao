import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/generated/app_motion.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/activity_list_item.dart' show kindLabel;
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';

/// Um módulo (categoria `ActivityKind`) e as funcionalidades internas que ele
/// está enviando — o card da tela de sincronização expande para revelar esta
/// lista, não a fila inteira de uma vez.
class _SyncModule {
  const _SyncModule({required this.kind, required this.items});

  final ActivityKind kind;
  final List<String> items;
}

/// Amostra usada quando a fila local está vazia — o protótipo não bloqueia a
/// demonstração do envio por falta de lançamentos reais na sessão. Premissa
/// funcional do protótipo frontend, como as demais distribuições de amostra
/// do catálogo (`functional_catalog.dart`).
const _demoSyncModules = <_SyncModule>[
  _SyncModule(
    kind: ActivityKind.pesagem,
    items: ['Pesagem do Lote 12', 'Pesagem do Lote 27', 'Pesagem do Lote 34'],
  ),
  _SyncModule(
    kind: ActivityKind.evento,
    items: ['Nascimento — Lote 8', 'Morte — Lote 15', 'Transferência de lote'],
  ),
  _SyncModule(
    kind: ActivityKind.nfe,
    items: ['NF-e #48213', 'NF-e #48220'],
  ),
  _SyncModule(
    kind: ActivityKind.venda,
    items: ['Venda — Lote 19', 'Venda — Lote 33'],
  ),
  _SyncModule(
    kind: ActivityKind.insumo,
    items: ['Aplicação de fertilizante', 'Retirada de diesel'],
  ),
  _SyncModule(
    kind: ActivityKind.arracoamento,
    items: [
      'Arraçoamento — Curral 3',
      'Arraçoamento — Curral 7',
      'Arraçoamento — Curral 11',
    ],
  ),
];

enum _SyncPhase { idle, syncing, done }

enum _ModuleStatus { pending, active, done }

/// Sincronização de dados (feature `sincronizacao`): envia a fila local para
/// a nuvem módulo a módulo (`ActivityKind`, fonte única também usada pelas
/// Atividades). Cada módulo é um card isolado que expande enquanto está
/// enviando — mostrando cada funcionalidade interna — e recolhe assim que
/// termina, liberando o próximo. Qualquer card pode ser reaberto a qualquer
/// momento para conferir exatamente onde a sincronização passou.
///
/// Fluxo de campo (`/fazendas/campo/sincronizacao`) como os demais — tela
/// funda, sem navbar, CTA fixo no rodapé — em vez de um passo intermediário
/// de fila com "Sincronizar agora": o próprio botão do rodapé é o disparo.
class SincronizacaoFlow extends ConsumerStatefulWidget {
  const SincronizacaoFlow({super.key});

  @override
  ConsumerState<SincronizacaoFlow> createState() => _SincronizacaoFlowState();
}

class _SincronizacaoFlowState extends ConsumerState<SincronizacaoFlow> {
  static const _tickInterval = Duration(milliseconds: 420);

  Timer? _timer;
  _SyncPhase _phase = _SyncPhase.idle;
  List<_SyncModule> _modules = const [];
  int _moduleIndex = 0;
  int _itemIndex = 0;
  final Map<int, bool> _expandedOverride = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<_SyncModule> _modulesFor(List<SyncItem> queue) {
    if (queue.isEmpty) return _demoSyncModules;
    final byKind = <ActivityKind, List<String>>{};
    for (final item in queue) {
      (byKind[item.kind] ??= []).add(item.label);
    }
    return [
      for (final kind in ActivityKind.values)
        if (byKind[kind] != null) _SyncModule(kind: kind, items: byKind[kind]!),
    ];
  }

  void _start(List<SyncItem> queue) {
    _timer?.cancel();
    setState(() {
      _modules = _modulesFor(queue);
      _moduleIndex = 0;
      _itemIndex = 0;
      _expandedOverride.clear();
      _phase = _SyncPhase.syncing;
    });
    _scheduleTick();
  }

  /// Avança um item por vez — de propósito, em vez de um `Timer.periodic`
  /// genérico: o passo seguinte depende de quantos itens restam no módulo
  /// ativo (fecha o módulo e pula pro próximo só quando ele esgota).
  void _scheduleTick() {
    _timer = Timer(_tickInterval, () {
      final current = _modules[_moduleIndex];
      final isLastModule = _moduleIndex == _modules.length - 1;
      final nextItemIndex = _itemIndex + 1;

      if (nextItemIndex >= current.items.length) {
        if (isLastModule) {
          ref.read(fazendasStoreProvider.notifier).clearSync();
          setState(() {
            _itemIndex = current.items.length;
            _phase = _SyncPhase.done;
          });
          return;
        }
        setState(() {
          _moduleIndex += 1;
          _itemIndex = 0;
        });
      } else {
        setState(() => _itemIndex = nextItemIndex);
      }
      _scheduleTick();
    });
  }

  _ModuleStatus _statusOf(int index) {
    if (_phase == _SyncPhase.idle) return _ModuleStatus.pending;
    if (index < _moduleIndex) return _ModuleStatus.done;
    if (index > _moduleIndex) return _ModuleStatus.pending;
    return _itemIndex >= _modules[index].items.length
        ? _ModuleStatus.done
        : _ModuleStatus.active;
  }

  bool _isExpanded(int index) =>
      _expandedOverride[index] ?? _statusOf(index) == _ModuleStatus.active;

  void _toggleExpanded(int index) =>
      setState(() => _expandedOverride[index] = !_isExpanded(index));

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));
    final queue = ref.watch(fazendasStoreProvider.select((s) => s.syncQueue));

    final finished = _phase == _SyncPhase.done;
    final syncing = _phase == _SyncPhase.syncing;
    final modules = syncing || finished ? _modules : _modulesFor(queue);
    final totalItems = modules.fold(0, (sum, m) => sum + m.items.length);
    var doneItems = 0;
    if (syncing || finished) {
      for (var i = 0; i < _moduleIndex; i++) {
        doneItems += _modules[i].items.length;
      }
      doneItems += _itemIndex;
    }

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
              value: doneItems.toDouble(),
              max: totalItems == 0 ? 1 : totalItems.toDouble(),
              size: 200,
              tone: AppGaugeTone.positive,
              valueFontSize: AppTypography.xl2 * 2,
              labelFontSize: AppTypography.xs * 2,
              label: '$doneItems/$totalItems',
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
          for (var i = 0; i < modules.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.space3),
            _ModuleCard(
              module: modules[i],
              status: _statusOf(i),
              currentItemIndex: i == _moduleIndex ? _itemIndex : 0,
              expanded: _isExpanded(i),
              onToggle: () => _toggleExpanded(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card isolado de um módulo — cabeçalho sempre visível (ícone de estado,
/// nome, contagem) e, quando expandido, a lista das funcionalidades internas
/// com o próprio estado (concluída, em andamento, pendente).
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.status,
    required this.currentItemIndex,
    required this.expanded,
    required this.onToggle,
  });

  final _SyncModule module;
  final _ModuleStatus status;

  /// Índice do item em andamento — só tem sentido quando [status] é
  /// [_ModuleStatus.active]; itens antes dele já foram enviados.
  final int currentItemIndex;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final label = kindLabel[module.kind] ?? '—';
    final done = switch (status) {
      _ModuleStatus.done => module.items.length,
      _ModuleStatus.active => currentItemIndex,
      _ModuleStatus.pending => 0,
    };

    return Container(
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        border: Border.all(color: semantic.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AppPressable(
            semanticLabel: expanded ? 'Recolher $label' : 'Expandir $label',
            onPressed: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.xl3),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space3,
              ),
              child: Row(
                children: [
                  _StatusIcon(status: status),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                  ),
                  Text(
                    '$done/${module.items.length}',
                    style: TextStyle(color: semantic.fgMuted),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: reduceMotion ? Duration.zero : AppMotion.fast,
                    child: AppIcon(
                      AppIcons.chevronDown,
                      size: AppSize.iconXs,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: reduceMotion ? Duration.zero : AppMotion.medium,
            curve: AppMotion.easingOut,
            alignment: Alignment.topCenter,
            child: !expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space3,
                      0,
                      AppSpacing.space3,
                      AppSpacing.space3,
                    ),
                    child: Column(
                      children: [
                        Divider(color: semantic.borderSubtle, height: 1),
                        const SizedBox(height: AppSpacing.space2),
                        for (var i = 0; i < module.items.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.space1,
                            ),
                            child: Row(
                              children: [
                                _ItemStatusIcon(
                                  done: status == _ModuleStatus.done ||
                                      (status == _ModuleStatus.active &&
                                          i < currentItemIndex),
                                  active: status == _ModuleStatus.active &&
                                      i == currentItemIndex,
                                ),
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: Text(
                                    module.items[i],
                                    style: TextStyle(
                                      color: semantic.fgMuted,
                                      fontSize: AppTypography.sm,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final _ModuleStatus status;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return switch (status) {
      _ModuleStatus.done => AppIcon(
        AppIcons.check,
        size: AppSize.iconSm,
        color: semantic.chartPositive,
      ),
      _ModuleStatus.active => AppSpinner(
        size: AppSize.iconXs,
        color: semantic.accentDefault,
      ),
      _ModuleStatus.pending => AppIcon(
        AppIcons.circle,
        size: AppSize.iconSm,
        color: semantic.borderDefault,
      ),
    };
  }
}

class _ItemStatusIcon extends StatelessWidget {
  const _ItemStatusIcon({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    if (done) {
      return AppIcon(
        AppIcons.check,
        size: AppSize.iconXs,
        color: semantic.chartPositive,
      );
    }
    if (active) {
      return AppSpinner(size: AppSize.iconXs, color: semantic.accentDefault);
    }
    return AppIcon(
      AppIcons.circle,
      size: AppSize.iconXs,
      color: semantic.borderDefault,
    );
  }
}
