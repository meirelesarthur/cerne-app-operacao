import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/fazendas/fazendas_module.dart';
import '../modules/fazendas/screens/busca_global_screen.dart';
import '../shell/pages/login_page.dart';
import '../shell/pages/notificacoes_page.dart';
import '../shell/pages/onboarding_page.dart';
import '../shell/pages/perfil_config_page.dart';
import '../shell/shell_layout.dart';
import '../shell/state/prototype_session_store.dart';

/// Router do app — `ShellRoute` (F3.1) com rotas `/:moduleId` e `/:moduleId/:tab`
/// aninhadas, espelhando a navegação de 2 níveis do protótipo React
/// (`react-router-dom`, `ShellLayout` + `Outlet` implícito).
///
/// A rota do módulo usa um segmento literal (`/fazendas`, não `/:moduleId`) —
/// por isso o `moduleId`/`tab` ativos são derivados de `state.uri.pathSegments`
/// dentro do builder do `ShellRoute`, não de `state.pathParameters` (não há
/// parâmetro nomeado `:moduleId` em nenhuma rota).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen<PrototypeSessionState>(prototypeSessionProvider, (previous, next) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(prototypeSessionProvider);
      return redirectForSession(state.uri.path, session);
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => UserAccessProfile.operational.homeRoute,
      ),
      ShellRoute(
        builder: (context, state, child) {
          final segments = state.uri.pathSegments;
          final moduleId = segments.isNotEmpty ? segments.first : 'fazendas';
          final tab = segments.length > 1 ? segments[1] : '';
          // A central de um grupo é um estado intermediário: mantém o
          // seletor de fazenda e o dock operacional, mas remove a saudação e
          // as abas para a própria tela renderizar busca + cards.
          // Funcionalidades, dashboards e fluxos continuam sendo telas
          // fundas, sem chrome.
          final isGroup = segments.length > 2 && segments[2] == 'grupo';
          final isDeep = segments.length > 2 && !isGroup;
          return ShellLayout(
            moduleId: moduleId,
            activeTab: tab,
            hideChrome: isDeep,
            compactChrome: isGroup,
            child: child,
          );
        },
        routes: [buildFazendasModuleRoute()],
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilConfigPage(),
      ),
      GoRoute(
        path: '/notificacoes',
        builder: (context, state) => const NotificacoesPage(),
      ),
      // Busca global de funcionalidades. Fica fora do `ShellRoute` — como
      // `/perfil` e `/notificacoes` — porque é tela cheia: quem busca quer a
      // lista, não o cromo do app. A tela vive no módulo Fazendas, onde mora o
      // catálogo funcional que ela pesquisa; a rota é de topo, onde mora a sua
      // navegação.
      GoRoute(
        path: '/busca',
        builder: (context, state) => const BuscaGlobalScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// Política única de acesso do protótipo, separada do roteador para permitir
/// testes determinísticos de deep links e perfis cruzados.
String? redirectForSession(String path, PrototypeSessionState session) {
  final isPublic = path == '/login' || path == '/onboarding';
  final profile = session.profile;

  if (profile == null) {
    // O login é a porta de entrada real do protótipo (ver `initialLocation`)
    // — sem sessão, qualquer rota protegida cai nele.
    return isPublic ? null : '/login';
  }

  if (path == '/' || path == '/fazendas' || path == '/login') {
    return path == '/fazendas' ? profile.homeRoute : profile.landingRoute;
  }
  if (path == '/fazendas/mais') return profile.homeRoute;
  if (path == '/onboarding') return null;

  return null;
}
