import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

enum _Secao { lotes, estoque, pesagens, localizacao }

const _hub = [
  (id: _Secao.lotes, label: 'Lotes', icon: AppIcons.layers),
  (id: _Secao.estoque, label: 'Estoque', icon: AppIcons.boxes),
  (id: _Secao.pesagens, label: 'Pesagens do dia', icon: AppIcons.scale),
  (id: _Secao.localizacao, label: 'Localização', icon: AppIcons.mapPin),
];

/// Consultas Gerenciais read-only (spec §4.7). 100% leitura: nenhum botão de
/// ação/edição. Localização de animais = placeholder de mapa (PESADO/diferido
/// no recorte). Espelha `DashConsultas.tsx`.
class DashConsultas extends StatefulWidget {
  const DashConsultas({super.key});

  @override
  State<DashConsultas> createState() => _DashConsultasState();
}

class _DashConsultasState extends State<DashConsultas> {
  _Secao _secao = _Secao.lotes;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ativo = _hub.firstWhere((h) => h.id == _secao);

    return DashboardScreen(
      title: 'Consultas Gerenciais',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon(AppIcons.lock, size: 12, color: semantic.fgSubtle),
              const SizedBox(width: AppSpacing.oneHalf),
              Text(
                'Somente leitura — dados espelhados do web.',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space2,
            crossAxisSpacing: AppSpacing.space2,
            childAspectRatio: 0.85,
            children: [
              for (final h in _hub)
                _HubTile(
                  label: h.label,
                  icon: h.icon,
                  selected: _secao == h.id,
                  onTap: () => setState(() => _secao = h.id),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          AppSectionTitle(child: Text(ativo.label)),
          const SizedBox(height: AppSpacing.space2),
          if (_secao == _Secao.lotes) const _ReadOnlyList(rows: lotes),
          if (_secao == _Secao.estoque) const _ReadOnlyList(rows: estoque),
          if (_secao == _Secao.pesagens) const _ReadOnlyList(rows: pesagensDia),
          if (_secao == _Secao.localizacao)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: semantic.borderStrong),
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                color: semantic.bgSubtle,
              ),
              child: const AppEmptyState(
                icon: AppIcons.mapPinned,
                title: 'Mapa de localização',
                description:
                    'Carregamento otimizado em desenvolvimento. O mapa de localização de animais será habilitado em uma próxima fase.',
              ),
            ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: label,
      selected: selected,
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: selected ? semantic.accentSubtle : semantic.bgSurface,
          border: Border.all(
            color: selected ? semantic.accentDefault : semantic.borderDefault,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: 20,
              color: selected ? semantic.accentDefault : semantic.fgMuted,
            ),
            const SizedBox(height: AppSpacing.oneHalf),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.weightMedium,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyList extends StatelessWidget {
  const _ReadOnlyList({required this.rows});

  final List<LinhaConsulta> rows;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Column(
        children: [
          for (final r in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          r.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.base,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppChip(child: Text(r.meta)),
                ],
              ),
            ),
            if (r != rows.last)
              Divider(height: 1, color: semantic.borderSubtle),
          ],
        ],
      ),
    );
  }
}
