import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_motion.dart';

const _periodos = ['Hoje', '7 dias', '30 dias'];

/// Painel **Adoção & Governança** (spec §4.6) — observabilidade multi-tenant.
///
/// Era uma lista expansível de usuários, sem nenhum indicador. Ganhou o topo de
/// KPI, a leitura de adoção por fazenda e a trilha de auditoria: as exportações
/// de log existiam no catálogo (`auditExport`) sem casa visual própria, e
/// adoção e auditoria são a mesma pergunta de governança. Tela sensível:
/// marcada como "Acesso restrito" no cabeçalho (via `DashboardScreen`).
/// Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
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
        title: 'Adoção & Governança',
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

    final totalOnline = usoFazendas.fold<int>(0, (s, f) => s + f.online);
    final totalUsuarios = usoFazendas.fold<int>(
      0,
      (s, f) => s + f.usuarios.length,
    );
    final fazendasAtivas = usoFazendas.where((f) => f.online > 0).length;
    final adocaoPct = totalUsuarios == 0
        ? 0
        : ((totalOnline / totalUsuarios) * 100).round();

    return DashboardScreen(
      title: 'Adoção & Governança',
      restricted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppSize.controlSm,
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
          AppMetricGrid(
            children: [
              AppKpiStatCard(
                label: 'Usuários online',
                value: '$totalOnline',
                caption: 'de $totalUsuarios cadastrados',
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(
                label: 'Adoção',
                value: '$adocaoPct%',
                caption: 'ativos agora',
              ),
              AppKpiStatCard(
                label: 'Fazendas ativas',
                value: '$fazendasAtivas',
                caption: 'de ${usoFazendas.length}',
                tone: fazendasAtivas < usoFazendas.length
                    ? AppKpiStatTone.warning
                    : AppKpiStatTone.neutral,
              ),
              AppKpiStatCard(label: 'Período', value: _periodo),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Adoção por fazenda',
            period: _periodo,
            footnote:
                'Usuários online contra o total cadastrado de cada fazenda.',
            child: AppBulletChart(
              targetLabel: 'cadastrados',
              data: [
                for (final f in usoFazendas)
                  AppBulletDatum(
                    label: f.nome,
                    value: f.online.toDouble(),
                    target: f.usuarios.length.toDouble(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Atividade por fazenda')),
          const SizedBox(height: AppSpacing.space2),
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
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Trilha de auditoria')),
          const SizedBox(height: AppSpacing.space2),
          const _AuditoriaLinks(),
        ],
      ),
    );
  }
}

/// Atalhos para as duas exportações de log do catálogo administrativo. A tela
/// de exportação continua sendo a genérica (`MappedFeatureScreen`, via
/// `auditExport`) — aqui só há a porta de entrada, não uma segunda cópia dela.
class _AuditoriaLinks extends StatelessWidget {
  const _AuditoriaLinks();

  static const _itens = [
    (
      label: 'Exportar log de estoque',
      icon: LucideIcons.boxes,
      to: '/fazendas/administracao/exportar-log-estoque',
    ),
    (
      label: 'Exportar log da pecuária',
      icon: LucideIcons.beef,
      to: '/fazendas/administracao/exportar-log-pecuaria',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in _itens)
          Padding(
            padding: EdgeInsets.only(
              bottom: item == _itens.last
                  ? AppSpacing.space0
                  : AppSpacing.space2,
            ),
            child: AppMenuItem(
              icon: item.icon,
              label: item.label,
              onTap: () => context.push(item.to),
            ),
          ),
      ],
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
            color: selected ? AppColors.neutral0 : semantic.fgMuted,
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
                    duration: AppMotion.fast,
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
