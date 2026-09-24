import '../../ui/ui.dart';

/// Separador das partes da descrição de um registro ("Exame · Lote Matrizes
/// 01 · 02/09/2026") — é como os mocks e o motor de jornadas
/// (`recordDescriptionFields`) montam a descrição.
const recordDescriptionSeparator = ' · ';

/// Dados de apoio de uma linha de listagem ([AppRecordTile]) a partir da
/// descrição do registro: cada parte vira um item com o ícone do tipo de
/// informação que ela é.
///
/// Fonte única da regra "texto → ícone" para todas as listagens — ninguém
/// escolhe ícone de metadado na própria tela.
List<AppRecordMeta> recordMetaFromDescription(String description) {
  final parts = description
      .split(recordDescriptionSeparator)
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  return [
    for (var i = 0; i < parts.length; i++)
      AppRecordMeta(
        icon: recordMetaIcon(parts[i], first: i == 0),
        label: parts[i],
      ),
  ];
}

final _date = RegExp(r'\b\d{2}/\d{2}(/\d{2,4})?\b');
final _count = RegExp(
  r'\b\d[\d.,]*\s*(animais|cabeças|novilhas|bois|vacas|bezerros)\b',
  caseSensitive: false,
);
final _measure = RegExp(
  r'\b\d[\d.,]*\s*(kg|g|t|l|ml|@|arrobas?|sacas?|ha|m|m³|doses?|un\.?|unidades?)\b',
  caseSensitive: false,
);
final _unitOnly = RegExp(
  r'^(kg|g|l|ml|dose|frasco.*|saca.*|unidade|un\.?|litro.*)$',
  caseSensitive: false,
);

/// Ícone de uma parte da descrição. As regras vão da mais específica para a
/// mais genérica; `first` é a primeira parte, que costuma ser o tipo ou a
/// categoria do registro ("Exame", "Vacinação", "Preventiva").
AppIconData recordMetaIcon(String part, {bool first = false}) {
  final text = part.toLowerCase();
  bool starts(List<String> words) => words.any(text.startsWith);
  bool has(List<String> words) => words.any(text.contains);

  if (_date.hasMatch(text)) return AppIcons.calendar;
  if (has(['hoje', 'ontem', 'atrás', 'recentemente', 'às '])) {
    return AppIcons.clock;
  }
  if (has([r'r$', 'custo'])) return AppIcons.cash;
  if (starts(['lote'])) return AppIcons.layers;
  if (_count.hasMatch(text)) return AppIcons.beef;
  if (starts(['fazenda'])) return AppIcons.fazenda;
  if (starts([
    'talhão',
    'pasto',
    'piquete',
    'curral',
    'área',
    'divisa',
    'baia',
  ])) {
    return AppIcons.mapPin;
  }
  if (starts(['armazém', 'farmácia', 'almoxarifado', 'depósito', 'galpão'])) {
    return AppIcons.warehouse;
  }
  if (starts([
    'trator',
    'colheitadeira',
    'caminhão',
    'pulverizador',
    'camionete',
    'implemento',
  ])) {
    return AppIcons.tractor;
  }
  if (_measure.hasMatch(text) || _unitOnly.hasMatch(text)) {
    return AppIcons.scale;
  }
  if (starts(['bovino', 'novilha', 'vaca', 'boi', 'bezerr', 'touro'])) {
    return AppIcons.beef;
  }
  if (has(['pendente', 'aguardando', 'concluída', 'sincroniz'])) {
    return AppIcons.cloudSync;
  }
  if (has(['tolerância', 'alerta'])) return AppIcons.slidersHorizontal;
  return first ? AppIcons.clipboardList : AppIcons.info;
}
