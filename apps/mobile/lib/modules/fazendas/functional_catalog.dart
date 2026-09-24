// Fonte funcional Flutter do AGRO365.
//
// Portado mecanicamente em 16/08/2026 do catálogo React congelado no commit
// 960fe54. A partir da M1, mudanças funcionais entram primeiro neste contrato
// Dart; o catálogo React permanece apenas como evidência histórica até M13.

import 'cadastros_vinculados.dart';

export 'cadastros_vinculados.dart'
    show catalogoEquipamentos, catalogoItensEstoque, catalogoProdutos;

enum FeatureProfile { operational }

enum FeatureStatus { ready, mapped, hardware }

// fidelidade-contrato (re-auditoria 3ª avaliação): `color` é uma paleta
// FECHADA (`AppColorInput` com `colorPalette`) — a API valida com
// `Rule::enum` (`AreaColor` em `/areas`, `MarkingColorEnum` em `/markings`),
// então hex livre daria 422. A onda 11 tinha lido o dump de produção (150+
// hex em repouso) como "seletor livre", mas isso é dado acumulado, não o
// contrato de escrita novo. Ver [areaColorPalette]/[markingColorPalette].
// fidelidade-esteira (onda 15): `boolean` é um switch de verdade
// (`AppToggleSwitch`), não mais simulado com `select` Sim/Não —
// `has_lot`/`is_equipment`/`is_enabled`/`control_stock`/`allow_pointing` em
// `consulta-produtos` são a primeira aplicação real.
// fidelidade-esteira: `searchSelect` é um `select` com busca (`AppSearchSelect`)
// em vez de dropdown simples (`AppFormSelect`) — todo campo de Lote usa este
// tipo, nunca `select` puro nem texto livre (pedido explícito do usuário).
enum FeatureFieldType {
  text,
  number,
  // fidelidade-contrato (re-auditoria 3ª avaliação): `integer` distingue o
  // número inteiro (ex. `mileage`/hodômetro no `SupplyRequest`) do decimal
  // (`number`) — só dígitos, sem casas decimais.
  integer,
  date,
  select,
  searchSelect,
  textarea,
  color,
  boolean,
}

enum HardwareSimulationKind { devices, scale, rfid, scanner }

enum AuditExportKind { estoque, pecuaria }

class FeatureField {
  const FeatureField({
    required this.id,
    required this.label,
    this.type,
    this.isRequired = false,
    this.placeholder,
    this.options = const [],
    this.colorPalette = const [],
    this.selectOptions = const [],
    this.derivedFrom,
    this.optionsFrom,
  });

  final String id;
  final String label;
  final FeatureFieldType? type;
  final bool isRequired;
  final String? placeholder;
  final List<String> options;

  /// Opções value/label de um `select`/`searchSelect` cujo VALOR emitido
  /// difere do rótulo exibido — espelho de um enum backed da API (ex.
  /// `WeaningType` 1/2, `AnimalIdentificationMode` single/no_id,
  /// `type_payment` código ≤2). Vazio mantém [options] (value == label). O
  /// `state` guarda o valor; a exibição resolve o rótulo via
  /// [featureFieldDisplay].
  final List<({String value, String label})> selectOptions;

  /// Paleta fechada de um campo `FeatureFieldType.color`. Quando não-vazia,
  /// o campo só aceita estas cores (espelho de um enum de cor da API, ex.
  /// `AreaColor`/`MarkingColorEnum`) e submete o `value` hex EXATO — vazia
  /// mantém o comportamento de hex livre.
  final List<({String value, String label})> colorPalette;

  /// Valor que vem do cadastro de outro campo do mesmo formulário (ou do
  /// mesmo item de coleção) — ver [FeatureFieldDerivation].
  final FeatureFieldDerivation? derivedFrom;

  /// Opções que dependem do valor de outro campo — ver [FeatureOptionsFilter].
  final FeatureOptionsFilter? optionsFrom;
}

/// banco-real (onda 5 — cadastros vinculados): o valor de um campo que o
/// cadastro de outro campo já responde. Escolher o produto responde a
/// unidade; escolher o item de estoque responde o armazém; escolher o
/// equipamento responde a última leitura do medidor.
///
/// Com [locked] (padrão), o campo é **do cadastro**: o motor preenche, trava
/// o controle e mostra de onde veio — a pessoa não digita o que o sistema já
/// sabe. Sem [locked], é uma **sugestão**: o motor preenche ao escolher a
/// fonte, mas o campo continua editável (ex.: combustível habitual do
/// equipamento, leitura atual do horímetro).
///
/// A fonte é sempre do mesmo escopo: campo do cabeçalho deriva de campo do
/// cabeçalho; campo de item deriva de campo do mesmo item.
class FeatureFieldDerivation {
  const FeatureFieldDerivation({
    required this.source,
    required this.values,
    this.locked = true,
  });

  /// `id` do campo-fonte.
  final String source;

  /// Valor da fonte → valor deste campo. Fonte fora do mapa não deriva nada
  /// (o campo volta a ser de preenchimento livre).
  final Map<String, String> values;
  final bool locked;
}

/// Opções de um `select`/`searchSelect` restritas pelo valor de outro campo —
/// o item de estoque só lista os lotes do produto escolhido; a atividade só
/// lista as atividades da operação escolhida (`operation_activities`). Sem
/// valor na fonte, o campo mostra todas as [FeatureField.options].
class FeatureOptionsFilter {
  const FeatureOptionsFilter({required this.source, required this.options});

  final String source;
  final Map<String, List<String>> options;
}

/// Rótulo de exibição de um valor armazenado: resolve
/// [FeatureField.selectOptions]/[FeatureField.colorPalette] (value → label)
/// quando o valor emitido difere do rótulo. Fora esses casos, devolve o
/// próprio valor. O `state` sempre guarda o valor (para submissão/round-trip);
/// só a apresentação usa o rótulo.
String featureFieldDisplay(FeatureField field, String value) {
  for (final option in field.selectOptions) {
    if (option.value == value) return option.label;
  }
  for (final option in field.colorPalette) {
    if (option.value == value) return option.label;
  }
  return value;
}

/// Paleta fechada de `Area` — espelho EXATO de `App\Enums\AreaColor`
/// (`GB.Cerne.Api/app/Enums/AreaColor.php`, 14 cores, hex minúsculo).
/// `AreaRequest::rules()` valida `color` com `Rule::enum(AreaColor)`, logo
/// hex livre (o antigo `AppColorInput` sem paleta) dava 422. Valores verbatim
/// — NÃO normalizar case.
const List<({String value, String label})> areaColorPalette = [
  (value: '#ffffff', label: 'Branco'),
  (value: '#0074d9', label: 'Azul'),
  (value: '#000000', label: 'Preto'),
  (value: '#2ecc40', label: 'Verde'),
  (value: '#ffdc00', label: 'Amarelo'),
  (value: '#ff4136', label: 'Vermelho'),
  (value: '#aaaaaa', label: 'Cinza'),
  (value: '#dddddd', label: 'Cinza Claro'),
  (value: '#7fdbff', label: 'Azul Claro'),
  (value: '#001f3f', label: 'Azul Escuro'),
  (value: '#39cccc', label: 'Turquesa'),
  (value: '#3d9970', label: 'Verde Escuro'),
  (value: '#01ff70', label: 'Verde Claro'),
  (value: '#ff851b', label: 'Laranja'),
];

/// Paleta fechada de `Marking` — espelho EXATO de `App\Enums\MarkingColorEnum`
/// (`GB.Cerne.Api/app/Enums/MarkingColorEnum.php`, 16 cores). Case É
/// SIGNIFICATIVO: 5 valores são MAIÚSCULOS (`#FF99FF`, `#FF69B4`, `#FBE7A1`,
/// `#00008B`, `#003366`) e `Rule::enum(MarkingColorEnum)` faz match exato de
/// string — normalizar case quebra a submissão (422). Distinta de
/// [areaColorPalette]: `/markings` NÃO usa `AreaColor`.
const List<({String value, String label})> markingColorPalette = [
  (value: '#ffee58', label: 'Amarelo'),
  (value: '#81d4fa', label: 'Azul claro'),
  (value: '#e0e0e0', label: 'Branco'),
  (value: '#a1887f', label: 'Marrom'),
  (value: '#212121', label: 'Preto'),
  (value: '#ec407a', label: 'Rosa'),
  (value: '#8e24aa', label: 'Roxo'),
  (value: '#4caf50', label: 'Verde'),
  (value: '#d32f2f', label: 'Vermelho'),
  (value: '#FF99FF', label: 'Rosa Claro'),
  (value: '#FF69B4', label: 'Rosa Pink'),
  (value: '#FBE7A1', label: 'Palha'),
  (value: '#00008B', label: 'Azul Escuro'),
  (value: '#003366', label: 'Azul Marinho'),
  (value: '#f75900', label: 'Laranja'),
  (value: '#0072c0', label: 'Azul Royal'),
];

/// Uma coleção de itens de um cadastro — `items[]`, `products[]`,
/// `identifications[]` e companhia no contrato real.
///
/// Antes da onda 8 uma coleção era só um nome numa lista de `String`, e o
/// motor genérico a tratava como contador: "Adicionar" incrementava um número
/// e nada mais. Servia para documentar que a coleção existe, não para
/// registrar o que ela contém — e as coleções são justamente o conteúdo real
/// de vários cadastros (a agenda do protocolo, os animais diagnosticados, os
/// insumos consumidos no manejo).
///
/// Com [fields] preenchido, cada "Adicionar" abre um formulário de item e a
/// linha entra na lista com os dados verdadeiros. Sem [fields], o
/// comportamento antigo de contador é preservado — é o caso das duas "seções"
/// de `processamentos`, que são rótulos de agrupamento, não coleções.
class FeatureCollection {
  const FeatureCollection({
    required this.name,
    this.itemLabel,
    this.fields = const [],
    this.isRequired = false,
    this.titleField,
    this.subtitleFields = const [],
  });

  /// Nome da coleção, como aparece na tela e no contrato ("Insumos").
  final String name;

  /// Título do formulário de um item ("Insumo"). Ausente, a tela usa [name].
  final String? itemLabel;

  /// Campos de **um item**. Vazio = coleção-contador (comportamento anterior).
  final List<FeatureField> fields;

  /// A coleção é `min:1` no contrato: salvar sem nenhum item não registra
  /// nada e o backend recusa.
  final bool isRequired;

  /// Campo que titula a linha da lista. Ausente, usa o primeiro de [fields].
  final String? titleField;

  /// Campos que compõem o resumo da linha, na ordem, separados por " · ".
  final List<String> subtitleFields;
}

/// Uma etapa do formulário longo — o arquétipo `Cadastro steps` do Figma
/// (`54349:1990`), que até aqui só existia nos fluxos dedicados de campo
/// (`FlowShell.totalSteps`) e não no motor genérico de cadastros.
///
/// Cada etapa nomeia um subconjunto dos [FeatureDefinition.fields] (por `id`)
/// e/ou das [FeatureDefinition.sections] (por nome). Uma etapa **sem** campos e
/// sem coleções é a etapa de revisão: a tela mostra ali o que foi preenchido,
/// antes de salvar.
///
/// Invariante conferida em `functional_catalog_test.dart`: quando uma
/// funcionalidade declara etapas, todo campo visível e toda coleção aparecem em
/// exatamente uma etapa — nada pode ficar inalcançável.
class FeatureFormStep {
  const FeatureFormStep({
    required this.title,
    this.fields = const [],
    this.sections = const [],
    this.hint,
  });

  /// Título da etapa, exibido no lugar de "Dados do registro".
  final String title;

  /// `id`s de [FeatureField] desta etapa, na ordem de exibição.
  final List<String> fields;

  /// Nomes de coleção ([FeatureDefinition.sections]) desta etapa.
  final List<String> sections;

  /// Uma linha de orientação sob o título — o que a pessoa precisa ter em mãos
  /// para vencer a etapa.
  final String? hint;
}

class FeatureDefinition {
  const FeatureDefinition({
    required this.id,
    required this.profile,
    required this.group,
    required this.title,
    required this.objective,
    required this.status,
    this.existingRoute,
    this.fields = const [],
    this.collections = const [],
    this.capabilities = const [],
    this.primaryAction,
    this.emptyLabel,
    this.sourceDetail,
    this.listMode = false,
    this.readOnly = false,
    this.dataSourceId,
    this.createAction,
    this.recordTitleField,
    this.recordDescriptionFields = const [],
    this.simulation,
    this.simulationTargetField,
    this.simulationCollectionName,
    this.successTitle,
    this.successDescription,
    this.auditExport,
    this.steps = const [],
  });

  final String id;
  final FeatureProfile profile;
  final String group;
  final String title;
  final String objective;
  final FeatureStatus status;
  final String? existingRoute;
  final List<FeatureField> fields;

  /// Coleções de itens da funcionalidade (onda 8). Ver [FeatureCollection].
  final List<FeatureCollection> collections;

  /// Nomes das coleções, na ordem — a forma como o resto do app sempre leu
  /// esta informação (etapas, motor, testes congelados). Derivado de
  /// [collections] desde a onda 8, para que exista uma fonte só.
  List<String> get sections => [
    for (final collection in collections) collection.name,
  ];

  /// Coleções `min:1` no contrato real.
  List<String> get requiredSections => [
    for (final collection in collections)
      if (collection.isRequired) collection.name,
  ];

  FeatureCollection? collectionByName(String name) {
    for (final collection in collections) {
      if (collection.name == name) return collection;
    }
    return null;
  }

  final List<String> capabilities;
  final String? primaryAction;
  final String? emptyLabel;
  final String? sourceDetail;
  final bool listMode;
  // banco-real (onda 1): torna explícito que uma funcionalidade é consulta —
  // sem virar edição em campo — mesmo mantendo `fields` preenchidos. Antes,
  // a única forma de virar consulta era esvaziar `fields`, o que jogaria fora
  // a documentação dos campos reais do sistema mapeados no banco (valiosa
  // para quando o backend for ligado). Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  final bool readOnly;
  final String? dataSourceId;
  final String? createAction;
  final String? recordTitleField;
  final List<String> recordDescriptionFields;
  final HardwareSimulationKind? simulation;
  final String? simulationTargetField;

  // fidelidade-esteira (onda 13): `animal_transfer_animal_farm` no dump é
  // pivô puro (`animal_id`, `transfer_animal_farm_id`) — o contrato real
  // aceita destino por animal, não um destino único para o lote inteiro.
  // Quando preenchido, a captura de hardware (RFID/scanner) não sobrescreve
  // mais um campo escalar de [simulationTargetField]: ela empilha um item
  // nesta coleção, com [simulationTargetField] como o `id` do campo do item
  // que recebe o valor capturado. Só `transferencia-animal` usa isto hoje.
  final String? simulationCollectionName;
  final String? successTitle;
  final String? successDescription;
  final AuditExportKind? auditExport;

  /// Etapas do formulário (fidelidade-campos, onda 0). Vazio = formulário de
  /// rolagem única, comportamento anterior. Preenchido, o motor genérico passa
  /// a paginar o cadastro e a validar etapa a etapa — usado só nos formulários
  /// longos, onde a rolagem única escondia o fim do preenchimento. Ver
  /// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
  final List<FeatureFormStep> steps;
}

