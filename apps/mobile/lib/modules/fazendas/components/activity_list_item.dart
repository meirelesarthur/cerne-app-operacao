import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../types.dart';

/// Ícone por tipo de atividade — fonte única, reutilizado no
/// `ActivityDetailSheet` (Lei 2). Espelha `KIND_ICON` de `ActivityListItem.tsx`.
const Map<ActivityKind, IconData> kindIcon = {
  ActivityKind.pesagem: LucideIcons.scale,
  ActivityKind.evento: LucideIcons.arrowLeftRight,
  ActivityKind.nfe: LucideIcons.fileText,
  ActivityKind.venda: LucideIcons.truck,
  ActivityKind.insumo: LucideIcons.sprout,
  ActivityKind.arracoamento: LucideIcons.wheat,
};

/// Rótulo + tom de status — fonte única, reutilizado no `ActivityDetailSheet`
/// (Lei 2). Espelha `STATUS_META`.
class StatusMeta {
  const StatusMeta({required this.label, required this.tone});
  final String label;
  final AppChipTone tone;
}

const Map<ActivityStatus, StatusMeta> statusMeta = {
  ActivityStatus.andamento: StatusMeta(
    label: 'Em andamento',
    tone: AppChipTone.blue,
  ),
  ActivityStatus.concluida: StatusMeta(
    label: 'Concluída',
    tone: AppChipTone.brand,
  ),
  ActivityStatus.autorizada: StatusMeta(
    label: 'Autorizada',
    tone: AppChipTone.brand,
  ),
  ActivityStatus.atrasada: StatusMeta(label: 'Atrasada', tone: AppChipTone.red),
};

/// Item da lista "Atividades recentes" (spec §6.7) — espelha `ActivityListItem.tsx`.
class ActivityListItem extends StatelessWidget {
  const ActivityListItem({
    super.key,
    required this.activity,
    this.onTap,
    this.showDivider = true,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final icon = kindIcon[activity.kind]!;
    final status = statusMeta[activity.status]!;

    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: semantic.borderSubtle)),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: AppSpacing.space10,
            height: AppSpacing.space10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: semantic.bgSubtle,
            ),
            child: Icon(icon, size: 18, color: semantic.fgMuted),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: semantic.fgDefault,
                  ),
                ),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: semantic.fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChip(tone: status.tone, child: Text(status.label)),
              const SizedBox(height: AppSpacing.space1),
              Text(
                activity.time,
                style: TextStyle(color: semantic.fgSubtle, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.space1),
          Icon(LucideIcons.chevronRight, size: 16, color: semantic.fgSubtle),
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
