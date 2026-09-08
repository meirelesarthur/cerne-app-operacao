import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';

/// Esqueleto comum dos fluxos operacionais (spec §5). Os 6 fluxos de campo
/// (`PesagemFlow`, `CicloRebanhoFlow`, etc.) usam este wrapper.
///
/// É o arquétipo *Cadastro* do padrão global, nas suas duas leituras do Figma:
/// `Cadastro bottom fixed` (`54300:16032`) quando o fluxo é de uma tela só, e
/// `Cadastro steps` (`54349:1990`) quando [totalSteps] é informado. A anatomia
/// é a mesma nos dois, e agora vem inteira de [AppPageScaffold]: faixa de
/// 64 px sobre o canvas, folha de conteúdo arredondada descendo até a base da
/// tela, régua de etapas dentro dela e [AppActionBar] fixa no rodapé. O que
/// resta aqui é o que só o operacional tem — o aviso de fila offline e o
/// resumo do fluxo, compostos na faixa acima do CTA.
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
    this.primaryLoading = false,
    this.onBack,
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.totalSteps,
    this.currentStep = 0,
    this.summary,
  });

  final String title;
  final Widget child;

  /// Rótulo do botão primário; o rodapé inteiro é ocultado se ausente.
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  /// Estado "enviando" do CTA — desabilita o botão e troca o rótulo pelo
  /// spinner do [AppButton], sem esconder o rodapé (a barra de resumo/aviso
  /// offline continua visível durante o envio).
  final bool primaryLoading;
  final VoidCallback? onBack;

  /// Ação contextual opcional no extremo direito do cabeçalho. Quando nula,
  /// o slot continua reservado para manter o título centralizado.
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Quantidade de etapas do fluxo. Presente, desenha a régua de passos do
  /// frame `Cadastro steps` no topo da folha.
  final int? totalSteps;
  final int currentStep;

  /// Resumo acima do CTA (o "Fornecido / Faltam" do frame *bottom fixed*).
  final Widget? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(shellStoreProvider).isOnline;

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

    return AppPageScaffold(
      title: title,
      onBack: onBack ?? () => Navigator.of(context).maybePop(),
      actionIcon: actionIcon,
      actionLabel: actionLabel,
      onAction: onAction,
      totalSteps: totalSteps,
      currentStep: currentStep,
      actionBar: primaryLabel == null
          ? null
          : AppActionBar(
              primaryLabel: primaryLabel!,
              primaryIcon: AppIcons.saveAll,
              primaryLoading: primaryLoading,
              onPrimary: onPrimary,
              summary: actionBarSummary,
            ),
      child: child,
    );
  }
}
