import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';

/// Card de deep-link de crédito pré-aprovado (spec §6.4) — espelha
/// `CreditoBanner.tsx`: o dado/régua vive no módulo Crédito; aqui é só um
/// ponto de entrada com deep link entre módulos.
class CreditoBanner extends StatelessWidget {
  const CreditoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Material(
      color: semantic.accentSubtle,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: AppPressable(
        semanticLabel: r'Abrir crédito pré-aprovado de R$ 480.000,00',
        onPressed: () => context.go('/credito'),
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl3),
            border: Border.all(color: semantic.borderTint),
          ),
          child: Row(
            children: [
              Container(
                width: AppSize.control,
                height: AppSize.control,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: semantic.accentDefault,
                ),
                child: const Icon(
                  LucideIcons.handCoins,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crédito pré-aprovado',
                      style: TextStyle(
                        fontSize: 13,
                        color: semantic.accentDefault,
                      ),
                    ),
                    Text(
                      'R\$ 480.000,00 disponíveis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Text(
                      'Ver no módulo Crédito',
                      style: TextStyle(
                        fontSize: 12,
                        color: semantic.accentDefault,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: semantic.accentDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
