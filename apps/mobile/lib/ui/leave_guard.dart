import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import 'button.dart';
import 'modal.dart';

/// Protege uma tela com dados preenchidos contra a saída acidental: com
/// [active] ligado, voltar (botão da barra, gesto ou botão do sistema)
/// pergunta antes de descartar o que a pessoa digitou.
///
/// Só intercepta saídas que passam por `Navigator.maybePop` — é o que o botão
/// voltar da faixa, o gesto e o botão do sistema usam. Um "Cancelar" de tela
/// deve chamar `Navigator.maybePop(context)` para cair na mesma pergunta.
class AppLeaveGuard extends StatelessWidget {
  const AppLeaveGuard({
    super.key,
    required this.active,
    required this.child,
    this.title = 'Sair sem salvar?',
    this.message = 'O que você preencheu nesta tela será perdido.',
    this.confirmLabel = 'Sair sem salvar',
    this.cancelLabel = 'Continuar preenchendo',
  });

  /// `true` quando há algo preenchido que ainda não foi salvo.
  final bool active;
  final Widget child;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !active,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await showAppConfirm(
          context,
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          danger: true,
        );
        // `pop` direto (e não `maybePop`) para não reabrir a pergunta.
        if (leave && context.mounted) Navigator.of(context).pop(result);
      },
      child: child,
    );
  }
}

WidgetbookComponent buildLeaveGuardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'LeaveGuard',
    useCases: [
      WidgetbookUseCase(
        name: 'Formulário preenchido',
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: AppButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AppLeaveGuard(
                    active: true,
                    child: Scaffold(
                      body: Center(
                        child: AppButton(
                          variant: AppButtonVariant.secondary,
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Abrir formulário preenchido'),
            ),
          ),
        ),
      ),
    ],
  );
}
