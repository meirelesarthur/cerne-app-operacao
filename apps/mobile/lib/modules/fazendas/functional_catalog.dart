// Fonte funcional Flutter do AGRO365.
//
// Portado mecanicamente em 16/08/2026 do catálogo React congelado no commit
// 960fe54. A partir da M1, mudanças funcionais entram primeiro neste contrato
// Dart; o catálogo React permanece apenas como evidência histórica até M13.

enum FeatureProfile { administration, operational }

enum FeatureStatus { ready, mapped, hardware }

enum FeatureFieldType { text, number, date, select, textarea }

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
  });

  final String id;
  final String label;
  final FeatureFieldType? type;
  final bool isRequired;
  final String? placeholder;
  final List<String> options;
}

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

// banco-real: única fonte de nomes de produto para todo o catálogo — espelha
// o cadastro real de `consulta-produtos` (fonte: `products`, 543.983 linhas no
// dump gbcerne). Todo campo "produto"/"matéria-prima" abaixo busca aqui; só a
// tela Produtos cria um item novo em campo livre. Ver
// docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
const catalogoProdutos = <String>[
  'Ração Engorda 18%',
  'Sal Mineral Proteinado',
  'Vacina Aftosa',
  'Vermífugo Injetável',
  'Diesel S10',
  'Semente de Braquiária',
  'Fertilizante NPK 20-05-20',
  'Filtro de óleo — trator',
];

// Onda 8 — domínios compartilhados pelos **itens** de coleção. Mesmo critério
// de `catalogoProdutos` acima: quando o mesmo domínio real aparece em mais de
// uma coleção (unidade de medida, armazém, centro de custo, modo de
// identificação animal), ele mora num lugar só. Ver
// docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 8.
const catalogoUnidades = <String>['kg', 't', 'L', 'Saco', 'Unidade'];

const catalogoArmazens = <String>['Armazém A', 'Depósito B', 'Farmácia'];

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

const catalogoCategoriasAnimais = <String>[
  'Bezerro',
  'Novilha',
  'Vaca',
  'Boi',
];

const catalogoEquipamentos = <String>[
  'Trator John Deere 6110',
  'Colheitadeira CR7',
  'Caminhão Boiadeiro',
  'Pulverizador',
  'Grade Aradora',
];

