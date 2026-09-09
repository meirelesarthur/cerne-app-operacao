import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/estoque_mocks.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Detalhe de Movimentação do Armazém, acionado pelo item de lista
/// (`AppTransactionListItem`) tanto na Home quanto em Movimentações — o mesmo
/// componente nos dois pontos de entrada (Lei 2). Espelha
/// `MovimentacaoDetailSheet.tsx`.
///
/// Abre em tela cheia ([showAppDetailPage]) em vez de folha inferior: é
/// visualização de registro, e a tela funda tem a altura que o dado pede.
Future<void> showMovimentacaoDetailSheet(
  BuildContext context, {
  required Movimentacao movimentacao,
}) {
  return showAppDetailPage<void>(
    context,
    title: 'Detalhe da movimentação',
    child: _SheetBody(mov: movimentacao),
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.mov});

  final Movimentacao mov;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isEntrada = mov.tipo == MovimentacaoTipo.entrada;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Container(
              height: AppSpacing.space12,
              width: AppSpacing.space12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEntrada ? semantic.accentSubtle : semantic.bgSubtle,
              ),
              child: AppIcon(
                isEntrada ? AppIcons.arrowDownLeft : AppIcons.arrowUpRight,
                size: AppSize.iconMd,
                color: isEntrada ? semantic.accentDefault : semantic.fgMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            AppChip(
              tone: isEntrada ? AppChipTone.brand : AppChipTone.neutral,
              icon: AppIcon(
                isEntrada ? AppIcons.arrowDownLeft : AppIcons.arrowUpRight,
                size: AppSize.iconXs,
              ),
              child: Text(isEntrada ? 'Entrada' : 'Saída'),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              '${isEntrada ? '+' : '−'} ${mov.quantidade}',
              style: TextStyle(
                fontSize: AppTypography.display,
                fontWeight: AppTypography.weightBold,
                height: 1.1,
                color: isEntrada ? semantic.accentDefault : semantic.fgDefault,
              ),
            ),
            Text(
              mov.item,
              style: TextStyle(
                fontSize: AppTypography.xl,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            Text(
              mov.tempo,
              style: TextStyle(
                fontSize: AppTypography.md,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: semantic.bgSubtle,
            border: Border.all(color: semantic.borderDefault),
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Origem', value: mov.origem),
              const SizedBox(height: AppSpacing.space3),
              _DetailRow(label: 'Destino', value: mov.destino),
              const SizedBox(height: AppSpacing.space3),
              _DetailRow(label: 'Responsável', value: mov.responsavel),
              const SizedBox(height: AppSpacing.space3),
              _DetailRow(label: 'Veículo', value: mov.veiculo),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            border: Border.all(color: semantic.borderDefault),
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NOTA',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgSubtle,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                mov.nota,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgDefault,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        Text(
          'Comprovante fiscal e histórico completo ficam disponíveis no sistema web GB CERNE.',
          style: TextStyle(
            fontSize: AppTypography.md,
            color: semantic.fgSubtle,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
        ),
        const SizedBox(width: AppSpacing.space3),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
        ),
      ],
    );
  }
}
