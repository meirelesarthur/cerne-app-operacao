import 'functional_catalog.dart';
import 'group_icons.dart';

/// Entrada de um grupo do catálogo operacional na navegação: o rótulo de
/// apresentação, o ícone e para onde o toque leva.
///
/// Fonte única da regra "grupo → destino", consumida pelo menu lateral
/// (`AppRevealMenu`, via `module_config.dart`) e pela grade de grupos
/// (`ResponsibilityWorkspace`) — Lei 2: as duas superfícies abrem o mesmo
/// destino para o mesmo grupo.
class OperationalGroupEntry {
  const OperationalGroupEntry({
    required this.group,
    required this.route,
    required this.isFeature,
  });

  /// Nome de domínio do grupo (`FeatureDefinition.group`).
  final String group;

  /// Rota absoluta de destino.
  final String route;

  /// `true` quando o grupo tem uma única funcionalidade e o toque pula direto
  /// para ela: a tela do grupo não teria nada além do próprio card. Destinos
  /// de funcionalidade são telas fundas com "Voltar" próprio, por isso quem
  /// navega deve empilhá-los (`push`), não substituir a rota (`go`).
  final bool isFeature;

  String get label => groupDisplayLabel(group);
}

/// Grupos do catálogo operacional na ordem de produto ([groupOrder]), com o
/// desempate pela posição original no catálogo — `List.sort` não é estável em
/// Dart, então grupos fora de `_groupDisplayOrder` embaralhariam entre si.
List<OperationalGroupEntry> operationalGroupEntries({
  Iterable<FeatureDefinition> features = operationalFeatures,
  Set<String> exclude = const {},
}) {
  final groups = <String, List<FeatureDefinition>>{};
  for (final feature in features) {
    if (exclude.contains(feature.group)) continue;
    groups.putIfAbsent(feature.group, () => []).add(feature);
  }
  final insertionOrder = groups.keys.toList();
  final ordered = [...insertionOrder]
    ..sort((a, b) {
      final byOrder = groupOrder(a).compareTo(groupOrder(b));
      if (byOrder != 0) return byOrder;
      return insertionOrder.indexOf(a).compareTo(insertionOrder.indexOf(b));
    });

  return [
    for (final group in ordered)
      if (groups[group]!.length == 1)
        OperationalGroupEntry(
          group: group,
          route: operationalFeatureRoute(groups[group]!.single),
          isFeature: true,
        )
      else
        OperationalGroupEntry(
          group: group,
          route: '/fazendas/operacional/grupo/${groupToSlug(group)}',
          isFeature: false,
        ),
  ];
}

/// Rota de uma funcionalidade operacional: a rota própria quando existe
/// (`existingRoute`, ex. `/fazendas/campo/pesagem`), senão a tela mapeada sob
/// o segmento operacional.
String operationalFeatureRoute(FeatureDefinition feature) {
  if (feature.existingRoute case final route?) return route;
  return '/fazendas/operacional/${feature.id}';
}
