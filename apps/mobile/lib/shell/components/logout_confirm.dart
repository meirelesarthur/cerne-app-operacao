import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/fazendas/state/fazendas_store.dart';
import '../../ui/ui.dart';

/// Pergunta antes de encerrar a sessão — "Sair" fica no fim do menu e é fácil
/// de tocar sem querer. Com lançamentos ainda não enviados, avisa quantos
/// ficam esperando no aparelho.
Future<bool> confirmLogout(BuildContext context, WidgetRef ref) {
  final pending = ref.read(fazendasStoreProvider).syncQueue.length;
  final message = switch (pending) {
    0 => 'Você vai precisar entrar de novo com seu e-mail e sua senha.',
    1 =>
      'Você tem 1 lançamento que ainda não foi enviado. Ele fica guardado '
          'neste celular até você entrar de novo e enviar.',
    _ =>
      'Você tem $pending lançamentos que ainda não foram enviados. Eles ficam '
          'guardados neste celular até você entrar de novo e enviar.',
  };
  return showAppConfirm(
    context,
    title: 'Sair do aplicativo?',
    message: message,
    confirmLabel: 'Sair',
    cancelLabel: 'Continuar no aplicativo',
    danger: pending > 0,
  );
}
