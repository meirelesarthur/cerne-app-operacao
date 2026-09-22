import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../mocks/hub_apps.dart';

/// Home do hub agregador — espelha `HubHome.tsx`. Único perfil do app
/// (Operacional): a porta de entrada mostra direto o grid de apps
/// (Fazendas/Armazém) injetável via catálogo.
class HubHomeScreen extends StatelessWidget {
  const HubHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionTitle(child: Text('Seus apps')),
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    rightIcon: const AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconXs,
                    ),
                    onPressed: () => context.go('/inicio/apps'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 1.6,
                children: [
                  for (final app in hubApps)
                    AppMiniAppTile(
                      icon: app.icon,
                      name: app.name,
                      description: app.description,
                      badge: app.badge,
                      onTap: app.route != null
                          ? () => context.go(app.route!)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
