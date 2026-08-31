import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/activity_list_item.dart' show kindIcon;
import '../state/fazendas_store.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Tela "Fila de sincronização" (spec §3.2/§6.9) — espelha
/// `SyncQueueScreen.tsx`: lista os lançamentos ainda não enviados ao servidor.
class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));
    final queue = ref.watch(fazendasStoreProvider.select((s) => s.syncQueue));
    final notifier = ref.read(fazendasStoreProvider.notifier);

    return Column(
      children: [
        const SubPageHeader(title: 'Fila de sincronização'),
        if (queue.isNotEmpty && !isOnline)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppBanner(
              tone: AppBannerTone.offline,
              icon: AppIcon(AppIcons.cloudOff, size: 14),
              child: Text(
                'Sem conexão — os itens serão enviados automaticamente assim que a internet voltar.',
              ),
            ),
          ),
        Expanded(
          child: queue.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: AppIcons.inbox,
                    title: 'Nenhum lançamento pendente',
                    description:
                        'Tudo o que foi registrado em campo já está sincronizado com o servidor.',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  children: [
                    Container(
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
                          for (final item in queue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.space3,
                              ),
                              decoration: item != queue.last
                                  ? BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: semantic.borderSubtle,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Row(
                                children: [
                                  Container(
                                    width: AppSpacing.space10,
                                    height: AppSpacing.space10,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: semantic.bgSubtle,
                                    ),
                                    child: AppIcon(
                                      kindIcon[item.kind],
                                      size: 18,
                                      color: semantic.fgMuted,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.space3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight:
                                                AppTypography.weightSemibold,
                                            color: semantic.fgDefault,
                                          ),
                                        ),
                                        Text(
                                          item.detail,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: semantic.fgMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const AppChip(
                                    tone: AppChipTone.amber,
                                    child: Text('Pendente'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    AppButton(
                      fullWidth: true,
                      onPressed: isOnline ? notifier.clearSync : null,
                      child: const Text('Sincronizar agora'),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
