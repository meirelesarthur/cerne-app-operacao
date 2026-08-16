import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_spacing.dart';
import '../../ui/heading.dart';
import '../../ui/icon_button.dart';

/// Espelha `SubPageHeader.tsx` — bolha circular de voltar + título centralizado
/// sobre o canvas, usado pelas páginas secundárias do shell (Perfil, Notificações, Login).
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          AppIconButton(
            label: 'Voltar',
            variant: AppIconButtonVariant.solid,
            size: AppIconButtonSize.lg,
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
          ),
          Expanded(
            child: AppHeading(
              level: AppHeadingLevel.h3,
              child: Text(title, textAlign: TextAlign.center),
            ),
          ),
          action ?? const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}
