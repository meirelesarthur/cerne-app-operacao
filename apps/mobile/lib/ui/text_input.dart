import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `TextInput.tsx` — campo-cápsula (Nova UI): pílula cheia (`rounded-full`),
/// fundo sutil, sem borda dura. Encapsula `TextFormField` para cumprir a Lei 1
/// (telas nunca usam `TextField`/`TextFormField` cru).
class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.invalid = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller OU initialValue, não os dois.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? placeholder;

  /// Equivalente à prop `invalid` do React: borda vermelha sem bloquear a digitação.
  final bool invalid;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final radius = BorderRadius.circular(AppRadius.full);

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    // `constraints.minHeight` sozinho não garante 48px reais: é só um piso, e
    // o `InputDecorator` calcula a altura pelo conteúdo (texto + padding
    // vertical) — com `contentPadding` só horizontal, o padding vertical cai
    // pra 0 e o campo "encolhe" visualmente por dentro da pílula. A forma
    // robusta é travar a altura de fora (`SizedBox`, que impõe constraints
    // tight — o filho É forçado a exatamente 48px) e usar `isCollapsed` pra
    // desligar o cálculo de padding automático do decorator por cima disso.
    // (Nada de `expands`/`maxLines: null` aqui: incompatível com
    // `obscureText` — o `SizedBox` sozinho já basta, testado empiricamente.)
    return SizedBox(
      height: AppSpacing.space12,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: semantic.accentDefault,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.md,
          color: enabled ? semantic.fgDefault : semantic.fgMuted,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          filled: true,
          fillColor: semantic.bgSubtle,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.md,
            color: semantic.fgSubtle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: border(AppColors.transparent),
          enabledBorder: border(
            invalid ? AppColors.red500 : AppColors.transparent,
          ),
          disabledBorder: border(AppColors.transparent),
          focusedBorder: border(
            invalid ? AppColors.red500 : semantic.accentDefault,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Use-cases da galeria (F2.5).
WidgetbookComponent buildTextInputWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'TextInput',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const _TextInputUseCase(),
      ),
    ],
  );
}

class _TextInputUseCase extends StatefulWidget {
  const _TextInputUseCase();

  @override
  State<_TextInputUseCase> createState() => _TextInputUseCaseState();
}

class _TextInputUseCaseState extends State<_TextInputUseCase> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextInput(
              controller: _controller,
              placeholder: 'Digite algo...',
            ),
            const SizedBox(height: AppSpacing.space4),
            const AppTextInput(placeholder: 'Campo inválido', invalid: true),
            const SizedBox(height: AppSpacing.space4),
            const AppTextInput(placeholder: 'Desabilitado', enabled: false),
          ],
        ),
      ),
    );
  }
}
