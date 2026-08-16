import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';

/// Espelha `BankFlowShell.tsx` — esqueleto comum dos fluxos de pagamento do
/// GB Bank: header com voltar + conteúdo rolável + rodapé com botão primário
/// (ocultado quando [primaryLabel] é nulo). Equivalente ao FlowShell de
/// Fazendas, porém sem contexto de fazenda/fila offline (composição local, Lei 1).
class BankFlowShell extends StatelessWidget {
  const BankFlowShell({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.primaryLabel,
    this.onPrimary,
    this.primaryDisabled = false,
    this.headerAction,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  /// Rótulo do botão primário; ocultado se ausente.
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryDisabled;

  /// Ação opcional no canto do header (ex.: passo atual).
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Column(
        children: [
          SubPageHeader(title: title, onBack: onBack, action: headerAction),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: child,
            ),
          ),
          if (primaryLabel != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: semantic.bgSurface,
                border: Border(top: BorderSide(color: semantic.borderDefault)),
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  onPressed: primaryDisabled ? null : onPrimary,
                  child: Text(primaryLabel!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
