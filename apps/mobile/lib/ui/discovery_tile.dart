import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Card de descoberta usado nos trilhos de acesso rápido e busca otimizada.
/// A mesma anatomia aparece na home administrativa e nas seções de produtos
/// da busca: ícone de 32 px no topo, nome na base e rolagem horizontal.
class AppDiscoveryTile extends StatelessWidget {
  const AppDiscoveryTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.width = 128,
    this.height = 132,
  });

  final AppIconData icon;
  final String label;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: label,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, size: AppSize.iconXxl, color: semantic.fgSecondary),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.xl,
                fontWeight: AppTypography.weightMedium,
                height: AppTypography.lineHeightTight,
                color: semantic.fgDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildDiscoveryTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'DiscoveryTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Trilho de produtos',
        builder: (context) => SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, index) => AppDiscoveryTile(
              icon: [
                AppIcons.sprout,
                AppIcons.boxes,
                AppIcons.store,
                AppIcons.openFinance,
              ][index],
              label: [
                'Fazendas',
                'Gestão de Estoque',
                'Marketplace',
                'Open Finance',
              ][index],
              onTap: () {},
            ),
          ),
        ),
      ),
    ],
  );
}
