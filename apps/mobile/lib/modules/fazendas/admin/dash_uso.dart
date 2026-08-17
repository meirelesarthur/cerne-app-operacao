import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

const _periodos = ['Hoje', '7 dias', '30 dias'];

/// Análise de Uso / Atividade (spec §4.6) — observabilidade multi-tenant.
/// Tela sensível: marcada como "Acesso restrito" no cabeçalho (via
/// `DashboardScreen`). Espelha `DashUso.tsx`.
class DashUso extends ConsumerStatefulWidget {
  const DashUso({super.key});

  @override
  ConsumerState<DashUso> createState() => _DashUsoState();
}

class _DashUsoState extends ConsumerState<DashUso> {
  String _periodo = _periodos.first;
  String? _expandido = usoFazendas.first.id;
  int _tentativa = 0;

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));

    // Dados multi-tenant em tempo real não são cacheáveis offline → estado de
    // erro com retry (spec §7.1).
    if (!isOnline) {
      return DashboardScreen(
        key: ValueKey(_tentativa),
        title: 'Análise de Uso',
        restricted: true,
        hideOfflineBanner: true,
        child: AppErrorState(
          title: 'Indisponível offline',
          description:
              'A atividade de usuários em tempo real exige conexão. Reconecte para visualizar.',
          onRetry: () => setState(() => _tentativa++),
        ),
      );
    }

    return DashboardScreen(
      title: 'Análise de Uso',
      restricted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in _periodos) ...[
                  _FiltroPill(
                    label: p,
                    selected: _periodo == p,
                    onTap: () => setState(() => _periodo = p),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Column(
            children: [
              for (final f in usoFazendas) ...[
                _FazendaTile(
                  fazenda: f,
                  open: _expandido == f.id,
                  onTap: () => setState(
                    () => _expandido = _expandido == f.id ? null : f.id,
                  ),
                ),
                if (f != usoFazendas.last)
                  const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltroPill extends StatelessWidget {
  const _FiltroPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: 'Filtrar por $label',
      selected: selected,
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: selected ? semantic.accentDefault : semantic.bgSurface,
          border: Border.all(
            color: selected ? semantic.accentDefault : semantic.borderDefault,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.weightSemibold,
            color: selected ? Colors.white : semantic.fgMuted,
          ),
        ),
      ),
    );
  }
}

class _FazendaTile extends StatelessWidget {
  const _FazendaTile({
    required this.fazenda,
    required this.open,
    required this.onTap,
  });

  final FazendaAtividade fazenda;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final onlineColor = fazenda.online > 0
        ? semantic.accentDefault
        : semantic.borderStrong;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Column(
        children: [
          AppPressable(
            semanticLabel: open
                ? 'Recolher detalhes de ${fazenda.nome}'
                : 'Expandir detalhes de ${fazenda.nome}',
            toggled: open,
            onPressed: onTap,
            minTouchTarget: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Row(
                children: [
                  Icon(LucideIcons.circle, size: 10, color: onlineColor),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fazenda.nome,
                          style: TextStyle(
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          '${fazenda.online} usuário(s) online',
                          style: TextStyle(
                            fontSize: AppTypography.base,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: semantic.fgSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Column(
              children: [
                Divider(height: 1, color: semantic.borderSubtle),
                for (final u in fazenda.usuarios)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.circle,
                          size: 8,
                          color: u.ativo
                              ? semantic.accentDefault
                              : semantic.borderStrong,
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Text(
                            u.nome,
                            style: TextStyle(
                              fontSize: AppTypography.base,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ),
                        Text(
                          u.ultimoAcesso,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
