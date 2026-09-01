import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';

/// Esqueleto comum dos fluxos de pagamento do GB Bank: o mesmo arquétipo
/// *Cadastro* do padrão global que o `FlowShell` de Fazendas usa — barra
/// superior sobre o canvas, folha de conteúdo arredondada e [AppActionBar]
/// fixa —, porém sem contexto de fazenda nem fila offline (composição local,
/// Lei 1).
///
/// [totalSteps] desenha a régua do frame `Cadastro steps` (`54349:1990`): o Pix
/// é um fluxo de quatro passos e a referência resolve isso com a régua, não com
/// o texto "Passo 2 de 4" no canto do cabeçalho.
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
    this.totalSteps,
    this.currentStep = 0,
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

  /// Quantidade de etapas do fluxo, quando há mais de uma.
  final int? totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubPageHeader(title: title, onBack: onBack, action: headerAction),
            Expanded(
              child: AppContentSheet(
                padded: false,
                child: Column(
                  children: [
                    if (totalSteps != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4,
                          AppSpacing.space5,
                          AppSpacing.space4,
                          0,
                        ),
                        child: AppStepProgress(
                          total: totalSteps!,
                          current: currentStep,
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.space4),
                        child: child,
                      ),
                    ),
                    if (primaryLabel != null)
                      AppActionBar(
                        primaryLabel: primaryLabel!,
                        primaryIcon: AppIcons.saveAll,
                        onPrimary: primaryDisabled ? null : onPrimary,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
