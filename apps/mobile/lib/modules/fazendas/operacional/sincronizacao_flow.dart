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
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';
import 'flow_shell.dart';

/// Um módulo (grupo do catálogo funcional, ex.: Confinamento) e as
/// funcionalidades internas que ele contém — o card da tela de sincronização
/// expande para revelar esta lista, uma a uma.
class _SyncModule {
  const _SyncModule({required this.group, required this.items});

  final String group;
  final List<String> items;
}

/// Agrupa `operationalFeatures` por `group` — mesma fonte e mesma ordem que a
/// central operacional ([ResponsibilityWorkspace]) usa para os cards de
/// módulo (Lei 2 — fonte única). `Sincronização` fica de fora: é o próprio
/// grupo desta tela, não algo que ela sincroniza.
List<_SyncModule> _buildSyncModules() {
  final byGroup = <String, List<String>>{};
  for (final feature in operationalFeatures) {
    if (feature.group == 'Sincronização') continue;
    (byGroup[feature.group] ??= []).add(feature.title);
  }
  final insertionOrder = byGroup.keys.toList();
  final orderedGroups = [...insertionOrder]
    ..sort((a, b) {
      final byOrder = groupOrder(a).compareTo(groupOrder(b));
      if (byOrder != 0) return byOrder;
      return insertionOrder.indexOf(a).compareTo(insertionOrder.indexOf(b));
    });
  return [
    for (final group in orderedGroups)
      _SyncModule(group: group, items: byGroup[group]!),
  ];
}

final _syncModules = _buildSyncModules();

enum _SyncPhase { idle, syncing, done }

enum _ModuleStatus { pending, active, done }

/// Sincronização de dados (feature `sincronizacao`): envia cada módulo
/// operacional do catálogo (Confinamento, Pecuária, Agricultura...) para a
/// nuvem, um de cada vez. Cada módulo é um card isolado que expande enquanto
/// está enviando — mostrando cada funcionalidade interna — e recolhe assim
/// que termina, liberando o próximo. Qualquer card pode ser reaberto a
/// qualquer momento para conferir exatamente onde a sincronização passou.
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
  static const _tickInterval = Duration(milliseconds: 180);

  Timer? _timer;
  _SyncPhase _phase = _SyncPhase.idle;
  int _moduleIndex = 0;
  int _itemIndex = 0;
  final Map<int, bool> _expandedOverride = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
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
      final current = _syncModules[_moduleIndex];
      final isLastModule = _moduleIndex == _syncModules.length - 1;
      final nextItemIndex = _itemIndex + 1;

      if (nextItemIndex >= current.items.length) {
        if (isLastModule) {
          // A tela sincroniza os módulos do catálogo, mas a fila offline
          // real (lançamentos de campo enfileirados por outros fluxos)
          // continua existindo — concluir aqui também a esvazia.
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
    return _itemIndex >= _syncModules[index].items.length
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

    final finished = _phase == _SyncPhase.done;
    final syncing = _phase == _SyncPhase.syncing;
    final totalItems = _syncModules.fold(0, (sum, m) => sum + m.items.length);
    var doneItems = 0;
    if (syncing || finished) {
      for (var i = 0; i < _moduleIndex; i++) {
        doneItems += _syncModules[i].items.length;
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
        _SyncPhase.idle => isOnline ? _start : null,
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
          for (var i = 0; i < _syncModules.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.space3),
            _ModuleCard(
              module: _syncModules[i],
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
    final label = groupDisplayLabel(module.group);
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
