import 'package:go_router/go_router.dart';

import '../modules/hub/hub_module.dart';
import '../shell/module_config.dart';
import '../shell/pages/module_placeholder_screen.dart';
import '../shell/pages/placeholder_page.dart';
import '../shell/shell_layout.dart';

/// Router do app — `ShellRoute` (F3.1) com rotas `/:moduleId` e `/:moduleId/:tab`
/// aninhadas, espelhando a navegação de 2 níveis do protótipo React
/// (`react-router-dom`, `ShellLayout` + `Outlet` implícito).
///
/// Cada rota de módulo usa um segmento literal (`/bank`, não `/:moduleId`) —
/// por isso o `moduleId`/`tab` ativos são derivados de `state.uri.pathSegments`
/// dentro do builder do `ShellRoute`, não de `state.pathParameters` (não há
/// parâmetro nomeado `:moduleId` em nenhuma rota).
final GoRouter appRouter = GoRouter(
  initialLocation: '/inicio',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/inicio'),
    ShellRoute(
      builder: (context, state, child) {
        final segments = state.uri.pathSegments;
        final moduleId = segments.isNotEmpty ? segments.first : 'inicio';
        final tab = segments.length > 1 ? segments[1] : '';
        return ShellLayout(moduleId: moduleId, activeTab: tab, child: child);
      },
      routes: [
        buildHubModuleRoute(),
        for (final module in modules.where((m) => m.id != 'inicio'))
          GoRoute(
            path: '/${module.id}',
            builder: (context, state) => ModulePlaceholderScreen(
              moduleLabel: module.label,
              tabLabel: _tabLabel(module, ''),
            ),
            routes: [
              GoRoute(
                path: ':tab',
                builder: (context, state) {
                  final tab = state.pathParameters['tab']!;
                  return ModulePlaceholderScreen(moduleLabel: module.label, tabLabel: _tabLabel(module, tab));
                },
              ),
            ],
          ),
      ],
    ),
    GoRoute(path: '/perfil', builder: (context, state) => const PlaceholderPage(title: 'Perfil')),
    GoRoute(path: '/notificacoes', builder: (context, state) => const PlaceholderPage(title: 'Notificações')),
    GoRoute(path: '/login', builder: (context, state) => const PlaceholderPage(title: 'Login')),
  ],
);

String _tabLabel(ModuleDef module, String tabPath) {
  for (final tab in module.bottomTabs) {
    if (tab.path == tabPath) return tab.label;
  }
  return tabPath;
}
