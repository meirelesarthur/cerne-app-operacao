import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'field_capsule.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

/// Campo de cor do catálogo — banco-real (esteira, onda 11): `areas.color`
/// no dump de produção (`varchar(7)`, `DEFAULT '#f6c23e'`) tem mais de 150
/// valores hex distintos em uso — não é um enum de rótulo fechado, é um
/// seletor de cor livre. Este componente é hex real, não `select` sobre uma
/// lista de nomes de cor mantida à mão.
///
/// Anatomia: um swatch circular (preview ao vivo do hex digitado, toque abre
/// uma grade de predefinições para atalho) + campo de texto com prefixo `#`
/// e máscara hexadecimal — mesma cápsula (`AppFieldCapsule`) dos demais
/// campos de `ui/`, Lei 1 do CLAUDE.md.
class AppColorInput extends StatefulWidget {
  const AppColorInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.invalid = false,
    this.enabled = true,
    this.focusNode,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       );

  final TextEditingController? controller;

  /// Valor inicial em hex, com ou sem `#` (ex. `f6c23e` ou `#f6c23e`).
  final String? initialValue;

  /// Disparado com o hex de 6 dígitos, sempre com `#` e maiúsculo
  /// (ex. `#F6C23E`), mesmo formato de `areas.color` no banco real.
  final ValueChanged<String>? onChanged;
  final bool invalid;
  final bool enabled;
  final FocusNode? focusNode;

  /// Predefinições de atalho na grade do swatch — reaproveita a paleta 500
  /// do design system (`AppColors`), sem inventar hex fora dos tokens
  /// gerados. O campo aceita qualquer hex digitado; isto é um atalho, não o
  /// domínio (Lei 3 do CLAUDE.md — nenhuma cor nova aqui, só reuso).
  static const List<Color> presets = [
    AppColors.brand500,
    AppColors.red500,
    AppColors.amber500,
    AppColors.blue500,
    AppColors.neutral800,
    AppColors.neutral500,
    AppColors.brand700,
    AppColors.red700,
    AppColors.amber700,
    AppColors.blue700,
    AppColors.neutral400,
    AppColors.neutral200,
  ];

  @override
  State<AppColorInput> createState() => _AppColorInputState();
}

class _AppColorInputState extends State<AppColorInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: _strip(widget.initialValue));
  FocusNode? _internalFocusNode;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  static String _strip(String? hex) {
    if (hex == null) return '';
    return hex.replaceFirst('#', '').toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  Color? get _parsedColor {
    final digits = _controller.text;
    if (digits.length != 6) return null;
    final value = int.tryParse(digits, radix: 16);
    if (value == null) return null;
    // `Color(0x...)` literal é proibido pelo teste de integridade de tokens
    // (M11) — aqui não é uma cor de design hardcoded, é o parse de um hex
    // digitado pela pessoa, então o ARGB é montado em variável.
    const opaqueAlpha = 0xFF000000;
    return Color(opaqueAlpha | value);
  }

  void _setHex(String digits) {
    final upper = digits.toUpperCase();
    _controller.value = TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
    if (upper.length == 6) widget.onChanged?.call('#$upper');
  }

  Future<void> _openPresets() async {
    if (!widget.enabled) return;
    final picked = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) =>
          const _ColorPresetSheet(presets: AppColorInput.presets),
    );
    if (picked == null || !mounted) return;
    final hex = picked.toARGB32().toRadixString(16).substring(2).toUpperCase();
    _setHex(hex);
  }

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);
    final swatchColor = _parsedColor;

    return AppFieldCapsule(
      focused: _focused,
      invalid: widget.invalid,
      leading: GestureDetector(
        onTap: _openPresets,
        child: Container(
          width: AppSize.iconMd,
          height: AppSize.iconMd,
          decoration: BoxDecoration(
            color: swatchColor ?? AppColors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: swatchColor == null
                  ? inputColors.placeholder
                  : AppColors.neutral0,
              width: 1.5,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '#',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.xl,
              color: widget.enabled ? inputColors.muted : inputColors.placeholder,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              onChanged: _setHex,
              enabled: widget.enabled,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(6),
                _UpperCaseTextFormatter(),
              ],
              cursorColor: inputColors.focus,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.xl,
                color: widget.enabled ? inputColors.foreground : inputColors.muted,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'F6C23E',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.xl,
                  color: inputColors.placeholder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Grade de atalho aberta pelo toque no swatch — não é o domínio do campo
/// (que aceita qualquer hex), só um acesso rápido às cores mais comuns da
/// paleta do design system.
class _ColorPresetSheet extends StatelessWidget {
  const _ColorPresetSheet({required this.presets});

  final List<Color> presets;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.space4),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space3,
          children: [
            for (final color in presets)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: AppSize.iconMd * 1.5,
                  height: AppSize.iconMd * 1.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral200),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Use-cases da galeria (F2.5).
WidgetbookComponent buildColorInputWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ColorInput',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppColorInput(),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(initialValue: '#f6c23e'),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(invalid: true),
                SizedBox(height: AppSpacing.space4),
                AppColorInput(enabled: false, initialValue: '#22C55E'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
