import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/context_badge.dart';

/// Esqueleto comum dos fluxos operacionais (spec §5). Os 6 fluxos de campo
/// (`PesagemFlow`, `CicloRebanhoFlow`, etc.) usam este wrapper.
///
/// É o arquétipo *Cadastro* do padrão global, nas suas duas leituras do Figma:
/// `Cadastro bottom fixed` (`54300:16032`) quando o fluxo é de uma tela só, e
/// `Cadastro steps` (`54349:1990`) quando [totalSteps] é informado. A anatomia
/// é a mesma nos dois: barra superior **sobre o canvas**, folha de conteúdo
/// arredondada logo abaixo e [AppActionBar] fixa no rodapé.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o botão primário não
/// aceita mais um estado desabilitado — antes, com campo obrigatório em
/// branco, o botão simplesmente não reagia ao toque, sem explicar por quê
/// (beco sem saída, especialmente ruim para baixa instrução/uso no campo).
/// Agora o botão sempre chama [onPrimary]; cada fluxo valida ali dentro e
/// mostra o que falta preencher (ver `PesagemFlow._confirmar`, por exemplo).
class FlowShell extends ConsumerWidget {
  const FlowShell({
    super.key,
    required this.title,
    required this.child,
    this.primaryLabel,
    this.onPrimary,
    this.onBack,
    this.totalSteps,
    this.currentStep = 0,
    this.summary,
  });

  final String title;
  final Widget child;

  /// Rótulo do botão primário; o rodapé inteiro é ocultado se ausente.
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;

  /// Quantidade de etapas do fluxo. Presente, desenha a régua de passos do
  /// frame `Cadastro steps` no topo da folha.
  final int? totalSteps;
  final int currentStep;

  /// Resumo acima do CTA (o "Fornecido / Faltam" do frame *bottom fixed*).
  final Widget? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider).isOnline;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final offlineNote = isOnline
        ? null
        : const Align(
            alignment: Alignment.centerLeft,
            child: AppChip(
              tone: AppChipTone.amber,
              child: Text('Sem conexão — será enfileirado para sincronização'),
            ),
          );

    // O aviso de fila offline e o resumo do fluxo disputam a mesma faixa acima
    // do CTA. Quando os dois existem, o aviso vem primeiro: é a informação que
    // muda o significado da ação, não só o seu contexto.
    final Widget? actionBarSummary = switch ((offlineNote, summary)) {
      (null, null) => null,
      (final note?, null) => note,
      (null, final s?) => s,
      (final note?, final s?) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          note,
          const SizedBox(height: AppSpacing.space2),
          s,
        ],
      ),
    };

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubPageHeader(title: title, onBack: onBack),
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
                    const ContextBadge(),
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
                        onPrimary: onPrimary,
                        summary: actionBarSummary,
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
