import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../ui/ui.dart';

/// Cabeçalho das páginas secundárias do shell e dos fluxos de módulo (Perfil,
/// Notificações, Pedidos, fluxos do Bank, etc.).
///
/// Hoje é só a moldura de espaçamento em volta de [AppScreenHeader]: o layout do
/// topo (voltar à esquerda do título) mora no catálogo, para o app ter **um**
/// padrão de cabeçalho. Antes este widget desenhava o seu próprio topo com o
/// título centralizado, enquanto outras telas colocavam o voltar numa linha
/// acima do título — dois padrões diferentes no mesmo app.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: AppScreenHeader(
        title: title,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
        action: action,
      ),
    );
  }
}
