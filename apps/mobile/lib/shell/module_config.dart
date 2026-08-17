import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'state/prototype_session_store.dart';

/// Registro central de módulos do superapp — espelha `moduleConfig.ts` (spec §3.4/§7.3).
/// O Shell itera este registro para montar o dock de módulos (`AppBottomTabBar`) e injeta os
/// `bottomTabs` do módulo ativo nas `AppContextTabs` do topo; a ação 'menu' vira bolha no header.
/// Nenhuma navegação de módulo é hardcodada fora daqui.

class BottomTab {
  const BottomTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.path,
    this.elevated = false,
    this.action,
    this.profiles = const {},
  });

  final String id;
  final String label;
  final IconData icon;

  /// Rota relativa dentro do módulo (ex.: '' = home, 'atividades').
  final String path;

  /// Botão central elevado (ex.: "Registrar" em campo).
  final bool elevated;

  /// Ação especial em vez de navegação (ex.: 'menu' abre o RevealMenu global).
  final String? action;

  final Set<UserAccessProfile> profiles;

  bool isVisibleTo(UserAccessProfile? profile) =>
      profiles.isEmpty || profiles.contains(profile);
}

class ModuleMenuItem {
  const ModuleMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.profiles = const {},
  });

  final String id;
  final String label;
  final IconData icon;

  /// Rota absoluta do destino.
  final String route;

  final Set<UserAccessProfile> profiles;

  bool isVisibleTo(UserAccessProfile? profile) =>
      profiles.isEmpty || profiles.contains(profile);
}

class ModuleMenuSection {
  const ModuleMenuSection({required this.title, required this.items});

  final String title;
  final List<ModuleMenuItem> items;
}

class ModuleDef {
  const ModuleDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.homeRoute,
    required this.bottomTabs,
    this.menuSections,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Rota inicial absoluta do módulo.
  final String homeRoute;
  final List<BottomTab> bottomTabs;

  /// Funcionalidades exibidas no RevealMenu (aba Mais) — contextuais ao módulo.
  /// Quando ausente, o menu deriva uma seção única das bottomTabs navegáveis.
  final List<ModuleMenuSection>? menuSections;
}

/// Fallback do RevealMenu: seção única derivada das abas navegáveis do módulo.
List<ModuleMenuSection> getMenuSections(
  ModuleDef module, {
  UserAccessProfile? profile,
}) {
  if (module.menuSections != null) {
    return module.menuSections!
        .map(
          (section) => ModuleMenuSection(
            title: section.title,
            items: section.items
                .where((item) => item.isVisibleTo(profile))
                .toList(),
          ),
        )
        .where((section) => section.items.isNotEmpty)
        .toList();
  }
  return [
    ModuleMenuSection(
      title: 'Funcionalidades',
      items: visibleBottomTabs(module, profile)
          .where((tab) => tab.path.isNotEmpty && tab.action == null)
          .map(
            (tab) => ModuleMenuItem(
              id: tab.id,
              label: tab.label,
              icon: tab.icon,
              route: '/${module.id}/${tab.path}',
            ),
          )
          .toList(),
    ),
  ];
}

List<BottomTab> visibleBottomTabs(
  ModuleDef module,
  UserAccessProfile? profile,
) => module.bottomTabs.where((tab) => tab.isVisibleTo(profile)).toList();

String moduleHomeRoute(ModuleDef module, UserAccessProfile? profile) {
  if (module.id == 'fazendas' && profile != null) return profile.homeRoute;
  return module.homeRoute;
}

