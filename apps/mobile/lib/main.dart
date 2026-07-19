import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/theme/app_theme.dart';
import 'design/theme/theme_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: CerneApp()));
}

/// Raiz do app — `MaterialApp.router` sobre o `appRouter` (F3: ShellRoute + go_router).
class CerneApp extends ConsumerWidget {
  const CerneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(themeVariantProvider);
    return MaterialApp.router(
      title: 'GB CERNE',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(variant),
      routerConfig: appRouter,
    );
  }
}
