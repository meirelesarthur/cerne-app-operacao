import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/generated/app_typography.dart';
import 'design/theme/app_theme.dart';
import 'design/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: CerneApp()));
}

/// Raiz do app — F0/F1: ainda sem shell/navegação (chegam na F3).
/// Ponto de entrada temporário até o `ShellRoute` (go_router) da F3.
class CerneApp extends ConsumerWidget {
  const CerneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(themeVariantProvider);
    return MaterialApp(
      title: 'GB CERNE',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(variant),
      home: const _FundacaoPlaceholder(),
    );
  }
}

class _FundacaoPlaceholder extends ConsumerWidget {
  const _FundacaoPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(themeVariantProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('GB CERNE — Fundação (F0/F1)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tokens e tema prontos.\nShell chega na F3.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppTypography.lg, fontWeight: AppTypography.weightMedium),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.read(themeVariantProvider.notifier).toggle(),
              child: Text('Variante atual: ${variant.name}'),
            ),
          ],
        ),
      ),
    );
  }
}