const List<ModuleDef> modules = [
  // New-UI — hub agregador: porta de entrada do superapp, Banking central.
  ModuleDef(
    id: 'inicio',
    label: 'Início',
    icon: LucideIcons.home,
    homeRoute: '/inicio',
    bottomTabs: [
      BottomTab(id: 'home', label: 'Início', icon: LucideIcons.home, path: ''),
      BottomTab(
        id: 'apps',
        label: 'Apps',
        icon: LucideIcons.layoutGrid,
        path: 'apps',
      ),
      BottomTab(
        id: 'carteira',
        label: 'Carteira',
        icon: LucideIcons.wallet,
        path: 'carteira',
      ),
      BottomTab(
        id: 'menu',
        label: 'Menu',
        icon: LucideIcons.menu,
        path: 'menu',
        action: 'menu',
      ),
    ],
  ),
  ModuleDef(
    id: 'fazendas',
    label: 'Fazendas',
    icon: LucideIcons.sprout,
    homeRoute: '/fazendas',
    bottomTabs: [
      BottomTab(
        id: 'dashboard',
        label: 'Gestão',
        icon: LucideIcons.layoutDashboard,
        path: 'administracao',
        profiles: {UserAccessProfile.administration},
      ),
      BottomTab(
        id: 'rotinas',
        label: 'Rotinas',
        icon: LucideIcons.clipboardList,
        path: 'operacional',
        profiles: {UserAccessProfile.operational},
      ),
      BottomTab(
        id: 'fazendas',
        label: 'Fazendas',
        icon: LucideIcons.sprout,
        path: 'fazendas',
      ),
      BottomTab(
        id: 'atividades',
        label: 'Atividades',
        icon: LucideIcons.activity,
        path: 'atividades',
      ),
      BottomTab(
        id: 'financeiro',
        label: 'Financeiro',
        icon: LucideIcons.wallet,
        path: 'financeiro',
        profiles: {UserAccessProfile.administration},
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      ModuleMenuSection(
        title: 'Ambiente',
        items: [
          ModuleMenuItem(
            id: 'central-administracao',
            label: 'Central de gestão',
            icon: LucideIcons.layoutDashboard,
            route: '/fazendas/administracao',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'central-operacional',
            label: 'Central de rotinas',
            icon: LucideIcons.clipboardList,
            route: '/fazendas/operacional',
            profiles: {UserAccessProfile.operational},
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Dashboards gerenciais',
        items: [
          ModuleMenuItem(
            id: 'financeiro',
            label: 'Financeiro',
            icon: LucideIcons.wallet,
            route: '/fazendas/dashboards/financeiro',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'pecuaria',
            label: 'Pecuária de Corte',
            icon: LucideIcons.beef,
            route: '/fazendas/dashboards/pecuaria',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'confinamento',
            label: 'Lotação de Currais',
            icon: LucideIcons.warehouse,
            route: '/fazendas/dashboards/confinamento',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'ativos',
            label: 'Ativos / Depreciação',
            icon: LucideIcons.package,
            route: '/fazendas/dashboards/ativos',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'suprimentos',
            label: 'Suprimentos',
            icon: LucideIcons.boxes,
            route: '/fazendas/dashboards/suprimentos',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'uso',
            label: 'Análise de Uso',
            icon: LucideIcons.users,
            route: '/fazendas/dashboards/uso',
            profiles: {UserAccessProfile.administration},
          ),
          ModuleMenuItem(
            id: 'consultas',
            label: 'Consultas Gerenciais',
            icon: LucideIcons.search,
            route: '/fazendas/dashboards/consultas',
            profiles: {UserAccessProfile.administration},
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Operacional',
        items: [
          ModuleMenuItem(
            id: 'sync',
            label: 'Fila de sincronização',
            icon: LucideIcons.refreshCw,
            route: '/fazendas/mais/sync',
            profiles: {UserAccessProfile.operational},
          ),
          ModuleMenuItem(
            id: 'atividades',
            label: 'Todas as atividades',
            icon: LucideIcons.activity,
            route: '/fazendas/atividades',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'bank',
    label: 'Bank',
    icon: LucideIcons.landmark,
    homeRoute: '/bank',
    bottomTabs: [
      BottomTab(
        id: 'inicio',
        label: 'Início',
        icon: LucideIcons.home,
        path: '',
      ),
      BottomTab(
        id: 'extrato',
        label: 'Extrato',
        icon: LucideIcons.receipt,
        path: 'extrato',
      ),
      BottomTab(
        id: 'pagamentos',
        label: 'Pagamentos',
        icon: LucideIcons.arrowLeftRight,
        path: 'pagamentos',
      ),
      BottomTab(
        id: 'cartoes',
        label: 'Cartões',
        icon: LucideIcons.creditCard,
        path: 'cartoes',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      ModuleMenuSection(
        title: 'Pagamentos e transferências',
        items: [
          ModuleMenuItem(
            id: 'pix',
            label: 'Pix',
            icon: LucideIcons.zap,
            route: '/bank/pix',
          ),
          ModuleMenuItem(
            id: 'pagamentos',
            label: 'Pagamentos',
            icon: LucideIcons.receipt,
            route: '/bank/pagamentos',
          ),
          ModuleMenuItem(
            id: 'extrato',
            label: 'Extrato',
            icon: LucideIcons.history,
            route: '/bank/extrato',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Cartão',
        items: [
          ModuleMenuItem(
            id: 'cartoes',
            label: 'Cartões',
            icon: LucideIcons.creditCard,
            route: '/bank/cartoes',
          ),
          ModuleMenuItem(
            id: 'limites',
            label: 'Limites',
            icon: LucideIcons.slidersHorizontal,
            route: '/bank/limites',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: LucideIcons.helpCircle,
            route: '/bank/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'credito',
    label: 'Crédito',
    icon: LucideIcons.handCoins,
    homeRoute: '/credito',
    bottomTabs: [
      BottomTab(
        id: 'inicio',
        label: 'Início',
        icon: LucideIcons.home,
        path: '',
      ),
      BottomTab(
        id: 'propostas',
        label: 'Minhas Propostas',
        icon: LucideIcons.fileText,
        path: 'propostas',
      ),
      BottomTab(
        id: 'simular',
        label: 'Simular',
        icon: LucideIcons.calculator,
        path: 'simular',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      ModuleMenuSection(
        title: 'Crédito',
        items: [
          ModuleMenuItem(
            id: 'simular',
            label: 'Simular',
            icon: LucideIcons.calculator,
            route: '/credito/simular',
          ),
          ModuleMenuItem(
            id: 'propostas',
            label: 'Propostas',
            icon: LucideIcons.clipboardList,
            route: '/credito/propostas',
          ),
          ModuleMenuItem(
            id: 'contratos',
            label: 'Contratos',
            icon: LucideIcons.fileSignature,
            route: '/credito/contratos',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: LucideIcons.helpCircle,
            route: '/credito/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'marketplace',
    label: 'Marketplace',
    icon: LucideIcons.shoppingBag,
    homeRoute: '/marketplace',
    bottomTabs: [
      BottomTab(
        id: 'inicio',
        label: 'Início',
        icon: LucideIcons.home,
        path: '',
      ),
      BottomTab(
        id: 'categorias',
        label: 'Categorias',
        icon: LucideIcons.listOrdered,
        path: 'categorias',
      ),
      BottomTab(
        id: 'pedidos',
        label: 'Pedidos',
        icon: LucideIcons.receipt,
        path: 'pedidos',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      ModuleMenuSection(
        title: 'Compras',
        items: [
          ModuleMenuItem(
            id: 'categorias',
            label: 'Categorias',
            icon: LucideIcons.layoutGrid,
            route: '/marketplace/categorias',
          ),
          ModuleMenuItem(
            id: 'pedidos',
            label: 'Pedidos',
            icon: LucideIcons.package,
            route: '/marketplace/pedidos',
          ),
          ModuleMenuItem(
            id: 'favoritos',
            label: 'Favoritos',
            icon: LucideIcons.heart,
            route: '/marketplace/favoritos',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: LucideIcons.helpCircle,
            route: '/marketplace/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'armazem',
    label: 'Armazém',
    icon: LucideIcons.warehouse,
    homeRoute: '/armazem',
    bottomTabs: [
      BottomTab(
        id: 'inicio',
        label: 'Início',
        icon: LucideIcons.home,
        path: '',
      ),
      BottomTab(
        id: 'estoque',
        label: 'Estoque',
        icon: LucideIcons.boxes,
        path: 'estoque',
      ),
      BottomTab(
        id: 'movimentacoes',
        label: 'Movimentações',
        icon: LucideIcons.arrowLeftRight,
        path: 'movimentacoes',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: LucideIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      ModuleMenuSection(
        title: 'Operação',
        items: [
          ModuleMenuItem(
            id: 'estoque',
            label: 'Estoque',
            icon: LucideIcons.boxes,
            route: '/armazem/estoque',
          ),
          ModuleMenuItem(
            id: 'movimentacoes',
            label: 'Movimentações',
            icon: LucideIcons.arrowLeftRight,
            route: '/armazem/movimentacoes',
          ),
          ModuleMenuItem(
            id: 'unidades',
            label: 'Unidades',
            icon: LucideIcons.warehouse,
            route: '/armazem/unidades',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Gestão',
        items: [
          ModuleMenuItem(
            id: 'relatorios',
            label: 'Relatórios',
            icon: LucideIcons.barChart3,
            route: '/armazem/relatorios',
          ),
        ],
      ),
    ],
  ),
];

final Map<String, ModuleDef> moduleMap = {for (final m in modules) m.id: m};

ModuleDef? getModule(String? id) => id == null ? null : moduleMap[id];
