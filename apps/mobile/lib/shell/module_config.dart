import '../modules/fazendas/functional_catalog.dart';
import '../modules/fazendas/group_icons.dart';
import '../modules/fazendas/operational_groups.dart';
import '../ui/ui.dart';
import 'state/prototype_session_store.dart';

/// Registro central de navegação — espelha `moduleConfig.ts` (spec §3.4/§7.3).
/// O app tem um módulo (Fazendas). A navbar vem de [operationalBottomTabs] e o
/// menu lateral de [operationalMenuSections]; nenhuma navegação é hardcodada
/// fora daqui.

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
    this.push = false,
    this.profiles = const {},
  });

  final String id;
  final String label;
  final AppIconData icon;

  /// Rota absoluta do destino.
  final String route;

  /// `true` quando o destino é uma tela funda com "Voltar" próprio (ex.: uma
  /// funcionalidade aberta direto do menu): o shell empilha a rota em vez de
  /// substituí-la, para o "Voltar" ter para onde retornar.
  final bool push;

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
    this.menuSectionsBuilder,
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

  /// Alternativa a [menuSections] quando as seções derivam de dados em vez de
  /// uma lista fixa (ex.: grupos do catálogo funcional). Tem precedência.
  final List<ModuleMenuSection> Function()? menuSectionsBuilder;
}

/// Navegação primária da entrada operacional: duas abas de cada lado e, no
/// centro, o "+" de adição rápida ([quickAddAction]), que abre
/// [operationalQuickAdds] em vez de navegar.
///
/// Confinamento saiu da barra para dar lugar ao "+": o grupo continua no
/// menu lateral ([operationalMenuSections]) e as duas rotinas diárias dele
/// (trato e leitura de cocho) estão na adição rápida.
const List<BottomTab> operationalBottomTabs = [
  BottomTab(
    id: 'inicio',
    label: 'Início',
    icon: AppIcons.home,
    path: 'operacional',
  ),
  BottomTab(
    id: 'pecuaria',
    label: 'Pecuária',
    icon: AppIcons.pecuaria,
    path: 'operacional/grupo/pecuaria',
  ),
  BottomTab(
    id: 'adicionar',
    label: 'Adicionar',
    icon: AppIcons.plus,
    path: '',
    action: quickAddAction,
  ),
  BottomTab(
    id: 'agricultura',
    label: 'Agricultura',
    icon: AppIcons.agricultura,
    path: 'operacional/grupo/agricultura',
  ),
  BottomTab(
    id: 'menu',
    label: 'Menu',
    icon: AppIcons.menu,
    path: '',
    action: 'menu',
  ),
];

/// Ação do "+" central da navbar.
const String quickAddAction = 'quick-add';

/// Adição rápida (o "+" da navbar): as rotinas de lançamento mais usadas no
/// dia a dia de campo, no máximo cinco. O destino vem do catálogo funcional
/// pelo id — a mesma rota do menu e dos atalhos —, só o rótulo é mais curto.
List<ModuleMenuItem> operationalQuickAdds() {
  const atalhos = [
    ('apontamento', 'Apontamento', AppIcons.tractor),
    ('pesagem', 'Pesagem', AppIcons.scale),
    ('trato-diario', 'Trato diário', AppIcons.wheat),
    ('leitura-cocho-confinamento', 'Leitura de cocho', AppIcons.clipboardCheck),
    ('sanitario', 'Manejo sanitário', AppIcons.heartPulse),
  ];
  return [
    for (final (id, label, icon) in atalhos)
      ModuleMenuItem(
        id: id,
        label: label,
        icon: icon,
        route: operationalFeatureRoute(
          operationalFeatures.firstWhere((f) => f.id == id),
        ),
        push: true,
      ),
  ];
}

/// Itens do menu lateral do Operacional — e, sem o "Início", os atalhos da
/// tela inicial (`OperacionalHomeScreen`): um item por grupo do catálogo, na
/// ordem de produto. O menu é o índice completo das rotinas e repete de
/// propósito o que a navbar já mostra (Início, Pecuária, Agricultura).
///
/// "Ordens de serviço" vem logo depois do Início e abre a lista completa com
/// filtro (`/fazendas/campo/minhas-os`, empilhada), a mesma do "Ver todas".
List<ModuleMenuSection> operationalMenuSections() {
  const osGroup = 'Ordem de serviço';
  final entries = operationalGroupEntries();
  return [
    ModuleMenuSection(
      title: 'Menu',
      items: [
        const ModuleMenuItem(
          id: 'inicio-operacional',
          label: 'Início',
          icon: AppIcons.home,
          route: operationalHomeRoute,
        ),
        for (final entry in [
          ...entries.where((e) => e.group == osGroup),
          ...entries.where((e) => e.group != osGroup),
        ])
          ModuleMenuItem(
            id: groupToSlug(entry.group),
            label: entry.group == osGroup ? 'Ordens de serviço' : entry.label,
            icon: groupIcon(entry.group),
            route: entry.route,
            push: entry.isFeature,
          ),
      ],
    ),
  ];
}

/// Tela inicial do Operacional (aba "Início" da navbar).
const String operationalHomeRoute = '/fazendas/operacional';

/// Fallback do RevealMenu: seção única derivada das abas navegáveis do módulo.
List<ModuleMenuSection> getMenuSections(
  ModuleDef module, {
  UserAccessProfile? profile,
}) {
  final declared = module.menuSectionsBuilder?.call() ?? module.menuSections;
  if (declared != null) {
    return declared
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

const List<ModuleDef> modules = [
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
    // Os grupos do catálogo operacional (antes a grade da tela inicial)
    // entram no grupo único "Menu" — ver [operationalMenuSections].
    menuSectionsBuilder: operationalMenuSections,
  ),
];

final Map<String, ModuleDef> moduleMap = {for (final m in modules) m.id: m};

ModuleDef? getModule(String? id) => id == null ? null : moduleMap[id];
