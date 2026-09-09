import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'icon_button.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um par rótulo/valor de uma visualização em modo leitura — revisão de
/// cadastro ou o detalhe de um registro já gravado.
class AppReviewItem {
  const AppReviewItem({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.copyable = true,
  });

  final String label;

  /// Valor já formatado para leitura — a revisão não converte nada.
  final String value;

  /// Destaca a linha: usado para as coleções ("3 item(ns)"), que são o
  /// conteúdo que a pessoa mais precisa conferir antes de salvar.
  final bool emphasis;

  /// Mostra o botão de copiar ao lado do valor. `false` para valores curtos
  /// de estado ("Ativo", "Sim") onde copiar não agrega nada — a maioria dos
  /// campos de um registro real (código, descrição, responsável...) se
  /// beneficia de poder colar em outro lugar, então o padrão é `true`.
  final bool copyable;
}

/// Campos de leitura de uma visualização — revisão final de um cadastro em
/// etapas (arquétipo `Cadastro steps` do Figma, `54349:1990`) **e** o detalhe
/// de um registro já gravado (`_showRecord` em `mapped_feature_screen.dart`,
/// `AppTransactionDetailSheet` e as demais fichas de detalhe do app —
/// fonte única, Lei 2).
///
/// Cada campo é seu próprio cartão — fundo abafado, raio [AppRadius.xl2],
/// rótulo em versalete pequeno acima do valor, que aparece maior e mais
/// legível abaixo — em vez de rótulo e valor lado a lado. Uma linha de
/// registro real pode ter um valor longo (um endereço, um ID de operação);
/// empilhar deixa os dois sempre legíveis, sem truncar nem depender da
/// largura disponível.
///
/// Quando o cadastro de origem declarou etapas
/// ([FeatureFormStep]/`FeatureDefinition.steps`), a visualização do registro
/// não usa esta lista sozinha: agrupa os campos por etapa e usa
/// [AppReviewTabs], que reaproveita [AppReviewList] por trás de cada aba.
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

class _ReviewRow extends StatefulWidget {
  const _ReviewRow({required this.item});

  final AppReviewItem item;

  @override
  State<_ReviewRow> createState() => _ReviewRowState();
}

class _ReviewRowState extends State<_ReviewRow> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.item.value));
    if (!mounted) return;
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.fgSubtle,
                    letterSpacing: 0.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.half),
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: AppTypography.base,
                      fontWeight: AppTypography.weightSemibold,
                      color: item.emphasis
                          ? semantic.accentDefault
                          : semantic.fgDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.copyable) ...[
            const SizedBox(width: AppSpacing.space2),
            AppIconButton(
              icon: AppIcon(
                _copied ? AppIcons.check : AppIcons.copy,
                size: AppSize.iconXs,
                color: _copied ? semantic.accentDefault : null,
              ),
              label: _copied ? '${item.label} copiado' : 'Copiar ${item.label}',
              size: AppIconButtonSize.sm,
              onPressed: _copy,
            ),
          ],
        ],
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
                copyable: false,
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Detalhe de registro (com cópia)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(
            items: [
              AppReviewItem(label: 'Código', value: '1.01'),
              AppReviewItem(label: 'Descrição', value: 'Administração'),
              AppReviewItem(label: 'Status', value: 'Ativo', copyable: false),
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
