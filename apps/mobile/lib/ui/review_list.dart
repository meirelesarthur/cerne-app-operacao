import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um par rótulo/valor da revisão final de um cadastro.
class AppReviewItem {
  const AppReviewItem({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;

  /// Valor já formatado para leitura — a revisão não converte nada.
  final String value;

  /// Destaca a linha: usado para as coleções ("3 item(ns)"), que são o
  /// conteúdo que a pessoa mais precisa conferir antes de salvar.
  final bool emphasis;
}

/// Revisão do que foi preenchido, exibida na última etapa dos formulários
/// longos (arquétipo `Cadastro steps` do Figma, `54349:1990`).
///
/// Existe porque a régua de etapas resolve *onde estou* mas não *o que já
/// respondi*: quebrar um cadastro de 12 campos em quatro telas esconde as três
/// primeiras no momento de salvar. A revisão devolve isso em uma tela só —
/// mesma anatomia de faixa das linhas de `AppAddableGroupList` (fundo abafado,
/// raio [AppRadius.xl2], `p 12`), rótulo abafado à esquerda e valor legível à
/// direita, quebrando em duas linhas quando a largura aperta.
///
/// Não confundir com `AppTransactionDetailSheet`, que detalha um registro já
/// gravado: esta lista é sobre um rascunho, antes do salvamento.
class AppReviewList extends StatelessWidget {
  const AppReviewList({super.key, required this.items, this.emptyLabel});

  final List<AppReviewItem> items;

  /// Texto quando nada foi preenchido — em etapas anteriores tudo era
  /// opcional, e uma lista vazia sem explicação parece defeito.
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    if (items.isEmpty) {
      return Text(
        emptyLabel ?? 'Nada preenchido até aqui.',
        style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _ReviewRow(item: items[index]),
          if (index < items.length - 1)
            const SizedBox(height: AppSpacing.space2),
        ],
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.item});

  final AppReviewItem item;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final label = Text(
      item.label,
      style: TextStyle(fontSize: AppTypography.xs, color: semantic.fgMuted),
    );
    final value = Text(
      item.value,
      style: TextStyle(
        fontSize: AppTypography.sm,
        fontWeight: AppTypography.weightSemibold,
        color: item.emphasis ? semantic.accentDefault : semantic.fgDefault,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < AppSpacing.space20 * 4;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [label, value],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: label),
              const SizedBox(width: AppSpacing.space3),
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: value),
              ),
            ],
          );
        },
      ),
    );
  }
}

WidgetbookComponent buildReviewListWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ReviewList',
    useCases: [
      WidgetbookUseCase(
        name: 'Revisão de cadastro',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(
            items: [
              AppReviewItem(label: 'Responsável', value: 'João Oliveira'),
              AppReviewItem(label: 'Data', value: '08/09/2026'),
              AppReviewItem(label: 'Área', value: 'Pasto Norte'),
              AppReviewItem(
                label: 'Insumos',
                value: '3 item(ns)',
                emphasis: true,
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Nada preenchido',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(items: []),
        ),
      ),
    ],
  );
}
