import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'button.dart';
import 'chip.dart';
import 'icon_button.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Grade 2x2 de cards quadrados para coleções de um cadastro — cada card
/// mostra só o nome do grupo e um contador; o "Adicionar" abre o mesmo
/// formulário do modo em lista ([AppAddableGroupList]), e um "Gerenciar"
/// opcional abre a listagem de itens já lançados naquele grupo (edição e
/// exclusão), sem expor os itens soltos na tela.
///
/// Usado quando o cadastro tem muitos grupos e mostrar cada item lançado em
/// linha (como [AppAddableGroupList] + itens abaixo) rola demais — o
/// apontamento agrícola, com 5 coleções, é o primeiro caso.
class AppSquareGroupGrid extends StatelessWidget {
  const AppSquareGroupGrid({
    super.key,
    required this.groups,
    required this.counts,
    required this.onAdd,
    this.onManage,
  });

  final List<String> groups;
  final Map<String, int> counts;
  final ValueChanged<String> onAdd;

  /// `null` esconde a ação de gerenciar — cada card fica só com "Adicionar",
  /// mesmo modo que [AppAddableGroupList].
  final ValueChanged<String>? onManage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const spacing = AppSpacing.space3;
        final cardSide = (constraints.maxWidth - spacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final group in groups)
              SizedBox(
                width: cardSide,
                height: cardSide,
                child: _SquareGroupCard(
                  group: group,
                  count: counts[group] ?? 0,
                  onAdd: () => onAdd(group),
                  onManage: onManage == null ? null : () => onManage!(group),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SquareGroupCard extends StatelessWidget {
  const _SquareGroupCard({
    required this.group,
    required this.count,
    required this.onAdd,
    this.onManage,
  });

  final String group;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
          const Spacer(),
          if (count > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: AppChip(tone: AppChipTone.brand, child: Text('$count')),
            )
          else
            Text(
              'Nenhum item',
              style: TextStyle(fontSize: AppTypography.xs, color: semantic.fgMuted),
            ),
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.secondary,
                  leftIcon: const AppIcon(AppIcons.plus, size: AppSpacing.space4),
                  onPressed: onAdd,
                  child: const Text('Adicionar'),
                ),
              ),
              if (onManage case final manage?) ...[
                const SizedBox(width: AppSpacing.space2),
                AppIconButton(
                  icon: const AppIcon(AppIcons.pencil, size: AppSize.iconXs),
                  label: 'Ver e editar itens de $group',
                  onPressed: count == 0 ? null : manage,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildSquareGroupGridWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SquareGroupGrid',
    useCases: [
      WidgetbookUseCase(
        name: 'Coleções 2x2',
        builder: (context) => const _SquareGroupGridUseCase(),
      ),
    ],
  );
}

class _SquareGroupGridUseCase extends StatefulWidget {
  const _SquareGroupGridUseCase();

  @override
  State<_SquareGroupGridUseCase> createState() =>
      _SquareGroupGridUseCaseState();
}

class _SquareGroupGridUseCaseState extends State<_SquareGroupGridUseCase> {
  final _counts = <String, int>{'Insumos': 1};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: AppSquareGroupGrid(
        groups: const [
          'Mão de obra / Serviços',
          'Máquinas / Implementos',
          'Insumos',
          'Produção',
          'Ocorrências',
        ],
        counts: _counts,
        onAdd: (group) =>
            setState(() => _counts[group] = (_counts[group] ?? 0) + 1),
        onManage: (group) {},
      ),
    );
  }
}
