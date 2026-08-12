import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/theme/app_theme_extension.dart';
import 'admin/admin_dashboard.dart';
import 'components/sync_banner.dart';
import 'operacional/campo_flow.dart';
import 'screens/atividades_screen.dart';
import 'screens/farm_list_screen.dart';
import 'screens/fazendas_home.dart';
import 'screens/mais_screen.dart';
import 'screens/sync_queue_screen.dart';

/// Rotas do módulo Fazendas (ex-"Cerne") — espelha `FazendasModule.tsx`.
/// Registrado no `ShellRoute` principal (`lib/router/app_router.dart`), no
/// mesmo padrão de `buildHubModuleRoute()`.
///
/// A troca de fazenda ativa vive na tela dedicada (tab "Fazendas" /
/// `FarmListScreen`); o switch Gerencial ⇄ Campo vive no menu "Mais"
/// (`AppRevealMenu`, via `ViewSwitch` — ver `components/view_switch.dart`).
GoRoute buildFazendasModuleRoute() {
  return GoRoute(
    path: '/fazendas',
    builder: (context, state) => const _FazendasScaffold(child: FazendasHome()),
    routes: [
      GoRoute(
        path: 'atividades',
        builder: (context, state) => const _FazendasScaffold(child: AtividadesScreen()),
      ),
      GoRoute(
        path: 'fazendas',
        builder: (context, state) => const _FazendasScaffold(child: FarmListScreen()),
      ),
      GoRoute(
        path: 'financeiro',
        // `DashFinanceiro` real vem do processo dos dashboards administrativos
        // (F3); por ora, delega ao dispatcher `AdminDashboard`, igual ao dashId
        // homônimo em `/fazendas/dashboards/financeiro`.
        builder: (context, state) => _FazendasScaffold(child: buildAdminDashboard('financeiro')),
      ),
      GoRoute(
        path: 'mais',
        builder: (context, state) => const _FazendasScaffold(child: MaisScreen()),
      ),
      GoRoute(
        path: 'mais/sync',
        builder: (context, state) => const _FazendasScaffold(child: SyncQueueScreen()),
      ),
      GoRoute(
        path: 'dashboards/:dashId',
        builder: (context, state) => _FazendasScaffold(child: buildAdminDashboard(state.pathParameters['dashId']!)),
      ),
      GoRoute(
        path: 'campo/:flowId',
        builder: (context, state) => _FazendasScaffold(child: buildCampoFlow(state.pathParameters['flowId']!)),
      ),
    ],
  );
}

/// Scaffold do próprio módulo (equivalente ao `<div className="flex h-full
/// flex-col">` de `FazendasModule.tsx`): `SyncBanner` fixo no topo + conteúdo
/// do módulo abaixo.
///
/// Desvio consciente do React: lá, o próprio `FazendasModule` aplica o padding
/// inferior (`AppLayout.tabBarClearance`) na área rolável. Na porta Flutter,
/// esse respiro para o dock de módulos já é aplicado uma única vez, de forma
/// global, pelo `ShellLayout` (`shell/shell_layout.dart`, `Padding(bottom:
/// AppLayout.tabBarClearance)` ao redor do `child` roteado) — o mesmo padrão
/// que as telas do hub (`hub_home_screen.dart`, `carteira_screen.dart`) já
/// seguem, sem duplicar o respiro por módulo. Reaplicá-lo aqui somaria as duas
/// paddings (Lei 2 — fonte única do espaçamento).
class _FazendasScaffold extends StatelessWidget {
  const _FazendasScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return ColoredBox(
      color: semantic.bgCanvas,
      child: Column(
        children: [
          const SyncBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
