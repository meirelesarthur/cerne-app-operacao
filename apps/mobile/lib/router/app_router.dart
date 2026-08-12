import 'package:go_router/go_router.dart';

import '../modules/armazem/armazem_module.dart';
import '../modules/bank/bank_module.dart';
import '../modules/credito/credito_module.dart';
import '../modules/fazendas/fazendas_module.dart';
import '../modules/hub/hub_module.dart';
import '../modules/marketplace/marketplace_module.dart';
import '../shell/module_config.dart';
import '../shell/pages/login_page.dart';
import '../shell/pages/module_placeholder_screen.dart';
import '../shell/pages/notificacoes_page.dart';
import '../shell/pages/onboarding_page.dart';
import '../shell/pages/perfil_config_page.dart';
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
        buildFazendasModuleRoute(),
        buildBankModuleRoute(),
        buildCreditoModuleRoute(),
        buildMarketplaceModuleRoute(),
        buildArmazemModuleRoute(),
        for (final module in modules.where((m) => !_wiredModules.contains(m.id)))
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
    GoRoute(path: '/perfil', builder: (context, state) => const PerfilConfigPage()),
    GoRoute(path: '/notificacoes', builder: (context, state) => const NotificacoesPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
  ],
);

/// Módulos com rota real registrada (todos, após a F4) — o loop genérico de
/// `ModulePlaceholderScreen` abaixo só existe como rede de segurança para um
/// módulo futuro sem tela própria ainda.
const _wiredModules = {'inicio', 'fazendas', 'bank', 'credito', 'marketplace', 'armazem'};

String _tabLabel(ModuleDef module, String tabPath) {
  for (final tab in module.bottomTabs) {
    if (tab.path == tabPath) return tab.label;
  }
  return tabPath;
}
