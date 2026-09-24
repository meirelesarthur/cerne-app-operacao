import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'chip.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um dado de apoio de uma [AppRecordTile]: ícone do tipo de informação
/// (data, lote, local…) + o valor.
class AppRecordMeta {
  const AppRecordMeta({required this.icon, required this.label});

  final AppIconData icon;
  final String label;
}

/// Linha de listagem de registros — o padrão global de toda listagem.
///
/// Pensada para leitura rápida no campo:
/// - **sem ícone à esquerda**: o título usa a largura inteira da linha;
/// - **dados de apoio com ícone** ([meta]), no máximo **dois por linha**, com
///   o ícone no tamanho do texto — "Exame", "Lote Matrizes 01" e
///   "02/09/2026" deixam de ser uma frase única separada por pontos;
/// - **situação embaixo** ([status], em geral um [AppChip]), nunca na lateral
///   — a tag ao lado do título roubava o espaço do texto.
///
/// Superfície cinza plana (`bgInset`), para dentro da folha branca — a mesma
/// das listagens (ver `AppMenuItemSurface.subtle`).
class AppRecordTile extends StatelessWidget {
  const AppRecordTile({
    super.key,
    required this.title,
    this.meta = const [],
    this.status,
    this.onTap,
  });

  final String title;
  final List<AppRecordMeta> meta;
  final Widget? status;
  final VoidCallback? onTap;

  /// Quantos dados de apoio cabem por linha.
  static const metaPerRow = 2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Material(
      color: semantic.bgInset,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.space14),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.xl,
                  fontWeight: AppTypography.weightMedium,
                  height: AppTypography.lineHeightSnug,
                  color: semantic.fgDefault,
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space1),
                AppRecordMetaGrid(meta: meta),
              ],
              if (status case final status?) ...[
                const SizedBox(height: AppSpacing.space2),
                Align(alignment: Alignment.centerLeft, child: status),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Grade dos dados de apoio: ícone + valor, no máximo
/// [AppRecordTile.metaPerRow] por linha. Pública para cards com ações
/// próprias (curral, ordem) seguirem o mesmo padrão da listagem.
class AppRecordMetaGrid extends StatelessWidget {
  const AppRecordMetaGrid({super.key, required this.meta});

  final List<AppRecordMeta> meta;

  @override
  Widget build(BuildContext context) {
    const perRow = AppRecordTile.metaPerRow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < meta.length; i += perRow) ...[
          if (i > 0) const SizedBox(height: AppSpacing.space1),
          Row(
            children: [
              Expanded(child: _MetaCell(meta: meta[i])),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: i + 1 < meta.length
                    ? _MetaCell(meta: meta[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.meta});

  final AppRecordMeta meta;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Row(
      children: [
        // Ícone na altura do texto (13 px → 14 px), na mesma cor do texto.
        AppIcon(meta.icon, size: AppSize.iconXs, color: semantic.fgMuted),
        const SizedBox(width: AppSpacing.space1),
        Flexible(
          child: Text(
            meta.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.base,
              color: semantic.fgMuted,
            ),
          ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildRecordTileWidgetbookComponent() {
  Widget sheet(Widget child) => ColoredBox(
    color: AppColors.neutral0,
    child: Center(
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: child,
        ),
      ),
    ),
  );

  return WidgetbookComponent(
    name: 'RecordTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Listagem',
        builder: (context) => sheet(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRecordTile(
                title: 'Exame de casco Lote Matrizes 01',
                meta: const [
                  AppRecordMeta(icon: AppIcons.clipboardList, label: 'Exame'),
                  AppRecordMeta(
                    icon: AppIcons.layers,
                    label: 'Lote Matrizes 01',
                  ),
                  AppRecordMeta(icon: AppIcons.calendar, label: '02/09/2026'),
                ],
                status: const AppChip(
                  tone: AppChipTone.blue,
                  child: Text('Programado'),
                ),
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppRecordTile(
                title: 'Vacinação Lote Recria 02',
                meta: const [
                  AppRecordMeta(
                    icon: AppIcons.clipboardList,
                    label: 'Vacinação',
                  ),
                  AppRecordMeta(icon: AppIcons.layers, label: 'Lote Recria 02'),
                ],
                status: const AppChip(
                  tone: AppChipTone.brand,
                  child: Text('Concluído'),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Só título',
        builder: (context) =>
            sheet(AppRecordTile(title: 'Ração Engorda', onTap: () {})),
      ),
    ],
  );
}
