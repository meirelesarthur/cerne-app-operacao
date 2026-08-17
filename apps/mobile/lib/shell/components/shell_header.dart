import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/shell_store.dart';
import '../state/prototype_session_store.dart';

/// Header global do Shell (Nova UI): zona clara sobre o canvas — avatar +
/// saudação à esquerda, bolhas de ação circulares à direita. Persiste ao
/// trocar de módulo; espelha `ShellHeader.tsx`.
///
/// Decisão de porte: as rotas `/perfil` e `/notificacoes` ainda não existem no
/// `go_router` (isso é F3.1, feito por outro processo depois). Por isso este
/// widget recebe [onOpenProfile]/[onOpenNotifications] como callbacks opcionais
/// em vez de navegar direto — quem monta o header no `ShellLayout` conecta ao
/// router quando as rotas existirem.
class AppShellHeader extends ConsumerWidget {
  const AppShellHeader({
    super.key,
    this.onConsultMode,
    this.consultActive = false,
    this.onOpenProfile,
    this.onOpenNotifications,
    this.child,
  });

  /// Callback do ícone "olho" (modo consulta) — contextual ao módulo ativo
  /// (spec §3.3/§6.1). Quando nulo, o botão não é exibido — equivalente a
  /// `onConsultMode &&` no React.
  final VoidCallback? onConsultMode;
  final bool consultActive;

  /// Navegação para `/perfil` — ver nota de decisão acima.
  final VoidCallback? onOpenProfile;

  /// Navegação para `/notificacoes` — ver nota de decisão acima.
  final VoidCallback? onOpenNotifications;

  /// Slot de contexto do módulo ativo (ex.: `AppCreditoPill`) — equivalente ao
  /// `children` do React; aqui é um único `child` porque só há um consumidor
  /// real (a pílula de crédito).
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final state = ref.watch(shellStoreProvider);
    final profile = ref.watch(prototypeSessionProvider).profile;
    final user = state.user;
    final unread = state.unreadCount;
    final menuOpen = state.menuOpen;

    // Determinístico no protótipo (sem Date.now/relógio real) — replica
    // exatamente `ShellHeader.tsx`, que fixa a hora em 8 (resulta em "Bom dia").
    const hour = 8;
    const greeting = hour < 12
        ? 'Bom dia'
        : (hour < 18 ? 'Boa tarde' : 'Boa noite');

    return ColoredBox(
      color: semantic.bgCanvas,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppPressable(
                    semanticLabel: 'Abrir perfil',
                    onPressed: onOpenProfile,
                    minTouchTarget: false,
                    child: Row(
                      children: [
                        AppAvatar(
                          name: user.name,
                          initials: user.initials,
                          size: AppAvatarSize.lg,
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$greeting,',
                                style: TextStyle(
                                  fontSize: AppTypography.md,
                                  fontWeight: AppTypography.weightMedium,
                                  height: AppTypography.lineHeightTight,
                                  color: semantic.fgMuted,
                                ),
                              ),
                              Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppTypography.xl2,
                                  fontWeight: AppTypography.weightBold,
                                  height: AppTypography.lineHeightTight,
                                  color: semantic.fgDefault,
                                ),
                              ),
                              if (profile != null)
                                Text(
                                  'Ambiente ${profile.label}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppTypography.xs,
                                    fontWeight: AppTypography.weightSemibold,
                                    color: semantic.accentDefault,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onConsultMode != null) ...[
                      _headerBubble(
                        icon: const Icon(LucideIcons.eye, size: 19),
                        label: consultActive
                            ? 'Sair do modo consulta'
                            : 'Modo consulta',
                        active: consultActive,
                        onPressed: onConsultMode,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                    ],
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppIconButton(
                          icon: const Icon(LucideIcons.bell, size: 19),
                          label: 'Notificações',
                          variant: AppIconButtonVariant.solid,
                          size: AppIconButtonSize.lg,
                          onPressed: onOpenNotifications,
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 10,
                            top: 8,
                            child: IgnorePointer(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.red500,
                                  border: Border.all(
                                    color: semantic.bgSurface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    _headerBubble(
                      icon: const Icon(LucideIcons.menu, size: 19),
                      label: 'Mais',
                      active: menuOpen,
                      onPressed: () =>
                          ref.read(shellStoreProvider.notifier).openMenu(),
                    ),
                  ],
                ),
              ],
            ),
            if (child != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space3),
                child: Align(alignment: Alignment.centerLeft, child: child!),
              ),
          ],
        ),
      ),
    );
  }

  /// Bolha do header com estado "ativo" (modo consulta ligado / menu aberto).
  /// No React o estado ativo usa `bg-ink text-ink-fg` sólido; o catálogo
  /// `AppIconButton` não tem essa variante exata (só `ghost`/`solid`/`onDark`,
  /// onde `onDark` usa `inkBubble` semitransparente). Usamos `onDark` como a
  /// aproximação mais próxima disponível sem editar `icon_button.dart`
  /// (fora do escopo desta tarefa) — desvio documentado.
  Widget _headerBubble({
    required Widget icon,
    required String label,
    required bool active,
    required VoidCallback? onPressed,
  }) {
    return AppIconButton(
      icon: icon,
      label: label,
      size: AppIconButtonSize.lg,
      variant: active
          ? AppIconButtonVariant.onDark
          : AppIconButtonVariant.solid,
      onPressed: onPressed,
    );
  }
}
