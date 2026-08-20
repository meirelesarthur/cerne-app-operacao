import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `QuickAction.tsx` (New-UI hub): círculo de 56px (`AppSpacing.space14`)
/// com rótulo abaixo — usado nas ações rápidas do hub. Ícone fixo em 21px,
/// espelhando `<Icon size={21} strokeWidth={1.9} />` do React.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o círculo era um
/// verde bem claro (`accentSubtle`) quase da mesma família de cor do ícone —
/// pouco contraste. Virou `bgSurface` (branco) + sombra de cartão, com o
/// ícone verde como único acento colorido — o círculo se destaca do canvas
/// em vez de se misturar com o próprio ícone.
class AppQuickAction extends StatelessWidget {
  const AppQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  /// Ícone fixo — equivalente ao `icon: LucideIcon` do React (ex.: `LucideIcons.wallet`).
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.space14,
              height: AppSpacing.space14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.bgSurface,
                boxShadow: semantic.shadowCard,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 21, color: semantic.accentDefault),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.weightSemibold,
                height: AppTypography.lineHeightTight,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildQuickActionWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'QuickAction',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => Center(
          child: Wrap(
            spacing: 20,
            children: [
              AppQuickAction(
                icon: LucideIcons.wallet,
                label: 'Carteira',
                onPressed: () {},
              ),
              AppQuickAction(
                icon: LucideIcons.send,
                label: 'Transferir',
                onPressed: () {},
              ),
              AppQuickAction(
                icon: LucideIcons.qrCode,
                label: 'Pagar com QR Code',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
