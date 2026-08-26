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
    this.sections = const [],
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
  });

  final String id;
  final FeatureProfile profile;
  final String group;
  final String title;
  final String objective;
  final FeatureStatus status;
  final String? existingRoute;
  final List<FeatureField> fields;
  final List<String> sections;
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

const adminFeatures = <FeatureDefinition>[
  FeatureDefinition(
    id: 'painel-financeiro',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Financeiro e operacional',
    objective:
        'Consolidar resultados financeiros, custos e produção por período.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/financeiro',
  ),
  FeatureDefinition(
    id: 'painel-pecuario',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Dashboard pecuário',
    objective: 'Acompanhar estoque atual e desempenho do rebanho.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/dashboards/pecuaria',
  ),
  FeatureDefinition(
    id: 'lotacao-currais',
    profile: FeatureProfile.administration,
    group: 'Painéis de decisão',
    title: 'Lotação de currais',
    objective: 'Supervisionar ocupação, capacidade e alertas dos currais.',
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
    title: 'Análise de uso',
    objective: 'Supervisionar usuários ativos e utilização por fazenda.',
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
    existingRoute: '/fazendas/dashboards/consultas',
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
    sections: ['Pendentes', 'Concluídos'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
        placeholder: 'Informações adicionais',
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
    ],
    sections: ['Matérias-primas'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
    ],
    primaryAction: 'Salvar batida',
    emptyLabel: 'Nenhuma batida registrada.',
    listMode: true,
    createAction: 'Nova batida',
    recordTitleField: 'produto',
    recordDescriptionFields: ['quantidade', 'quantidade-realizada', 'armazem'],
  ),
  FeatureDefinition(
    id: 'conexao-aparelhos',
    profile: FeatureProfile.operational,
    group: 'Misturador',
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
  // banco-real (Onda 3): `carga` grava na mesma tabela real que
  // `producao-batelada` do Confinamento (`item_diet_beats`) — confirmado em
  // docs/ajustes-banco-real/01-mapa-catalogo-banco.md. Não removida do
  // catálogo (quem já usa o caminho antigo não pode perder o acesso); vira
  // redirecionamento para a tela nova, no mesmo padrão já usado por
  // `pesagem`/`nascimentos`/`mortes`/`nutricoes` acima: só `existingRoute`,
  // sem `fields`/`listMode` próprios. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 3.
  FeatureDefinition(
    id: 'carga',
    profile: FeatureProfile.operational,
    group: 'Misturador',
    title: 'Carga',
    objective:
        'Registrar a produção física de uma mistura de dieta, ingrediente a ingrediente.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/batelada',
  ),
  // banco-real (Onda 3): `descarga` grava na mesma tabela real que
  // `trato-diario` do Confinamento (`item_nutritions`) — confirmado em
  // docs/ajustes-banco-real/01-mapa-catalogo-banco.md. Mesmo tratamento de
  // `carga` acima: redireciona em vez de excluir. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 3.
  FeatureDefinition(
    id: 'descarga',
    profile: FeatureProfile.operational,
    group: 'Misturador',
    title: 'Descarga',
    objective: 'Distribuir uma batelada entre os currais elegíveis do dia.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/trato-diario',
  ),
  FeatureDefinition(
    id: 'balanca',
    profile: FeatureProfile.operational,
    group: 'Misturador',
    title: 'Balança',
    objective: 'Obter dados de pesagem do equipamento conectado.',
    status: FeatureStatus.hardware,
    capabilities: ['Bluetooth', 'Balança'],
    primaryAction: 'Confirmar leitura',
    simulation: HardwareSimulationKind.scale,
    successTitle: 'Leitura de balança confirmada',
    successDescription:
        'O peso simulado foi capturado e pode ser usado na apresentação do fluxo.',
  ),
  // banco-real (Onda 3): `nota-cocho` grava na mesma tabela real que
  // `leitura-cocho-confinamento` do Confinamento
  // (`feedlot_corral_diet_histories`) — confirmado em
  // docs/ajustes-banco-real/01-mapa-catalogo-banco.md. Mesmo tratamento de
  // `carga`/`descarga` acima: redireciona em vez de excluir. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 3.
  FeatureDefinition(
    id: 'nota-cocho',
    profile: FeatureProfile.operational,
    group: 'Misturador',
    title: 'Nota de cocho',
    objective:
        'Avaliar sobras por curral e registrar ocorrências sanitárias, estruturais e ambientais.',
    status: FeatureStatus.ready,
    existingRoute: '/fazendas/campo/leitura-cocho',
  ),
  FeatureDefinition(
    id: 'configuracoes-misturador',
    profile: FeatureProfile.operational,
    group: 'Misturador',
    title: 'Configurações',
    objective: 'Parametrizar recursos do misturador.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
  // banco-real (onda 2): campos e abas realinhados à especificação real de
  // Apontamentos do AGRO365 web (não mais a `service_orders`, que não é a
  // fonte do Apontamento — ver comentário histórico removido desta unidade).
  // `prazo`, `resultado-esperado` e `criterio-sucesso` saíram por não
  // existirem no Apontamento real do desktop. `data-apontamento`,
  // `descricao`, `cultura-variedade` e `safra` entraram para espelhar a
  // identificação e a classificação agronômica reais. Ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 2.
  FeatureDefinition(
    id: 'apontamento',
    profile: FeatureProfile.operational,
    group: 'Agricultura',
    title: 'Apontamento agrícola',
    objective: 'Registrar uma operação agrícola e os recursos associados.',
    status: FeatureStatus.ready,
    fields: [
      // banco-real (onda 2): no desktop, `responsavel` é preenchido
      // automaticamente com o usuário logado e é somente leitura — o
      // contrato genérico de `FeatureField` não tem um modo read-only por
      // campo (só a tela inteira via `readOnly`, que aqui removeria a
      // criação). Mantido como seleção manual até o motor de formulário
      // ganhar esse modo por campo. Ver
      // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 2.
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(
        id: 'area',
        label: 'Área',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['Talhão 01', 'Talhão 02', 'Pasto Norte'],
      ),
      FeatureField(id: 'operacao', label: 'Operação', isRequired: true),
      FeatureField(id: 'atividade', label: 'Atividade', isRequired: true),
      FeatureField(
        id: 'data-apontamento',
        label: 'Data do apontamento',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      // banco-real (onda 2): no desktop, `area-total` é herdado da área
      // selecionada e é somente leitura — mesma limitação de campo
      // read-only descrita acima em `responsavel`. Ver
      // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 2.
      FeatureField(
        id: 'area-total',
        label: 'Área total',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'area-utilizada',
        label: 'Área utilizada',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'cultura-variedade',
        label: 'Cultura / variedade',
        type: FeatureFieldType.select,
        options: ['Soja', 'Milho', 'Algodão', 'Cana-de-açúcar', 'Café'],
      ),
      FeatureField(
        id: 'safra',
        label: 'Safra',
        type: FeatureFieldType.select,
        options: ['2024/2025', '2025/2026', '2026/2027'],
      ),
      FeatureField(
        id: 'armazem-insumo',
        label: 'Armazém de insumo',
        type: FeatureFieldType.select,
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
        id: 'descricao',
        label: 'Descrição / Histórico',
        type: FeatureFieldType.textarea,
      ),
    ],
    // banco-real (onda 2): 4 abas alinhadas ao Apontamento real do desktop.
    // `Abastecimentos` saiu por não existir no desktop; `Produção` fica
    // exclusiva do desktop junto dos 13 parâmetros de classificação de
    // qualidade (PH, avariados, umidade, quebra técnica…) que exigem
    // balança e classificador. Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md,
    // Onda 2.
    sections: [
      'Mão de obra / Serviços',
      'Máquinas / Implementos',
      'Insumos',
      'Ocorrências',
    ],
    primaryAction: 'Salvar apontamento',
    listMode: true,
    createAction: 'Novo apontamento',
    recordTitleField: 'atividade',
    recordDescriptionFields: ['operacao', 'area', 'area-utilizada'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(id: 'area', label: 'Área', isRequired: true),
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
    ],
    primaryAction: 'Salvar marcação',
    sourceDetail:
        'Os campos não foram exibidos; o protótipo usa premissas mínimas sem GPS real.',
    listMode: true,
    createAction: 'Nova marcação',
    recordTitleField: 'descricao',
    recordDescriptionFields: ['tipo', 'area', 'referencia'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['Bezerro', 'Novilha', 'Vaca', 'Boi'],
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
      FeatureField(
        id: 'peso-medio',
        label: 'Peso médio (kg)',
        type: FeatureFieldType.number,
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['Bezerro', 'Novilha', 'Vaca', 'Boi'],
      ),
    ],
    primaryAction: 'Criar lote',
    listMode: true,
    createAction: 'Novo lote',
    recordTitleField: 'descricao',
    recordDescriptionFields: ['especie', 'categoria'],
  ),
  FeatureDefinition(
    id: 'registrar-animal',
    profile: FeatureProfile.operational,
    group: 'Pecuária',
    title: 'Registrar animal',
    objective: 'Cadastrar um animal individualmente.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(id: 'categoria', label: 'Categoria', isRequired: true),
      FeatureField(id: 'raca', label: 'Raça', isRequired: true),
      FeatureField(
        id: 'nascimento',
        label: 'Data de nascimento',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(
        id: 'peso',
        label: 'Peso (kg)',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'preco-kg',
        label: 'Preço do kg vivo',
        type: FeatureFieldType.number,
      ),
    ],
    primaryAction: 'Registrar animal',
    listMode: true,
    createAction: 'Novo animal',
    recordTitleField: 'categoria',
    recordDescriptionFields: ['raca', 'peso', 'nascimento'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(id: 'lote-atual', label: 'Lote atual', isRequired: true),
      FeatureField(id: 'novo-lote', label: 'Novo lote', isRequired: true),
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(id: 'lote', label: 'Lote', isRequired: true),
      FeatureField(
        id: 'local-atual',
        label: 'Área / módulo atual',
        isRequired: true,
      ),
      FeatureField(id: 'area', label: 'Nova área', isRequired: true),
      FeatureField(id: 'modulo', label: 'Novo módulo', isRequired: true),
    ],
    primaryAction: 'Salvar transferência',
    listMode: true,
    createAction: 'Nova transferência',
    recordTitleField: 'lote',
    recordDescriptionFields: ['area', 'modulo'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
    ],
    sections: ['Identificações adicionais'],
    primaryAction: 'Salvar desmama',
    listMode: true,
    createAction: 'Nova desmama',
    recordTitleField: 'lote',
    recordDescriptionFields: ['tipo', 'identificacao'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(
        id: 'armazem-insumos',
        label: 'Armazém de insumos',
        isRequired: true,
      ),
      FeatureField(
        id: 'armazem-producao',
        label: 'Armazém de produção',
        isRequired: true,
      ),
    ],
    sections: ['Insumos', 'Abastecimentos', 'Máquinas / Equipamentos'],
    primaryAction: 'Salvar pastagem',
    listMode: true,
    createAction: 'Novo manejo de pastagem',
    recordTitleField: 'armazem-producao',
    recordDescriptionFields: ['armazem-insumos', 'responsavel'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(id: 'nome', label: 'Nome da estação', isRequired: true),
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
    id: 'lotes-reproducao',
    profile: FeatureProfile.operational,
    group: 'Reprodução',
    title: 'Lotes / reprodução',
    objective: 'Organizar lotes vinculados ao processo reprodutivo.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
    primaryAction: 'Salvar vínculo',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Vincular lote',
    recordTitleField: 'lote',
    recordDescriptionFields: ['finalidade', 'estacao', 'quantidade'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
    ],
    sections: ['Etapas do protocolo'],
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
  FeatureDefinition(
    id: 'monta-natural',
    profile: FeatureProfile.operational,
    group: 'Reprodução',
    title: 'Monta natural',
    objective: 'Registrar operações de monta natural.',
    status: FeatureStatus.ready,
    fields: [
      FeatureField(
        id: 'responsavel',
        label: 'Responsável',
        type: FeatureFieldType.select,
        isRequired: true,
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
      ),
      FeatureField(
        id: 'data',
        label: 'Data',
        type: FeatureFieldType.date,
        isRequired: true,
      ),
      FeatureField(id: 'lote', label: 'Lote de matrizes', isRequired: true),
      FeatureField(id: 'touro', label: 'Touro / reprodutor', isRequired: true),
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
    primaryAction: 'Registrar monta',
    sourceDetail:
        'A fonte mostrou apenas o acesso; os campos são premissas funcionais do protótipo frontend.',
    listMode: true,
    createAction: 'Nova monta',
    recordTitleField: 'lote',
    recordDescriptionFields: ['touro', 'quantidade', 'data'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
      FeatureField(
        id: 'medidor',
        label: 'Hodômetro / horímetro',
        type: FeatureFieldType.number,
        isRequired: true,
      ),
      FeatureField(
        id: 'origem',
        label: 'Posto / tanque de origem',
        isRequired: true,
      ),
    ],
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
        options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
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
      FeatureField(
        id: 'observacao',
        label: 'Observação',
        type: FeatureFieldType.textarea,
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
    existingRoute: '/fazendas/mais/sync',
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
