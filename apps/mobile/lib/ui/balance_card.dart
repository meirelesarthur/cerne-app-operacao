import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `BalanceCard.tsx` (Nova UI / Banking): cápsula ink escura nos dois
/// temas — o hero da referência — com glow da marca, números tabulares e
/// toggle de visibilidade com touch target de 44px (`AppSize.control`).
/// Skeleton interno preserva o layout enquanto `loading` é true.
class AppBalanceCard extends StatelessWidget {
  const AppBalanceCard({
    super.key,
    this.label = 'Saldo disponível',
    required this.value,
    this.accountLabel,
    this.hidden = false,
    this.onToggleHidden,
    this.loading = false,
    this.footer,
  });

  final String label;
  final String value;
  final String? accountLabel;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final bool loading;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      label: label,
      container: true,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: semantic.inkBg,
          borderRadius: BorderRadius.circular(AppRadius.xl3),
          boxShadow: semantic.shadowCard,
        ),
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // glow radial sutil da marca — profundidade sem ruído.
            Positioned(
              right: -40,
              top: -64,
              child: IgnorePointer(
                child: Container(
                  width: 176,
                  height: 176,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppComponentColors.hubBankCardGlow,
                        AppColors.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppSize.iconBtnMd,
                      height: AppSize.iconBtnMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: semantic.inkBubble,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.landmark,
                        size: 17,
                        color: semantic.inkFg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: AppTypography.md,
                              fontWeight: AppTypography.weightMedium,
                              color: semantic.inkMuted,
                            ),
                          ),
                          if (accountLabel != null)
                            Text(
                              accountLabel!,
                              style: TextStyle(
                                fontSize: AppTypography.xs,
                                color: semantic.inkSubtle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (onToggleHidden != null)
                      Semantics(
                        button: true,
                        toggled: hidden,
                        label: hidden ? 'Mostrar saldo' : 'Ocultar saldo',
                        child: Material(
                          color: AppColors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onToggleHidden,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: AppSize.control,
                              height: AppSize.control,
                              child: Icon(
                                hidden ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 20,
                                color: semantic.inkFg,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                SizedBox(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: loading
                        ? FractionallySizedBox(
                            widthFactor: 2 / 3,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: semantic.inkBubble,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            hidden ? '••••••' : value,
                            style: TextStyle(
                              fontSize: AppTypography.xl4,
                              fontWeight: AppTypography.weightBold,
                              height: AppTypography.lineHeightTight,
                              color: semantic.inkFg,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                  ),
                ),
                if (footer != null)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.space4),
                    padding: const EdgeInsets.only(top: AppSpacing.space3),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: semantic.inkLine)),
                    ),
                    child: footer,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Coluna de resumo para o footer do [AppBalanceCard] (ex.: entradas/saídas do mês).
class AppBalanceSummaryItem extends StatelessWidget {
  const AppBalanceSummaryItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.hidden = false,
  });

  final Widget? icon;
  final String label;
  final String value;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Container(
            width: AppSize.iconBtnSm,
            height: AppSize.iconBtnSm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: semantic.inkBubble,
            ),
            alignment: Alignment.center,
            child: IconTheme.merge(
              data: IconThemeData(color: semantic.inkFg, size: 16),
              child: icon!,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.inkMuted,
                ),
              ),
              Text(
                hidden ? '••••' : value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.inkFg,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildBalanceCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'BalanceCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => Center(
          child: SizedBox(
            width: 340,
            child: AppBalanceCard(
              value: 'R\$ 128.450,32',
              accountLabel: 'Conta GB Bank · Ag 0001',
              onToggleHidden: () {},
              footer: const Row(
                children: [
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: Icon(LucideIcons.arrowDownLeft),
                      label: 'Entradas',
                      value: 'R\$ 32.100,00',
                    ),
                  ),
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: Icon(LucideIcons.arrowUpRight),
                      label: 'Saídas',
                      value: 'R\$ 11.240,00',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 340,
                child: AppBalanceCard(value: 'R\$ 128.450,32', loading: true),
              ),
              const SizedBox(height: AppSpacing.space4),
              SizedBox(
                width: 340,
                child: AppBalanceCard(
                  value: 'R\$ 128.450,32',
                  hidden: true,
                  onToggleHidden: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
