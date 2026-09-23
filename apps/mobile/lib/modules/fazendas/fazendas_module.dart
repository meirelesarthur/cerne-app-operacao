import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'components/sync_banner.dart';
import 'functional_catalog.dart';
import 'operacional/campo_flow.dart';
import 'operacional/minhas_os_screen.dart';
import 'screens/atividades_screen.dart';
import 'screens/farm_list_screen.dart';
import 'screens/fazendas_home.dart';
import 'screens/group_features_screen.dart';
import 'screens/mais_screen.dart';
import 'screens/mapped_feature_screen.dart';

/// Rotas do módulo Fazendas (ex-"Cerne") — espelha `FazendasModule.tsx`.
/// Registrado no `ShellRoute` principal (`lib/router/app_router.dart`), no
/// mesmo padrão de `buildHubModuleRoute()`.
///
/// A troca de fazenda ativa vive na tela dedicada (tab "Fazendas"). O app tem
/// só o perfil Operacional.
GoRoute buildFazendasModuleRoute() {
  return GoRoute(
    path: '/fazendas',
    builder: (context, state) => const _FazendasScaffold(child: FazendasHome()),
    routes: [
      GoRoute(
        path: 'operacional',
        // Tela inicial do Operacional: as ordens de serviço do funcionário
        // (aba "OSs" da navbar). Os grupos do catálogo que antes formavam a
        // grade desta tela vivem no menu lateral (`AppRevealMenu`).
        builder: (context, state) =>
            const _FazendasScaffold(child: MinhasOsScreen(embedded: true)),
        routes: [
          GoRoute(
            path: 'grupo/:group',
            builder: (context, state) => _FazendasScaffold(
              child: GroupFeaturesScreen(
                groupSlug: state.pathParameters['group']!,
                profile: FeatureProfile.operational,
                embedded: true,
              ),
            ),
          ),
          GoRoute(
            path: ':featureId',
            builder: (context, state) => _FazendasScaffold(
              child: MappedFeatureScreen(
                featureId: state.pathParameters['featureId']!,
                profile: FeatureProfile.operational,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'atividades',
        builder: (context, state) =>
            const _FazendasScaffold(child: AtividadesScreen()),
      ),
      GoRoute(
        path: 'fazendas',
        builder: (context, state) =>
            const _FazendasScaffold(child: FarmListScreen()),
      ),
      GoRoute(
        path: 'mais',
        builder: (context, state) =>
            const _FazendasScaffold(child: MaisScreen()),
      ),
      GoRoute(
        path: 'campo/:flowId',
        builder: (context, state) => _FazendasScaffold(
          child: buildCampoFlow(state.pathParameters['flowId']!),
        ),
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
/// esse respiro para o dock de módulos é aplicado uma única vez, de forma
/// global, pelo `ShellLayout` quando a rota está rasa e o dock está visível.
/// Rotas profundas de cadastro usam a área liberada integralmente — sem
/// duplicar o respiro por módulo (Lei 2 — fonte única do espaçamento).
class _FazendasScaffold extends StatelessWidget {
  const _FazendasScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Sem `ColoredBox` de canvas: quem pinta o fundo é a folha de conteúdo do
    // shell (`AppContentSheet`), e repintar o canvas aqui cobria a folha —
    // deixava o cabeçalho sobre a superfície clara e o resto da tela sobre o
    // cinza, com uma emenda visível logo abaixo das abas.
    return Column(
      children: [
        const SyncBanner(),
        Expanded(child: child),
      ],
    );
  }
}
