import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_motion.dart';
import '../design/theme/app_theme_extension.dart';
import '../modules/fazendas/components/farm_picker.dart';
import '../modules/fazendas/state/fazendas_store.dart';
import '../ui/ui.dart';
import 'components/bottom_tab_bar.dart';
import 'components/quick_add_sheet.dart';
import 'components/shell_header.dart';
import 'module_config.dart';
import 'state/shell_store.dart';
import 'state/prototype_session_store.dart';

/// Layout do Shell (spec §3.1) — espelha `ShellLayout.tsx`: header global fixo +
/// abas de contexto + conteúdo do módulo ativo + navbar flutuante. Trocar de
/// módulo troca só o conteúdo, o header persiste. Não há menu lateral: a
/// navegação é a navbar e os atalhos da tela inicial.
class ShellLayout extends ConsumerStatefulWidget {
  const ShellLayout({
    super.key,
    required this.moduleId,
    required this.activeTab,
    required this.child,
    this.hideChrome = false,
    this.compactChrome = false,
  });

  final String moduleId;
  final String activeTab;
  final Widget child;

  /// Quando `true` (rota mais funda que `/modulo/aba`, ex.: uma
  /// funcionalidade ou dashboard específico), o header global e as abas de
  /// contexto somem — quem mostra navegação/título ali é a própria tela
  /// (botão "Voltar", `SubPageHeader`, etc.), e o espaço liberado vai para o
  /// conteúdo da função.
  final bool hideChrome;

  /// Central de um módulo (`/fazendas/operacional/grupo/...`): mantém o
  /// contexto da fazenda e o dock operacional, mas entrega a saudação, o
  /// perfil e as abas para a tela interna ganhar espaço para sua própria
  /// busca e grade de funções.
  final bool compactChrome;

  @override
  ConsumerState<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends ConsumerState<ShellLayout> {
  /// Header global colapsado (ver plano de UX): rolar a tela do módulo para
  /// baixo esconde avatar/saudação/nome (`AppShellHeader.collapsed`), deixando
  /// só as bolhas de ação — libera ~74px de tela durante a tarefa. Nas rotas
  /// completas, as abas de contexto continuam visíveis (só o bloco de
  /// identidade colapsa).
  bool _headerCollapsed = false;

  @override
  void didUpdateWidget(covariant ShellLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nova tela/aba: volta a mostrar a identidade completa em vez de manter o
    // header colapsado de onde a pessoa rolou na tela anterior.
    if (oldWidget.moduleId != widget.moduleId ||
        oldWidget.activeTab != widget.activeTab ||
        oldWidget.compactChrome != widget.compactChrome) {
      _headerCollapsed = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    // Ignora rolagens horizontais (carrosséis dentro da tela) — só a rolagem
    // vertical do conteúdo principal decide o colapso do header.
    if (metrics.axis != Axis.vertical) return false;
    final shouldCollapse = metrics.pixels > 24;
    if (shouldCollapse != _headerCollapsed) {
      setState(() => _headerCollapsed = shouldCollapse);
    }
    return false;
  }

  void _openSearch(BuildContext context) => context.push('/busca');

  /// Dock do "+" aberta — o "+" da navbar vira "×" enquanto isso.
  bool _quickAddOpen = false;

  Future<void> _openQuickAdd(BuildContext context) async {
    setState(() => _quickAddOpen = true);
    final picked = await showQuickAddOverlay(
      context,
      items: operationalQuickAdds(),
    );
    if (!mounted) return;
    setState(() => _quickAddOpen = false);
    if (picked != null && context.mounted) {
      context.push(picked.route);
    }
  }

  /// Corpo do módulo: faixa de offline (quando aplicável) e a tela em si.
  /// Ocupa toda a altura disponível; o dock flutuante é desenhado por cima na
  /// Stack do shell, sem encurtar nem recortar o viewport do conteúdo.
  Widget _content(ShellState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Column(
        children: [
          if (!state.isOnline)
            const AppBanner(
              tone: AppBannerTone.offline,
              icon: AppIcon(AppIcons.cloudOff, size: AppSize.iconXs),
              child: Text(
                'Você está offline — os lançamentos serão sincronizados quando a conexão voltar.',
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shellStoreProvider);
    final profile = ref.watch(prototypeSessionProvider).profile;
    final activeFarm = ref.watch(fazendasStoreProvider).activeFarm;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final hideChrome = widget.hideChrome;
    final compactChrome = widget.compactChrome;
    final showGlobalContext = !hideChrome && profile != null;
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            // Rotas fundas mantêm o topo sobre o canvas: nos frames de
            // cadastro do Figma a barra superior fica *acima* da folha, e é a
            // própria tela que abre a folha logo abaixo dela. Nas rotas rasas
            // o shell abre a folha aqui, com o cabeçalho e as abas dentro —
            // como nas duas homes da referência.
            child: hideChrome
                ? _content(state)
                : AppContentSheet(
                    padded: false,
                    header: showGlobalContext
                        ? AppFarmSelector(
                            farmName: activeFarm.name,
                            onTap: () => openFarmPicker(context, ref),
                          )
                        : null,
                    child: Column(
                      children: [
                        if (!compactChrome)
                          AnimatedSize(
                            duration: reduceMotion
                                ? Duration.zero
                                : AppMotion.base,
                            curve: AppMotion.easingOut,
                            alignment: Alignment.topCenter,
                            child: AppShellHeader(
                              collapsed: _headerCollapsed,
                              showProfileSubtitle: false,
                              onOpenProfile: () => context.push('/perfil'),
                              onOpenNotifications: () =>
                                  context.push('/notificacoes'),
                              child: showGlobalContext
                                  ? AppSearchField(
                                      onTap: () => _openSearch(context),
                                    )
                                  : null,
                            ),
                          ),
                        Expanded(child: _content(state)),
                      ],
                    ),
                  ),
          ),
          if (!hideChrome)
            Positioned(
              left: AppComponentMetrics.tabbarInset,
              right: AppComponentMetrics.tabbarInset,
              // soma o respiro do token à safe-area inferior real do aparelho
              // (home indicator/gesture bar) — sem isso a cápsula flutuante
              // fica colada/sobreposta pela área do sistema em telas com esse
              // recurso.
              bottom:
                  AppComponentMetrics.tabbarInset +
                  MediaQuery.of(context).padding.bottom,
              child: Center(
                child: AppBottomTabBar(
                  tabs: operationalBottomTabs,
                  quickAddOpen: _quickAddOpen,
                  activeId: _operationalTabFor(currentPath),
                  onSelected: (tab) {
                    if (tab.action == quickAddAction) {
                      _openQuickAdd(context);
                    } else {
                      context.go('/fazendas/${tab.path}');
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Aba da navbar operacional destacada para a rota atual. Grupos que só
/// existem nos atalhos da tela inicial (Reprodução, Máquinas…) não acendem
/// nenhuma aba — destacar "Início" ali diria que a pessoa está na tela
/// inicial.
String _operationalTabFor(String path) {
  if (path.contains('/grupo/pecuaria')) return 'pecuaria';
  if (path.contains('/grupo/agricultura')) return 'agricultura';
  if (path.contains('/grupo/confinamento')) return 'confinamento';
  if (path.contains('/grupo/')) return '';
  return 'inicio';
}