const adminFeatures = <FeatureDefinition>[
  // Auditoria dos painéis (docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2):
  // `painel-pecuario` fundiu aqui. Os dois painéis mostravam o mesmo P&L e o
  // bloco produtivo da Pecuária estava desativado por falta de dado — dado que
  // existe em Confinamento e passou a ser servido por `lotacao-currais`.
  FeatureDefinition(
    id: 'painel-financeiro',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Resultado',
    objective:
        'Consolidar receita, custo, margem e posição financeira por período.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/resultado',
  ),
  FeatureDefinition(
    id: 'lotacao-currais',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Rebanho e confinamento',
    objective:
        'Supervisionar ocupação, desempenho do lote (GMD) e alertas dos currais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/confinamento',
  ),
  FeatureDefinition(
    id: 'ativos',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Ativos e depreciação',
    objective: 'Acompanhar patrimônio, manutenção e valor residual.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/ativos',
  ),
  FeatureDefinition(
    id: 'suprimentos',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Suprimentos',
    objective: 'Comparar cotações e apoiar decisões de compra.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/suprimentos',
  ),
  FeatureDefinition(
    id: 'analise-uso',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Adoção e governança',
    objective:
        'Supervisionar usuários ativos, utilização por fazenda e trilha de auditoria.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/uso',
  ),
  FeatureDefinition(
    id: 'consultas-gerenciais',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Consultas gerenciais',
    objective: 'Consultar lotes, estoque e pesagens sem permitir alterações.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/consultas/gerenciais',
  ),
  FeatureDefinition(
    id: 'areas',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Áreas cadastradas',
    objective: 'Consultar as áreas usadas pelos processos da fazenda.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhuma área encontrada para os filtros atuais.',
    sourceDetail:
        'A consulta usa os mesmos registros criados no ambiente operacional.',
    listMode: true,
    dataSourceId: 'cadastrar-area',
  ),
  // TODO(banco-real): quando esta consulta ganhar filtro por tipo/classificação
  // de movimento, checar `stocks.type`/`stock_movements.classification` — sem
  // tabela de domínio no dump; hoje esta tela ainda não expõe esse filtro.
  // Ver docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
  FeatureDefinition(
    id: 'saldo-estoque',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Saldo de estoque',
    objective: 'Consultar o saldo disponível dos itens armazenados.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhum item de estoque encontrado.',
    sourceDetail:
        'Consulta demonstrativa consolidada por item e local de armazenamento.',
    listMode: true,
  ),
  // banco-real (onda 2): `products` é a maior tabela do dump gbcerne (543.983
  // linhas) e não tinha nenhuma tela própria — só aparecia embutida como select
  // em outras funcionalidades. Ver
  // docs/ajustes-banco-real/02-oportunidades-banco-real.md, seção 2.6.
  FeatureDefinition(
    id: 'consulta-produtos',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Produtos',
    objective:
        'Consultar e cadastrar o catálogo de produtos, categorias e custo médio.',
    status: FeatureStatus.ready,
    emptyLabel: 'Nenhum produto encontrado para os filtros atuais.',
    sourceDetail:
        'Única tela que cria produto em campo livre — Formulações, Batida, Carga e Descarga '
        'buscam neste catálogo em vez de digitar o nome.',
    // banco-real: única superfície de criação de produto (campo livre). Todo
    // outro campo "produto" do catálogo busca em `catalogoProdutos` acima, em
    // vez de aceitar texto livre — fonte real: `products` (543.983 linhas).
    fields: [
      FeatureField(
        id: 'nome-produto',
        label: 'Nome do produto',
        isRequired: true,
        placeholder: 'Ex.: Ração Engorda 18%',
      ),
      FeatureField(
        id: 'categoria',
        label: 'Categoria',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Nutrição',
          'Sanitário',
          'Combustível',
          'Agrícola',
          'Peça de equipamento',
        ],
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade de medida',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['kg', 't', 'L', 'unidade', 'saca', 'dose', 'frasco'],
      ),
      FeatureField(
        id: 'custo-medio',
        label: 'Custo médio (R\$)',
        type: FeatureFieldType.number,
      ),
    ],
    primaryAction: 'Salvar produto',
    listMode: true,
    createAction: 'Novo produto',
    recordTitleField: 'nome-produto',
    recordDescriptionFields: ['categoria', 'unidade'],
  ),
  FeatureDefinition(
    id: 'processamentos',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Processamentos pecuários',
    objective: 'Acompanhar rotinas pendentes e concluídas.',
    status: FeatureStatus.ready,
    collections: [
      FeatureCollection(name: 'Pendentes'),
      FeatureCollection(name: 'Concluídos'),
    ],
    emptyLabel: 'Nenhum processamento pendente.',
    listMode: true,
  ),
  // banco-real (onda 1): compra e venda de animais são decisão comercial/
  // financeira (fornecedor/cliente, valor, documento fiscal) — sobem do
  // operacional para o ADM, que só visualiza; a decisão desce como ordem
  // para o Operacional confirmar a execução, igual ao padrão `OrdemPendente`
  // já implementado em `confinamento/models.dart`. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  FeatureDefinition(
    id: 'compras-animais',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Compra de animais',
    objective: 'Consultar compras de animais registradas.',
    status: FeatureStatus.ready,
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'fornecedor', label: 'Fornecedor', isRequired: true),
      FeatureField(
        id: 'data',
        label: 'Data da compra',
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
      FeatureField(id: 'categoria', label: 'Categoria', isRequired: true),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'valor-total',
        label: 'Valor total (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'documento',
        label: 'Nota / documento de origem',
        isRequired: true,
      ),
      // fidelidade-campos (onda 5): `/movement-purchases` exige o bloco
      // financeiro inteiro de cabeçalho — forma de pagamento, total de
      // produtos, frete, outros valores e desconto — e nada disso existia. Sem
      // eles a consulta mostra um valor total que não se explica.
      FeatureField(
        id: 'forma-pagamento',
        label: 'Forma de pagamento',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['À vista', 'Parcelado', 'Permuta', 'Boleto'],
      ),
      FeatureField(
        id: 'total-produtos',
        label: 'Total de produtos (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'frete',
        label: 'Frete (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'outros-valores',
        label: 'Outros valores (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'desconto',
        label: 'Desconto (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'valor-unitario',
        label: 'Valor unitário por animal (R\$)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'vendedor',
        label: 'Vendedor',
        placeholder: 'Quem intermediou a compra',
      ),
    ],
    // `items[]` traz lote, pasto e centro de custo de cada grupo comprado;
    // `financial[]` é o parcelamento. Duas coleções, nenhuma no protótipo.
    collections: [
      FeatureCollection(
        name: 'Itens da compra',
        itemLabel: 'Item da compra',
        titleField: 'categoria',
        subtitleFields: ['quantidade', 'valor-unitario'],
        fields: [
          FeatureField(
            id: 'categoria',
            label: 'Categoria',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoCategoriasAnimais,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
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
            id: 'lote',
            label: 'Lote de destino',
          ),
          FeatureField(
            id: 'pasto',
            label: 'Pasto de destino',
          ),
          FeatureField(
            id: 'centro-custo',
            label: 'Centro de custo',
            type: FeatureFieldType.select,
            options: catalogoCentrosCusto,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Parcelas',
        itemLabel: 'Parcela',
        titleField: 'vencimento',
        subtitleFields: ['valor', 'forma'],
        fields: [
          FeatureField(
            id: 'vencimento',
            label: 'Vencimento',
            type: FeatureFieldType.date,
            isRequired: true,
          ),
          FeatureField(
            id: 'valor',
            label: 'Valor (R\$)',
            type: FeatureFieldType.number,
            isRequired: true,
          ),
          FeatureField(
            id: 'forma',
            label: 'Forma',
            type: FeatureFieldType.select,
            options: [
              'Boleto',
              'Transferência',
              'Cheque',
              'Dinheiro',
            ],
          ),
        ],
      ),
    ],
    emptyLabel: 'Nenhuma compra de animais registrada.',
    sourceDetail:
        'O formulário não foi aberto; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    recordTitleField: 'fornecedor',
    recordDescriptionFields: ['quantidade', 'categoria', 'data'],
  ),
  // banco-real (onda 1): em Confinamento, "Vender Animais" já é exclusiva do
  // ADM — o catálogo geral ainda contradizia isso com `existingRoute` para
  // `/fazendas/campo/venda`, uma rota bloqueada para administração pela
  // política de acesso (`router/app_router.dart`, `redirectForSession`). A
  // rota saiu; a tela vira consulta pelo motor genérico, sem `fields`
  // documentados na fonte original (mesmo padrão de `minhas-os`). Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
  FeatureDefinition(
    id: 'vendas',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Vendas',
    objective: 'Consultar vendas de animais registradas.',
    status: FeatureStatus.ready,
    readOnly: true,
    emptyLabel: 'Nenhuma venda registrada.',
    sourceDetail:
        'Consulta demonstrativa das vendas de animais registradas nesta sessão.',
    listMode: true,
  ),
  // fidelidade-campos (onda 4): `lotes-reproducao` volta ao catálogo, mas do
  // lado administrativo e somente leitura. A avaliação de 360f0f8 continua
  // valendo — vincular lote à estação de monta é organização estrutural, não
  // execução de campo —, e a lacuna era outra: tirar do catálogo apagou
  // também a documentação do contrato `/breeding-batches`, que a auditoria de
  // fidelidade audita. Como consulta, o vínculo volta a ser visível no app sem
  // reabrir o cadastro no celular. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md,
  // Onda 4.
  FeatureDefinition(
    id: 'lotes-reproducao',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Lotes / reprodução',
    objective: 'Consultar lotes vinculados ao processo reprodutivo.',
    status: FeatureStatus.ready,
    readOnly: true,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      // Os dois escalares required de `/breeding-batches` que faltavam.
      FeatureField(id: 'codigo', label: 'Código', isRequired: true),
      FeatureField(
        id: 'data',
        label: 'Data do vínculo',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(id: 'estacao', label: 'Estação de monta', isRequired: true),
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
      FeatureField(
        id: 'finalidade',
        label: 'Finalidade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Matrizes', 'Reprodutores', 'Receptoras', 'Novilhas'],
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
    ],
    emptyLabel: 'Nenhum lote vinculado à reprodução.',
    sourceDetail:
        'Consulta demonstrativa dos vínculos de lote e estação de monta.',
    listMode: true,
    recordTitleField: 'lote',
    recordDescriptionFields: ['finalidade', 'estacao', 'data'],
  ),
  FeatureDefinition(
    id: 'exportar-log-estoque',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Exportar log de estoque',
    objective: 'Exportar registros de auditoria relacionados ao estoque.',
    status: FeatureStatus.ready,
    sourceDetail:
        'Período e formatos CSV/JSON são premissas funcionais do protótipo frontend.',
    auditExport: AuditExportKind.estoque,
  ),
  FeatureDefinition(
    id: 'exportar-log-pecuaria',
    profile: FeatureProfile.administration,
    group: 'Consultas e auditoria',
    title: 'Exportar log da pecuária',
    objective: 'Exportar o histórico de eventos e movimentações do rebanho.',
    status: FeatureStatus.ready,
    sourceDetail:
        'Período e formatos CSV/JSON são premissas funcionais do protótipo frontend.',
    auditExport: AuditExportKind.pecuaria,
  ),
];

