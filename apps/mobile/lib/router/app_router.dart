import 'package:go_router/go_router.dart';

import '../shell/module_config.dart';
import '../shell/pages/module_placeholder_screen.dart';
import '../shell/pages/placeholder_page.dart';
import '../shell/shell_layout.dart';

/// Router do app — `ShellRoute` (F3.1) com rotas `/:moduleId` e `/:moduleId/:tab`
/// aninhadas, espelhando a navegação de 2 níveis do protótipo React
/// (`react-router-dom`, `ShellLayout` + `Outlet` implícito).
final GoRouter appRouter = GoRouter(
  initialLocation: '/inicio',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/inicio'),
    ShellRoute(
      builder: (context, state, child) {
        final moduleId = state.pathParameters['moduleId'] ?? 'inicio';
        final tab = state.pathParameters['tab'] ?? '';
        return ShellLayout(moduleId: moduleId, activeTab: tab, child: child);
      },
      routes: [
        for (final module in modules)
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
