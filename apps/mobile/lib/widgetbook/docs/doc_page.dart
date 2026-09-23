import 'package:flutter/material.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';

/// Blocos das páginas de documentação do Widgetbook (Documentação → Guia).
/// Ferramenta de desenvolvimento: nunca é consumida pelas telas do app, mas
/// segue os mesmos tokens e a mesma tipografia (Lei 3).
class DocPage extends StatelessWidget {
  const DocPage({
    super.key,
    required this.title,
    required this.lead,
    required this.children,
    this.eyebrow,
  });

  final String title;
  final String lead;
  final String? eyebrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ColoredBox(
      color: semantic.bgCanvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSize.drawer * 2.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow case final eyebrow?) ...[
                  Text(
                    eyebrow.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.accentDefault,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
                AppHeading(level: AppHeadingLevel.h1, child: Text(title)),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  lead,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    color: semantic.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seção com título e conteúdo, separada da próxima por um respiro fixo.
class DocSection extends StatelessWidget {
  const DocSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading(level: AppHeadingLevel.h3, child: Text(title)),
          const SizedBox(height: AppSpacing.space3),
          ...children,
        ],
      ),
    );
  }
}

/// Parágrafo de corpo.
class DocText extends StatelessWidget {
  const DocText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTypography.base,
          height: 1.5,
          color: semantic.fgDefault,
        ),
      ),
    );
  }
}

/// Lista com marcadores — cada item pode ter um termo em destaque.
class DocBullets extends StatelessWidget {
  const DocBullets(this.items, {super.key});

  /// `(termo, descrição)` — `termo` vazio vira item simples.
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (term, description) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space2),
                    child: Container(
                      width: AppSpacing.space1 * 1.5,
                      height: AppSpacing.space1 * 1.5,
                      decoration: BoxDecoration(
                        color: semantic.accentDefault,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (term.isNotEmpty)
                            TextSpan(
                              text: '$term — ',
                              style: const TextStyle(
                                fontWeight: AppTypography.weightSemibold,
                              ),
                            ),
                          TextSpan(text: description),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: AppTypography.base,
                        height: 1.5,
                        color: semantic.fgDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Destaque de regra ou aviso.
class DocCallout extends StatelessWidget {
  const DocCallout({
    super.key,
    required this.title,
    required this.text,
    this.icon = AppIcons.info,
  });

  final String title;
  final String text;
  final AppIconData icon;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: semantic.accentSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderTint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: AppSize.iconMd, color: semantic.accentDefault),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.base,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    height: 1.5,
                    color: semantic.fgDefault,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabela simples de duas ou mais colunas com cabeçalho.
class DocTable extends StatelessWidget {
  const DocTable({super.key, required this.header, required this.rows});

  final List<String> header;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget cell(String text, {bool head = false}) => Padding(
      padding: const EdgeInsets.all(AppSpacing.space3),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTypography.sm,
          height: 1.4,
          fontWeight: head
              ? AppTypography.weightSemibold
              : AppTypography.weightNormal,
          color: head ? semantic.fgMuted : semantic.fgDefault,
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: semantic.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: semantic.borderDefault),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: semantic.bgCanvas),
            children: [for (final text in header) cell(text, head: true)],
          ),
          for (final row in rows)
            TableRow(children: [for (final text in row) cell(text)]),
        ],
      ),
    );
  }
}
