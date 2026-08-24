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
  'Confinamento' => LucideIcons.warehouse,
  'Reprodução' => LucideIcons.heartPulse,
  'Gestão de frota' => LucideIcons.truck,
  'Ordem de serviço' => LucideIcons.fileText,
  'Sincronização' => LucideIcons.refreshCw,
  _ => LucideIcons.layers,
};

/// Slug estável por grupo, usado no segmento de rota `grupo/:slug`.
///
/// Evita colocar o nome do grupo (com espaços/acentos) cru na URL: o
/// go_router já decodifica `pathParameters` automaticamente, e o percurso
/// round-trip pelo endereço do navegador no Flutter Web pode re-codificar o
/// caminho de forma inconsistente, quebrando um `Uri.decodeComponent` extra
/// no lado da leitura. Um slug ASCII fixo não tem esse problema.
const Map<String, String> _groupSlugs = {
  'Painéis de decisão': 'paineis-de-decisao',
  'Consultas e auditoria': 'consultas-e-auditoria',
  'Cadastros': 'cadastros',
  'Estoque': 'estoque',
  'Misturador': 'misturador',
  'Agricultura': 'agricultura',
  'Pecuária': 'pecuaria',
  'Confinamento': 'confinamento',
  'Reprodução': 'reproducao',
  'Gestão de frota': 'gestao-de-frota',
  'Ordem de serviço': 'ordem-de-servico',
  'Sincronização': 'sincronizacao',
};

/// Converte um `feature.group` no slug usado na rota. Grupos fora do mapa
/// (ex.: um grupo novo esquecido aqui) caem num fallback determinístico em
/// vez de quebrar a navegação.
String groupToSlug(String group) =>
    _groupSlugs[group] ??
    group
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

/// Resolve um slug de volta ao nome do grupo original. Retorna `null` quando
/// o slug não corresponde a nenhum grupo conhecido — quem chama decide o
/// fallback (ex.: `GroupFeaturesScreen` mostra estado vazio).
String? groupFromSlug(String slug) {
  for (final entry in _groupSlugs.entries) {
    if (entry.value == slug) return entry.key;
  }
  return null;
}
