import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/theme/app_theme_extension.dart';
import '../ui/ui.dart';
import 'components/bottom_tab_bar.dart';
import 'components/context_tabs.dart';
import 'components/credito_pill.dart';
import 'components/reveal_menu.dart';
import 'components/shell_header.dart';
import 'module_config.dart';
import 'state/shell_store.dart';
import 'state/prototype_session_store.dart';

/// Layout do Shell (spec §3.1) — espelha `ShellLayout.tsx`: header global fixo +
/// abas de contexto + conteúdo do módulo ativo + dock de módulos flutuante +
/// menu "reveal". Trocar de módulo troca só o conteúdo, o header persiste.
///
/// Com o menu aberto, o app inteiro encolhe (scale+translateX) revelando o
/// `AppRevealMenu` à direita — únicas responsabilidades deste widget que os
/// componentes filhos documentaram como "de quem monta o shell".
class ShellLayout extends ConsumerWidget {
  const ShellLayout({
    super.key,
    required this.moduleId,
    required this.activeTab,
    required this.child,
  });

  final String moduleId;
  final String activeTab;
  final Widget child;

  void _go(BuildContext context, WidgetRef ref, String route) {
    ref.read(shellStoreProvider.notifier).closeMenu();
    context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = getModule(moduleId) ?? modules.first;
    final state = ref.watch(shellStoreProvider);
    final profile = ref.watch(prototypeSessionProvider).profile;
    final menuOpen = state.menuOpen;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: menuOpen
                  ? AppComponentColors.revealMenuBg
                  : semantic.bgCanvas,
            ),
          ),
          // menu revelado — fica atrás do app encolhido, à direita.
          Positioned.fill(
            child: AppRevealMenu(
              module: module,
              activeRoute: GoRouterState.of(context).uri.toString(),
              onNavigate: (route) => _go(context, ref, route),
            ),
          ),
          // o app inteiro — encolhe como cartão quando o menu abre.
          LayoutBuilder(
            builder: (context, constraints) {
              final shiftX =
                  constraints.maxWidth *
                  (AppComponentMetrics.revealMenuAppShiftX / 100);
              final scale = AppComponentMetrics.revealMenuAppScale;

              return AnimatedContainer(
                duration: reduceMotion ? Duration.zero : AppMotion.slow,
                curve: AppMotion.easingSpring,
                transform: menuOpen
                    ? (Matrix4.identity()
                        ..translateByDouble(shiftX, 0, 0, 1)
                        ..scaleByDouble(scale, scale, scale, 1))
                    : Matrix4.identity(),
                transformAlignment: Alignment.centerLeft,
                clipBehavior: menuOpen ? Clip.antiAlias : Clip.none,
                decoration: menuOpen
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl3),
                        boxShadow: semantic.shadowModal,
                      )
                    : null,
                child: _ShrunkAppTapToClose(
                  menuOpen: menuOpen,
                  onClose: () =>
                      ref.read(shellStoreProvider.notifier).closeMenu(),
                  child: ColoredBox(
                    color: semantic.bgCanvas,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          AppShellHeader(
                            onOpenProfile: () => _go(context, ref, '/perfil'),
                            onOpenNotifications: () =>
                                _go(context, ref, '/notificacoes'),
                            child: AppCreditoPill(
                              onTap: () => _go(context, ref, '/credito'),
                            ),
                          ),
                          AppContextTabs(
                            module: module,
                            profile: profile,
                            activePath: activeTab,
                            onTabSelected: (path) => _go(
                              context,
                              ref,
                              path.isEmpty
                                  ? '/${module.id}'
                                  : '/${module.id}/$path',
                            ),
                          ),
                          if (!state.isOnline)
                            const AppBanner(
                              tone: AppBannerTone.offline,
                              icon: Icon(LucideIcons.cloudOff, size: 14),
                              child: Text(
                                'Você está offline — os lançamentos serão sincronizados quando a conexão voltar.',
                              ),
                            ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppLayout.tabBarClearance,
                                    ),
                                    child: child,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: AppComponentMetrics.tabbarInset,
                                  child: Center(
                                    child: AppBottomTabBar(
                                      activeId: module.id,
                                      onModuleSelected: (id) => _go(
                                        context,
                                        ref,
                                        moduleHomeRoute(
                                          getModule(id)!,
                                          profile,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Com o menu aberto, tocar em área vazia do app encolhido fecha o menu —
/// espelha o botão-overlay invisível do React (`absolute inset-0` ATRÁS do
/// conteúdo). Envolver o conteúdo inteiro (em vez de um overlay separado por
/// cima de tudo) é necessário no Flutter: um overlay `Positioned.fill`
/// desenhado por cima bloquearia também os toques no `AppRevealMenu` ao lado,
/// já que ambos ocupam a Stack inteira. Botões internos (header, tabs, dock)
/// continuam recebendo seus próprios toques normalmente — a arena de gestos
/// do Flutter prioriza o `AppPressable` mais interno.
class _ShrunkAppTapToClose extends StatelessWidget {
  const _ShrunkAppTapToClose({
    required this.menuOpen,
    required this.onClose,
    required this.child,
  });

  final bool menuOpen;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!menuOpen) return child;
    return AppPressable(
      semanticLabel: 'Fechar menu',
      onPressed: onClose,
      minTouchTarget: false,
      showVisualFeedback: false,
      child: child,
    );
  }
}
