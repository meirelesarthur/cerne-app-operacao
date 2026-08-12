import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../state/fazendas_store.dart';

/// Badge de contexto fixo no topo de formulários operacionais (spec §3.5):
/// "Lançando em: {fazenda}" — mantém o tenant sempre visível (mitigação de UX
/// p/ IDOR). Espelha `ContextBadge.tsx`. Usado por `FlowShell` (fluxos
/// operacionais) e demais telas do módulo Fazendas.
class ContextBadge extends ConsumerWidget {
  const ContextBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFarm = ref.watch(fazendasStoreProvider.select((s) => s.activeFarm));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
      decoration: const BoxDecoration(
        color: AppColors.brand50,
        border: Border(bottom: BorderSide(color: AppColors.brand200)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.mapPin, size: 14, color: AppColors.brand700),
          const SizedBox(width: AppSpacing.space1),
          Flexible(
            child: Text(
              'Lançando em: ${activeFarm.name}',
              style: const TextStyle(fontSize: AppTypography.sm, fontWeight: AppTypography.weightSemibold, color: AppColors.brand700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
