import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../state/fazendas_store.dart';
import '../types.dart';

/// Switch de Visão Gerencial ⇄ Campo (spec §3.3) — espelha `ViewSwitch.tsx`:
/// segmented control abaixo do header do módulo. "Gerencial" = Administrativa
/// (leitura); "Campo" = Operacional (escrita).
///
/// Este widget será importado pelo `AppRevealMenu`
/// (`shell/components/reveal_menu.dart`, ver `// TODO F4: ViewSwitch do
/// módulo Fazendas`) por outro processo — não editado aqui.
class ViewSwitch extends ConsumerWidget {
  const ViewSwitch({super.key, this.onChanged});

  final ValueChanged<FarmView>? onChanged;

  static const _options = [
    (
      value: FarmView.gerencial,
      label: 'Gerencial',
      icon: LucideIcons.layoutDashboard,
    ),
    (value: FarmView.campo, label: 'Campo', icon: LucideIcons.clipboardList),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(fazendasStoreProvider.select((s) => s.view));
    final notifier = ref.read(fazendasStoreProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opt in _options)
            _Segment(
              label: opt.label,
              icon: opt.icon,
              active: view == opt.value,
              onTap: () {
                notifier.setView(opt.value);
                onChanged?.call(opt.value);
              },
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active
                    ? semantic.accentDefault
                    : Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? semantic.accentDefault
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
