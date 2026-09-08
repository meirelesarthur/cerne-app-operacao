import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'addable_group_list.dart';
import 'app_icon.dart';
import 'icon_button.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Uma linha já adicionada a uma coleção, do ponto de vista da tela: um título
/// e um resumo. Quem monta os dois textos é quem conhece o domínio.
class AppCollectionItemView {
  const AppCollectionItemView({required this.title, this.subtitle});

  final String title;
  final String? subtitle;
}

/// Uma coleção de itens de um cadastro — a faixa "Adicionar" seguida das
/// linhas já lançadas, cada uma removível.
///
/// Compõe [AppAddableGroupList] em vez de redesenhar a faixa: o cabeçalho
/// (nome, "N item(ns) adicionado(s)", contador e botão) é o mesmo pixel, e
/// esta classe acrescenta só o que faltava — **as linhas do que foi
/// adicionado**. Era o pedaço que cada tela reimplementava por conta
/// (`_ItemRow` em `apontamento_flow.dart`) e que o motor genérico de cadastros
/// não tinha, o que obrigava toda coleção a viver como um contador cego.
///
/// Sem [onRemove] as linhas ficam apenas legíveis — é o caso das consultas
/// somente leitura.
class AppCollectionList extends StatelessWidget {
  const AppCollectionList({
    super.key,
    required this.name,
    required this.items,
    required this.onAdd,
    this.onRemove,
    this.removeLabel = 'Remover item',
  });

  /// Nome da coleção, como aparece no contrato e na faixa ("Insumos").
  final String name;

  final List<AppCollectionItemView> items;

  final VoidCallback onAdd;

  /// Recebe o índice da linha a remover. Nulo deixa as linhas só de leitura.
  final void Function(int index)? onRemove;

  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppAddableGroupList(
          groups: [name],
          counts: {name: items.length},
          onAdd: (_) => onAdd(),
        ),
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space2),
            child: _CollectionRow(
              item: items[index],
              removeLabel: removeLabel,
              onRemove: onRemove == null ? null : () => onRemove!(index),
            ),
          ),
      ],
    );
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({
    required this.item,
    required this.removeLabel,
    this.onRemove,
  });

  final AppCollectionItemView item;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              if (item.subtitle case final subtitle?)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    color: semantic.fgMuted,
                  ),
                ),
            ],
          ),
        ),
        if (onRemove case final remove?)
          AppIconButton(
            icon: const AppIcon(AppIcons.x, size: AppSize.iconXs),
            label: removeLabel,
            onPressed: remove,
          ),
      ],
    );
  }
}

WidgetbookComponent buildCollectionListWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'CollectionList',
    useCases: [
      WidgetbookUseCase(
        name: 'Coleção com itens',
        builder: (context) => const _CollectionListUseCase(),
      ),
      WidgetbookUseCase(
        name: 'Somente leitura',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppCollectionList(
            name: 'Etapas do protocolo',
            items: [
              AppCollectionItemView(
                title: 'Implante de progesterona',
                subtitle: '2026-09-01 · 1 dose · Farmácia',
              ),
            ],
            onAdd: _noop,
          ),
        ),
      ),
    ],
  );
}

void _noop() {}

class _CollectionListUseCase extends StatefulWidget {
  const _CollectionListUseCase();

  @override
  State<_CollectionListUseCase> createState() => _CollectionListUseCaseState();
}

class _CollectionListUseCaseState extends State<_CollectionListUseCase> {
  final _items = <AppCollectionItemView>[
    const AppCollectionItemView(
      title: 'Ração Engorda 18%',
      subtitle: '20 kg · Armazém A',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: AppCollectionList(
        name: 'Insumos',
        items: _items,
        onAdd: () => setState(
          () => _items.add(
            const AppCollectionItemView(
              title: 'Sal Mineral Proteinado',
              subtitle: '50 kg · Depósito B',
            ),
          ),
        ),
        onRemove: (index) => setState(() => _items.removeAt(index)),
      ),
    );
  }
}
