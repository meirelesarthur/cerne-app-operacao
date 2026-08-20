import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'field_capsule.dart';

class AppFormSelectOption {
  const AppFormSelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Espelha `FormSelect.tsx` — dropdown inline (equivalente ao `<select>` nativo do
/// React). Diferente de `SearchSelect`, este é um dropdown simples sem busca, então
/// usamos `DropdownButtonFormField` inline em vez de `showModalBottomSheet`
/// (exceção prevista no plano de migração para "dropdown inline simples").
class AppFormSelect extends StatelessWidget {
  const AppFormSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
  });

  final List<AppFormSelectOption> options;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final textStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: AppTypography.md,
      color: enabled ? semantic.fgDefault : semantic.fgMuted,
    );

    // Cápsula (altura de 48px, fundo, raio) vem de `AppFieldCapsule` — o
    // `InputDecorator` dimensiona `fillColor`/`border` pelo conteúdo, não pelas
    // constraints, então pintar por ele deixava a pílula com a altura do texto.
    return AppFieldCapsule(
      child: DropdownButtonFormField<String>(
        // `DropdownButtonFormField` não é totalmente "controlado" como `TextFormField`
        // (ignora mudanças externas de `initialValue` após o primeiro build); a
        // `ValueKey` força reconstrução completa quando `value` muda de fora,
        // mantendo o padrão controlado (`value`/`onChanged`) do restante do catálogo.
        key: ValueKey(value),
        initialValue: value,
        isExpanded: true,
        icon: Icon(LucideIcons.chevronDown, size: 16, color: semantic.fgSubtle),
        dropdownColor: semantic.bgSurface,
        style: textStyle,
        onChanged: enabled ? onChanged : null,
        decoration: const InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: [
          if (placeholder != null)
            DropdownMenuItem<String>(
              child: Text(
                placeholder!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: semantic.fgSubtle,
                ),
              ),
            ),
          ...options.map(
            (o) => DropdownMenuItem<String>(
              value: o.value,
              child: Text(o.label, style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildFormSelectWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'FormSelect',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const _FormSelectUseCase(),
      ),
    ],
  );
}

class _FormSelectUseCase extends StatefulWidget {
  const _FormSelectUseCase();

  @override
  State<_FormSelectUseCase> createState() => _FormSelectUseCaseState();
}

class _FormSelectUseCaseState extends State<_FormSelectUseCase> {
  String? _value;

  static const _options = [
    AppFormSelectOption(value: 'soja', label: 'Soja'),
    AppFormSelectOption(value: 'milho', label: 'Milho'),
    AppFormSelectOption(value: 'algodao', label: 'Algodão'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFormSelect(
              options: _options,
              value: _value,
              placeholder: 'Selecione a cultura',
              onChanged: (v) => setState(() => _value = v),
            ),
            const SizedBox(height: AppSpacing.space4),
            const AppFormSelect(
              options: _options,
              enabled: false,
              placeholder: 'Desabilitado',
            ),
          ],
        ),
      ),
    );
  }
}
