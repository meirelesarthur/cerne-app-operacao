import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../ui/ui.dart';

/// Cabeçalho das páginas secundárias do shell e dos fluxos de módulo (Perfil,
/// Notificações, Pedidos, fluxos do Bank, etc.).
///
/// É a moldura de espaçamento em volta de [AppTopBar] — a barra superior do
/// padrão global (Figma `54349:2081`): voltar de 32 px, título centralizado de
/// 18 px e ação opcional à direita. Fica **sobre o canvas**, acima da folha de
/// conteúdo, exatamente como nos frames de cadastro da referência.
///
/// Substituiu `AppScreenHeader` aqui: aquele é cabeçalho de página (título à
/// esquerda, descrição, rótulo "Voltar" textual) e continua servindo telas que
/// precisam de descrição; este é o cromo de navegação de altura fixa.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;

  /// Ação de overflow à direita do título.
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Conteúdo livre à direita, quando a ação não cabe num glifo (selo de
  /// acesso restrito, "Marcar lidas").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: AppTopBar(
        title: title,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
        actionIcon: actionIcon,
        actionLabel: actionLabel,
        onAction: onAction,
        trailing: action,
      ),
    );
  }
}
