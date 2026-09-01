import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Ladrilho do lançador de módulos — o bloco de repetição do padrão global
/// (Figma `54300-2458`, frames `operacao-home` e `modulo-confinamento`).
///
/// Anatomia medida no Figma: 116 px de altura, raio [AppRadius.tile] (20),
/// `px 12 / py 16`, ícone de 24 px **ancorado no topo-esquerda** e rótulo de
/// 14 px **ancorado na base-esquerda**. A largura vem da grade, não do widget.
///
/// Por que não é uma variante de `AppBentoTile`: o bento ancora o ícone numa
/// bolha preenchida e centraliza o conjunto; aqui o ícone é nu e o par
/// ícone/rótulo é empurrado para as duas extremidades da coluna. São leituras
/// visuais diferentes, e forçá-las no mesmo widget por `enum` esconderia dois
/// componentes dentro de um (ver §1.2-A da esteira do padrão global).
///
/// [description] cobre o frame `modulo-confinamento`, onde o mesmo ladrilho
/// ganha um resumo da funcionalidade abaixo do título.
class AppModuleTile extends StatelessWidget {
  const AppModuleTile({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.onTap,
  });

  /// Ícone do módulo — entrada de `AppIcons`, preferencialmente um apelido de
  /// domínio (`AppIcons.confinamento`, `AppIcons.pecuaria`…).
  final AppIconData icon;

  /// Nome do módulo. Quebra em até duas linhas, como "Ordem de Serviço" e
  /// "Sincronizar aplicativo" no Figma.
  final String label;

  /// Resumo curto da funcionalidade. Presente na grade de um módulo, ausente
  /// na home.
  final String? description;

  final VoidCallback? onTap;

  /// Altura do Figma. Fixa de propósito: a grade da home alinha ladrilhos de
  /// rótulos com 1 e 2 linhas, e altura por conteúdo desalinharia as fileiras.
  static const double height = 116;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: label,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space4,
        ),
        // Divergência deliberada do Figma, registrada na esteira: lá o ladrilho
        // é cinza (#f0f0f0) sobre um cartão branco. Aqui não existe esse cartão
        // — o ladrilho assenta direto no canvas, e no tema claro `bgSubtle` é a
        // mesma cor do canvas: as fileiras sumiriam, separadas só pela sombra.
        // `bgSurface` inverte a relação figura/fundo e mantém o mesmo contraste
        // com uma camada a menos.
        decoration: BoxDecoration(
          color: semantic.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.tile),
          boxShadow: semantic.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Neutro, não verde: na referência o ladrilho não usa a cor da
            // marca — o destaque vem do rótulo, e o ícone é um traço fino
            // escuro (medido em 54349:2639).
            AppIcon(icon, size: AppSize.iconLg, color: semantic.fgSecondary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightMedium,
                    height: AppTypography.lineHeightTight,
                    color: semantic.fgDefault,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space1),
                    child: Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        height: AppTypography.lineHeightTight,
                        color: semantic.fgSecondary,
                      ),
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

/// Grade de ladrilhos do padrão global: duas colunas, `gap 8`, com o último
/// item ocupando a largura inteira quando a contagem é ímpar — exatamente o
/// que o Figma faz com "Sincronizar aplicativo".
///
/// A grade existe como componente porque a regra do item largo é do padrão,
/// não da tela: repeti-la em cada home reintroduziria a divergência que a
/// esteira fechou.
class AppModuleTileGrid extends StatelessWidget {
  const AppModuleTileGrid({super.key, required this.tiles});

  final List<AppModuleTile> tiles;

  /// `gap 8` do Figma.
  static const double gap = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < tiles.length; i += 2) {
      final isLast = i == tiles.length - 1;
      if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));
      rows.add(
        isLast
            ? SizedBox(width: double.infinity, child: tiles[i])
            // Sem `stretch`: o ladrilho já tem altura fixa, e `stretch` num
            // `Row` dentro de uma coluna de altura não limitada (o `ListView`
            // da home) pede altura infinita e quebra o layout.
            : Row(
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: gap),
                  Expanded(child: tiles[i + 1]),
                ],
              ),
      );
    }

    // `min`: a grade é um bloco dentro da rolagem da home, não a própria tela.
    // Com o padrão (`max`) ela ocuparia toda a altura disponível e empurraria o
    // que vem depois para fora.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

WidgetbookComponent buildModuleTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ModuleTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Grade da home de Operação',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SingleChildScrollView(
            child: AppModuleTileGrid(
              tiles: [
                AppModuleTile(
                  icon: AppIcons.confinamento,
                  label: 'Confinamento',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.pecuaria,
                  label: 'Pecuária',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.agricultura,
                  label: 'Agricultura',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.ordemServico,
                  label: 'Ordem de Serviço',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.sincronizar,
                  label: 'Sincronizar aplicativo',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Grade de um módulo (com resumo)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SingleChildScrollView(
            child: AppModuleTileGrid(
              tiles: [
                AppModuleTile(
                  icon: AppIcons.warehouse,
                  label: 'Meus Currais',
                  description: 'Ações realizadas nos currais',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.misturador,
                  label: 'Produzir Batelada',
                  description: 'Registrar produção física',
                  onTap: () {},
                ),
                AppModuleTile(
                  icon: AppIcons.wheat,
                  label: 'Trato Diário',
                  description: 'Registrar produção das dietas',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
