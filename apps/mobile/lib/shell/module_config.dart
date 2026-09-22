import '../ui/ui.dart';
import 'state/prototype_session_store.dart';

/// Registro central de módulos do superapp — espelha `moduleConfig.ts` (spec §3.4/§7.3).
/// O Shell itera este registro para montar o dock de módulos (`AppBottomTabBar`) e injeta os
/// `bottomTabs` do módulo ativo nas `AppContextTabs` do topo. A entrada operacional possui uma
/// navegação primária própria, declarada em [operationalBottomTabs].
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
  final AppIconData icon;

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
  final AppIconData icon;

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
  final AppIconData icon;

  /// Rota inicial absoluta do módulo.
  final String homeRoute;
  final List<BottomTab> bottomTabs;

  /// Funcionalidades exibidas no RevealMenu (aba Mais) — contextuais ao módulo.
  /// Quando ausente, o menu deriva uma seção única das bottomTabs navegáveis.
  final List<ModuleMenuSection>? menuSections;
}

/// Navegação primária da entrada operacional. Pecuária, Agricultura e
/// Confinamento apontam diretamente para seus grupos; as demais rotinas
/// continuam acessíveis pela grade da tela inicial.
///
/// fidelidade-esteira: o "Menu" (RevealMenu) saiu daqui — redundante com a
/// grade de módulos que a própria Home operacional já mostra, e o essencial
/// do dia a dia da equipe de campo é ficar dentro de Fazendas, não trocar de
/// módulo. Confinamento entrou no lugar por ser o grupo de uso diário mais
/// frequente (mesmo critério de `group_icons.dart`).
const List<BottomTab> operationalBottomTabs = [
  BottomTab(
    id: 'home',
    label: 'Home',
    icon: AppIcons.home,
    path: 'operacional',
  ),
  BottomTab(
    id: 'confinamento',
    label: 'Confinamento',
    icon: AppIcons.confinamento,
    path: 'operacional/grupo/confinamento',
  ),
  BottomTab(
    id: 'pecuaria',
    label: 'Pecuária',
    icon: AppIcons.pecuaria,
    path: 'operacional/grupo/pecuaria',
  ),
  BottomTab(
    id: 'agricultura',
    label: 'Agricultura',
    icon: AppIcons.agricultura,
    path: 'operacional/grupo/agricultura',
  ),
];

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
  // New-UI — hub agregador: porta de entrada do app.
  ModuleDef(
    id: 'inicio',
    label: 'Início',
    icon: AppIcons.home,
    homeRoute: '/inicio',
    bottomTabs: [
      BottomTab(id: 'home', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'apps',
        label: 'Apps',
        icon: AppIcons.layoutGrid,
        path: 'apps',
      ),
      BottomTab(
        id: 'menu',
        label: 'Menu',
        icon: AppIcons.menu,
        path: 'menu',
        action: 'menu',
      ),
    ],
    // Vazio, não omitido (ver plano de UX): sem isso, o menu "reveal" cai no
    // fallback de `getMenuSections` — que deriva a lista das próprias
    // `bottomTabs` — e mostra de novo "Apps" ali dentro, que já é aba visível
    // no topo. O menu "Mais" deste módulo vira só a seção CONTA.
    menuSections: [],
  ),
  ModuleDef(
    id: 'fazendas',
    label: 'Fazendas',
    icon: AppIcons.sprout,
    homeRoute: '/fazendas',
    bottomTabs: [
      BottomTab(
        id: 'rotinas',
        label: 'Rotinas',
        icon: AppIcons.clipboardList,
        path: 'operacional',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    // Vazio, não omitido (ver plano de UX): toda esta lista duplicava algo
    // que já existe em outro lugar — "Central de gestão/rotinas" é a própria
    // aba de contexto ativa; os 7 "Dashboards gerenciais" já são o grupo
    // "Painéis de decisão"/"Consultas e auditoria" da central; "Fila de
    // sincronização" já é o grupo "Sincronização"; a consulta de Ordens de
    // Serviço já é a aba "Ordens de Serviço". Dois caminhos para o mesmo
    // destino não é conveniência, é a pessoa não saber se são a mesma coisa.
    menuSections: [],
  ),
  ModuleDef(
    id: 'armazem',
    label: 'Armazém',
    icon: AppIcons.warehouse,
    homeRoute: '/armazem',
    bottomTabs: [
      BottomTab(id: 'inicio', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'estoque',
        label: 'Estoque',
        icon: AppIcons.boxes,
        path: 'estoque',
      ),
      BottomTab(
        id: 'movimentacoes',
        label: 'Movimentações',
        icon: AppIcons.arrowLeftRight,
        path: 'movimentacoes',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      // Estoque e Movimentações saíram: já são abas de contexto no topo.
      // Unidades não é aba — fica.
      ModuleMenuSection(
        title: 'Operação',
        items: [
          ModuleMenuItem(
            id: 'unidades',
            label: 'Unidades',
            icon: AppIcons.warehouse,
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
            icon: AppIcons.barChart3,
            route: '/armazem/relatorios',
          ),
        ],
      ),
    ],
  ),
];

final Map<String, ModuleDef> moduleMap = {for (final m in modules) m.id: m};

ModuleDef? getModule(String? id) => id == null ? null : moduleMap[id];

/// Módulos exibidos no dock global (ver plano de melhorias de UX): o app tem
/// só o perfil operacional (mão de obra de campo), que usa Início, Fazendas e
/// Armazém como atalhos persistentes — os únicos módulos do app.
List<ModuleDef> visibleModulesFor(UserAccessProfile? profile) => modules;
