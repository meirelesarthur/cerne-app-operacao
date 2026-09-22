import 'package:go_router/go_router.dart';

import 'screens/apps_screen.dart';
import 'screens/hub_home_screen.dart';

/// Rotas do módulo Início — espelha `HubModule.tsx`. Registrado no `ShellRoute`
/// principal (`lib/router/app_router.dart`).
GoRoute buildHubModuleRoute() {
  return GoRoute(
    path: '/inicio',
    builder: (context, state) => const HubHomeScreen(),
    routes: [
      GoRoute(path: 'apps', builder: (context, state) => const AppsScreen()),
    ],
  );
}
