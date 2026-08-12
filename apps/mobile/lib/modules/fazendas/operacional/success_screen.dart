import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';

/// Tela de sucesso pós-lançamento, com resumo dos efeitos no sistema web.
/// Espelha `SuccessScreen.tsx` — usa `AppSuccessPanel` do catálogo (Lei 1).
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.title, required this.effects, this.queued = false});

  final String title;

  /// Texto informativo sobre os efeitos no web (spec §5) — não executa nada real.
  final String effects;

  /// Verdadeiro quando o lançamento foi para a fila offline.
  final bool queued;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: AppSuccessPanel(
          title: queued ? 'Enviado para sincronização' : title,
          icon: queued ? LucideIcons.refreshCw : LucideIcons.checkCircle2,
          description: Text(
            queued ? 'O lançamento será processado assim que a conexão voltar. $effects' : effects,
          ),
          actions: AppButton(
            fullWidth: true,
            onPressed: () => context.go('/fazendas'),
            child: const Text('Voltar ao início'),
          ),
        ),
      ),
    );
  }
}
