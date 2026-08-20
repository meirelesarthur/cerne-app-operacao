import 'package:flutter/material.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Cápsula visual compartilhada de todos os campos de formulário do catálogo
/// (`AppTextInput`, `AppFormSelect`, `AppSearchSelect`). Fonte única da altura,
/// do fundo, do raio e do anel de foco — os campos só entregam o conteúdo.
///
/// Por que a cápsula é pintada aqui e não pelo `InputDecoration`: o
/// `InputDecorator` do Material pinta `fillColor`/`border` num container
/// dimensionado pelo **conteúdo** (`_BorderContainer`), não pelas constraints
/// recebidas. Com `isCollapsed: true` + `contentPadding` só-horizontal esse
/// container fica com a altura do texto (~21px) e é alinhado ao topo: o
/// `SizedBox(height: 48)` externo media 48px em teste, mas o pixel visível era
/// uma pílula de 21px — exatamente o "campo fino" reportado. Pintando a cápsula
/// num `Container` nosso, a altura medida e a altura vista são a mesma coisa.
class AppFieldCapsule extends StatelessWidget {
  const AppFieldCapsule({
    super.key,
    required this.child,
    this.focused = false,
    this.invalid = false,
    this.height = AppSpacing.space12,
    this.horizontalPadding = AppSpacing.space5,
    this.leading,
    this.trailing,
  });

  /// Conteúdo do campo (o editor/label). É centralizado verticalmente e ocupa
  /// a largura restante entre `leading` e `trailing`.
  final Widget child;
  final bool focused;
  final bool invalid;

  /// Altura fixa da cápsula. Padrão: 48px (`space12`), a altura de toque do
  /// design. Passe outro token apenas em campos com semântica diferente.
  final double height;
  final double horizontalPadding;
  final Widget? leading;
  final Widget? trailing;

  /// A borda é sempre desenhada com a mesma espessura (mudando só a cor) para
  /// que foco/erro não deslochem o conteúdo em 1px.
  static const double _borderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final Color borderColor;
    if (invalid) {
      borderColor = AppColors.red500;
    } else if (focused) {
      borderColor = semantic.accentDefault;
    } else {
      borderColor = AppColors.transparent;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor, width: _borderWidth),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding - _borderWidth,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.space2),
          ],
          Expanded(child: child),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.space2),
            trailing!,
          ],
        ],
      ),
    );
  }
}
