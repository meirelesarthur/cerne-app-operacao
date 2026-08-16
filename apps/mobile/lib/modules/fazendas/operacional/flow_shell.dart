import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/context_badge.dart';

/// Esqueleto comum dos fluxos operacionais (spec §5): header + badge de
/// contexto (fazenda) + conteúdo + rodapé fixo com botão primário. Mostra chip
/// de fila offline quando sem conexão. Espelha `FlowShell.tsx` — os 6 fluxos de
/// campo (`PesagemFlow`, `CicloRebanhoFlow`, etc.) usam este wrapper.
class FlowShell extends ConsumerWidget {
  const FlowShell({
    super.key,
    required this.title,
    required this.child,
    this.primaryLabel,
    this.onPrimary,
    this.primaryDisabled = false,
    this.onBack,
  });

  final String title;
  final Widget child;

  /// Rótulo do botão primário; o rodapé inteiro é ocultado se ausente.
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryDisabled;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider).isOnline;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            SubPageHeader(title: title, onBack: onBack),
            const ContextBadge(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: child,
              ),
            ),
            if (primaryLabel != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: semantic.bgSurface,
                  border: Border(
                    top: BorderSide(color: semantic.borderDefault),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOnline)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.space2),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AppChip(
                            tone: AppChipTone.amber,
                            child: Text(
                              'Sem conexão — será enfileirado para sincronização',
                            ),
                          ),
                        ),
                      ),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: primaryDisabled ? null : onPrimary,
                      child: Text(primaryLabel!),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
