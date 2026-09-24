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

    // Tela de resultado padrão (faixa colorida + selo): verde quando foi
    // para o sistema, âmbar quando ficou guardado no aparelho sem internet.
    // A faixa sobe por trás da barra de status, então só o rodapé respeita a
    // área segura.
    return Scaffold(
      backgroundColor: semantic.bgSurface,
      body: SafeArea(
        top: false,
        child: AppSuccessPanel(
          kind: queued ? AppResultKind.pending : AppResultKind.created,
          title: queued ? 'Salvo no celular' : title,
          description: Text(
            queued
                ? 'Sem internet agora. Fica guardado e é enviado quando o '
                      'sinal voltar — '
                      '$pendentes ${pendentes == 1 ? 'lançamento esperando' : 'lançamentos esperando'}. '
                      '$effects'
                : effects,
          ),
          // Repetir (contorno) em cima e seguir (CTA) embaixo, como no padrão.
          actions: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nextLabel != null && onNext != null) ...[
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  variant: AppButtonVariant.outline,
                  onPressed: onNext,
                  child: Text(nextLabel!.toUpperCase()),
                ),
                const SizedBox(height: AppSpacing.space3),
              ],
              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: () => context.go('/fazendas'),
                child: const Text('CONCLUIR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
