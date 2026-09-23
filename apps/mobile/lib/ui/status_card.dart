import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'button.dart';
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

/// Tom da linha de situação de um [AppStatusCard].
enum AppStatusCardTone { neutral, info, warning, danger, success }

/// Linha de situação: o que está acontecendo com o registro *agora*
/// ("Atrasada há 3 dias", "Em execução há 2h15"). Uma linha só, com ícone e
/// cor — o card mostra uma situação por vez, a mais importante.
class AppStatusCardSituation {
  const AppStatusCardSituation({
    required this.icon,
    required this.label,
    this.tone = AppStatusCardTone.neutral,
  });

  final AppIconData icon;
  final String label;
  final AppStatusCardTone tone;
}

/// Ação rápida do card: o próximo passo do registro, ao lado da situação.
/// Um botão só por card; ações que encerram o registro ficam no detalhe.
class AppStatusCardAction {
  const AppStatusCardAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = true,
  });

  final String label;
  final AppIconData icon;
  final VoidCallback onPressed;

  /// `true` pinta o botão como CTA (iniciar, retomar); `false` como ação
  /// secundária (pausar).
  final bool primary;
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
    this.situation,
    this.action,
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

  /// Linha de situação no rodapé do card, à esquerda da [action].
  final AppStatusCardSituation? situation;

  /// Botão de ação rápida no rodapé, à direita da [situation]. Tem alvo de
  /// toque próprio: tocar nele não dispara o [onTap] do card.
  final AppStatusCardAction? action;
  final VoidCallback? onTap;

  Color _toneColor(AppSemanticColors semantic, AppStatusCardTone tone) =>
      switch (tone) {
        AppStatusCardTone.neutral => semantic.fgMuted,
        AppStatusCardTone.info => AppColors.feedbackInfoText,
        AppStatusCardTone.warning => AppColors.feedbackWarningText,
        AppStatusCardTone.danger => AppColors.feedbackErrorText,
        AppStatusCardTone.success => semantic.accentDefault,
      };

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
          if (situation != null || action != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Expanded(
                  child: situation == null
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            AppIcon(
                              situation!.icon,
                              size: AppSize.iconSm,
                              color: _toneColor(semantic, situation!.tone),
                            ),
                            const SizedBox(width: AppSpacing.space1),
                            Expanded(
                              child: Text(
                                situation!.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  fontWeight: AppTypography.weightSemibold,
                                  color: _toneColor(semantic, situation!.tone),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                if (action != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: action!.primary
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    leftIcon: AppIcon(
                      action!.icon,
                      size: AppSize.iconSm,
                      color: action!.primary
                          ? semantic.ctaFg
                          : semantic.fgDefault,
                    ),
                    onPressed: action!.onPressed,
                    child: Text(action!.label),
                  ),
                ],
              ],
            ),
          ],
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
              situation: const AppStatusCardSituation(
                icon: AppIcons.clock,
                label: 'Em execução há 2h15',
                tone: AppStatusCardTone.info,
              ),
              action: AppStatusCardAction(
                label: 'Pausar',
                icon: AppIcons.pause,
                primary: false,
                onPressed: () {},
              ),
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
              situation: const AppStatusCardSituation(
                icon: AppIcons.alertTriangle,
                label: 'Atrasada há 4 dias',
                tone: AppStatusCardTone.danger,
              ),
              action: AppStatusCardAction(
                label: 'Iniciar',
                icon: AppIcons.play,
                onPressed: () {},
              ),
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
