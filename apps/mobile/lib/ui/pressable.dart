import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';

/// Superfície interativa sem aparência própria, com semântica, foco, ripple e
/// alvo mínimo centralizados no catálogo.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onPressed,
    this.borderRadius,
    this.minTouchTarget = true,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final bool minTouchTarget;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl2);
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        canRequestFocus: onPressed != null,
        child: child,
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: minTouchTarget
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppSpacing.space12,
                minHeight: AppSpacing.space12,
              ),
              child: content,
            )
          : content,
    );
  }
}

WidgetbookComponent buildPressableWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Pressable',
    useCases: [
      WidgetbookUseCase(
        name: 'Superfície acessível',
        builder: (context) => Center(
          child: AppPressable(
            semanticLabel: 'Abrir detalhe da fazenda',
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: Text('Toque, Enter ou Espaço'),
            ),
          ),
        ),
      ),
    ],
  );
}
