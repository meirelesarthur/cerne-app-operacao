import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Ícone por grupo de `FeatureDefinition.group` — usado no acesso rápido e nos
/// cards de módulo da central de rotinas/gestão (`ResponsibilityWorkspace`) e
/// na tela fullscreen de funções de um grupo (`GroupFeaturesScreen`).
///
/// `FeatureDefinition` não carrega ícone próprio (é um contrato de dados puro
/// — `functional_catalog.dart` não deve depender de UI), então o mapeamento
/// fica aqui, isolado do catálogo.
IconData groupIcon(String group) => switch (group) {
  'Painéis de decisão' => LucideIcons.layoutDashboard,
  'Consultas e auditoria' => LucideIcons.search,
  'Cadastros' => LucideIcons.clipboardList,
  'Estoque' => LucideIcons.boxes,
  'Misturador' => LucideIcons.wrench,
  'Agricultura' => LucideIcons.sprout,
  'Pecuária' => LucideIcons.beef,
  'Reprodução' => LucideIcons.heartPulse,
  'Gestão de frota' => LucideIcons.truck,
  'Ordem de serviço' => LucideIcons.fileText,
  'Sincronização' => LucideIcons.refreshCw,
  _ => LucideIcons.layers,
};