const operationalFeatures = <FeatureDefinition>[
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
      // TODO(banco-real): `areas.type` é smallint no banco real, sem tabela de
      // domínio no dump — as opções abaixo são placeholder. Confirmar com o
      // time web os valores válidos antes de travar este select em produção.
      // Ver docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
      FeatureField(
        id: 'tipo',
        label: 'Tipo de uso',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Agricultura', 'Pecuária', 'Fruticultura', 'Reserva'],
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
      FeatureField(
        id: 'area-produtiva',
        label: 'Área produtiva',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'area-nao-produtiva',
        label: 'Área não produtiva',
        type: FeatureFieldType.number,
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
      FeatureField(
        id: 'cor',
        label: 'Cor no mapa',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Verde', 'Amarelo', 'Vermelho', 'Azul', 'Roxo', 'Cinza'],
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
      FeatureField(
        id: 'area-recreio',
        label: 'Área de recreio',
        type: FeatureFieldType.select,
        options: ['Sim', 'Não'],
      ),
      FeatureField(
        id: 'ativo',
        label: 'Ativa',
        type: FeatureFieldType.select,
        options: ['Sim', 'Não'],
      ),
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
        placeholder: 'Informações adicionais',
      ),
    ],
    // `infrastructure[]` — cercas, bebedouros, currais e benfeitorias da área.
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
      FeatureField(
        id: 'ativo',
        label: 'Ativo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Sim', 'Não'],
      ),
      FeatureField(
        id: 'produto',
        label: 'Produto',
        type: FeatureFieldType.select,
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
      ),
      // TODO(banco-real): este campo conflate `diets.type` e `diets.objective`
      // (duas colunas distintas no banco, ambas sem tabela de domínio no dump).
      // Confirmar com o time web se devem virar dois selects separados e quais
      // os valores válidos. Ver docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md,
      // seção C.
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Estoque', 'Formulação'],
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
      FeatureCollection(
        name: 'Matérias-primas',
        itemLabel: 'Matéria-prima',
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
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Armazém A', 'Depósito B', 'Farmácia'],
      ),
      FeatureField(
        id: 'produto',
        label: 'Produto',
        type: FeatureFieldType.select,
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
        options: [
          'Dieta Adaptação',
          'Dieta Crescimento',
          'Dieta Terminação',
        ],
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
      FeatureCollection(
        name: 'Itens da batida',
        itemLabel: 'Item da batida',
        titleField: 'produto',
        subtitleFields: ['quantidade', 'porcentagem'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém de estoque',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoArmazens,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
            isRequired: true,
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
          ),
          FeatureField(
            id: 'porcentagem',
            label: 'Porcentagem da dieta (%)',
            type: FeatureFieldType.number,
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
      FeatureField(id: 'area', label: 'Área', isRequired: true),
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
      FeatureField(
        id: 'safra',
        label: 'Safra',
        type: FeatureFieldType.select,
        options: ['2023/2024', '2024/2025', '2025/2026', '2026/2027'],
      ),
      FeatureField(
        id: 'variedade',
        label: 'Variedade / cultura',
        type: FeatureFieldType.select,
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
        placeholder: 'Nº da semana',
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'cor',
        label: 'Cor no mapa',
        type: FeatureFieldType.select,
        options: ['Verde', 'Amarelo', 'Vermelho', 'Azul', 'Roxo'],
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
        type: FeatureFieldType.select,
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
      FeatureField(
        id: 'data-entrada',
        label: 'Data de entrada',
        type: FeatureFieldType.date,
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
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoCategoriasAnimais,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
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
      FeatureField(id: 'raca', label: 'Raça'),
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
      ),
      FeatureField(
        id: 'preco-arroba',
        label: 'Preço da arroba (vivo)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'valor-unitario',
        label: 'Valor unitário (R\$)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'ua',
        label: 'Unidade animal (UA)',
        type: FeatureFieldType.number,
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
          'tipo-identificacao',
          'peso-medio',
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
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
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
      FeatureField(
        id: 'categoria',
        label: 'Categoria',
        type: FeatureFieldType.select,
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
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'categoria',
            label: 'Categoria',
            type: FeatureFieldType.select,
            options: catalogoCategoriasAnimais,
          ),
          FeatureField(
            id: 'peso',
            label: 'Peso (kg)',
            type: FeatureFieldType.number,
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
      FeatureField(
        id: 'nascimento',
        label: 'Data de nascimento',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade',
        type: FeatureFieldType.number,
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
      FeatureField(
        id: 'preco-kg',
        label: 'Preço do kg vivo',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'preco-arroba',
        label: 'Preço da arroba (vivo)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'valor-unitario',
        label: 'Valor unitário (R\$)',
        type: FeatureFieldType.number,
      ),
      FeatureField(
        id: 'ua',
        label: 'Unidade animal (UA)',
        type: FeatureFieldType.number,
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
    id: 'pesagem',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Pesagens',
    objective: 'Consultar e registrar pesagens do rebanho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/pesagem',
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
        id: 'identificacao',
        label: 'Identificação animal',
        isRequired: true,
        placeholder: 'Brinco ou ID',
      ),
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'lote-atual', label: 'Lote atual', isRequired: true),
      FeatureField(id: 'novo-lote', label: 'Novo lote', isRequired: true),
      // fidelidade-campos (onda 3): `same_batch` é a flag required de
      // `/animals/batch-transfer` — decide se todos os animais vão para um
      // lote só ou se cada um tem o seu destino. Sem ela o backend não sabe
      // como interpretar o resto da submissão.
      FeatureField(
        id: 'destino-unico',
        label: 'Mesmo lote para todos',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Sim', 'Não'],
      ),
    ],
    capabilities: ['Balança', 'RFID', 'Scanner SISBOV'],
    primaryAction: 'Salvar transferência',
    listMode: true,
    createAction: 'Nova transferência de animal',
    recordTitleField: 'identificacao',
    recordDescriptionFields: ['lote-atual', 'novo-lote'],
    simulation: HardwareSimulationKind.rfid,
    simulationTargetField: 'identificacao',
  ),
  FeatureDefinition(
    id: 'scanner-sisbov',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Scanner SISBOV',
    objective: 'Capturar a identificação do animal usando a câmera.',
    status: FeatureStatus.hardware,
    capabilities: ['Câmera', 'Área de enquadramento', 'Reiniciar leitura'],
    primaryAction: 'Usar identificação capturada',
    simulation: HardwareSimulationKind.scanner,
    successTitle: 'Identificação SISBOV capturada',
    successDescription:
        'O código simulado está disponível para identificação do animal nesta sessão.',
  ),
  FeatureDefinition(
    id: 'transferencia-lote-area',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Transferência lote / área',
    objective: 'Alterar a localização de um lote entre área e módulo.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
      FeatureField(
        id: 'local-atual',
        label: 'Área / módulo atual',
        isRequired: true,
      ),
      FeatureField(id: 'area', label: 'Nova área', isRequired: true),
      FeatureField(id: 'modulo', label: 'Novo módulo', isRequired: true),
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
    id: 'nascimentos',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Nascimentos',
    objective: 'Registrar nascimento de animais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/ciclo',
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
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: catalogoResponsaveis,
      ),
      FeatureField(
        id: 'data',
        label: 'Data da ocorrência',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(id: 'lote', label: 'Lote atual', isRequired: true),
      FeatureField(id: 'causa', label: 'Motivo da perda', isRequired: true),
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
    id: 'nutricoes',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Nutrições',
    objective: 'Registrar produtos, quantidade, área, módulo e cocho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/arracoamento',
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
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
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
      FeatureField(
        id: 'produto',
        label: 'Produto / procedimento',
        isRequired: true,
      ),
      // banco-real: `sanitaries.time_control` indica se o manejo tem
      // carência/intervalo a respeitar — dado sensível de rastreabilidade
      // (retirada de leite/carne pós-medicamento) ausente no protótipo. Ver
      // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
      FeatureField(
        id: 'controle-por-tempo',
        label: 'Controle por tempo (carência)',
        type: FeatureFieldType.select,
        options: ['Sim', 'Não'],
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
      FeatureCollection(
        name: 'Animais alvo',
        itemLabel: 'Animal',
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
          ),
        ],
      ),
      FeatureCollection(
        name: 'Itens de estoque',
        itemLabel: 'Item de estoque',
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade', 'armazem'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.select,
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
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoArmazens,
          ),
          FeatureField(
            id: 'centro-custo',
            label: 'Centro de custo',
            type: FeatureFieldType.select,
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
          FeatureField(
            id: 'tipo',
            label: 'Tipo',
            type: FeatureFieldType.select,
            isRequired: true,
            options: [
              'Própria',
              'Terceirizada',
            ],
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
            options: [
              'Hora',
              'Dia',
            ],
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
      FeatureField(
        id: 'tipo',
        label: 'Tipo',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Convencional', 'Precoce', 'Temporária'],
      ),
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
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
      ),
    ],
    collections: [
      FeatureCollection(
        name: 'Identificações adicionais',
        itemLabel: 'Identificação',
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
      FeatureField(
        id: 'lote-origem',
        label: 'Lote de origem',
        isRequired: true,
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
        isRequired: true,
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade de animais',
        type: FeatureFieldType.number,
        isRequired: true,
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
      FeatureField(id: 'lote', label: 'Lote'),
      FeatureField(
        id: 'animal',
        label: 'Animal',
        placeholder: 'Brinco ou ID — só quando o manejo é de um animal',
      ),
      FeatureField(
        id: 'armazem-insumos',
        label: 'Armazém de insumos',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Armazém A', 'Depósito B'],
      ),
      FeatureField(
        id: 'armazem-producao',
        label: 'Armazém de produção',
        type: FeatureFieldType.select,
        isRequired: true,
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
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoEquipamentos,
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
            options: [
              'Hora',
              'Dia',
              'km',
            ],
          ),
          FeatureField(
            id: 'horimetro-inicial',
            label: 'Horímetro inicial',
            type: FeatureFieldType.number,
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
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.select,
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
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            options: catalogoArmazens,
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
            type: FeatureFieldType.select,
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
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            options: catalogoArmazens,
          ),
        ],
      ),
      FeatureCollection(
        name: 'Serviços',
        itemLabel: 'Serviço',
        titleField: 'servico',
        subtitleFields: ['prestador', 'valor'],
        fields: [
          FeatureField(
            id: 'servico',
            label: 'Serviço',
            isRequired: true,
            placeholder: 'Descrição do serviço',
          ),
          FeatureField(
            id: 'prestador',
            label: 'Prestador',
            placeholder: 'Quem executou',
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
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
          FeatureField(
            id: 'prioridade',
            label: 'Prioridade',
            type: FeatureFieldType.select,
            isRequired: true,
            options: [
              'Baixa',
              'Média',
              'Alta',
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
    collections: [
      FeatureCollection(
        name: 'Produtos (armazém e sêmen)',
        itemLabel: 'Produto reprodutivo',
        titleField: 'produto',
        subtitleFields: ['armazem', 'quantidade'],
        fields: [
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoArmazens,
          ),
          FeatureField(
            id: 'produto',
            label: 'Produto',
            isRequired: true,
            placeholder: 'Palheta, dose ou embrião',
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
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
      FeatureField(id: 'estacao', label: 'Estação de monta', isRequired: true),
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
            options: [
              'Produto',
              'Serviço',
            ],
          ),
          FeatureField(
            id: 'produto',
            label: 'Produto',
            type: FeatureFieldType.select,
            options: catalogoProdutos,
          ),
          FeatureField(
            id: 'quantidade',
            label: 'Quantidade',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            options: catalogoArmazens,
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
      FeatureField(id: 'lote', label: 'Lote de matrizes', isRequired: true),
      FeatureField(id: 'touro', label: 'Touro / reprodutor', isRequired: true),
      // fidelidade-campos (onda 4): `type` e `launch_type` são required em
      // `/breeding-matings` e controlam o modo inteiro do registro — o
      // primeiro diz se é monta natural, IA, IATF ou TE; o segundo, se o
      // lançamento é por lote ou animal por animal. O TODO(banco-real) que
      // existia aqui (`breeding_matings.type` sem tabela de domínio) fica
      // resolvido pelo próprio contrato: os valores são os métodos
      // reprodutivos, os mesmos de `estacao-monta.metodo`.
      FeatureField(
        id: 'tipo',
        label: 'Tipo de acasalamento',
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Monta natural',
          'Inseminação artificial',
          'IATF',
          'Transferência de embrião',
        ],
      ),
      FeatureField(
        id: 'tipo-lancamento',
        label: 'Tipo de lançamento',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Por lote', 'Animal por animal'],
      ),
      FeatureField(id: 'estacao-monta', label: 'Estação de monta'),
      FeatureField(
        id: 'material-reprodutivo',
        label: 'Material reprodutivo',
        placeholder: 'Touro, sêmen ou embrião do estoque',
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
    // coleção das fêmeas cobertas; `protocol_animals[]`/`simplified_animals[]`
    // é o lançamento linha a linha, quando o tipo de lançamento é por animal.
    // Nenhuma das duas é obrigatória aqui porque no contrato a exigência é
    // condicional ao `type`/`launch_type`, não absoluta.
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
          ),
        ],
      ),
      FeatureCollection(
        name: 'Animais por linha',
        itemLabel: 'Animal do acasalamento',
        titleField: 'identificacao',
        subtitleFields: ['touro', 'data'],
        fields: [
          FeatureField(
            id: 'identificacao',
            label: 'Identificação',
            isRequired: true,
            placeholder: 'Brinco ou RFID',
          ),
          FeatureField(
            id: 'touro',
            label: 'Touro / material',
          ),
          FeatureField(
            id: 'data',
            label: 'Data da cobertura',
            type: FeatureFieldType.date,
          ),
          FeatureField(
            id: 'observacao',
            label: 'Observação',
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
        fields: ['estacao-monta', 'lote', 'touro', 'material-reprodutivo'],
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
        sections: ['Vacas do acasalamento', 'Animais por linha'],
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
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
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
        options: [
          'Palpação retal',
          'Ultrassonografia',
          'Dosagem hormonal',
        ],
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
            options: [
              'Palpação retal',
              'Ultrassonografia',
              'Dosagem hormonal',
            ],
          ),
          FeatureField(
            id: 'resultado',
            label: 'Resultado',
            type: FeatureFieldType.select,
            isRequired: true,
            options: [
              'Prenhe',
              'Vazia',
              'Reavaliar',
            ],
          ),
          FeatureField(
            id: 'dias-gestacao',
            label: 'Dias de gestação',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'touro',
            label: 'Touro atribuído',
          ),
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
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Trator John Deere 6110',
          'Colheitadeira CR7',
          'Caminhão Boiadeiro',
          'Pulverizador',
        ],
      ),
      FeatureField(
        id: 'combustivel',
        label: 'Combustível',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Diesel S10', 'Diesel S500', 'Gasolina', 'Etanol'],
      ),
      FeatureField(
        id: 'quantidade',
        label: 'Quantidade (L)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      // fidelidade-campos (onda 5): o "medidor" cobria horímetro e hodômetro
      // no mesmo campo — quem lê o número não sabia qual estava informando.
      // O tipo agora é explícito, e a unidade (`items.*.measurement_uuid`) é
      // required no contrato e faltava.
      FeatureField(
        id: 'tipo-medidor',
        label: 'Tipo de medidor',
        type: FeatureFieldType.select,
        options: ['Hodômetro', 'Horímetro'],
      ),
      FeatureField(
        id: 'medidor',
        label: 'Leitura do medidor',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'unidade',
        label: 'Unidade',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['L', 'kg'],
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
      FeatureCollection(
        name: 'Itens do abastecimento',
        itemLabel: 'Item do abastecimento',
        titleField: 'veiculo',
        subtitleFields: ['quantidade', 'unidade'],
        fields: [
          FeatureField(
            id: 'veiculo',
            label: 'Veículo / equipamento',
            type: FeatureFieldType.select,
            isRequired: true,
            options: catalogoEquipamentos,
          ),
          FeatureField(
            id: 'combustivel',
            label: 'Combustível',
            type: FeatureFieldType.select,
            isRequired: true,
            options: [
              'Diesel S10',
              'Diesel S500',
              'Gasolina',
              'Etanol',
            ],
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
            options: [
              'L',
              'kg',
            ],
          ),
          FeatureField(
            id: 'medidor',
            label: 'Leitura do medidor',
            type: FeatureFieldType.number,
          ),
          FeatureField(
            id: 'observacao',
            label: 'Observação',
          ),
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
        type: FeatureFieldType.select,
        isRequired: true,
        options: [
          'Trator John Deere 6110',
          'Colheitadeira CR7',
          'Caminhão Boiadeiro',
          'Pulverizador',
        ],
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
      ),
      FeatureField(
        id: 'hodometro',
        label: 'Hodômetro',
        type: FeatureFieldType.number,
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
      FeatureCollection(
        name: 'Peças / Insumos',
        itemLabel: 'Peça / Insumo',
        titleField: 'produto',
        subtitleFields: ['quantidade', 'unidade'],
        fields: [
          FeatureField(
            id: 'produto',
            label: 'Produto / peça',
            type: FeatureFieldType.select,
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
          ),
          FeatureField(
            id: 'armazem',
            label: 'Armazém',
            type: FeatureFieldType.select,
            options: catalogoArmazens,
          ),
          FeatureField(
            id: 'valor',
            label: 'Valor (R\$)',
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
        hint: 'Leitura do equipamento e o que será consumido.',
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
  // TODO(banco-real): quando esta tela ganhar filtro/campo de categoria ou
  // status, checar `service_orders.category`/`service_orders.status` — sem
  // tabela de domínio no dump; hoje esta tela ainda não expõe esses campos
  // (o status mostrado vem de `PrototypeRecordStatus`, genérico do protótipo,
  // não do banco). Ver docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md,
  // seção C.
  FeatureDefinition(
    id: 'minhas-os',
    profile: FeatureProfile.operational,
    group: 'Ordem de serviço',
    title: 'Minhas OS',
    objective:
        'Consultar ordens de serviço vinculadas ao funcionário e à fazenda.',
    status: FeatureStatus.ready,
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
  // (ago/2026). Cadastro/Dieta/Fases são só leitura no dashboard ADM
  // (`/fazendas/dashboards/confinamento`) — feitos pelo app web, que divide o
  // banco. As 6 entradas abaixo são as telas dedicadas do Operacional; sem
  // `fields` porque o formulário real vive na tela, não no motor genérico
  // (mesmo padrão de `pesagem`/`nutricoes` acima).
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
  FeatureDefinition(
    id: 'ordens-pendentes',
    profile: FeatureProfile.operational,
    group: 'Confinamento',
    title: 'Ordens pendentes',
    objective:
        'Confirmar a execução de transferências de lote e trocas de dieta criadas pelo ADM.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/ordens-pendentes',
  ),
];

const allFeatures = <FeatureDefinition>[
  ...adminFeatures,
  ...operationalFeatures,
];

FeatureDefinition? featureById(String id) {
  for (final feature in allFeatures) {
    if (feature.id == id) return feature;
  }
  return null;
}
