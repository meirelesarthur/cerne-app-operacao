import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';

/// Tela de sucesso pós-lançamento, com resumo dos efeitos no sistema web.
/// Espelha `SuccessScreen.tsx` — usa `AppSuccessPanel` do catálogo (Lei 1).
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): a mensagem offline
/// trocou "será processado assim que a conexão voltar" (linguagem de sistema)
/// por "foi salvo no aparelho, vai subir quando pegar sinal" e mostra quantos
/// lançamentos estão nessa fila agora — confiar que "sumiu, mas está seguro"
/// é o ponto de maior ansiedade de quem lança sem conexão em campo.
class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({
    super.key,
    required this.title,
    required this.effects,
    this.queued = false,
    this.nextLabel,
    this.onNext,
  });

  final String title;

  /// Texto informativo sobre os efeitos no web (spec §5) — não executa nada real.
  final String effects;

  /// Verdadeiro quando o lançamento foi para a fila offline.
  final bool queued;

  /// Ação principal de repetição ("Pesar outro"): em lançamentos
  /// feitos em série, voltar ao início a cada item obrigava a reabrir o fluxo.
  /// Com ela, "Concluir" desce para ação secundária.
  final String? nextLabel;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final pendentes = ref.watch(
      fazendasStoreProvider.select((s) => s.syncQueue.length),
    );

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: AppContentSheet(
          child: AppSuccessPanel(
            title: queued ? 'Salvo no aparelho' : title,
            icon: queued ? AppIcons.refreshCw : AppIcons.checkCircle2,
            description: Text(
              queued
                  ? 'Vai subir sozinho quando o celular pegar sinal de novo — '
                        '$pendentes ${pendentes == 1 ? 'lançamento está' : 'lançamentos estão'} '
                        'esperando para sincronizar. $effects'
                  : effects,
            ),
            actions: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (nextLabel != null && onNext != null) ...[
                  AppButton(
                    fullWidth: true,
                    size: AppButtonSize.lg,
                    onPressed: onNext,
                    child: Text(nextLabel!),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  variant: nextLabel != null
                      ? AppButtonVariant.subtle
                      : AppButtonVariant.primary,
                  onPressed: () => context.go('/fazendas'),
                  child: const Text('Concluir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
