import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'field_capsule.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';

class AppSearchSelectOption {
  const AppSearchSelectOption({
    required this.value,
    required this.label,
    this.detail,
  });

  final String value;
  final String label;
  final String? detail;
}

/// Espelha `SearchSelect.tsx` — seleção com busca (ex.: selecionar lote/carga).
/// No React a lista é sempre inline (sem modal), então aqui também é inline —
/// não usamos `showModalBottomSheet` porque o próprio componente já é a lista
/// visível (diferente de um dropdown fechado por padrão).
///
/// `value`/`onChanged` são controlados (padrão do catálogo); a busca (`query`)
/// é estado interno, espelhando o `useState` local do componente React.
class AppSearchSelect extends StatefulWidget {
  const AppSearchSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder = 'Buscar...',
  });

  final List<AppSearchSelectOption> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String placeholder;

  @override
  State<AppSearchSelect> createState() => _AppSearchSelectState();
}

class _AppSearchSelectState extends State<AppSearchSelect> {
  final _queryController = TextEditingController();

  /// O anel de foco é pintado pela cápsula, então o estado de foco precisa ser
  /// observável aqui.
  final _queryFocusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _queryFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _queryFocusNode.removeListener(_handleFocusChange);
    _queryFocusNode.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _handleFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final inputColors = appInputColors(context);
    final filtered = widget.options
        .where((o) => o.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cápsula compartilhada: garante os 52px reais (o `InputDecorator`
        // dimensiona a própria decoração pelo conteúdo, não pelas constraints).
        AppFieldCapsule(
          focused: _queryFocusNode.hasFocus,
          horizontalPadding: AppSpacing.space4,
          leading: AppIcon(
            AppIcons.search,
            size: AppSize.iconSm,
            color: inputColors.placeholder,
          ),
          child: TextField(
            controller: _queryController,
            focusNode: _queryFocusNode,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.xl,
              color: inputColors.foreground,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.xl,
                color: inputColors.placeholder,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Container(
          // 224px = max-h-56 do React, composto por tokens existentes
          // (space20*2 + space16 = 160 + 64) para não hardcodar um valor fora de tokens.
          constraints: const BoxConstraints(
            maxHeight: AppSpacing.space20 * 2 + AppSpacing.space16,
          ),
          decoration: BoxDecoration(
            color: semantic.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(color: semantic.borderSubtle),
            boxShadow: semantic.shadowCard,
          ),
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space4,
                    horizontal: AppSpacing.space3,
                  ),
                  child: Text(
                    'Nada encontrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.sm,
                      color: semantic.fgSubtle,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: semantic.borderSubtle),
                  itemBuilder: (context, index) {
                    final option = filtered[index];
                    final selected = option.value == widget.value;
                    return InkWell(
                      onTap: () => widget.onChanged(option.value),
                      child: Container(
                        color: selected
                            ? semantic.accentSubtle
                            : AppColors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space3,
                          vertical: AppSpacing.space2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: AppTypography.md,
                                      fontWeight: AppTypography.weightMedium,
                                      color: semantic.fgDefault,
                                    ),
                                  ),
                                  if (option.detail != null)
                                    Text(
                                      option.detail!,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: AppTypography.md,
                                        color: semantic.fgMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (selected)
                              AppIcon(
                                AppIcons.check,
                                size: AppSize.iconSm,
                                color: semantic.accentDefault,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildSearchSelectWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SearchSelect',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const _SearchSelectUseCase(),
      ),
    ],
  );
}

class _SearchSelectUseCase extends StatefulWidget {
  const _SearchSelectUseCase();

  @override
  State<_SearchSelectUseCase> createState() => _SearchSelectUseCaseState();
}

class _SearchSelectUseCaseState extends State<_SearchSelectUseCase> {
  String? _value;

  static const _options = [
    AppSearchSelectOption(
      value: 'lote-01',
      label: 'Lote 01',
      detail: '120 sacas',
    ),
    AppSearchSelectOption(
      value: 'lote-02',
      label: 'Lote 02',
      detail: '80 sacas',
    ),
    AppSearchSelectOption(
      value: 'lote-03',
      label: 'Lote 03',
      detail: '210 sacas',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: AppSearchSelect(
          options: _options,
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          placeholder: 'Buscar lote...',
        ),
      ),
    );
  }
}
