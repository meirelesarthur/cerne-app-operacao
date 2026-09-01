import '../../ui/ui.dart';

/// Ícone por grupo de `FeatureDefinition.group` — usado no acesso rápido e nos
/// cards de módulo da central de rotinas/gestão (`ResponsibilityWorkspace`) e
/// na tela fullscreen de funções de um grupo (`GroupFeaturesScreen`).
///
/// `FeatureDefinition` não carrega ícone próprio (é um contrato de dados puro
/// — `functional_catalog.dart` não deve depender de UI), então o mapeamento
/// fica aqui, isolado do catálogo.
AppIconData groupIcon(String group) => switch (group) {
  'Painéis de decisão' => AppIcons.layoutDashboard,
  'Consultas e auditoria' => AppIcons.search,
  'Cadastros' => AppIcons.clipboardList,
  'Estoque' => AppIcons.boxes,
  'Misturador' => AppIcons.wrench,
  'Agricultura' => AppIcons.sprout,
  'Pecuária' => AppIcons.pecuaria,
  'Confinamento' => AppIcons.confinamento,
  'Consultas' => AppIcons.bookOpen,
  'Reprodução' => AppIcons.heartPulse,
  'Gestão de frota' => AppIcons.truck,
  'Ordem de serviço' => AppIcons.fileText,
  'Sincronização' => AppIcons.refreshCw,
  _ => AppIcons.layers,
};

/// Rótulo de apresentação dos módulos na entrada operacional. O catálogo
/// mantém o nome de domínio para chaves, slugs e auditoria; a home usa o
/// vocabulário curto que aparece no layout de referência.
String groupDisplayLabel(String group) => switch (group) {
  'Ordem de serviço' => 'Ordem de Serviço',
  'Gestão de frota' => 'Gestão de Frota',
  'Sincronização' => 'Sincronizar aplicativo',
  _ => group,
};

/// Ordem de exibição dos grupos na central de responsabilidade.
///
/// Sem isso, a ordem seria a de inserção no array do catálogo — acidente de
/// edição, não decisão de produto: era por isso que Confinamento caía por
/// último, só porque foi o último bloco acrescentado ao arquivo.
///
/// Confinamento vem primeiro porque Trato Diário e Leitura de Cocho são o uso
/// diário mais frequente da equipe de campo; Consultas vem depois de tudo que
/// é lançamento, porque é material de apoio, não tarefa do dia.
const List<String> _groupDisplayOrder = [
  // Operacional — do mais frequente ao mais esporádico.
  'Confinamento',
  'Pecuária',
  'Agricultura',
  'Ordem de serviço',
  'Misturador',
  'Reprodução',
  'Consultas',
  'Gestão de frota',
  'Sincronização',
  // Administração.
  'Painéis de decisão',
  'Consultas e auditoria',
];

/// Posição do grupo na ordem de exibição. Grupos fora da lista (ex.: um grupo
/// novo esquecido aqui) vão para o fim, sem quebrar a navegação.
int groupOrder(String group) {
  final index = _groupDisplayOrder.indexOf(group);
  return index == -1 ? _groupDisplayOrder.length : index;
}

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
  'Consultas': 'consultas',
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