// banco-real: `catalogoProdutos`, `catalogoItensEstoque` e
// `catalogoEquipamentos` moram em `cadastros_vinculados.dart` desde a onda 5 —
// junto dos atributos que cada opção carrega (unidade, armazém, medidor...).
// Todo campo "produto"/"matéria-prima" abaixo busca lá; só a tela Produtos
// cria um item novo em campo livre. Ver
// docs/ajustes-banco-real/05-cadastros-vinculados.md.

// Onda 8 — domínios compartilhados pelos **itens** de coleção. Mesmo critério
// de `catalogoProdutos` acima: quando o mesmo domínio real aparece em mais de
// uma coleção (unidade de medida, armazém, centro de custo, modo de
// identificação animal), ele mora num lugar só. Ver
// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 8.
const catalogoUnidades = <String>['kg', 't', 'L', 'Saco', 'Unidade'];

const catalogoArmazens = <String>[
  'Armazém A',
  'Depósito B',
  'Farmácia',
  'Tanque Diesel',
];

const catalogoCentrosCusto = <String>[
  'Centro Agrícola',
  'Centro Pecuária',
  'Centro Frota',
];

const catalogoResponsaveis = <String>[
  'João Oliveira',
  'Maria Souza',
  'Carlos Dias',
];

const catalogoIdentificacaoAnimal = <String>[
  'Brinco',
  'RFID',
  'SISBOV',
  'Tatuagem',
];

const catalogoCategoriasAnimais = <String>['Bezerro', 'Novilha', 'Vaca', 'Boi'];

// fidelidade-campos (onda 9 — re-auditoria 11/09): `stock_uuid` é o lote de
// estoque de um produto já recebido (o `ItemEstoque` do módulo Armazém), não
// o produto em si — `produto`/`materia-prima` seguem apontando para
// `catalogoProdutos`. Compartilhado por `pastagens.inputs[]`,
// `sanitario.items[]` e `monta-natural.simplified_animals[]`. Ver
// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 9.

// fidelidade-contrato (onda 3): categoria C da re-auditoria de 14/09 — o
// contrato exige UUID de catálogo (`exists` tenant-scoped) onde o protótipo
// captura texto livre. Sem persistência real, o protótipo não tem UUID de
// verdade; a correção é de forma — texto livre vira `select` sobre um
// domínio real, mesmo critério de `catalogoItensEstoque` acima. Compartilhado
// por `desmama`, `apartacao` e `transferencia-animal` (só
// lote-atual/novo-lote — a identificação do animal continua texto: é o
// campo-alvo da simulação de RFID). Ver
// docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 3.
const catalogoLotes = <String>[
  'Lote Recria 02',
  'Lote Engorda 05',
  'Lote Matrizes 01',
  'Lote Receptoras 03',
];

// fidelidade-contrato (re-auditoria pós-fix): catálogos fechados para FKs que
// ainda eram texto livre — dropdown de conjunto conhecido em vez de campo
// aberto. O valor emitido segue sendo o rótulo (③ uuid×rótulo só some com
// persistência), mas o campo deixa de aceitar texto arbitrário.
const catalogoAreas = <String>[
  'Talhão 01',
  'Talhão 02',
  'Talhão 03',
  'Pasto Norte',
  'Pasto Sul',
  'Reserva Legal',
];
const catalogoModulos = <String>['Módulo A', 'Módulo B', 'Módulo C'];
const catalogoEstacoesMonta = <String>[
  'Estação 2025/2026',
  'Estação 2026/2027',
];
const catalogoTouros = <String>[
  'Touro Nelore 4210',
  'Touro Angus 1180',
  'Touro Brahman 3055',
];

// Compartilhado por `compras-animais` (fornecedor e vendedor).
const catalogoFornecedores = <String>[
  'Fazenda Boa Vista',
  'Corretora Campo Alto',
  'Central de Genética Boa Vista',
  'Fazenda São Pedro',
  'Agropecuária Vale Verde',
];

// fidelidade-esteira (onda 15): domínios novos da expansão fiscal de
// `consulta-produtos` — curadoria representativa (mesmo critério das listas
// acima), não o domínio federal/tributário inteiro. `group_uuid` é uma FK
// distinta de `category_uuid` (`categoria`, já existente): grupo é a
// classificação contábil/fiscal do produto, categoria é a classificação
// operacional (Nutrição, Sanitário...) já usada pelo resto do catálogo.
const catalogoGruposProdutos = <String>[
  'Insumo agropecuário',
  'Matéria-prima',
  'Peça e equipamento',
  'Combustível e lubrificante',
  'Produto acabado',
  // fidelidade-contrato (re-auditoria 3ª avaliação): o grupo "Produção"
  // (`GroupProduct::PRODUCTION_GROUP_ID`, seed 8, description = 'Produção')
  // é o que torna `cultivation_uuid`/`ncm_uuid` obrigatórios no
  // `ProductRequest`. Faltava na lista — sem ele o gate condicional nunca
  // dispararia. O rótulo precisa ser exatamente 'Produção' (usado pela
  // condição em functional_journey_engine.dart).
  'Produção',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): cultivos (lavouras) —
// destino de `cultivation_uuid` em `consulta-produtos`, required quando o
// grupo é 'Produção'. Lista mock por instância de cultivo (safra + área),
// análoga ao FK `cultivations` do contrato.
const catalogoCultivos = <String>[
  'Soja 2025/2026 — Talhão 01',
  'Milho 2ª safra 2025/2026 — Talhão 02',
  'Algodão 2025/2026 — Pivô Central',
  'Café 2025/2026 — Setor Sul',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): estágios reprodutivos de
// matriz (FK `category_matrices` de `category_matrice_id` em /animals). Lista
// mock por instância; o gate required_if (RN-6) fica como follow-up.
const catalogoEstagiosReprodutivos = <String>[
  'Novilha de reposição',
  'Matriz em serviço',
  'Matriz descarte',
  'Doadora',
  'Receptora',
];

// fidelidade-contrato (re-auditoria 3ª avaliação): causas de perda/morte (FK
// `death_losses` de `cause_uuid`). Lista fechada mock — melhora sobre o texto
// livre (que nunca casaria no `exists`); o mapeamento para uuid é ③.
const catalogoCausasPerda = <String>[
  'Doença',
  'Predação',
  'Acidente',
  'Intoxicação',
  'Parto',
  'Causa desconhecida',
];

const catalogoNcm = <String>[
  '2309.90.90 — Preparações para alimentação animal',
  '3808.91.90 — Inseticidas',
  '3004.90.99 — Medicamentos veterinários',
  '2710.19.21 — Óleo diesel',
  '3105.20.10 — Adubos NPK',
];

const catalogoCategoriasFinanceiras = <String>[
  'Insumos agrícolas',
  'Insumos pecuários',
  'Manutenção e peças',
  'Combustíveis',
  'Ativo imobilizado',
];

// CST/CSOSN do Simples Nacional e do regime normal convivem na mesma coluna
// no dump (`products.cst_csosn`) — curadoria dos códigos mais comuns dos dois
// regimes, não a tabela CST completa.
const catalogoCstCsosn = <String>[
  '00 — Tributada integralmente',
  '20 — Com redução de base de cálculo',
  '40 — Isenta',
  '60 — ICMS cobrado por substituição tributária',
  '102 — Simples Nacional, sem permissão de crédito',
  '500 — ICMS cobrado anteriormente por ST (Simples Nacional)',
];

const catalogoCstPisCofins = <String>[
  '01 — Tributável, alíquota básica',
  '04 — Tributável, alíquota zero',
  '06 — Tributável, alíquota zero (monofásica)',
  '07 — Isenta',
  '08 — Sem incidência',
  '49 — Outras operações de saída',
];

const catalogoCstIpi = <String>[
  '00 — Entrada tributada com alíquota zero',
  '49 — Outras entradas',
  '50 — Saída tributada',
  '99 — Outras saídas',
];

const catalogoCfop = <String>[
  '5102 — Venda de mercadoria dentro do estado',
  '6102 — Venda de mercadoria fora do estado',
  '5101 — Venda de produção do estabelecimento',
  '6101 — Venda de produção fora do estado',
];

const catalogoOrigemMercadoria = <String>[
  '0 — Nacional',
  '1 — Estrangeira, importação direta',
  '2 — Estrangeira, adquirida no mercado interno',
  '3 — Nacional, conteúdo de importação acima de 40%',
  '5 — Nacional, conteúdo de importação até 40%',
];

// fidelidade-esteira (onda 15): campos da reforma tributária (IBS/CBS/IS) —
// muitos e recentes no dump; curadoria mínima só para não deixar o bloco
// vazio, sem pretensão de cobrir a tabela completa do novo regime.
const catalogoCstIbsCbs = <String>[
  '000 — Tributação integral',
  '200 — Alíquota reduzida',
  '400 — Imunidade',
  '800 — Suspensão',
];

