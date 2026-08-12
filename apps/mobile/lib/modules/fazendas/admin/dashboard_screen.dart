import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shared/simulated_load.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';

/// Scaffold comum dos dashboards administrativos de Fazendas (spec §7.1) —
/// espelha `DashboardScreen.tsx`: cabeçalho, chip de "Acesso restrito", banner
/// de dados em cache quando offline e skeleton de carregamento simulado.
/// Compartilhado pelos 7 dashboards de `admin/` (Lei 2 — fonte única).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.title,
    required this.child,
    this.restricted = false,
    this.hideOfflineBanner = false,
  });

  final String title;
  final Widget child;

  /// Marca a tela como de acesso restrito (spec §4.6).
  final bool restricted;

  /// Oculta o banner de dados em cache (ex.: telas não cacheáveis offline).
  final bool hideOfflineBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubPageHeader(
          title: title,
          action: restricted
              ? const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.space1),
                  child: AppChip(
                    tone: AppChipTone.amber,
                    icon: Icon(LucideIcons.shieldAlert, size: 12),
                    child: Text('Acesso restrito'),
                  ),
                )
              : null,
        ),
        if (!isOnline && !hideOfflineBanner)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppBanner(
              icon: Icon(LucideIcons.cloudOff, size: 14),
              child: Text('Dados de 01/07 às 08:00 — última sincronização.'),
            ),
          ),
        Expanded(
          child: SimulatedLoad(
            builder: (context, loading) => loading
                ? GridView.count(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.space3,
                    crossAxisSpacing: AppSpacing.space3,
                    childAspectRatio: 1.3,
                    children: const [AppCardSkeleton(), AppCardSkeleton(), AppCardSkeleton(), AppCardSkeleton()],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: child,
                  ),
          ),
        ),
      ],
    );
  }
}
