import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../components/sub_page_header.dart';

/// Página secundária (Perfil, Notificações, Login) antes de ganhar conteúdo real
/// — essas telas específicas não fazem parte do escopo do shell/navegação (F3);
/// chegam com os módulos correspondentes (F4/F6). Aqui só provam que a rota existe
/// e volta corretamente.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            SubPageHeader(title: title),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Text('$title — conteúdo chega com o módulo correspondente.', textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