const operationalFeatures = <FeatureDefinition>[
  FeatureDefinition(
    id: 'lote-animais',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Lote de animais',
    objective: 'Criar um lote em fluxo de múltiplas etapas.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): montar lote é organização de rebanho, não evento
    // de campo — cadastro fica no desktop, o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): employee_uuid é
      // nullable no AnimalBatchRequest — o app exigia a mais.
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'especie',
        label: 'Espécie',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Bovino', 'Bubalino', 'Ovino'],
      ),
      FeatureField(id: 'descricao', label: 'Descrição', isRequired: true),
      // fidelidade-contrato (onda 5): o contrato real é `category_uuids[]`
      // (array, min:1) — este escalar permanece só para a descrição do
      // registro nesta consulta (mesma nuance de `diagnostico-gestacao`/
      // `lotes-reproducao` na onda 4); a coleção abaixo documenta a
      // cardinalidade correta. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md,
      // Onda 5.
      FeatureField(
        id: 'categoria',
        label: 'Categoria',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoCategoriasAnimais,
      ),
      // fidelidade-campos (onda 3): `/animal-batches` exige `date` e liga o
      // lote a curral e parâmetro de peso — nada disso existia na tela.
      FeatureField(
        id: 'data',
        label: 'Data de formação',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'curral',
        label: 'Curral de confinamento',
        type: FeatureFieldType.select,
        options: ['Curral 01', 'Curral 02', 'Curral 03', 'Curral 04'],
      ),
      FeatureField(
        id: 'parametro-peso',
        label: 'Parâmetro de peso',
        type: FeatureFieldType.select,
        options: ['Leve', 'Médio', 'Pesado'],
      ),
    ],
    // `animal_uuids[]` — quais animais compõem o lote. É o que diferencia
    // `/animal-batches` de `/batches`, que não tem a coleção.
    collections: [
      FeatureCollection(
        name: 'Animais do lote',
        itemLabel: 'Animal do lote',
        titleField: 'identificacao',
        subtitleFields: ['categoria', 'peso'],
        fields: [
          // fidelidade-contrato (onda 3): `animal_uuids[]` exige UUID de um
          // animal já cadastrado — texto livre não referencia nada de
          // verdade. Vira `select` sobre `catalogoIdentificacaoAnimal`
          // combinado ao número (mesmo padrão de `identifications[]` de
          // `registrar-animal`), documentando a intenção de FK.
          FeatureField(
            id: 'tipo-identificacao',
            label: 'Modo de identificação',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoIdentificacaoAnimal,
          ),
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco, RFID ou SISBOV',
          ),
          FeatureField(
            id: 'categoria',
            label: 'Categoria',
            type: FeatureFieldType.searchSelect,
            options: catalogoCategoriasAnimais,
          ),
          FeatureField(
            id: 'peso',
            label: 'Peso (kg)',
            type: FeatureFieldType.number,
          ),
        ],
      ),
      // fidelidade-contrato (onda 5): `category_uuids[]` — o contrato aceita
      // mais de uma categoria por lote (ex.: um lote de "novilhas e bois").
      // Reusa o motor de coleção (nenhum componente novo) em vez de um
      // multi-select próprio: o mesmo truque de `lotes-reproducao` na onda 4.
      FeatureCollection(
        name: 'Categorias do lote',
        itemLabel: 'Categoria',
        isRequired: true,
        titleField: 'categoria',
        fields: [
          FeatureField(
            id: 'categoria',
            label: 'Categoria',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoCategoriasAnimais,
          ),
        ],
      ),
    ],
    primaryAction: 'Criar lote',
    listMode: true,
    createAction: 'Novo lote',
    recordTitleField: 'descricao',
    recordDescriptionFields: ['especie', 'categoria', 'data'],
  ),
  FeatureDefinition(
    id: 'cadastrar-area',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Áreas',
    objective: 'Cadastrar áreas usadas nos processos da fazenda.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): estrutura física da fazenda, não ação diária de
    // campo — cadastro fica no desktop, o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'nome',
        label: 'Nome da área',
        isRequired: true,
        placeholder: 'Ex.: Talhão 03',
      ),
      // fidelidade-contrato (onda 2): o TODO(banco-real) abaixo fica
      // resolvido — a auditoria de 14/09 confirma o enum real de `AreaType`:
      // `{Produtiva, Reserva}`. A classificação setorial (agricultura,
      // pecuária…) já mora em "Atividade", mais abaixo — este campo é outra
      // dimensão do contrato (se a área produz ou é reserva). Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 2.
      // fidelidade-contrato (re-auditoria 3ª avaliação): AreaType é int-backed
      // (PRODUCTIVE=1, RESERVE=2) e Rule::enum valida o backing — o campo
      // emite o int (selectOptions) e exibe o rótulo.
      FeatureField(
        id: 'tipo',
        label: 'Tipo de uso',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: '1', label: 'Produtiva'),
          (value: '2', label: 'Reserva'),
        ],
      ),
      FeatureField(
        id: 'area-total',
        label: 'Área total',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // banco-real: `areas.productive_area`, `areas.unproductive_area` e
      // `areas.animal_load` já existem no banco e alimentam o dashboard pecuário
      // real — faltavam no cadastro. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
      //
      // fidelidade-contrato (onda 1): `productive_area` e `unproductive_area`
      // são required em `/areas` e entraram opcionais. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      FeatureField(
        id: 'area-produtiva',
        label: 'Área produtiva',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'area-nao-produtiva',
        label: 'Área não produtiva',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'carga-animal',
        label: 'Carga animal (UA/ha)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['ha', 'm²'],
      ),
      FeatureField(
        id: 'localizacao',
        label: 'Localização',
        isRequired: true,
        placeholder: 'Setor ou referência',
      ),
      FeatureField(
        id: 'cultura',
        label: 'Cultura / cobertura',
        placeholder: 'Opcional',
      ),
      // fidelidade-campos (onda 3): o que `/areas` tem e a tela não mostrava.
      // `color` é required no contrato — é a cor com que a área aparece no
      // mapa, sem ela o desenho da fazenda não se distingue.
      //
      // fidelidade-contrato (re-auditoria 3ª avaliação): `AreaRequest::rules()`
      // valida `color` com `Rule::enum(AreaColor)` — 14 cores fechadas. A onda
      // 11 tinha aberto isto para hex livre lendo o dump de produção (`varchar`
      // com 150+ hex), mas dado-em-repouso acumulado ≠ contrato de escrita: o
      // POST novo rejeita qualquer hex fora do enum (422). Volta a ser paleta
      // fechada — agora via [areaColorPalette], não a lista de nomes à mão da
      // onda 2b. O antigo `DEFAULT '#f6c23e'` do banco NÃO está no enum; o
      // motor não semeia valor inicial, então nenhuma cor inválida entra.
      FeatureField(
        id: 'cor',
        label: 'Cor no mapa',
        type: FeatureFieldType.color,
        isRequired: true,
        colorPalette: areaColorPalette,
      ),
      FeatureField(
        id: 'matricula',
        label: 'Matrícula',
        placeholder: 'Matrícula do imóvel',
      ),
      FeatureField(
        id: 'atividade',
        label: 'Atividade',
        type: FeatureFieldType.select,
        options: ['Agricultura', 'Pecuária', 'Fruticultura', 'Silvicultura'],
      ),
      FeatureField(
        id: 'proprietario',
        label: 'Proprietário',
        placeholder: 'Pessoa ou empresa titular',
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): recreation_area e
      // is_enabled são `required|boolean` — 'Sim'/'Não' não passa na regra
      // boolean. Emitem 'true'/'false' (aceitos por `boolean` do Laravel) via
      // selectOptions, exibindo Sim/Não.
      FeatureField(
        id: 'area-recreio',
        label: 'Área de recreio',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'true', label: 'Sim'),
          (value: 'false', label: 'Não'),
        ],
      ),
      FeatureField(
        id: 'ativo',
        label: 'Ativa',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'true', label: 'Sim'),
          (value: 'false', label: 'Não'),
        ],
      ),
      // fidelidade-campos (onda 9 — re-auditoria 11/09): `farm_uuid` é
      // required no POST de `/areas` (a fazenda dona da área) e `coordinates`
      // é o polígono desenhado no mapa — os dois vêm do cadastro no desktop;
      // aqui documentam o contrato que a consulta audita.
      FeatureField(
        id: 'fazenda',
        label: 'Fazenda',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Fazenda São Pedro', 'Fazenda Boa Vista'],
      ),
      // fidelidade-contrato (re-auditoria pós-fix): `coordinates` é
      // `required|array` (polígono). É uma interação de MAPA/localização —
      // que o CLAUDE.md declara SIMULADA no protótipo ("não apresentar
      // localização como integração nativa concluída"), na mesma categoria do
      // hardware (RFID/balança). Fica como captura simulada (placeholder do
      // polígono desenhado no desktop), não um textarea de conteúdo livre; a
      // materialização como array acontece na integração com o mapa real. Tela
      // readOnly no protótipo (não submete).
      FeatureField(
        id: 'coordenadas',
        label: 'Coordenadas (polígono — mapa)',
        type: FeatureFieldType.textarea,
        isRequired: true,
        placeholder:
            'Polígono desenhado no mapa (captura simulada no protótipo)',
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
        placeholder: 'Informações adicionais',
      ),
    ],
    // `infrastructure[]` — no contrato é um array de UUID de markers (tipo
    // INFRASTRUCTURE) POSICIONADOS no mapa da área — outra interação de
    // localização SIMULADA pelo protótipo (CLAUDE.md). A coleção representa o
    // array (cardinalidade fiel); cada item captura o marcador de forma
    // descritiva (tipo/descrição/qtd) em vez do UUID do marker no mapa — a
    // resolução para marker_uuid acontece na integração com o mapa real (③).
    collections: [
      FeatureCollection(
        name: 'Infraestrutura',
        itemLabel: 'Item de infraestrutura',
        titleField: 'tipo',
        subtitleFields: ['descricao', 'quantidade'],
        fields: [
          FeatureField(
            id: 'tipo',
            label: 'Tipo',
            type: FeatureFieldType.select,
            isRequired: true,
            options: [
              'Cerca',
              'Bebedouro',
              'Curral',
              'Cocho',
              'Porteira',
              'Galpão',
              'Balança',
            ],
          ),
          FeatureField(
            id: 'descricao',
            label: 'Descrição',
            placeholder: 'Onde fica, de que é feito',
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
          ),
        ],
      ),
    ],
    primaryAction: 'Salvar área',
    listMode: true,
    createAction: 'Adicionar área',
    recordTitleField: 'nome',
    recordDescriptionFields: ['tipo', 'area-total', 'unidade'],
  ),
  FeatureDefinition(
    id: 'formulacoes',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Formulações',
    objective: 'Criar formulações compostas por matérias-primas e percentuais.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): formular dieta é decisão técnica e de custo, não
    // ação de campo — cadastro fica no desktop, o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // fidelidade-contrato (re-auditoria pós-fix): is_enabled é required|boolean
      // — emite 'true'/'false' (selectOptions), exibe Sim/Não.
      FeatureField(
        id: 'ativo',
        label: 'Ativo',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'true', label: 'Sim'),
          (value: 'false', label: 'Não'),
        ],
      ),
      FeatureField(
        id: 'produto',
        label: 'Produto',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoProdutos,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de referência',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade de medida',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['kg', 't', 'L'],
        derivedFrom: FeatureFieldDerivation(
          source: 'produto',
          values: unidadePorProduto,
        ),
      ),
      // fidelidade-esteira (onda 16): rótulo confirmado pelo usuário —
      // `FoodTypeEnum` (`P`/`U`) é `P` = "Porcentagem", `U` = "Unidade". O
      // TODO(banco-real) anterior (mantido por falta de confirmação do
      // rótulo) foi resolvido; supera também a nota de categoria 2b da
      // fidelidade-contrato. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md,
      // Onda 16.
      // fidelidade-contrato (re-auditoria 3ª avaliação): FoodTypeEnum é
      // string-backed 'P'/'U' e Rule::enum valida o backing — o campo emite
      // 'P'/'U' (selectOptions) e exibe o rótulo.
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'P', label: 'Porcentagem'),
          (value: 'U', label: 'Unidade'),
        ],
      ),
      FeatureField(
        id: 'materia-prima',
        label: 'Matéria-prima',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoProdutos,
      ),
      FeatureField(
        id: 'porcentagem',
        label: 'Porcentagem (%)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // banco-real: `diets.cost_per_kg` e `diets.estimated_cost` — dado que o
      // banco real já calcula e o protótipo não mostrava. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
      FeatureField(
        id: 'custo-por-kg',
        label: 'Custo por kg (R\$)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'custo-estimado',
        label: 'Custo estimado (R\$)',
        type: FeatureFieldType.number,
      ),
      // fidelidade-campos (onda 5): esta é a tela mais alinhada da auditoria —
      // faltavam a data (required no contrato), a unidade da matéria-prima
      // (`feedstocks.*.measurement_uuid`, que no contrato é por ingrediente) e,
      // se a tela for lida como Dieta, objetivo e observação. `custo-por-kg` e
      // `custo-estimado` continuam aqui como leitura: são calculados no
      // servidor e nunca entram como input.
      FeatureField(
        id: 'data',
        label: 'Data da formulação',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'unidade-materia-prima',
        label: 'Unidade da matéria-prima',
        type: FeatureFieldType.select,
        options: ['kg', 't', 'L', 'Saco'],
      ),
      FeatureField(
        id: 'objetivo',
        label: 'Objetivo',
        placeholder: 'Ganho de peso, mantença, terminação',
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): feedstocks é
      // required|array|min:1 no FoodRequest — trava ≥1.
      FeatureCollection(
        name: 'Matérias-primas',
        itemLabel: 'Matéria-prima',
        isRequired: true,
        titleField: 'materia-prima',
        subtitleFields: ['porcentagem', 'unidade'],
        fields: [
          FeatureField(
            id: 'materia-prima',
            label: 'Matéria-prima',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'porcentagem',
            label: 'Porcentagem (%)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'materia-prima',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'materia-seca',
            label: 'Matéria seca (%)',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'custo',
            label: 'Custo (R\$)',
            type: FeatureFieldType.number,
            derivedFrom: FeatureFieldDerivation(
              source: 'materia-prima',
              values: custoMedioPorProduto,
              locked: false,
            ),
          ),
        ],
      ),
    ],
    primaryAction: 'Salvar formulação',
    listMode: true,
    createAction: 'Nova formulação',
    recordTitleField: 'produto',
    recordDescriptionFields: ['quantidade', 'unidade', 'custo-estimado'],
  ),
  FeatureDefinition(
    id: 'trato-diario',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Trato diário',
    objective: 'Distribuir uma batelada entre os currais elegíveis do dia.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/trato-diario',
  ),
  FeatureDefinition(
    id: 'leitura-cocho-confinamento',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Leitura de cocho',
    objective:
        'Avaliar sobras por curral e registrar ocorrências sanitárias, estruturais e ambientais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/leitura-cocho',
  ),
  // banco-real (onda 4): fonte real identificada no dump gbcerne é
  // `appropriations` + tabelas filhas `appropriation_employee/equipment/
  // stock/occurrences` — não `service_orders`, hipótese das ondas 1/2 (a
  // esteira anterior não conhecia a família `appropriation_*`, só analisada
  // nesta onda a partir do dump de homologação). Motor genérico
  // (`fields`/`sections`) trocado por fluxo dedicado: os quatro grupos de
  // recurso são listas reais por item (função, colaborador, quantidade,
  // unidade, valor — não um contador), e Operação/Atividade viram dropdown
  // vindo de `operations`/`activities` em vez de campo livre. Ver
  // docs/ajustes-banco-real/04-apontamento-appropriations.md.
  FeatureDefinition(
    id: 'apontamento',
    profile: FeatureProfile.operational,
    group: 'Agricultura',
    title: 'Apontamento agrícola',
    objective: 'Registrar uma operação agrícola e os recursos associados.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/apontamento',
  ),
  FeatureDefinition(
    id: 'marcacao',
    profile: FeatureProfile.operational,
    group: 'Agricultura',
    title: 'Marcação',
    objective: 'Acessar e registrar marcações agrícolas.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'area',
        label: 'Área',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoAreas,
      ),
      // fidelidade-campos (onda 2): `date` não vem marcado como required em
      // `/markings`, mas toda marcação nasce de um dia de campo e todos os
      // demais lançamentos do catálogo pedem a data — mantida obrigatória.
      FeatureField(
        id: 'data',
        label: 'Data da marcação',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'tipo',
        label: 'Tipo de marcação',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Ponto de atenção',
          'Amostragem',
          'Ocorrência',
          'Limite de operação',
        ],
      ),
      FeatureField(id: 'descricao', label: 'Descrição', isRequired: true),
      FeatureField(
        id: 'referencia',
        label: 'Referência de localização',
        isRequired: true,
      ),
      // Os 8 campos reais de `/markings` que o protótipo não tinha. A tela era
      // quase inteiramente presumida: tipo/descrição/referência não existem no
      // contrato (ficam, por decisão desta leva — nada sai), e o que existe de
      // verdade (safra, variedade, semana, cor, quantidade, funcionário,
      // centro de custo) estava ausente.
      //
      // fidelidade-contrato (onda 1): os 5 abaixo são `required` no contrato
      // real e entraram como opcionais na leva anterior — a submissão
      // quebraria com 422. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      FeatureField(
        id: 'safra',
        label: 'Safra',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['2023/2024', '2024/2025', '2025/2026', '2026/2027'],
      ),
      FeatureField(
        id: 'variedade',
        label: 'Variedade / cultura',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Soja',
          'Milho',
          'Algodão',
          'Cana-de-açúcar',
          'Café',
          'Braquiária',
        ],
      ),
      // TODO(banco-real): `week_vintage_uuid` é FK para a semana da safra;
      // sem a tabela de domínio no dump, o protótipo pede o número da semana.
      // Confirmar com o time web se vira select antes de ligar o backend.
      FeatureField(
        id: 'semana-safra',
        label: 'Semana da safra',
        type: FeatureFieldType.number,
        isRequired: true,
        placeholder: 'Nº da semana',
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): quantity é integer|min:1
      // em /markings.
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade',
        type: FeatureFieldType.integer,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): a cor de `/markings`
      // é validada por `MarkingRequest::rules()` com
      // `Rule::enum(MarkingColorEnum)` — 16 cores, DISTINTAS das de Área
      // (`/markings` NÃO usa `AreaColor`; o comentário anterior desta tela,
      // que dizia escrever em `areas.color` no "mesmo domínio", estava
      // errado). Paleta fechada própria via [markingColorPalette]. Atenção:
      // 5 valores são MAIÚSCULOS e o enum casa string exata — não normalizar.
      FeatureField(
        id: 'cor',
        label: 'Cor no mapa',
        type: FeatureFieldType.color,
        isRequired: true,
        colorPalette: markingColorPalette,
      ),
      FeatureField(
        id: 'funcionario',
        label: 'Funcionário',
        type: FeatureFieldType.select,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'centro-custo',
        label: 'Centro de custo',
        type: FeatureFieldType.searchSelect,
        options: catalogoCentrosCusto,
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem marcou, quando e em que área.',
        fields: ['responsavel', 'data', 'area', 'referencia'],
      ),
      FeatureFormStep(
        title: 'Marcação',
        hint: 'O que foi marcado e como aparece no mapa.',
        fields: ['tipo', 'descricao', 'cor', 'quantidade'],
      ),
      FeatureFormStep(
        title: 'Safra e custo',
        hint: 'A que safra a marcação pertence e quem a executou.',
        fields: [
          'safra',
          'variedade',
          'semana-safra',
          'funcionario',
          'centro-custo',
        ],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira a marcação antes de salvar.',
      ),
    ],
    primaryAction: 'Salvar marcação',
    sourceDetail:
        'Os campos não foram exibidos; o protótipo usa premissas mínimas sem GPS real.',
    listMode: true,
    createAction: 'Nova marcação',
    recordTitleField: 'descricao',
    recordDescriptionFields: ['tipo', 'area', 'data'],
  ),
  FeatureDefinition(
    id: 'pesagem',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Pesagens',
    objective: 'Consultar e registrar pesagens do rebanho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/pesagem',
  ),
  FeatureDefinition(
    id: 'sanitario',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Sanitário',
    objective: 'Criar um manejo sanitário por responsável e lote.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'data',
        label: 'Data do manejo',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'tipo',
        label: 'Tipo de manejo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Vacinação', 'Vermifugação', 'Tratamento', 'Exame'],
      ),
      // fidelidade-esteira: fica de fora da regra "todo campo Produto é
      // dropdown com busca" de propósito — o rótulo é dual ("Produto /
      // procedimento") porque cobre tanto um item de `catalogoProdutos`
      // quanto um procedimento sem produto associado (ex. "Exame de casco"),
      // que não existe nesse catálogo. Forçar `catalogoProdutos` aqui
      // impediria registrar procedimentos reais.
      FeatureField(
        id: 'produto',
        label: 'Produto / procedimento',
        isRequired: true,
      ),
      // banco-real: `sanitaries.time_control` indica se o manejo tem
      // carência/intervalo a respeitar — dado sensível de rastreabilidade
      // (retirada de leite/carne pós-medicamento) ausente no protótipo. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
      //
      // fidelidade-contrato (onda 1): `time_control` é required no contrato
      // real, não opcional. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      // fidelidade-contrato (re-auditoria pós-fix): time_control é
      // required|boolean — emite 'true'/'false' (selectOptions), exibe Sim/Não.
      FeatureField(
        id: 'controle-por-tempo',
        label: 'Controle por tempo (carência)',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'true', label: 'Sim'),
          (value: 'false', label: 'Não'),
        ],
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // fidelidade-campos (onda 3): em `/sanitaries` o manejo tem três coleções
    // e a tela tinha um "produto" solto. `animal_uuids[]` diz a **quais
    // animais** o manejo se aplica — sem isso não há rastreabilidade de
    // carência; `items[]` são os produtos consumidos (armazém, estoque,
    // unidade, quantidade, centro de custo) e `labor[]` quem executou.
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): animal_uuids é
      // required|array|min:1 no SanitaryRequest — a coleção precisa travar ≥1.
      FeatureCollection(
        name: 'Animais alvo',
        itemLabel: 'Animal',
        isRequired: true,
        titleField: 'identificacao',
        subtitleFields: ['lote'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
        ],
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): items é
      // required|array|min:1 no SanitaryRequest — trava ≥1.
      FeatureCollection(
        name: 'Itens de estoque',
        itemLabel: 'Item de estoque',
        isRequired: true,
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade', 'armazem'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoProdutos,
          ),
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `items.*.stock_uuid` é required em `/sanitaries` — o lote de
          // estoque de onde o produto saiu, não só o produto.
          FeatureField(
            id: 'estoque',
            label: 'Item de estoque',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoItensEstoque,
            optionsFrom: FeatureOptionsFilter(
              source: 'produto',
              options: estoquesPorProduto,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'estoque',
              values: armazemPorItemEstoque,
            ),
          ),
          FeatureField(
            id: 'centro-custo',
            label: 'Centro de custo',
            type: FeatureFieldType.searchSelect,
            options: catalogoCentrosCusto,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Mão de obra',
        itemLabel: 'Mão de obra',
        titleField: 'executor',
        subtitleFields: ['tipo', 'quantidade', 'unidade'],
        fields: [
          FeatureField(
            id: 'executor',
            label: 'Executor',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoResponsaveis,
          ),
          // fidelidade-contrato (onda 2): `labor.func_type` real tem 3
          // valores (`employees`/`functions`/`providers`), não 2. TODO
          // (banco-real): confirmar com o time web o rótulo em português
          // exato de `functions` — "Função" é a tradução literal, mas pode
          // não ser o termo usado para tipo de mão de obra em campo. Ver
          // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 2.
          // fidelidade-contrato (re-auditoria pós-fix): labor.*.func_type é
          // in:[1,2,3] — emite o int (selectOptions), exibe o rótulo.
          FeatureField(
            id: 'tipo',
            label: 'Tipo',
            type: FeatureFieldType.select,
            isRequired: true,
            selectOptions: [
              (value: '1', label: 'Empregado'),
              (value: '2', label: 'Função'),
              (value: '3', label: 'Prestador'),
            ],
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação):
          // labor.*.measurement_uuid é required_with:labor — ao adicionar uma
          // linha de mão de obra, a unidade é obrigatória.
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Hora', 'Dia'],
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem aplicou o manejo, em que lote e quando.',
        fields: ['responsavel', 'lote', 'data'],
      ),
      FeatureFormStep(
        title: 'Manejo',
        hint: 'O que foi feito e se há carência a respeitar.',
        fields: ['tipo', 'produto', 'controle-por-tempo', 'observacao'],
      ),
      FeatureFormStep(
        title: 'Animais, produtos e equipe',
        hint: 'A quem se aplicou, o que saiu do estoque e quem executou.',
        sections: ['Animais alvo', 'Itens de estoque', 'Mão de obra'],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira o manejo antes de salvar.',
      ),
    ],
    primaryAction: 'Salvar manejo',
    sourceDetail:
        'A fonte mostrou apenas a primeira etapa; os campos complementares são premissas do protótipo frontend.',
    listMode: true,
    createAction: 'Novo manejo sanitário',
    recordTitleField: 'lote',
    recordDescriptionFields: ['tipo', 'data'],
  ),
  // banco-real: `diet_beats.quantity` (previsto) e `item_diet_beats.quantity_realized`
  // (realizado) já vêm separados no banco — a diferença entre os dois é o dado mais
  // valioso desta tela (mostra desvio de batida) e antes ficava resumido em um único
  // campo "quantidade de referência". Ver
  // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
  FeatureDefinition(
    id: 'batidas',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Batida',
    objective:
        'Registrar a produção de uma formulação para um armazém de destino.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): cadastro de produção; a execução real de campo é
    // `producao-batelada` (Confinamento) — aqui vira consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // TODO(banco-real): mesmo campo `tipo` de `formulacoes` — conflate
      // `item_diet_beats.type`/dieta associada, sem tabela de domínio no dump.
      // Confirmar valores com o time web antes de travar. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Estoque', 'Formulação'],
      ),
      FeatureField(
        id: 'armazem',
        label: 'Armazém de destino',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: ['Armazém A', 'Depósito B', 'Farmácia'],
      ),
      FeatureField(
        id: 'produto',
        label: 'Produto',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoProdutos,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade prevista',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'quantidade-realizada',
        label: 'Quantidade realizada',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade de medida',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['kg', 't', 'L'],
        derivedFrom: FeatureFieldDerivation(
          source: 'produto',
          values: unidadePorProduto,
        ),
      ),
      // fidelidade-campos (onda 5): a tela misturava dois recursos reais
      // (DietBeat × FoodBeat). `tipo` e `armazem` acima pertencem ao FoodBeat
      // e ficam (nada sai nesta leva); o que faltava era o DietBeat inteiro —
      // dieta, vagão e data, os três required em `/diet-beats`.
      FeatureField(
        id: 'dieta',
        label: 'Dieta',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Dieta Adaptação', 'Dieta Crescimento', 'Dieta Terminação'],
      ),
      FeatureField(
        id: 'equipamento',
        label: 'Vagão / equipamento',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Vagão Misturador 01',
          'Vagão Misturador 02',
          'Misturador Fixo',
        ],
      ),
      FeatureField(
        id: 'data',
        label: 'Data da batida',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
    ],
    // `items[]` — cada ingrediente da batida tem estoque, matéria seca, custo
    // e porcentagem próprios; é onde o desvio da batida aparece.
    collections: [
      // fidelidade-contrato (re-auditoria pós-fix): items é required|array|min:1
      // no DietBeatRequest — trava ≥1 (mesmo padrão de producao-batelada).
      FeatureCollection(
        name: 'Itens da batida',
        itemLabel: 'Item da batida',
        isRequired: true,
        titleField: 'produto',
        subtitleFields: ['quantidade', 'porcentagem'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém de estoque',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: armazemPadraoPorProduto,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `items.*.quantity_realized` é required em `/diet-beats` e é **por
          // item** — só existia no cabeçalho, que mostra o total da batida.
          FeatureField(
            id: 'quantidade-realizada',
            label: 'Quantidade realizada',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          // fidelidade-contrato (onda 4): `items.*.measurement_uuid` é
          // required e estava ausente; `materia-seca`/`custo`/`porcentagem`
          // são os 3 required por item que a leva anterior deixou opcionais.
          // Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 4.
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'materia-seca',
            label: 'Matéria seca (%)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'custo',
            label: 'Custo (R\$)',
            type: FeatureFieldType.number,
            isRequired: true,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: custoMedioPorProduto,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'porcentagem',
            label: 'Porcentagem da dieta (%)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
        ],
      ),
    ],
    primaryAction: 'Salvar batida',
    emptyLabel: 'Nenhuma batida registrada.',
    listMode: true,
    createAction: 'Nova batida',
    recordTitleField: 'produto',
    recordDescriptionFields: ['quantidade', 'quantidade-realizada', 'armazem'],
  ),
  FeatureDefinition(
    id: 'nutricoes',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Arraçoamento',
    objective: 'Registrar produtos, quantidade, área, módulo e cocho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/arracoamento',
  ),
  // banco-real: ao integrar, o backend real de troca de LOTE é a tabela
  // `transfer_batch_farms` — `transfer_animal_farms` é troca entre FAZENDAS e não
  // deve ser usada aqui apesar do nome parecido. Ver
  // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
  FeatureDefinition(
    id: 'transferencia-animal',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Transferência animal / lote',
    objective:
        'Mover um animal para outro lote com identificação por brinco, RFID ou câmera.',
    status: FeatureStatus.hardware,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // fidelidade-contrato (onda 3): texto livre vira `select` sobre
      // `catalogoLotes`.
      FeatureField(
        id: 'lote-atual',
        label: 'Lote atual',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      // fidelidade-esteira (onda 13): `novo-lote` deixa de ser sempre
      // obrigatório — só quando `destino-unico` = "Sim" (um lote só para
      // todos). Quando "Não", cada animal da coleção abaixo tem o seu
      // próprio destino (`isCollectionItemFieldRequired`). Ver
      // `functional_journey_engine.dart`.
      FeatureField(
        id: 'novo-lote',
        label: 'Novo lote (todos os animais)',
        type: FeatureFieldType.searchSelect,
        options: catalogoLotes,
      ),
      // fidelidade-campos (onda 3): `same_batch` é a flag required de
      // `/animals/batch-transfer` — decide se todos os animais vão para um
      // lote só ou se cada um tem o seu destino. Sem ela o backend não sabe
      // como interpretar o resto da submissão.
      // fidelidade-contrato (re-auditoria pós-fix): same_batch é required|boolean
      // — emite 'true'/'false' (selectOptions), exibe Sim/Não. Os condicionais
      // do motor comparam contra 'true'/'false'.
      FeatureField(
        id: 'destino-unico',
        label: 'Mesmo lote para todos',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'true', label: 'Sim'),
          (value: 'false', label: 'Não'),
        ],
      ),
    ],
    // fidelidade-esteira (onda 13): `animal_transfer_animal_farm` no dump é
    // pivô puro (`animal_id`, `transfer_animal_farm_id`) — o contrato real
    // aceita **destino por animal**, não um destino único para o lote
    // inteiro. A captura por RFID/scanner deixa de sobrescrever um campo
    // escalar `identificacao` e passa a empilhar um item aqui a cada
    // leitura (`simulationCollectionName` abaixo); quando `destino-unico` =
    // "Não", cada item ganha seu próprio `novo-lote`.
    collections: [
      FeatureCollection(
        name: 'Animais transferidos',
        itemLabel: 'Animal',
        isRequired: true,
        titleField: 'identificacao',
        subtitleFields: ['novo-lote'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação animal',
            isRequired: true,
            placeholder: 'Brinco ou ID',
          ),
          FeatureField(
            id: 'novo-lote',
            label: 'Novo lote',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
        ],
      ),
    ],
    capabilities: ['Balança', 'RFID', 'Scanner SISBOV'],
    primaryAction: 'Salvar transferência',
    listMode: true,
    createAction: 'Nova transferência de animal',
    recordTitleField: 'lote-atual',
    recordDescriptionFields: ['novo-lote', 'destino-unico'],
    simulation: HardwareSimulationKind.rfid,
    simulationTargetField: 'identificacao',
    simulationCollectionName: 'Animais transferidos',
  ),
  FeatureDefinition(
    id: 'transferencia-lote-area',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Transferência lote / área',
    objective: 'Alterar a localização de um lote entre área e módulo.',
    status: FeatureStatus.ready,
    fields: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): employee_uuid é
      // nullable no BatchModuleAreaTransferRequest — o app exigia a mais.
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): 'local-atual' não
      // existe no contrato (o Request não tem origem) — deixa de ser required
      // para não exigir um campo não-contratual.
      FeatureField(id: 'local-atual', label: 'Área / módulo atual'),
      // fidelidade-contrato (onda 6): o contrato exige **exatamente um**
      // destino — área, módulo ou curral — nunca área e módulo ao mesmo
      // tempo (como o form obrigava fixo até aqui) nem nenhum dos três. Este
      // select decide qual dos três campos abaixo passa a ser exigido, mesmo
      // padrão do XOR de `pastagens.destino`. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 6.
      FeatureField(
        id: 'destino',
        label: 'Destino da transferência',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Área', 'Módulo', 'Curral'],
      ),
      FeatureField(
        id: 'area',
        label: 'Nova área',
        type: FeatureFieldType.searchSelect,
        options: catalogoAreas,
      ),
      FeatureField(
        id: 'modulo',
        label: 'Novo módulo',
        type: FeatureFieldType.searchSelect,
        options: catalogoModulos,
      ),
      // fidelidade-campos (onda 3): `date` é required em
      // `/batch-module-area-transfers`, e o curral de confinamento é o
      // terceiro destino possível, em XOR com área e módulo.
      FeatureField(
        id: 'data',
        label: 'Data da transferência',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'curral',
        label: 'Curral de confinamento',
        type: FeatureFieldType.select,
        options: ['Curral 01', 'Curral 02', 'Curral 03', 'Curral 04'],
      ),
    ],
    primaryAction: 'Salvar transferência',
    listMode: true,
    createAction: 'Nova transferência',
    recordTitleField: 'lote',
    recordDescriptionFields: ['area', 'modulo', 'data'],
  ),
  FeatureDefinition(
    id: 'localizar-animal',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Localizar animal',
    objective: 'Localizar um animal por brinco, ID, RFID ou câmera.',
    status: FeatureStatus.hardware,
    fields: [
      FeatureField(
        id: 'identificacao',
        label: 'Identificação animal',
        isRequired: true,
        placeholder: 'Brinco ou ID',
      ),
    ],
    capabilities: ['RFID', 'Scanner SISBOV'],
    primaryAction: 'Buscar animal',
    simulation: HardwareSimulationKind.rfid,
    simulationTargetField: 'identificacao',
    successTitle: 'Animal localizado',
    successDescription:
        'Animal ativo no Lote 42 · Engorda, atualmente no Pasto Norte · Módulo A.',
  ),
  // fidelidade-campos (onda 1): `pastagens` volta ao operacional. A terceira
  // decisão de 360f0f8 a tinha tratado como decisão de manejo, mas o registro
  // é o mesmo gênero do apontamento agrícola — data, local, operação e os
  // recursos consumidos no dia —, e o app é o executor desse lançamento.
  //
  // Volta com o formulário inteiro que o protótipo nunca teve: no contrato
  // `/pastures` faltavam 6 escalares (data, destino em XOR, operação,
  // atividade, lote, animal) e as 5 coleções de lançamento; a tela tinha só
  // responsável e dois armazéns. Por ser o formulário mais longo do motor
  // genérico, é também o primeiro a usar as etapas da onda 0. Ver
  // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 1.
  FeatureDefinition(
    id: 'pastagens',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Pastagens',
    objective: 'Registrar recursos e serviços aplicados à pastagem.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data do manejo',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // O contrato aceita área **ou** piquete, nunca os dois: este select é o
      // que decide qual dos dois campos abaixo passa a ser exigido (regra em
      // `isFeatureFieldRequired`/`featureFieldError`). Sem ele, a tela pediria
      // os dois e nenhuma submissão passaria.
      FeatureField(
        id: 'destino',
        label: 'Local do manejo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Área', 'Piquete'],
      ),
      FeatureField(
        id: 'area',
        label: 'Área',
        type: FeatureFieldType.select,
        options: ['Talhão 01', 'Talhão 02', 'Pasto Norte', 'Pasto Sul'],
      ),
      FeatureField(
        id: 'piquete',
        label: 'Piquete',
        type: FeatureFieldType.select,
        options: ['Piquete 01', 'Piquete 02', 'Piquete 03', 'Piquete 04'],
      ),
      FeatureField(
        id: 'operacao',
        label: 'Operação',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Formação de pastagem',
          'Manutenção de pastagem',
          'Reforma de pastagem',
          'Vedação / diferimento',
        ],
      ),
      FeatureField(
        id: 'atividade',
        label: 'Atividade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Roçada',
          'Gradagem',
          'Calagem',
          'Adubação de cobertura',
          'Aplicação de herbicida',
          'Plantio de forrageira',
          'Sobressemeadura',
          'Rotação de piquete',
        ],
      ),
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'animal',
        label: 'Animal',
        placeholder: 'Brinco ou ID — só quando o manejo é de um animal',
      ),
      // fidelidade-contrato (re-auditoria pós-fix): inputs/productions_warehouse_uuid
      // são nullable no PastureRequest — o app exigia a mais.
      FeatureField(
        id: 'armazem-insumos',
        label: 'Armazém de insumos',
        type: FeatureFieldType.searchSelect,
        options: ['Armazém A', 'Depósito B'],
      ),
      FeatureField(
        id: 'armazem-producao',
        label: 'Armazém de produção',
        type: FeatureFieldType.searchSelect,
        options: ['Armazém A', 'Depósito B'],
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // As 5 coleções de `/pastures`: equipments[], inputs[], productions[],
    // services[] e occurrences[]. Nenhuma é `min:1` no contrato — um manejo
    // pode ser só a operação registrada.
    collections: [
      FeatureCollection(
        name: 'Máquinas / Equipamentos',
        itemLabel: 'Máquina / Equipamento',
        titleField: 'equipamento',
        subtitleFields: ['quantidade', 'unidade'],
        fields: [
          FeatureField(
            id: 'equipamento',
            label: 'Equipamento',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoEquipamentos,
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação): equipments.* do
          // PastureRequest não tem `quantity` — o campo é extra; deixa de ser
          // obrigatório para não exigir algo que o contrato ignora.
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Hora', 'Dia', 'km'],
            derivedFrom: FeatureFieldDerivation(
              source: 'equipamento',
              values: unidadeUsoPorEquipamento,
            ),
          ),
          FeatureField(
            id: 'horimetro-inicial',
            label: 'Horímetro inicial',
            type: FeatureFieldType.number,
            derivedFrom: FeatureFieldDerivation(
              source: 'equipamento',
              values: horimetroAtualPorEquipamento,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'horimetro-final',
            label: 'Horímetro final',
            type: FeatureFieldType.number,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Insumos',
        itemLabel: 'Insumo',
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade', 'armazem'],
        fields: [
          // fidelidade-contrato (onda 7): `product_uuid` é opcional no
          // contrato real — é `stock_uuid` (abaixo) o obrigatório, o lote
          // específico de onde o insumo saiu. A onda 9 tinha travado
          // `produto` como required por engano (sentido invertido). Ver
          // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 7.
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.searchSelect,
            options: catalogoProdutos,
          ),
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `inputs.*.stock_uuid` é required em `/pastures` e faltava — o
          // lote de estoque de onde o insumo saiu, não só o produto.
          FeatureField(
            id: 'estoque',
            label: 'Item de estoque',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoItensEstoque,
            optionsFrom: FeatureOptionsFilter(
              source: 'produto',
              options: estoquesPorProduto,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'estoque',
              values: unidadePorItemEstoque,
            ),
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'estoque',
              values: armazemPorItemEstoque,
            ),
          ),
        ],
      ),
      FeatureCollection(
        name: 'Produção',
        itemLabel: 'Produção',
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade', 'armazem'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto colhido',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: armazemPadraoPorProduto,
              locked: false,
            ),
          ),
        ],
      ),
      // fidelidade-contrato (onda 7): a coleção estava "quase incompatível"
      // — faltava o executor real do serviço (`employee`/`function`/
      // `provider`, XOR pelo tipo). `prestador` (texto livre) vira
      // `tipo-executor` + `executor`, mesma família de `sanitario.labor` —
      // a obrigatoriedade condicional de `executor` entra na Onda 6. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 7.
      FeatureCollection(
        name: 'Serviços',
        itemLabel: 'Serviço',
        titleField: 'servico',
        subtitleFields: ['tipo-executor', 'valor'],
        fields: [
          FeatureField(
            id: 'servico',
            label: 'Serviço',
            isRequired: true,
            placeholder: 'Descrição do serviço',
          ),
          FeatureField(
            id: 'tipo-executor',
            label: 'Executor',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Empregado', 'Função', 'Prestador'],
          ),
          FeatureField(
            id: 'executor',
            label: 'Quem executou',
            type: FeatureFieldType.select,
            options: catalogoResponsaveis,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
          ),
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `services.*.measurement_uuid` é required em `/pastures` — a
          // unidade em que a quantidade do serviço é medida.
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
          ),
          FeatureField(
            id: 'valor',
            label: 'Valor (R\$)',
            type: FeatureFieldType.number,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Ocorrências',
        itemLabel: 'Ocorrência',
        titleField: 'diagnostico',
        subtitleFields: ['prioridade'],
        fields: [
          // fidelidade-contrato (re-auditoria pós-fix): occurrences.*.priority é
          // in:[0,1,2] — emite o código (selectOptions), exibe o rótulo.
          FeatureField(
            id: 'prioridade',
            label: 'Prioridade',
            type: FeatureFieldType.select,
            isRequired: true,
            selectOptions: [
              (value: '0', label: 'Baixa'),
              (value: '1', label: 'Média'),
              (value: '2', label: 'Alta'),
            ],
          ),
          FeatureField(
            id: 'diagnostico',
            label: 'Diagnóstico',
            isRequired: true,
            placeholder: 'O que foi observado',
          ),
          FeatureField(
            id: 'recomendacao',
            label: 'Recomendação',
            type: FeatureFieldType.textarea,
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem lançou, quando e onde o manejo aconteceu.',
        fields: ['responsavel', 'data', 'destino', 'area', 'piquete'],
      ),
      FeatureFormStep(
        title: 'Manejo',
        hint: 'A operação executada e o rebanho envolvido.',
        fields: ['operacao', 'atividade', 'lote', 'animal'],
      ),
      FeatureFormStep(
        title: 'Estoque',
        hint: 'De onde saem os insumos e para onde vai a produção.',
        fields: ['armazem-insumos', 'armazem-producao', 'observacao'],
      ),
      FeatureFormStep(
        title: 'Lançamentos',
        hint: 'Recursos consumidos, produção medida e ocorrências do dia.',
        sections: [
          'Máquinas / Equipamentos',
          'Insumos',
          'Produção',
          'Serviços',
          'Ocorrências',
        ],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira o manejo antes de salvar.',
      ),
    ],
    primaryAction: 'Salvar pastagem',
    emptyLabel: 'Nenhum manejo de pastagem registrado.',
    listMode: true,
    createAction: 'Novo manejo de pastagem',
    recordTitleField: 'atividade',
    recordDescriptionFields: ['lote', 'data', 'armazem-producao'],
  ),
  FeatureDefinition(
    id: 'apartacao',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Apartação',
    objective: 'Executar e registrar a apartação do rebanho.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-contrato (onda 3): o contrato real é `batches[]` (array de
      // UUID); `lote-origem` continua escalar aqui de propósito (a
      // cardinalidade vira Onda 5), mas o texto livre vira `select` sobre
      // `catalogoLotes` — mesma correção de forma que `desmama`. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 3.
      FeatureField(
        id: 'lote-origem',
        label: 'Lote de origem',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'criterio',
        label: 'Critério',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Peso', 'Categoria', 'Sexo', 'Condição corporal'],
      ),
      FeatureField(
        id: 'lote-destino',
        label: 'Lote de destino',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
    ],
    // fidelidade-contrato (onda 5): `batches[]` é array de UUID (min:1) — o
    // escalar `lote-origem` acima permanece só como `recordTitleField`
    // (mesma nuance de `lote-animais`/`diagnostico-gestacao`); a coleção
    // documenta a cardinalidade real. Reusa o motor de coleção, sem
    // componente novo. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 5.
    collections: [
      FeatureCollection(
        name: 'Lotes de origem',
        itemLabel: 'Lote',
        isRequired: true,
        titleField: 'lote',
        fields: [
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoLotes,
          ),
        ],
      ),
    ],
    primaryAction: 'Registrar apartação',
    sourceDetail:
        'Os campos não foram exibidos; o protótipo usa premissas operacionais mínimas.',
    listMode: true,
    createAction: 'Nova apartação',
    recordTitleField: 'lote-origem',
    recordDescriptionFields: ['criterio', 'lote-destino', 'quantidade'],
  ),
  FeatureDefinition(
    id: 'nascimentos',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Nascimentos',
    objective: 'Registrar nascimento de animais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/ciclo',
  ),
  FeatureDefinition(
    id: 'desmama',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Desmama',
    objective: 'Registrar desmama e identificar vacas paridas.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `WeaningTypeEnum` é
      // int-backed (Recria=1, Venda=2) e `Rule::enum` valida o backing —
      // enviar o rótulo dava 422. O campo emite o valor int (selectOptions) e
      // exibe o rótulo.
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: '1', label: 'Recria'),
          (value: '2', label: 'Venda'),
        ],
      ),
      // fidelidade-contrato (onda 3): `lote` referencia um `batch_uuid` real
      // no contrato — texto livre não referencia nada. Vira `select` sobre
      // `catalogoLotes`. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 3.
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'identificacao',
        label: 'Identificação das vacas paridas',
        isRequired: true,
      ),
      // fidelidade-campos (onda 3): `date` é required em `/weanings` e o lote
      // de destino é para onde os bezerros desmamados são transferidos —
      // faltavam os dois.
      FeatureField(
        id: 'data',
        label: 'Data da desmama',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'lote-destino',
        label: 'Lote de destino dos bezerros',
        type: FeatureFieldType.searchSelect,
        options: catalogoLotes,
      ),
    ],
    collections: [
      // fidelidade-contrato (re-auditoria pós-fix): animal_uuids é
      // required|array|min:1 no WeaningRequest — a coleção (que mapeia o array)
      // trava ≥1 animal. O escalar de cabeçalho segue como identificação
      // primária.
      FeatureCollection(
        name: 'Identificações adicionais',
        itemLabel: 'Identificação',
        isRequired: true,
        titleField: 'identificacao',
        subtitleFields: ['lote'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
        ],
      ),
    ],
    primaryAction: 'Salvar desmama',
    listMode: true,
    createAction: 'Nova desmama',
    recordTitleField: 'lote',
    recordDescriptionFields: ['tipo', 'data', 'lote-destino'],
  ),
  FeatureDefinition(
    id: 'mortes',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Mortes',
    objective: 'Consultar e registrar mortes do rebanho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/ciclo',
  ),
  FeatureDefinition(
    id: 'registrar-animal',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Registrar animal',
    objective: 'Cadastrar um animal individualmente.',
    status: FeatureStatus.ready,
    // fidelidade-campos (onda 3): faltavam espécie e data de entrada
    // (obrigatórias em `/animals`) e o bloco inteiro de identificação,
    // genealogia e valores. Os três valores calculados (arroba, unitário, UA)
    // entram **opcionais** de propósito: o Form Request os marca `required`,
    // mas o servidor os recalcula, e pedir "UA" a quem está no brete seria
    // exigir conta de escritório em pé no curral. Ver
    // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, "Curadoria".
    fields: [
      FeatureField(
        id: 'especie',
        label: 'Espécie',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Bovino', 'Bubalino', 'Ovino'],
      ),
      FeatureField(
        id: 'tipo-identificacao',
        label: 'Modo de identificação',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoIdentificacaoAnimal,
      ),
      FeatureField(
        id: 'identificacao',
        label: 'Identificação principal',
        placeholder: 'Número do brinco, RFID ou SISBOV',
      ),
      FeatureField(id: 'categoria', label: 'Categoria', isRequired: true),
      FeatureField(id: 'raca', label: 'Raça', isRequired: true),
      FeatureField(
        id: 'data-entrada',
        label: 'Data de entrada',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria pós-fix): birth_date é nullable no
      // AnimalRequest — o app exigia a mais.
      FeatureField(
        id: 'nascimento',
        label: 'Data de nascimento',
        type: FeatureFieldType.date,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): quantity é integer no
      // AnimalRequest (sometimes|integer|min:1).
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade',
        type: FeatureFieldType.integer,
        placeholder: 'Para lançamento em lote',
      ),
      FeatureField(id: 'mae', label: 'Mãe', placeholder: 'Identificação'),
      FeatureField(id: 'pai', label: 'Pai', placeholder: 'Identificação'),
      FeatureField(
        id: 'previsao-parto',
        label: 'Previsão de parto',
        type: FeatureFieldType.date,
      ),
      FeatureField(
        id: 'peso',
        label: 'Peso (kg)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'pelagem',
        label: 'Pelagem',
        placeholder: 'Descrição da pelagem',
      ),
      // fidelidade-contrato (onda 1): `price_kilo_alive` é required em
      // `/animals` — só os três valores recalculados pelo servidor abaixo
      // continuam opcionais por decisão da curadoria original. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      FeatureField(
        id: 'preco-kg',
        label: 'Preço do kg vivo',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): price_arroba_alive/
      // value_unitary/unity_animal_ua são `required` no AnimalRequest (NOT NULL
      // físico) — antes opcionais por curadoria de UX. O servidor os RECALCULA
      // e ignora no create (RN-2), mas a ausência ainda dá 422. Tornados
      // obrigatórios para casar o contrato. TENSÃO DE UX registrada: um
      // valor-default (0) evitaria pedir a conta no brete — decisão do dono.
      FeatureField(
        id: 'preco-arroba',
        label: 'Preço da arroba (vivo)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'valor-unitario',
        label: 'Valor unitário (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'ua',
        label: 'Unidade animal (UA)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `type` é required no
      // AnimalRequest (Rule::enum AnimalIdentificationMode: single/no_id) e
      // faltava — distinto do 'tipo-identificacao' (método: brinco/RFID, que
      // vai para identifications[]). single = animal com identificação
      // individual; no_id = lançamento sem identificação (lote).
      FeatureField(
        id: 'modo-registro',
        label: 'Modo de registro',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'single', label: 'Individual (com identificação)'),
          (value: 'no_id', label: 'Sem identificação (lote)'),
        ],
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): bloco reprodução —
      // category_matrice_id + reproductive_status são `required_if` a categoria
      // é "reprodução permitida" (RN-6, comparação por rótulo, frágil até no
      // servidor). Capturados aqui como opcionais; o gate por-categoria fica
      // como follow-up (depende da lista de categorias reprodutivas).
      FeatureField(
        id: 'estagio-reprodutivo',
        label: 'Estágio reprodutivo (matriz)',
        type: FeatureFieldType.searchSelect,
        options: catalogoEstagiosReprodutivos,
      ),
      FeatureField(
        id: 'status-reprodutivo',
        label: 'Status reprodutivo',
        type: FeatureFieldType.select,
        selectOptions: [
          (value: '1', label: 'Prenha'),
          (value: '2', label: 'Vazia'),
          (value: '3', label: 'Parida'),
        ],
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // `identifications[]` — um animal costuma ter mais de uma marca (brinco de
    // manejo, SISBOV, tatuagem); no contrato é coleção, não campo único.
    collections: [
      FeatureCollection(
        name: 'Identificações',
        itemLabel: 'Identificação',
        titleField: 'numero',
        subtitleFields: ['tipo'],
        fields: [
          FeatureField(
            id: 'tipo',
            label: 'Modo de identificação',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoIdentificacaoAnimal,
          ),
          FeatureField(
            id: 'numero',
            label: 'Número',
            isRequired: true,
            placeholder: 'Brinco, RFID ou SISBOV',
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Espécie, marca e classificação do animal.',
        fields: [
          'especie',
          'modo-registro',
          'tipo-identificacao',
          'identificacao',
          'categoria',
          'raca',
        ],
      ),
      FeatureFormStep(
        title: 'Origem e genealogia',
        hint: 'Quando entrou na fazenda, quando nasceu e de quem.',
        fields: [
          'data-entrada',
          'nascimento',
          'quantidade',
          'mae',
          'pai',
          'previsao-parto',
          'estagio-reprodutivo',
          'status-reprodutivo',
        ],
      ),
      FeatureFormStep(
        title: 'Peso e valores',
        hint: 'Peso de entrada e, se houver, os valores de referência.',
        fields: [
          'peso',
          'pelagem',
          'preco-kg',
          'preco-arroba',
          'valor-unitario',
          'ua',
          'observacao',
        ],
      ),
      FeatureFormStep(
        title: 'Identificações adicionais',
        hint: 'Outras marcas do mesmo animal.',
        sections: ['Identificações'],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira o animal antes de registrar.',
      ),
    ],
    primaryAction: 'Registrar animal',
    listMode: true,
    createAction: 'Novo animal',
    recordTitleField: 'identificacao',
    recordDescriptionFields: ['categoria', 'raca', 'peso'],
  ),
  FeatureDefinition(
    id: 'perdas',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Perdas',
    objective: 'Registrar perdas após identificar o animal.',
    status: FeatureStatus.hardware,
    fields: [
      FeatureField(
        id: 'identificacao',
        label: 'Identificação animal',
        isRequired: true,
        placeholder: 'Brinco ou ID',
      ),
      // fidelidade-contrato (re-auditoria pós-fix): LossAnimalRequest não tem
      // campo de responsável (o servidor usa Auth) — deixa de ser required.
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data da ocorrência',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): batch_uuid é nullable
      // no LossAnimalRequest — o app exigia a mais. Lote vira opcional.
      FeatureField(
        id: 'lote',
        label: 'Lote atual',
        type: FeatureFieldType.searchSelect,
        options: catalogoLotes,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): cause_uuid é required
      // + exists:death_losses — texto livre nunca casaria. Vira lista fechada
      // (o mapeamento para uuid é ③).
      FeatureField(
        id: 'causa',
        label: 'Motivo da perda',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoCausasPerda,
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    capabilities: ['Balança', 'RFID', 'Scanner SISBOV'],
    primaryAction: 'Registrar perda',
    sourceDetail:
        'A fonte mostrou apenas a identificação; os campos posteriores são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Nova perda',
    recordTitleField: 'identificacao',
    recordDescriptionFields: ['causa', 'lote', 'data'],
    simulation: HardwareSimulationKind.rfid,
    simulationTargetField: 'identificacao',
  ),
  FeatureDefinition(
    id: 'rebanho-inicial',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Rebanho inicial',
    objective: 'Estabelecer a composição inicial do rebanho.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data de referência',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // banco-real: `animals.entry_date` é a data de entrada do animal na
      // fazenda e é distinta da data de referência do levantamento — o banco
      // guarda as duas separadas. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
      //
      // fidelidade-contrato (onda 1): `entry_date` é required em `/animals` —
      // este é o campo que mapeia para ele, e entrou opcional na leva
      // anterior. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      FeatureField(
        id: 'data-entrada',
        label: 'Data de entrada',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'especie',
        label: 'Espécie',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Bovino', 'Bubalino', 'Ovino'],
      ),
      FeatureField(
        id: 'categoria',
        label: 'Categoria',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoCategoriasAnimais,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.integer,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `type` required no
      // AnimalRequest (single/no_id). Rebanho inicial normalmente é lote →
      // 'Sem identificação', mas o campo fica explícito.
      FeatureField(
        id: 'modo-registro',
        label: 'Modo de registro',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: 'single', label: 'Individual (com identificação)'),
          (value: 'no_id', label: 'Sem identificação (lote)'),
        ],
      ),
      FeatureField(
        id: 'area',
        label: 'Área / módulo inicial',
        isRequired: true,
      ),
      // fidelidade-campos (onda 3): o rebanho inicial grava em `/animals` — o
      // mesmo contrato de `registrar-animal`, não uma importação de planilha
      // (`/inventoried-animals` não tem store). Faltava o bloco de raça,
      // nascimento, identificação, valores e genealogia. Mesma curadoria dos
      // três valores calculados: entram opcionais.
      //
      // fidelidade-contrato (onda 1): `breed_id` (raca) e `weight`
      // (peso-medio) são required em `/animals` e entraram opcionais — só
      // `nascimento` não tem contrapartida `required` no contrato e continua
      // opcional de propósito. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md,
      // Onda 1.
      FeatureField(id: 'raca', label: 'Raça', isRequired: true),
      FeatureField(
        id: 'nascimento',
        label: 'Data de nascimento',
        type: FeatureFieldType.date,
      ),
      FeatureField(
        id: 'tipo-identificacao',
        label: 'Modo de identificação',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoIdentificacaoAnimal,
      ),
      FeatureField(
        id: 'peso-medio',
        label: 'Peso médio (kg)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-campos (onda 9 — re-auditoria 11/09): `price_kilo_alive` é
      // required no mesmo `/animals` de `registrar-animal` — que já declara
      // este campo — e ficou de fora aqui. Mesmo id/rótulo dos dois
      // cadastros, mesma fonte real.
      //
      // fidelidade-contrato (onda 1): entra obrigatório, como o contrato
      // exige — só os três valores recalculados pelo servidor (abaixo)
      // continuam opcionais por decisão da curadoria original.
      FeatureField(
        id: 'preco-kg',
        label: 'Preço do kg vivo',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): required no AnimalRequest
      // (recalculados no servidor, mas exigidos presentes). Mesma tensão de UX
      // de registrar-animal — default 0 seria alternativa (decisão do dono).
      FeatureField(
        id: 'preco-arroba',
        label: 'Preço da arroba (vivo)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'valor-unitario',
        label: 'Valor unitário (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'ua',
        label: 'Unidade animal (UA)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(id: 'mae', label: 'Mãe', placeholder: 'Identificação'),
      FeatureField(id: 'pai', label: 'Pai', placeholder: 'Identificação'),
    ],
    collections: [
      FeatureCollection(
        name: 'Identificações',
        itemLabel: 'Identificação',
        titleField: 'numero',
        subtitleFields: ['tipo'],
        fields: [
          FeatureField(
            id: 'tipo',
            label: 'Modo de identificação',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoIdentificacaoAnimal,
          ),
          FeatureField(
            id: 'numero',
            label: 'Número',
            isRequired: true,
            placeholder: 'Brinco, RFID ou SISBOV',
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Levantamento',
        hint: 'Quem levantou, quando, e onde o rebanho está.',
        fields: ['responsavel', 'data', 'data-entrada', 'area'],
      ),
      FeatureFormStep(
        title: 'Composição',
        hint: 'De que é feito o rebanho que está entrando.',
        fields: ['especie', 'categoria', 'raca', 'quantidade', 'nascimento'],
      ),
      FeatureFormStep(
        title: 'Identificação e valores',
        hint: 'Como os animais são marcados e quanto valem.',
        fields: [
          'modo-registro',
          'tipo-identificacao',
          'peso-medio',
          'preco-kg',
          'preco-arroba',
          'valor-unitario',
          'ua',
        ],
      ),
      FeatureFormStep(
        title: 'Genealogia',
        hint: 'Quando o levantamento conhece a origem dos animais.',
        fields: ['mae', 'pai'],
        sections: ['Identificações'],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira a composição antes de cadastrar.',
      ),
    ],
    primaryAction: 'Cadastrar rebanho',
    sourceDetail:
        'Os campos internos não foram exibidos; o protótipo usa a composição mínima necessária para iniciar o rebanho.',
    listMode: true,
    createAction: 'Nova composição inicial',
    recordTitleField: 'categoria',
    recordDescriptionFields: ['quantidade', 'especie', 'area'],
  ),
  FeatureDefinition(
    id: 'scanner-sisbov',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Scanner SISBOV',
    objective: 'Capturar a identificação do animal usando a câmera.',
    status: FeatureStatus.hardware,
    capabilities: ['Câmera', 'Área de enquadramento', 'Reiniciar leitura'],
    primaryAction: 'Usar identificação',
    simulation: HardwareSimulationKind.scanner,
    successTitle: 'Identificação SISBOV capturada',
    successDescription:
        'O código simulado está disponível para identificação do animal nesta sessão.',
  ),
  FeatureDefinition(
    id: 'conexao-aparelhos-pecuaria',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Conexão de aparelhos',
    objective: 'Preparar balança e leitor RFID para as rotinas pecuárias.',
    status: FeatureStatus.hardware,
    capabilities: ['Bluetooth', 'Localização', 'Balança', 'RFID'],
    primaryAction: 'Concluir configuração',
    simulation: HardwareSimulationKind.devices,
    successTitle: 'Aparelhos pecuários conectados',
    successDescription:
        'A balança e o leitor RFID estão conectados na simulação desta sessão.',
  ),
  FeatureDefinition(
    id: 'estacao-monta',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Estação de monta',
    objective: 'Gerenciar períodos e ciclos de reprodução.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): planejamento sazonal (nome, datas, método) — não
    // é ação diária de campo, o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'nome', label: 'Nome da estação', isRequired: true),
      // fidelidade-campos (onda 4): `code` e `date` são required em
      // `/breeding-seasons` e faltavam — o formulário não submeteria. `date` é
      // a data do lançamento da estação, distinta do início do período.
      FeatureField(id: 'codigo', label: 'Código', isRequired: true),
      FeatureField(
        id: 'data',
        label: 'Data do lançamento',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'inicio',
        label: 'Data de início',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'fim',
        label: 'Data de término',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'metodo',
        label: 'Método principal',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Monta natural',
          'Inseminação artificial',
          'IATF',
          'Transferência de embrião',
        ],
      ),
      // fidelidade-esteira (onda 10): `breeding_seasons.description` é
      // varchar(191) NOT NULL no banco real — campo distinto de
      // `observacao` (textarea opcional, abaixo).
      FeatureField(id: 'descricao', label: 'Descrição', isRequired: true),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    primaryAction: 'Criar estação',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Nova estação',
    recordTitleField: 'nome',
    recordDescriptionFields: ['metodo', 'inicio', 'fim'],
  ),
  FeatureDefinition(
    id: 'protocolos-estacao',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Protocolos / estação',
    objective: 'Gerenciar protocolos associados à estação reprodutiva.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): configuração de regra reprodutiva — não é ação
    // diária de campo, o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'nome', label: 'Nome do protocolo', isRequired: true),
      FeatureField(
        id: 'estacao',
        label: 'Estação de monta',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoEstacoesMonta,
      ),
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'IATF',
          'Inseminação',
          'Transferência de embrião',
          'Sincronização de cio',
        ],
      ),
      FeatureField(
        id: 'inicio',
        label: 'Data de início',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-campos (onda 4): `code` é required em `/protocols-season`.
      FeatureField(id: 'codigo', label: 'Código', isRequired: true),
      FeatureField(
        id: 'descricao',
        label: 'Descrição',
        type: FeatureFieldType.textarea,
      ),
    ],
    collections: [
      FeatureCollection(
        name: 'Etapas do protocolo',
        itemLabel: 'Etapa do protocolo',
        isRequired: true,
        titleField: 'data',
        subtitleFields: ['tipo', 'produto', 'quantidade'],
        fields: [
          FeatureField(
            id: 'data',
            label: 'Data da etapa',
            type: FeatureFieldType.date,
            isRequired: true,
          ),
          FeatureField(
            id: 'tipo',
            label: 'Tipo',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Produto', 'Serviço'],
          ),
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.searchSelect,
            options: catalogoProdutos,
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação): `items.*.service`
          // é `ProtocolItemServiceEnum` int-backed (1..4) — o texto livre não
          // casava. Emite o valor int (selectOptions) e exibe o rótulo.
          FeatureField(
            id: 'servico',
            label: 'Serviço',
            type: FeatureFieldType.select,
            selectOptions: [
              (value: '1', label: 'Inseminação'),
              (value: '2', label: 'Ultrassom'),
              (value: '3', label: 'Diagnóstico de gestação'),
              (value: '4', label: 'Remoção de implante'),
            ],
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação):
          // `items.*.measurement_uuid` é required_with:product_uuid — só a
          // linha de Produto exige unidade (condicional no motor), não a de
          // Serviço.
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: armazemPadraoPorProduto,
              locked: false,
            ),
          ),
        ],
      ),
    ],
    // `items[] ·req min:1` — a agenda do protocolo **é** o protocolo: data,
    // quantidade, produto ou serviço e armazém de cada etapa. Um protocolo
    // sem nenhuma etapa não protocola nada, e o contrato recusa.
    //
    // Enquanto esta tela for consulta (`readOnly`), a exigência é documentação
    // do contrato, não regra de tela: o motor só a aplica onde há formulário
    // (hoje, `diagnostico-gestacao`). Fica declarada para quando o cadastro
    // descer para o app — ou para quando o time web ler o contrato daqui.
    primaryAction: 'Salvar protocolo',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Novo protocolo',
    recordTitleField: 'nome',
    recordDescriptionFields: ['tipo', 'estacao', 'inicio'],
  ),
  FeatureDefinition(
    id: 'material-reprodutivo',
    profile: FeatureProfile.operational,
    group: 'Consultas',
    title: 'Touros / sêmen / embrião',
    objective: 'Gerenciar material e recursos reprodutivos.',
    status: FeatureStatus.ready,
    // banco-real (onda 1): estoque de material genético é cadastro de
    // insumo, não ação de campo — o app só consulta. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'tipo',
        label: 'Tipo de recurso',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Touro', 'Sêmen', 'Embrião'],
      ),
      FeatureField(
        id: 'identificacao',
        label: 'Identificação / código',
        isRequired: true,
      ),
      FeatureField(id: 'raca', label: 'Raça', isRequired: true),
      FeatureField(
        id: 'fornecedor',
        label: 'Fornecedor / origem',
        isRequired: true,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade disponível',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-campos (onda 4): `/bull-seed-season` exige code, date,
      // description e a estação de monta — os quatro faltavam, e sem eles
      // nenhuma submissão passaria. `identificacao` (acima) é a marca do
      // touro/palheta; `codigo` é o código do lançamento, outra coisa.
      FeatureField(id: 'codigo', label: 'Código', isRequired: true),
      FeatureField(
        id: 'data',
        label: 'Data do lançamento',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(id: 'descricao', label: 'Descrição', isRequired: true),
      FeatureField(
        id: 'estacao-monta',
        label: 'Estação de monta',
        isRequired: true,
      ),
    ],
    // `products[]` — cada palheta/dose tem armazém e produto próprios.
    // fidelidade-esteira (onda 12): `animal_bull_seed_season` no dump é
    // pivô puro (`animal_id`, `bull_seed_season_id`, timestamps) — confirma
    // que o contrato real é só um array de referências a animal, sem campo
    // extra por item. O plano original previa um `select` sobre "o catálogo
    // de animais existente", mas este catálogo não existe no protótipo
    // (animais são muitos e individuais, não uma lista fechada como
    // categorias/lotes) — reusa o padrão real já em uso para referenciar um
    // animal específico sem inventar UUID sintético
    // (`tipo-identificacao`+`identificacao`, mesmo par de `lote-animais`.
    // "Animais do lote"/`registrar-animal`."Identificações"), não o
    // `select` de campo único que o plano assumia.
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): `animals` NÃO tem
      // min:1 no BullSeedSeasonRequest (GAP-BSS-06, `present` sem `min`) — o
      // app estava mais restrito que o contrato. Coleção deixa de ser
      // obrigatória (aceita registro sem animais, como o contrato).
      FeatureCollection(
        name: 'Animais',
        itemLabel: 'Animal',
        titleField: 'identificacao',
        subtitleFields: ['tipo-identificacao'],
        fields: [
          FeatureField(
            id: 'tipo-identificacao',
            label: 'Modo de identificação',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoIdentificacaoAnimal,
          ),
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco, RFID ou SISBOV',
          ),
        ],
      ),
      FeatureCollection(
        name: 'Produtos (armazém e sêmen)',
        itemLabel: 'Produto reprodutivo',
        titleField: 'produto',
        subtitleFields: ['armazem', 'quantidade'],
        fields: [
          // fidelidade-contrato (onda 1): `products.*.armazem` é opcional no
          // contrato real de `/bull-seed-season` — a leva anterior travou
          // como required por engano (sentido invertido, não faltando). Ver
          // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: armazemPadraoPorProduto,
              locked: false,
            ),
          ),
          // fidelidade-esteira: fica de fora da regra "todo campo Produto é
          // dropdown com busca" de propósito — aqui "Produto" é a
          // identificação de uma palheta/dose/embrião específica (material
          // reprodutivo por instância, como `identificacao` de animal), não
          // uma seleção sobre `catalogoProdutos` (insumos genéricos).
          FeatureField(
            id: 'produto',
            label: 'Produto',
            isRequired: true,
            placeholder: 'Palheta, dose ou embrião',
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação):
          // `products.*.quantity` é `required_with:products.*` no
          // `BullSeedSeasonRequest` — obrigatória por item de produto (estava
          // opcional; um item sem quantidade daria 422).
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
        ],
      ),
    ],
    primaryAction: 'Cadastrar recurso',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Novo recurso',
    recordTitleField: 'identificacao',
    recordDescriptionFields: ['tipo', 'raca', 'quantidade'],
  ),
  // TODO(banco-real): quando esta tela ganhar um campo de tipo (natural vs.
  // IATF vs. outro), checar `breeding_matings.type` — smallint sem tabela de
  // domínio no dump; hoje esta tela ainda não expõe esse campo. Ver
  // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
  //
  // Simplificação de grupo: "Monta natural" renomeada para "Acasalamento"
  // (nome mais amplo, já que a tela cobre o registro do acasalamento em si,
  // não um método específico — "Monta natural" continua existindo como
  // valor de método em `estacao-monta.metodo`, ao lado de "Inseminação
  // artificial"/"IATF"/"Transferência de embrião"). `lotes-reproducao`
  // ("Lotes / reprodução") saiu do catálogo: o grupo Reprodução passa a ter
  // só as duas funcionalidades de execução do dia a dia (Acasalamento e
  // Diagnóstico de gestação) — vincular lote à estação é organização
  // estrutural, mais próxima do papel de `lote-animais` (Consultas).
  FeatureDefinition(
    id: 'monta-natural',
    profile: FeatureProfile.operational,
    group: 'Reprodução',
    title: 'Acasalamento',
    objective: 'Registrar operações de acasalamento.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria pós-fix): breeding_batch_uuid (lote) e
      // bull_seed_season_uuid são nullable no Simplificado — obrigatoriedade
      // condicional ao modo (required no Normal), no motor.
      FeatureField(
        id: 'lote',
        label: 'Lote de matrizes',
        type: FeatureFieldType.searchSelect,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'touro',
        label: 'Touro / reprodutor',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoTouros,
      ),
      // fidelidade-campos (onda 4): `type` e `launch_type` são required em
      // `/breeding-matings` e controlam o modo inteiro do registro — o
      // primeiro diz se é monta natural, IA, IATF ou TE; o segundo, se o
      // lançamento é por lote ou animal por animal. O TODO(banco-real) que
      // existia aqui (`breeding_matings.type` sem tabela de domínio) fica
      // resolvido pelo próprio contrato: os valores são os métodos
      // reprodutivos, os mesmos de `estacao-monta.metodo`.
      //
      // fidelidade-contrato (onda 2): o enum real de `breeding_matings.type`
      // tem só 3 valores — "Inseminação artificial" e "Transferência de
      // embrião" não existem nele, e faltava "FIV". `estacao-monta.metodo`
      // não foi tocado: a auditoria não o aponta como divergente (é campo
      // descritivo da estação, não validado contra este mesmo enum). Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 2.
      // fidelidade-contrato (re-auditoria pós-fix): type e launch_type são
      // int-backed (BreedingMatingType NATURAL=1/IATF=2/FIV=3;
      // BreedingMatingLaunchType NORMAL=1/SIMPLIFICADO=2) e Rule::enum valida o
      // backing — emitem o int (selectOptions), exibem o rótulo. Os condicionais
      // por-modo do motor comparam contra esses valores ('1'..'3' / '1','2').
      FeatureField(
        id: 'tipo',
        label: 'Tipo de acasalamento',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: '1', label: 'Monta natural'),
          (value: '2', label: 'IATF'),
          (value: '3', label: 'FIV'),
        ],
      ),
      FeatureField(
        id: 'tipo-lancamento',
        label: 'Tipo de lançamento',
        type: FeatureFieldType.select,
        isRequired: true,
        selectOptions: [
          (value: '1', label: 'Por lote'),
          (value: '2', label: 'Animal por animal'),
        ],
      ),
      FeatureField(id: 'estacao-monta', label: 'Estação de monta'),
      FeatureField(
        id: 'material-reprodutivo',
        label: 'Material reprodutivo',
        placeholder: 'Touro, sêmen ou embrião do estoque',
      ),
      // fidelidade-contrato (onda 1): `bull_seed_season_uuid` é required em
      // `/breeding-matings` e estava ausente por completo — é o registro de
      // `material-reprodutivo` (touro/sêmen/embrião já vinculado a uma
      // estação, catálogo `/bull-seed-season`) usado nesta cobertura, não o
      // texto livre de `material-reprodutivo` acima. Ver
      // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 1.
      FeatureField(
        id: 'bull-seed-season',
        label: 'Touro / sêmen da estação',
        type: FeatureFieldType.select,
        options: ['BSS-2026-007', 'BSS-2026-012'],
      ),
      FeatureField(id: 'protocolo', label: 'Protocolo'),
      FeatureField(
        id: 'identificacao-protocolo',
        label: 'Identificação do protocolo',
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de fêmeas',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // O protótipo tinha o touro e não **as vacas**. `natural.cow_uuids[]` é a
    // coleção das fêmeas cobertas. O lançamento linha a linha, quando o tipo
    // de lançamento é por animal, é **duas** coleções distintas no contrato —
    // `simplified_animals[]` (lançamento direto, com o material que saiu do
    // estoque) e `protocol_animals[]` (lançamento por protocolo, com hora e
    // elegibilidade) — e não uma coleção genérica só, que era o único
    // cadastro da re-auditoria de 11/09 em que a coleção existia sem os itens
    // do contrato. Nenhuma das três é obrigatória aqui porque no contrato a
    // exigência é condicional ao `type`/`launch_type`, não absoluta. Ver
    // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 9.
    collections: [
      FeatureCollection(
        name: 'Vacas do acasalamento',
        itemLabel: 'Vaca',
        titleField: 'identificacao',
        subtitleFields: ['lote'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Animais (lançamento simplificado)',
        itemLabel: 'Animal do lançamento',
        titleField: 'identificacao',
        subtitleFields: ['estoque', 'quantidade'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'estoque',
              values: armazemPorItemEstoque,
            ),
          ),
          FeatureField(
            id: 'estoque',
            label: 'Item de estoque',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoItensEstoque,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'estoque',
              values: unidadePorItemEstoque,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Animais do protocolo',
        itemLabel: 'Animal do protocolo',
        titleField: 'identificacao',
        subtitleFields: ['hora', 'elegivel'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'hora',
            label: 'Hora da aplicação',
            isRequired: true,
            placeholder: 'HH:MM',
          ),
          FeatureField(
            id: 'elegivel',
            label: 'Elegível',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Sim', 'Não'],
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem registrou, quando, e de que tipo é o acasalamento.',
        fields: ['responsavel', 'data', 'tipo', 'tipo-lancamento'],
      ),
      FeatureFormStep(
        title: 'Vínculos',
        hint: 'Estação, lote de matrizes e o material reprodutivo usado.',
        fields: [
          'estacao-monta',
          'lote',
          'touro',
          'material-reprodutivo',
          'bull-seed-season',
        ],
      ),
      FeatureFormStep(
        title: 'Protocolo',
        hint: 'Quando o acasalamento segue um protocolo da estação.',
        fields: [
          'protocolo',
          'identificacao-protocolo',
          'quantidade',
          'observacao',
        ],
      ),
      FeatureFormStep(
        title: 'Animais',
        hint: 'As fêmeas cobertas e, se for o caso, o lançamento por animal.',
        sections: [
          'Vacas do acasalamento',
          'Animais (lançamento simplificado)',
          'Animais do protocolo',
        ],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira o acasalamento antes de registrar.',
      ),
    ],
    primaryAction: 'Registrar acasalamento',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Novo acasalamento',
    recordTitleField: 'lote',
    recordDescriptionFields: ['tipo', 'touro', 'data'],
  ),
  FeatureDefinition(
    id: 'diagnostico-gestacao',
    profile: FeatureProfile.operational,
    group: 'Reprodução',
    title: 'Diagnóstico de gestação',
    objective: 'Registrar e consultar diagnósticos de gestação.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data do diagnóstico',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'lote',
        label: 'Lote',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoLotes,
      ),
      FeatureField(
        id: 'resultado',
        label: 'Resultado',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Prenhe', 'Vazia', 'Reavaliar'],
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'veterinario',
        label: 'Veterinário responsável',
        isRequired: true,
      ),
      // fidelidade-campos (onda 4): a técnica do diagnóstico é required no
      // contrato (`animals.*.diagnostic_technique_uuid`) e faltava; dias de
      // gestação e touro completam a leitura por animal.
      FeatureField(
        id: 'tecnica-diagnostico',
        label: 'Técnica de diagnóstico',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Palpação retal', 'Ultrassonografia', 'Dosagem hormonal'],
      ),
      FeatureField(
        id: 'dias-gestacao',
        label: 'Dias de gestação',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'touro',
        label: 'Touro atribuído',
        placeholder: 'Reprodutor da cobertura',
      ),
    ],
    // O contrato é um **array de animais**, um por linha diagnosticada; o
    // protótipo tratava como formulário plano com uma quantidade. A coleção é
    // o registro em si — por isso `min:1`.
    collections: [
      FeatureCollection(
        name: 'Animais diagnosticados',
        itemLabel: 'Animal diagnosticado',
        isRequired: true,
        titleField: 'identificacao',
        subtitleFields: ['resultado', 'dias-gestacao'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'tecnica',
            label: 'Técnica',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Palpação retal', 'Ultrassonografia', 'Dosagem hormonal'],
          ),
          FeatureField(
            id: 'resultado',
            label: 'Resultado',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Prenhe', 'Vazia', 'Reavaliar'],
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação): dias_gestation é
          // integer|min:0 no PregnancyDiagnosisRequest.
          FeatureField(
            id: 'dias-gestacao',
            label: 'Dias de gestação',
            type: FeatureFieldType.integer,
          ),
          FeatureField(id: 'touro', label: 'Touro atribuído'),
          // fidelidade-contrato (onda 4): `provider_uuid` é required **por
          // item** no contrato — cada linha tem seu próprio veterinário, não
          // um só no cabeçalho. O campo `veterinario` do cabeçalho permanece
          // (nuance registrada em ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 4:
          // remover a duplicação exigiria redesenhar `recordTitleField` e as
          // etapas, fora do escopo desta onda). Ver
          // docs/ESTEIRA-FIDELIDADE-CONTRATO.md, Onda 4.
          FeatureField(
            id: 'veterinario',
            label: 'Veterinário responsável',
            isRequired: true,
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação): resync/note/
          // batch_uuid são `present, nullable` por item — a regra `present`
          // falha se a chave não for enviada. Capturados como opcionais para
          // que a chave exista no payload.
          FeatureField(
            id: 'resync',
            label: 'Ressincronizar',
            type: FeatureFieldType.select,
            selectOptions: [
              (value: 'true', label: 'Sim'),
              (value: 'false', label: 'Não'),
            ],
          ),
          FeatureField(
            id: 'lote',
            label: 'Lote',
            type: FeatureFieldType.searchSelect,
            options: catalogoLotes,
          ),
          FeatureField(id: 'observacao', label: 'Observação'),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem diagnosticou, quando e em que lote.',
        fields: ['responsavel', 'data', 'lote', 'veterinario'],
      ),
      FeatureFormStep(
        title: 'Diagnóstico',
        hint: 'Técnica usada e o que foi encontrado.',
        fields: [
          'tecnica-diagnostico',
          'resultado',
          'dias-gestacao',
          'touro',
          'quantidade',
        ],
      ),
      FeatureFormStep(
        title: 'Animais',
        hint: 'Uma linha por animal diagnosticado.',
        sections: ['Animais diagnosticados'],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira o diagnóstico antes de salvar.',
      ),
    ],
    primaryAction: 'Salvar diagnóstico',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Novo diagnóstico',
    recordTitleField: 'lote',
    recordDescriptionFields: ['resultado', 'quantidade', 'data'],
  ),
  FeatureDefinition(
    id: 'abastecimentos',
    profile: FeatureProfile.operational,
    group: 'Gestão de frota',
    title: 'Abastecimentos',
    objective: 'Consultar e registrar abastecimentos da frota.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'veiculo',
        label: 'Veículo / equipamento',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoEquipamentosMotorizados,
      ),
      FeatureField(
        id: 'combustivel',
        label: 'Combustível',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Diesel S10', 'Diesel S500', 'Gasolina', 'Etanol'],
        derivedFrom: FeatureFieldDerivation(
          source: 'veiculo',
          values: combustivelPorEquipamento,
          locked: false,
        ),
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade (L)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-contrato (re-auditoria 3ª avaliação): `SupplyRequest` põe
      // `hour_meter`/`mileage` em `items.*` (por item), não no cabeçalho — a
      // leitura de onda 10 (`appropriation_supply` no cabeçalho) era do dump
      // legado, não do contrato de escrita novo. Os medidores foram para a
      // coleção "Itens do abastecimento" abaixo.
      FeatureField(
        id: 'unidade',
        label: 'Unidade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['L', 'kg'],
        derivedFrom: FeatureFieldDerivation(
          source: 'combustivel',
          values: unidadePorCombustivel,
        ),
      ),
      FeatureField(
        id: 'origem',
        label: 'Posto / tanque de origem',
        isRequired: true,
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // `/supplies` é multi-item: um abastecimento pode encher mais de um
    // equipamento na mesma ida ao tanque.
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): items é
      // required|array|min:1 no SupplyRequest — trava ≥1.
      FeatureCollection(
        name: 'Itens do abastecimento',
        itemLabel: 'Item do abastecimento',
        isRequired: true,
        titleField: 'veiculo',
        subtitleFields: ['quantidade', 'unidade'],
        fields: [
          FeatureField(
            id: 'veiculo',
            label: 'Veículo / equipamento',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoEquipamentosMotorizados,
          ),
          FeatureField(
            id: 'combustivel',
            label: 'Combustível',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['Diesel S10', 'Diesel S500', 'Gasolina', 'Etanol'],
            derivedFrom: FeatureFieldDerivation(
              source: 'veiculo',
              values: combustivelPorEquipamento,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: ['L', 'kg'],
            derivedFrom: FeatureFieldDerivation(
              source: 'combustivel',
              values: unidadePorCombustivel,
            ),
          ),
          // fidelidade-contrato (re-auditoria 3ª avaliação): `items.*.hour_meter`
          // (numeric) e `items.*.mileage` (integer) são POR item no
          // `SupplyRequest`. `horimetro` é decimal (`number`); `hodometro` é
          // inteiro (`integer`, teclado sem casas decimais + validação inteira).
          FeatureField(
            id: 'horimetro',
            label: 'Horímetro',
            type: FeatureFieldType.number,
            derivedFrom: FeatureFieldDerivation(
              source: 'veiculo',
              values: horimetroAtualPorEquipamento,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'hodometro',
            label: 'Hodômetro',
            type: FeatureFieldType.integer,
            derivedFrom: FeatureFieldDerivation(
              source: 'veiculo',
              values: hodometroAtualPorEquipamento,
              locked: false,
            ),
          ),
          FeatureField(id: 'observacao', label: 'Observação'),
        ],
      ),
    ],
    // Sem etapas: com 10 campos, abastecimento fica na fronteira e o ganho
    // não paga o custo — em campo a pessoa abastece e lança na hora, e uma
    // tela só é mais rápida do que quatro. As etapas ficam nos formulários de
    // 11 campos ou mais. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
    primaryAction: 'Registrar abastecimento',
    emptyLabel: 'Nenhum abastecimento registrado.',
    sourceDetail:
        'Campos complementares adotados como premissa funcional do protótipo frontend.',
    listMode: true,
    createAction: 'Novo abastecimento',
    recordTitleField: 'veiculo',
    recordDescriptionFields: ['quantidade', 'combustivel', 'data'],
  ),
  FeatureDefinition(
    id: 'manutencao-frota',
    profile: FeatureProfile.operational,
    group: 'Gestão de frota',
    title: 'Manutenção',
    objective: 'Controlar manutenções da frota.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'equipamento',
        label: 'Veículo / equipamento',
        type: FeatureFieldType.searchSelect,
        isRequired: true,
        options: catalogoEquipamentosMotorizados,
      ),
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Preventiva', 'Corretiva', 'Inspeção'],
      ),
      FeatureField(
        id: 'descricao',
        label: 'Serviço',
        isRequired: true,
        placeholder: 'Descreva a manutenção',
      ),
      FeatureField(
        id: 'data',
        label: 'Data prevista',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'oficina',
        label: 'Oficina / responsável externo',
        isRequired: true,
      ),
      FeatureField(
        id: 'custo',
        label: 'Custo estimado (R\$)',
        type: FeatureFieldType.number,
      ),
      // fidelidade-campos (onda 5): `/maintenances` é cabeçalho + itens e o
      // protótipo achatou — faltava toda a parte de peça/insumo. Horímetro,
      // hodômetro e horas de mão de obra são por item no contrato; aqui entram
      // como leitura do equipamento no cabeçalho, que é como o mecânico anota.
      FeatureField(
        id: 'horimetro',
        label: 'Horímetro',
        type: FeatureFieldType.number,
        derivedFrom: FeatureFieldDerivation(
          source: 'equipamento',
          values: horimetroAtualPorEquipamento,
          locked: false,
        ),
      ),
      FeatureField(
        id: 'hodometro',
        label: 'Hodômetro',
        type: FeatureFieldType.number,
        derivedFrom: FeatureFieldDerivation(
          source: 'equipamento',
          values: hodometroAtualPorEquipamento,
          locked: false,
        ),
      ),
      FeatureField(
        id: 'horas-mao-de-obra',
        label: 'Horas de mão de obra',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
      ),
    ],
    // `items[]` — produto, unidade, quantidade e armazém de cada peça ou
    // insumo consumido na manutenção.
    collections: [
      // fidelidade-contrato (re-auditoria 3ª avaliação): items é
      // required|array|min:1 no MaintenanceRequest — trava ≥1.
      FeatureCollection(
        name: 'Peças / Insumos',
        itemLabel: 'Peça / Insumo',
        isRequired: true,
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade'],
        fields: [
          // fidelidade-campos (onda 9 — re-auditoria 11/09):
          // `items.*.equipment_uuid` é required em `/maintenances` e é **por
          // item** — a peça pertence a um veículo/equipamento específico da
          // manutenção, não só ao cabeçalho.
          FeatureField(
            id: 'equipamento',
            label: 'Veículo / equipamento',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoEquipamentosMotorizados,
          ),
          FeatureField(
            id: 'produto',
            label: 'Produto / peça',
            type: FeatureFieldType.searchSelect,
            isRequired: true,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'unidade',
            label: 'Unidade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoUnidades,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: unidadePorProduto,
            ),
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.searchSelect,
            options: catalogoArmazens,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: armazemPadraoPorProduto,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'valor',
            label: 'Valor (R\$)',
            type: FeatureFieldType.number,
            derivedFrom: FeatureFieldDerivation(
              source: 'produto',
              values: custoMedioPorProduto,
              locked: false,
            ),
          ),
          // fidelidade-contrato (onda 4): `hour_meter`/`mileage` são leituras
          // **por item** no contrato real. re-auditoria 3ª avaliação:
          // `items.*.mileage` é integer → hodômetro usa FeatureFieldType.integer.
          FeatureField(
            id: 'horimetro',
            label: 'Horímetro',
            type: FeatureFieldType.number,
            derivedFrom: FeatureFieldDerivation(
              source: 'equipamento',
              values: horimetroAtualPorEquipamento,
              locked: false,
            ),
          ),
          FeatureField(
            id: 'hodometro',
            label: 'Hodômetro',
            type: FeatureFieldType.integer,
            derivedFrom: FeatureFieldDerivation(
              source: 'equipamento',
              values: hodometroAtualPorEquipamento,
              locked: false,
            ),
          ),
          // fidelidade-contrato (re-auditoria pós-fix): o contrato tem UM
          // `items[]` que combina peça + leituras + EXECUTOR na mesma linha
          // (`items.*.executor_type`/`employee_uuid`/`provider_uuid`/
          // `employee_quantity`/`provider_total`). O executor deixa de ser uma
          // coleção separada e passa a viver dentro do item. `executor_type` é
          // nullable (item pode ser só peça); quando informado, o alvo e o
          // valor viram obrigatórios por item (condicional no motor).
          FeatureField(
            id: 'tipo-executor',
            label: 'Executor (opcional)',
            type: FeatureFieldType.select,
            selectOptions: [
              (value: 'employee', label: 'Empregado'),
              (value: 'provider', label: 'Prestador'),
            ],
          ),
          FeatureField(
            id: 'executor',
            label: 'Nome do executor',
            type: FeatureFieldType.searchSelect,
            options: catalogoResponsaveis,
          ),
          FeatureField(
            id: 'horas',
            label: 'Horas (empregado)',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'total',
            label: 'Total do prestador (R\$)',
            type: FeatureFieldType.number,
          ),
        ],
      ),
    ],
    steps: [
      FeatureFormStep(
        title: 'Identificação',
        hint: 'Quem programou, em que equipamento e quando.',
        fields: ['responsavel', 'equipamento', 'data'],
      ),
      FeatureFormStep(
        title: 'Serviço',
        hint: 'O que será feito e por quem.',
        fields: ['tipo', 'descricao', 'oficina', 'custo'],
      ),
      FeatureFormStep(
        title: 'Medidores e peças',
        hint:
            'Leitura do equipamento e o que será consumido (peça + executor por item).',
        fields: ['horimetro', 'hodometro', 'horas-mao-de-obra', 'observacao'],
        sections: ['Peças / Insumos'],
      ),
      FeatureFormStep(
        title: 'Revisão',
        hint: 'Confira a manutenção antes de programar.',
      ),
    ],
    primaryAction: 'Programar manutenção',
    listMode: true,
    createAction: 'Nova manutenção',
    recordTitleField: 'descricao',
    recordDescriptionFields: ['tipo', 'equipamento', 'data'],
  ),
  // Tela dedicada (`operacional/minhas_os_screen.dart`, via
  // `campo/:flowId`): motor genérico não cobre o ciclo de ação da OS
  // (iniciar/pausar/retomar/entregar/refazer), só listagem read-only. Ver
  // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C, para o
  // mapeamento com `service_orders.category`/`service_orders.status` quando
  // o banco real existir.
  FeatureDefinition(
    id: 'minhas-os',
    profile: FeatureProfile.operational,
    group: 'Ordem de serviço',
    title: 'Minhas OS',
    objective:
        'Consultar ordens de serviço vinculadas ao funcionário e à fazenda, '
        'e conduzir a execução (iniciar, pausar, entregar ou sinalizar que precisa refazer).',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/minhas-os',
    emptyLabel: 'Nenhuma ordem de serviço atribuída.',
    sourceDetail:
        'Consulta demonstrativa das ordens atribuídas ao funcionário e à fazenda ativa.',
    listMode: true,
  ),
  FeatureDefinition(
    id: 'sincronizacao',
    profile: FeatureProfile.operational,
    group: 'Sincronização',
    title: 'Sincronização de dados',
    objective: 'Enviar a fila local para a nuvem após operação offline.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/sincronizacao',
    capabilities: ['Rebanho', 'Lotes', 'Pesagem', 'Mortes'],
  ),
  // confinamento (onda 1): submódulo de Confinamento (Cadastro + Nutrição),
  // separado por perfil a partir de Especificacao_Funcional_Confinamento_AGRO365.docx
  // (ago/2026). Cadastro/Dieta/Fases são feitos pelo escritório no app web,
  // que divide o banco. As telas dedicadas do Operacional deste grupo (Confinamento) não
  // têm `fields` porque o formulário real vive na tela, não no motor
  // genérico (mesmo padrão de `pesagem`/`nutricoes`). Trato diário e Leitura
  // de cocho — a tarefa mais repetida da equipe de campo — abrem o grupo
  // (fidelidade-esteira: ordem por prioridade de uso); as demais entradas do
  // grupo não ficam todas fisicamente adjacentes aqui por causa disso.
  FeatureDefinition(
    id: 'meus-currais',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Meus currais',
    objective:
        'Consultar a situação dos currais e acionar pesagem, sanitário e óbito.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/meus-currais',
  ),
  FeatureDefinition(
    id: 'producao-batelada',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Produzir batelada',
    objective:
        'Registrar a produção física de uma mistura de dieta, ingrediente a ingrediente.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/batelada',
  ),
  FeatureDefinition(
    id: 'ordens-pendentes',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Ordens pendentes',
    objective:
        'Confirmar a execução de transferências de lote e trocas de dieta criadas pelo escritório.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/ordens-pendentes',
  ),
  // confinamento (onda 2): o Confinamento absorveu as funções restantes do
  // extinto grupo "Misturador" — `carga`, `descarga` e `balanca` deixaram de
  // existir como funcionalidades próprias (a produção física e a distribuição
  // de batelada já são cobertas por `producao-batelada`/`trato-diario`, e a
  // simulação de balança standalone não tinha mais uso sem elas); `nota-cocho`
  // saiu por ser duplicata exata de `leitura-cocho-confinamento` (mesmo
  // objetivo, mesma rota). `configuracoes-misturador` e `conexao-aparelhos`
  // (abaixo) seguem existindo, agora sob o grupo `Confinamento`.
  FeatureDefinition(
    id: 'configuracoes-misturador',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Configurações',
    objective: 'Parametrizar recursos do misturador.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'nome', label: 'Nome da configuração', isRequired: true),
      FeatureField(
        id: 'unidade',
        label: 'Unidade padrão',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['kg', 't'],
      ),
      FeatureField(
        id: 'tolerancia',
        label: 'Tolerância de pesagem (%)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'alerta',
        label: 'Alertas sonoros',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Ativados', 'Desativados'],
      ),
    ],
    primaryAction: 'Salvar configuração',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os parâmetros são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Nova configuração',
    recordTitleField: 'nome',
    recordDescriptionFields: ['unidade', 'tolerancia', 'alerta'],
  ),
  // confinamento (onda 2): o Confinamento absorveu as funções restantes do
  // extinto grupo "Misturador" — `carga`, `descarga` e `balanca` deixaram de
  // existir como funcionalidades próprias (a produção física e a distribuição
  // de batelada já são cobertas por `producao-batelada`/`trato-diario`, e a
  // simulação de balança standalone não tinha mais uso sem elas); `nota-cocho`
  // saiu por ser duplicata exata de `leitura-cocho-confinamento` (mesmo
  // objetivo, mesma rota). `conexao-aparelhos` e `configuracoes-misturador`
  // seguem existindo, agora sob o grupo `Confinamento`.
  FeatureDefinition(
    id: 'conexao-aparelhos',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Conexão de aparelhos',
    objective: 'Conectar balança e equipamentos externos por Bluetooth.',
    status: FeatureStatus.hardware,
    capabilities: [
      'Bluetooth',
      'Localização',
      'Busca de dispositivos',
      'Permissão durante o uso',
    ],
    primaryAction: 'Concluir configuração',
    simulation: HardwareSimulationKind.devices,
    successTitle: 'Aparelhos conectados no protótipo',
    successDescription:
        'A balança e o equipamento externo estão disponíveis para os fluxos simulados desta sessão.',
  ),
];

const allFeatures = operationalFeatures;

FeatureDefinition? featureById(String id) {
  for (final feature in allFeatures) {
    if (feature.id == id) return feature;
  }
  return null;
}
