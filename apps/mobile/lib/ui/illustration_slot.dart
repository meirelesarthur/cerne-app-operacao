import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/theme/app_theme_extension.dart';
import '../design/generated/app_layout.dart';

/// Espelha `IllustrationSlot.tsx` — área de ilustração (onboarding/empty states).
/// Com [src], a arte final é autocontida (a ilustração já traz o próprio fundo).
/// Sem [src], renderiza o fallback tokenizado: bolha ink com o ícone do tema.
class AppIllustrationSlot extends StatelessWidget {
  const AppIllustrationSlot({
    super.key,
    this.src,
    required this.alt,
    this.icon,
    this.maxSize = 280,
  });

  /// Caminho do asset da ilustração gerada (ex.: `assets/illustrations/onboarding-1.png`).
  /// Sem [src], mostra o fallback com [icon].
  final String? src;

  /// Descrição acessível da ilustração (equivalente ao `alt`/`aria-label` do React).
  final String alt;

  /// Ícone de fallback enquanto a arte final não existe.
  final AppIconData? icon;

  final double maxSize;

  @override
  Widget build(BuildContext context) {
    if (src != null) {
      return Semantics(
        label: alt,
        image: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxSize),
          child: Image.asset(src!, fit: BoxFit.contain, width: double.infinity),
        ),
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      label: alt,
      image: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize),
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: icon == null
                ? const SizedBox.shrink()
                : Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: semantic.inkBg,
                      borderRadius: BorderRadius.circular(AppRadius.xl4),
                      boxShadow: semantic.shadowCard,
                    ),
                    alignment: Alignment.center,
                    // O traço vem de `AppSize.iconStroke` (1.2) como em todo o app —
                    // `AppIcon` o aplica; nenhuma tela ou componente define o seu.
                    child: AppIcon(
                      icon,
                      size: AppSize.iconXxl,
                      color: semantic.ctaBg,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildIllustrationSlotWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'IllustrationSlot',
    useCases: [
      WidgetbookUseCase(
        name: 'Fallback com ícone',
        builder: (context) => const Center(
          child: AppIllustrationSlot(
            alt: 'Onboarding — boas-vindas',
            icon: AppIcons.sprout,
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem ícone (vazio)',
        builder: (context) =>
            const Center(child: AppIllustrationSlot(alt: 'Estado vazio')),
      ),
    ],
  );
}
