import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

const List<CotacaoTipo?> _filtros = [
  null,
  CotacaoTipo.produto,
  CotacaoTipo.servico,
  CotacaoTipo.frete,
  CotacaoTipo.manutencao,
];

const Map<CotacaoTipo, String> _tipoLabel = {
  CotacaoTipo.produto: 'Produto',
  CotacaoTipo.servico: 'Serviço',
  CotacaoTipo.frete: 'Frete',
  CotacaoTipo.manutencao: 'Manutenção',
};

const Map<CotacaoStatus, ({String label, AppChipTone tone})> _statusMeta = {
  CotacaoStatus.cotacao: (label: 'Em cotação', tone: AppChipTone.blue),
  CotacaoStatus.aprovada: (label: 'Aprovada', tone: AppChipTone.brand),
  CotacaoStatus.recusada: (label: 'Recusada', tone: AppChipTone.red),
};

/// Formata número cru do mock como preço em reais (aproximação manual — o
/// projeto não tem `intl` instalado — mesmo padrão de `precoAtual`).
String _formatPreco(double v) =>
    'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

/// Dashboard de Suprimentos (spec §4.4) — status PARCIAL: UI completa com
/// mock, mas com selo "Dados de exemplo" sinalizando fonte a confirmar.
/// Espelha `DashSuprimentos.tsx`.
class DashSuprimentos extends StatefulWidget {
  const DashSuprimentos({super.key});

  @override
  State<DashSuprimentos> createState() => _DashSuprimentosState();
}

class _DashSuprimentosState extends State<DashSuprimentos> {
  CotacaoTipo? _filtro;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final lista = cotacoes
        .where((c) => _filtro == null || c.tipo == _filtro)
        .toList();

    return DashboardScreen(
      title: 'Suprimentos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final tipo in _filtros) ...[
                  _FiltroPill(
                    label: tipo == null ? 'Todos' : _tipoLabel[tipo]!,
                    selected: _filtro == tipo,
                    onTap: () => setState(() => _filtro = tipo),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Column(
            children: [
              for (final c in lista) ...[
                _CotacaoCard(cotacao: c),
                if (c != lista.last) const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
          if (lista.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
              child: Center(
                child: Text(
                  'Nenhuma cotação encontrada',
                  style: TextStyle(color: semantic.fgSubtle),
                ),
              ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}

class _CotacaoCard extends StatelessWidget {
  const _CotacaoCard({required this.cotacao});

  final Cotacao cotacao;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final status = _statusMeta[cotacao.status]!;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showCotacaoDetail(context, cotacao),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cotacao.fornecedor,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        '${_tipoLabel[cotacao.tipo]} · ${cotacao.itens} itens',
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppChip(tone: status.tone, child: Text(status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cotacao.total,
                  style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.fgDefault,
                  ),
                ),
                Text(
                  'Dados de exemplo',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontStyle: FontStyle.italic,
                    color: semantic.fgSubtle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showCotacaoDetail(BuildContext context, Cotacao c) {
  final status = _statusMeta[c.status]!;
  final alta = c.variacao >= 0;
  const historicoLabels = ['2 cotações atrás', 'Cotação anterior', 'Atual'];

  showAppBottomSheet<void>(
    context,
    title: 'Detalhe da cotação',
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        final variacaoColor = alta ? semantic.accentDefault : AppColors.red600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tipoLabel[c.tipo]!.toUpperCase(),
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgSubtle,
                        ),
                      ),
                      Text(
                        c.produto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.lg,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        c.fornecedor,
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
                AppChip(tone: status.tone, child: Text(status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: Column(
                children: [
                  Text(
                    c.precoAtual,
                    style: TextStyle(
                      fontSize: AppTypography.xl3,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  Text(
                    'por ${c.unidade}',
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      color: semantic.fgSubtle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        alta
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                        size: 14,
                        color: variacaoColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${alta ? '+' : ''}${c.variacao.toStringAsFixed(1)}% frente à cotação anterior',
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightSemibold,
                          color: variacaoColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Unidade', value: c.unidade),
                  _DetailRow(label: 'Validade da cotação', value: c.validade),
                  _DetailRow(label: 'Itens', value: '${c.itens}'),
                  _DetailRow(label: 'Total', value: c.total),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Histórico de preço',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: semantic.fgMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            AppSparklineArea(
              data: c.historico,
              color: variacaoColor,
              width: 240,
              height: 40,
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < c.historico.length; i++)
                  Column(
                    children: [
                      Text(
                        historicoLabels[i],
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: semantic.fgSubtle,
                        ),
                      ),
                      Text(
                        _formatPreco(c.historico[i]),
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Dados de exemplo — ficha completa da cotação, anexos e histórico de negociação ficam no sistema web GB CERNE.',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.base,
              color: semantic.fgMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.base,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
