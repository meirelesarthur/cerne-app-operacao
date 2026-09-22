import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/context_badge.dart';
import '../state/fazendas_store.dart';

/// Home do módulo Fazendas (aba Dashboard) — espelha `FazendasHome.tsx`.
/// Único perfil do app (Operacional): a home entra direto nos lançamentos de
/// campo.
class FazendasHome extends StatelessWidget {
  const FazendasHome({super.key});

  @override
  Widget build(BuildContext context) => const _HomeCampo();
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
                      icon: AppIcons.scale,
                      label: 'Pesagem',
                      caption: 'Balança conectada',
                      onTap: () => context.go('/fazendas/campo/pesagem'),
                    ),
                  ),
                  RiseIn(
                    index: 1,
                    child: AppBentoTile(
                      icon: AppIcons.arrowLeftRight,
                      label: 'Ciclo rebanho',
                      caption: 'Entradas e saídas',
                      onTap: () => context.go('/fazendas/campo/ciclo'),
                    ),
                  ),
                  RiseIn(
                    index: 2,
                    child: AppBentoTile(
                      icon: AppIcons.wheat,
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
                        icon: AppIcons.truck,
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
                        icon: AppIcons.fileText,
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
                        icon: AppIcons.sprout,
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
