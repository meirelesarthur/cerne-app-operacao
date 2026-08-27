import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/theme/app_theme_extension.dart';
import 'admin/admin_dashboard.dart';
import 'components/sync_banner.dart';
import 'functional_catalog.dart';
import 'operacional/campo_flow.dart';
import 'screens/atividades_screen.dart';
import 'screens/farm_list_screen.dart';
import 'screens/fazendas_home.dart';
import 'screens/group_features_screen.dart';
import 'screens/mais_screen.dart';
import 'screens/mapped_feature_screen.dart';
import 'screens/responsibility_workspace.dart';
import 'screens/sync_queue_screen.dart';

/// Rotas do módulo Fazendas (ex-"Cerne") — espelha `FazendasModule.tsx`.
/// Registrado no `ShellRoute` principal (`lib/router/app_router.dart`), no
/// mesmo padrão de `buildHubModuleRoute()`.
///
/// A troca de fazenda ativa vive na tela dedicada (tab "Fazendas"). O perfil
/// da sessão define se o ambiente é Administração ou Operacional.
GoRoute buildFazendasModuleRoute() {
  return GoRoute(
    path: '/fazendas',
    builder: (context, state) => const _FazendasScaffold(child: FazendasHome()),
    routes: [
      GoRoute(
        path: 'administracao',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(
            profile: FeatureProfile.administration,
          ),
        ),
        routes: [
          GoRoute(
            path: 'grupo/:group',
            builder: (context, state) => _FazendasScaffold(
              child: GroupFeaturesScreen(
                groupSlug: state.pathParameters['group']!,
                profile: FeatureProfile.administration,
              ),
            ),
          ),
          GoRoute(
            path: ':featureId',
            builder: (context, state) => _FazendasScaffold(
              child: MappedFeatureScreen(
                featureId: state.pathParameters['featureId']!,
                profile: FeatureProfile.administration,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'operacional',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(profile: FeatureProfile.operational),
        ),
        routes: [
          GoRoute(
            path: 'grupo/:group',
            builder: (context, state) => _FazendasScaffold(
              child: GroupFeaturesScreen(
                groupSlug: state.pathParameters['group']!,
                profile: FeatureProfile.operational,
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
        path: 'financeiro',
        // Atalho legado; hoje resolve no painel Resultado, mesma tela do dashId
        // `resultado` (e dos aliases `financeiro`/`pecuaria`).
        builder: (context, state) =>
            _FazendasScaffold(child: buildAdminDashboard('resultado')),
      ),
      GoRoute(
        path: 'mais',
        builder: (context, state) =>
            const _FazendasScaffold(child: MaisScreen()),
      ),
      GoRoute(
        path: 'mais/sync',
        builder: (context, state) =>
            const _FazendasScaffold(child: SyncQueueScreen()),
      ),
      // Consultas Gerenciais e 100% leitura, sem indicador e sem acao: e um
      // console de consulta, nao um painel de decisao. Fica fora de
      // `dashboards/` para o menu nao ensinar errado o que e painel — o dashId
      // antigo continua resolvendo pelo dispatcher, para links salvos.
      // Ver docs/ESTEIRA-DASHBOARDS-ADM.md, secao 2.
      GoRoute(
        path: 'consultas',
        builder: (context, state) =>
            _FazendasScaffold(child: buildAdminDashboard('consultas')),
      ),
      GoRoute(
        path: 'dashboards/:dashId',
        builder: (context, state) => _FazendasScaffold(
          child: buildAdminDashboard(state.pathParameters['dashId']!),
        ),
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
