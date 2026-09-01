import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';

/// Espelha `Card.tsx` do protótipo React. `variant: ink` é a superfície escura
/// de destaque (hero da referência) — permanece escura nos dois temas.
///
/// Geometria do padrão global: raio [AppRadius.surface] (24), sem borda e com
/// a sombra quase imperceptível `AppShadows.tile`. A borda de 1px saiu porque
/// no Figma nenhuma superfície de conteúdo tem contorno — a separação vem só
/// da diferença entre a folha e o cartão.
/// Quando `interactive` e `onTap` estão presentes, o toque dispara ripple e o
/// widget é focável/ativável via teclado (Enter/Espaço), espelhando o
/// `role="button"` + `onKeyDown` do React.
enum AppCardVariant { surface, ink }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.interactive = false,
    this.padded = true,
    this.variant = AppCardVariant.surface,
    this.onTap,
  });

  final Widget child;
  final bool interactive;
  final bool padded;
  final AppCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isInk = variant == AppCardVariant.ink;
    final bg = isInk ? semantic.inkBg : semantic.bgRaised;
    final fg = isInk ? semantic.inkFg : null;

    Widget content = Padding(
      padding: padded
          ? const EdgeInsets.all(AppSpacing.space5)
          : EdgeInsets.zero,
      child: child,
    );

    if (fg != null) {
      content = DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: content,
      );
    }

    final radius = BorderRadius.circular(AppRadius.surface);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        boxShadow: AppShadows.tile,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: AppColors.transparent,
          child: interactive && onTap != null
              ? InkWell(onTap: onTap, child: content)
              : content,
        ),
      ),
    );
  }
}

WidgetbookComponent buildCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Card',
    useCases: [
      WidgetbookUseCase(
        name: 'Variantes',
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 280,
                child: AppCard(child: Text('Card padrão (surface)')),
              ),
              const SizedBox(height: AppSpacing.space4),
              const SizedBox(
                width: 280,
                child: AppCard(
                  variant: AppCardVariant.ink,
                  child: Text('Card ink (hero)'),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              SizedBox(
                width: 280,
                child: AppCard(
                  interactive: true,
                  onTap: () {},
                  child: const Text('Card interativo (toque)'),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
