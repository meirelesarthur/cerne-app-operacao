import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chip.dart';
import 'pressable.dart';

/// Par rótulo/valor exibido à direita do título de um [AppStatusCard]
/// (ex.: "Prioridade: Alta").
class AppStatusCardMeta {
  const AppStatusCardMeta({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;

  /// Destaca o valor na cor de acento — para o dado que pede atenção
  /// (prioridade alta, atraso), sem virar mais um chip.
  final bool highlight;
}

/// Card de registro com andamento — listas de ordens, pedidos e tarefas em
/// que o **status** é a primeira coisa a ler.
///
/// Anatomia: chip de status no topo; título grande (o identificador que a
/// pessoa procura, ex.: "OS #2201") com a descrição e a legenda abaixo; à
/// direita, até dois ou três pares rótulo/valor ([meta]). Superfície
/// [AppSemanticColors.bgRaised] sem borda nem sombra e raio [AppRadius.tile]
/// — branco sobre a folha cinza (`AppContentSheet`) no tema claro e o verde
/// elevado sobre a folha escura no Modo GB. Nada é cor crua.
class AppStatusCard extends StatelessWidget {
  const AppStatusCard({
    super.key,
    required this.statusLabel,
    this.statusTone = AppChipTone.neutral,
    required this.title,
    this.subtitle,
    this.caption,
    this.meta = const [],
    this.onTap,
  });

  final String statusLabel;
  final AppChipTone statusTone;
  final String title;

  /// Descrição curta do registro (até duas linhas).
  final String? subtitle;

  /// Linha de apoio abafada (ex.: prazo e local).
  final String? caption;
  final List<AppStatusCardMeta> meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final radius = BorderRadius.circular(AppRadius.tile);

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(color: semantic.bgRaised, borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppChip(tone: statusTone, child: Text(statusLabel)),
          const SizedBox(height: AppSpacing.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.xl2,
                        fontWeight: AppTypography.weightMedium,
                        height: AppTypography.lineHeightTight,
                        color: semantic.fgHeading,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightMedium,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                    if (caption != null) ...[
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.space3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in meta)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space1,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${item.label}: ',
                                style: TextStyle(color: semantic.fgMuted),
                              ),
                              TextSpan(
                                text: item.value,
                                style: TextStyle(
                                  fontWeight: AppTypography.weightSemibold,
                                  color: item.highlight
                                      ? semantic.accentDefault
                                      : semantic.fgDefault,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: AppTypography.sm),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return AppPressable(
      semanticLabel: '$title, $statusLabel',
      onPressed: onTap,
      borderRadius: radius,
      child: content,
    );
  }
}

WidgetbookComponent buildStatusCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'StatusCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Lista de ordens de serviço',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppStatusCard(
              statusLabel: 'Em execução',
              statusTone: AppChipTone.blue,
              title: 'OS #2198',
              subtitle: 'Vacinação contra aftosa — Lote 12',
              caption: 'Prazo 20/09/2026 · Curral de manejo 2',
              meta: const [
                AppStatusCardMeta(label: 'Tipo', value: 'Pecuário'),
                AppStatusCardMeta(label: 'Prioridade', value: 'Média'),
              ],
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppStatusCard(
              statusLabel: 'Aguardando',
              title: 'OS #2201',
              subtitle: 'Reparo de cerca do Talhão 04',
              caption: 'Prazo 25/09/2026 · Talhão 04',
              meta: const [
                AppStatusCardMeta(label: 'Tipo', value: 'Infraestrutura'),
                AppStatusCardMeta(
                  label: 'Prioridade',
                  value: 'Alta',
                  highlight: true,
                ),
              ],
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            const AppStatusCard(
              statusLabel: 'Refeita',
              statusTone: AppChipTone.red,
              title: 'OS #2160',
              subtitle: 'Contenção emergencial de gado solto — Estrada vicinal',
            ),
          ],
        ),
      ),
    ],
  );
}
