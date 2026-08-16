import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../components/context_badge.dart';
import '../components/credito_banner.dart';
import '../components/shortcut_grid.dart';
import '../mocks/atividades.dart';
import '../state/fazendas_store.dart';
import '../types.dart';

/// Home do módulo Fazendas (aba Dashboard) — espelha `FazendasHome.tsx`:
/// alterna conteúdo entre a visão Gerencial (leitura) e Campo (escrita) via
/// `fazendasStoreProvider`.
class FazendasHome extends ConsumerWidget {
  const FazendasHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(fazendasStoreProvider.select((s) => s.view));
    return view == FarmView.gerencial
        ? const _HomeGerencial()
        : const _HomeCampo();
  }
}

class _HomeGerencial extends StatelessWidget {
  const _HomeGerencial();

  @override
  Widget build(BuildContext context) {
    final adminShortcuts = [
      Shortcut(
        id: 'financeiro',
        label: 'Financeiro',
        icon: LucideIcons.wallet,
        onTap: () => context.go('/fazendas/dashboards/financeiro'),
      ),
      Shortcut(
        id: 'pecuaria',
        label: 'Pecuária',
        icon: LucideIcons.beef,
        onTap: () => context.go('/fazendas/dashboards/pecuaria'),
      ),
      Shortcut(
        id: 'confinamento',
        label: 'Currais',
        icon: LucideIcons.warehouse,
        onTap: () => context.go('/fazendas/dashboards/confinamento'),
      ),
      Shortcut(
        id: 'ativos',
        label: 'Ativos',
        icon: LucideIcons.package,
        onTap: () => context.go('/fazendas/dashboards/ativos'),
      ),
      Shortcut(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        onTap: () => context.go('/fazendas/mais'),
      ),
    ];

    return _ActivityAwareList(
      builder: (context, onActivityTap) => ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          const RiseIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  level: AppHeadingLevel.h3,
                  child: Text('Resumo da safra'),
                ),
                _SafraPill(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 1,
            child: ShortcutGrid(items: adminShortcuts, columns: 5),
          ),
          const SizedBox(height: AppSpacing.space4),
          const RiseIn(index: 2, child: CreditoBanner()),
          const SizedBox(height: AppSpacing.space4),
          const RiseIn(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: AppDashboardCard(
                    icon: LucideIcons.wallet,
                    label: 'Receita',
                    value: 'R\$ 2,4 mi',
                    delta: 12,
                    spark: [8, 10, 9, 12, 14, 13, 16],
                  ),
                ),
                SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: AppDashboardCard(
                    icon: LucideIcons.package,
                    label: 'Custo',
                    value: 'R\$ 1,1 mi',
                    delta: -4,
                    spark: [9, 8, 8, 7, 6, 7, 6],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          const RiseIn(
            index: 4,
            child: AppDashboardCard(
              icon: LucideIcons.beef,
              label: 'Margem operacional',
              value: 'R\$ 1,3 mi',
              delta: 9,
              spark: [4, 6, 5, 7, 8, 9, 11],
              variant: AppDashboardCardVariant.finance,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppSectionTitle(child: Text('Atividades recentes')),
                    AppButton(
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      rightIcon: const Icon(LucideIcons.arrowRight, size: 13),
                      onPressed: () => context.go('/fazendas/atividades'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Builder(
                  builder: (context) {
                    final semantic = Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!;
                    final recentes = atividades.take(4).toList();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: semantic.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xl3),
                        border: Border.all(color: semantic.borderDefault),
                      ),
                      child: Column(
                        children: [
                          for (final a in recentes)
                            ActivityListItem(
                              activity: a,
                              showDivider: a != recentes.last,
                              onTap: () => onActivityTap(a),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encapsula o acionamento do `ActivityDetailSheet` — equivalente ao
/// `useState<Activity | null>` do React, sem precisar de `StatefulWidget` na
/// tela inteira (o bottom sheet já é a fonte de estado "aberto/fechado").
class _ActivityAwareList extends StatelessWidget {
  const _ActivityAwareList({required this.builder});

  final Widget Function(
    BuildContext context,
    void Function(Activity activity) onActivityTap,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      (activity) => showActivityDetailSheet(context, activity: activity),
    );
  }
}

class _SafraPill extends StatelessWidget {
  const _SafraPill();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: semantic.borderDefault),
        color: semantic.bgSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Safra 24/25',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          Icon(LucideIcons.chevronDown, size: 14, color: semantic.fgDefault),
        ],
      ),
    );
  }
}

class _HomeCampo extends ConsumerWidget {
  const _HomeCampo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncQueue = ref.watch(
      fazendasStoreProvider.select((s) => s.syncQueue),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ContextBadge(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            children: [
              RiseIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeading(
                      level: AppHeadingLevel.h3,
                      child: Text('Lançamentos de campo'),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Builder(
                      builder: (context) => Text(
                        'Escolha o tipo de registro para começar.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).extension<AppSemanticColors>()!.fgMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                children: [
                  RiseIn(
                    child: AppBentoTile(
                      icon: LucideIcons.scale,
                      label: 'Pesagem',
                      caption: 'Balança conectada',
                      onTap: () => context.go('/fazendas/campo/pesagem'),
                    ),
                  ),
                  RiseIn(
                    index: 1,
                    child: AppBentoTile(
                      icon: LucideIcons.arrowLeftRight,
                      label: 'Ciclo rebanho',
                      caption: 'Entradas e saídas',
                      onTap: () => context.go('/fazendas/campo/ciclo'),
                    ),
                  ),
                  RiseIn(
                    index: 2,
                    child: AppBentoTile(
                      icon: LucideIcons.wheat,
                      label: 'Arraçoamento',
                      caption: 'Trato do dia',
                      onTap: () => context.go('/fazendas/campo/arracoamento'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              // Sem `stretch`: cada tile tem altura própria (com `iconSize:
              // lg`, "Venda" naturalmente fica um pouco mais alto que
              // "Entrada NF-e") — `stretch` num Row dentro de um ListView
              // (altura vertical não limitada) pede altura infinita e quebra
              // o layout.
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RiseIn(
                      index: 3,
                      child: AppBentoTile(
                        icon: LucideIcons.truck,
                        label: 'Venda',
                        caption: 'GTA, romaneio e frete',
                        iconSize: AppBentoTileIconSize.lg,
                        onTap: () => context.go('/fazendas/campo/venda'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: RiseIn(
                      index: 4,
                      child: AppBentoTile(
                        icon: LucideIcons.fileText,
                        label: 'Entrada NF-e',
                        caption: 'Importar XML',
                        variant: AppBentoTileVariant.accent,
                        onTap: () => context.go('/fazendas/campo/recebimento'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RiseIn(
                      index: 5,
                      child: AppBentoTile(
                        icon: LucideIcons.sprout,
                        label: 'Insumos',
                        caption: 'Aplicações e retiradas',
                        onTap: () => context.go('/fazendas/campo/insumos'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    flex: 2,
                    child: RiseIn(
                      index: 6,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: AppSectionTitle(
                                    child: Text(
                                      'Fila de sincronização',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                AppChip(
                                  tone: syncQueue.isEmpty
                                      ? AppChipTone.brand
                                      : AppChipTone.amber,
                                  child: Text(
                                    syncQueue.isEmpty
                                        ? 'Tudo sincronizado'
                                        : '${syncQueue.length} pendente(s)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Builder(
                              builder: (context) => Text(
                                syncQueue.isEmpty
                                    ? 'Nenhum lançamento aguardando envio.'
                                    : 'Lançamentos feitos offline serão enviados quando a conexão voltar.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).extension<AppSemanticColors>()!.fgMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
