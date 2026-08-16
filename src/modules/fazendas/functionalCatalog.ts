/**
 * Catálogo funcional do AGRO365, normalizado a partir do mapeamento de 16/08/2026.
 *
 * Esta é a fonte única da esteira de protótipo: cada item tem um responsável,
 * uma rota e o nível de fidelidade permitido pela evidência disponível.
 * `mapped` significa que a gravação mostrou apenas o acesso ou parte do fluxo;
 * nesses casos o protótipo não inventa campos além dos observados.
 */
export type FeatureStatus = 'ready' | 'mapped' | 'hardware'
export type FeatureFieldType = 'text' | 'number' | 'date' | 'select' | 'textarea'

export interface FeatureField {
  id: string
  label: string
  type?: FeatureFieldType
  required?: boolean
  placeholder?: string
  options?: string[]
}

export interface FeatureDefinition {
  id: string
  group: string
  title: string
  objective: string
  status: FeatureStatus
  existingRoute?: string
  fields?: FeatureField[]
  sections?: string[]
  capabilities?: string[]
  primaryAction?: string
  emptyLabel?: string
  sourceDetail?: string
}

const responsavel: FeatureField = {
  id: 'responsavel',
  label: 'Responsável',
  type: 'select',
  required: true,
  options: ['João Oliveira', 'Maria Souza', 'Carlos Dias'],
}

export const ADMIN_FEATURES: FeatureDefinition[] = [
  {
    id: 'painel-financeiro',
    group: 'Painéis de decisão',
    title: 'Financeiro e operacional',
    objective: 'Consolidar resultados financeiros, custos e produção por período.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/financeiro',
  },
  {
    id: 'painel-pecuario',
    group: 'Painéis de decisão',
    title: 'Dashboard pecuário',
    objective: 'Acompanhar estoque atual e desempenho do rebanho.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/pecuaria',
  },
  {
    id: 'lotacao-currais',
    group: 'Painéis de decisão',
    title: 'Lotação de currais',
    objective: 'Supervisionar ocupação, capacidade e alertas dos currais.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/confinamento',
  },
  {
    id: 'ativos',
    group: 'Painéis de decisão',
    title: 'Ativos e depreciação',
    objective: 'Acompanhar patrimônio, manutenção e valor residual.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/ativos',
  },
  {
    id: 'suprimentos',
    group: 'Painéis de decisão',
    title: 'Suprimentos',
    objective: 'Comparar cotações e apoiar decisões de compra.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/suprimentos',
  },
  {
    id: 'analise-uso',
    group: 'Painéis de decisão',
    title: 'Análise de uso',
    objective: 'Supervisionar usuários ativos e utilização por fazenda.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/uso',
  },
  {
    id: 'consultas-gerenciais',
    group: 'Consultas e auditoria',
    title: 'Consultas gerenciais',
    objective: 'Consultar lotes, estoque e pesagens sem permitir alterações.',
    status: 'ready',
    existingRoute: '/fazendas/dashboards/consultas',
  },
  {
    id: 'areas',
    group: 'Consultas e auditoria',
    title: 'Áreas cadastradas',
    objective: 'Consultar as áreas usadas pelos processos da fazenda.',
    status: 'mapped',
    emptyLabel: 'Nenhuma área encontrada para os filtros atuais.',
    sourceDetail: 'A fonte exibiu lista, visualização e inclusão, sem mostrar os campos internos.',
  },
  {
    id: 'saldo-estoque',
    group: 'Consultas e auditoria',
    title: 'Saldo de estoque',
    objective: 'Consultar o saldo disponível dos itens armazenados.',
    status: 'mapped',
    emptyLabel: 'Nenhum item de estoque encontrado.',
    sourceDetail: 'Filtros e campos internos não foram exibidos na gravação.',
  },
  {
    id: 'processamentos',
    group: 'Consultas e auditoria',
    title: 'Processamentos pecuários',
    objective: 'Acompanhar rotinas pendentes e concluídas.',
    status: 'mapped',
    sections: ['Pendentes', 'Concluídos'],
    emptyLabel: 'Nenhum processamento pendente.',
  },
  {
    id: 'exportar-log-estoque',
    group: 'Consultas e auditoria',
    title: 'Exportar log de estoque',
    objective: 'Exportar registros de auditoria relacionados ao estoque.',
    status: 'mapped',
    primaryAction: 'Preparar exportação',
    sourceDetail: 'A fonte identificou o acesso, mas não exibiu filtros ou formato do arquivo.',
  },
  {
    id: 'exportar-log-pecuaria',
    group: 'Consultas e auditoria',
    title: 'Exportar log da pecuária',
    objective: 'Exportar o histórico de eventos e movimentações do rebanho.',
    status: 'mapped',
    primaryAction: 'Preparar exportação',
    sourceDetail: 'A fonte identificou apenas o item de menu.',
  },
]

export const OPERATIONAL_FEATURES: FeatureDefinition[] = [
  {
    id: 'cadastrar-area',
    group: 'Cadastros',
    title: 'Áreas',
    objective: 'Cadastrar áreas usadas nos processos da fazenda.',
    status: 'mapped',
    primaryAction: 'Adicionar área',
    sourceDetail: 'Os campos internos não foram abertos na gravação.',
  },
  {
    id: 'formulacoes',
    group: 'Estoque',
    title: 'Formulações',
    objective: 'Criar formulações compostas por matérias-primas e percentuais.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'ativo', label: 'Ativo', type: 'select', required: true, options: ['Sim', 'Não'] },
      { id: 'produto', label: 'Produto', required: true, placeholder: 'Selecione ou busque o produto' },
      { id: 'quantidade', label: 'Quantidade de referência', type: 'number', required: true },
      { id: 'unidade', label: 'Unidade de medida', type: 'select', required: true, options: ['kg', 't', 'L'] },
      { id: 'tipo', label: 'Tipo', type: 'select', required: true, options: ['Estoque', 'Formulação'] },
      { id: 'materia-prima', label: 'Matéria-prima', required: true },
      { id: 'porcentagem', label: 'Porcentagem (%)', type: 'number', required: true },
    ],
    sections: ['Dados da formulação', 'Matérias-primas'],
    primaryAction: 'Salvar formulação',
  },
  {
    id: 'batidas',
    group: 'Estoque',
    title: 'Batida',
    objective: 'Registrar a produção de uma formulação para um armazém de destino.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'tipo', label: 'Tipo', type: 'select', required: true, options: ['Estoque', 'Formulação'] },
      { id: 'armazem', label: 'Armazém de destino', type: 'select', required: true, options: ['Armazém A', 'Depósito B', 'Farmácia'] },
      { id: 'produto', label: 'Produto', required: true },
      { id: 'quantidade', label: 'Quantidade de referência', type: 'number', required: true },
      { id: 'unidade', label: 'Unidade de medida', type: 'select', required: true, options: ['kg', 't', 'L'] },
    ],
    primaryAction: 'Salvar batida',
    emptyLabel: 'Nenhuma batida registrada.',
  },
  {
    id: 'conexao-aparelhos',
    group: 'Misturador',
    title: 'Conexão de aparelhos',
    objective: 'Conectar balança e equipamentos externos por Bluetooth.',
    status: 'hardware',
    capabilities: ['Bluetooth', 'Localização', 'Busca de dispositivos', 'Permissão durante o uso'],
    primaryAction: 'Buscar dispositivos',
  },
  {
    id: 'carga',
    group: 'Misturador',
    title: 'Carga',
    objective: 'Executar o fluxo operacional de carregamento do misturador.',
    status: 'mapped',
    primaryAction: 'Iniciar carga',
    sourceDetail: 'A fonte mostrou apenas a entrada da funcionalidade.',
  },
  {
    id: 'descarga',
    group: 'Misturador',
    title: 'Descarga',
    objective: 'Executar o fluxo operacional de descarga do misturador.',
    status: 'mapped',
    primaryAction: 'Iniciar descarga',
    sourceDetail: 'A fonte mostrou apenas a entrada da funcionalidade.',
  },
  {
    id: 'balanca',
    group: 'Misturador',
    title: 'Balança',
    objective: 'Obter dados de pesagem do equipamento conectado.',
    status: 'hardware',
    capabilities: ['Bluetooth', 'Balança'],
    primaryAction: 'Conectar balança',
  },
  {
    id: 'nota-cocho',
    group: 'Misturador',
    title: 'Nota de cocho',
    objective: 'Registrar e consultar a nota de cocho.',
    status: 'mapped',
    primaryAction: 'Nova nota de cocho',
    sourceDetail: 'A fonte mostrou apenas o acesso de menu.',
  },
  {
    id: 'configuracoes-misturador',
    group: 'Misturador',
    title: 'Configurações',
    objective: 'Parametrizar recursos do misturador.',
    status: 'mapped',
    sourceDetail: 'A fonte mostrou apenas o acesso de menu.',
  },
  {
    id: 'apontamento',
    group: 'Agricultura',
    title: 'Apontamento agrícola',
    objective: 'Registrar uma operação agrícola e os recursos associados.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'area', label: 'Área', type: 'select', required: true, options: ['Talhão 01', 'Talhão 02', 'Pasto Norte'] },
      { id: 'operacao', label: 'Operação', required: true },
      { id: 'atividade', label: 'Atividade', required: true },
      { id: 'area-total', label: 'Área total', type: 'number', required: true },
      { id: 'area-utilizada', label: 'Área utilizada', type: 'number', required: true },
      { id: 'armazem-insumo', label: 'Armazém de insumo', type: 'select', options: ['Armazém A', 'Depósito B'] },
      { id: 'armazem-producao', label: 'Armazém de produção', type: 'select', required: true, options: ['Armazém A', 'Depósito B'] },
    ],
    sections: ['Insumos', 'Abastecimentos', 'Máquinas / Implementos', 'Mão de obra / Serviços', 'Ocorrências', 'Produção'],
    primaryAction: 'Salvar apontamento',
  },
  {
    id: 'marcacao',
    group: 'Agricultura',
    title: 'Marcação',
    objective: 'Acessar e registrar marcações agrícolas.',
    status: 'mapped',
    primaryAction: 'Nova marcação',
    sourceDetail: 'Os campos internos não foram exibidos.',
  },
  {
    id: 'colheita-frutas',
    group: 'Agricultura',
    title: 'Colheita de frutas',
    objective: 'Registrar motorista, veículo e caixas da colheita.',
    status: 'ready',
    fields: [
      { id: 'placa', label: 'Placa', required: true },
      { id: 'motorista', label: 'Motorista', required: true },
      { id: 'cpf', label: 'CPF do motorista', required: true },
      { id: 'caixas', label: 'Caixas (kg)', type: 'number', required: true },
    ],
    sections: ['Caixas da colheita'],
    primaryAction: 'Registrar colheita',
  },
  {
    id: 'rebanho-inicial',
    group: 'Pecuária',
    title: 'Rebanho inicial',
    objective: 'Estabelecer a composição inicial do rebanho.',
    status: 'mapped',
    primaryAction: 'Cadastrar rebanho',
    sourceDetail: 'Os campos internos não foram exibidos.',
  },
  {
    id: 'conexao-aparelhos-pecuaria',
    group: 'Pecuária',
    title: 'Conexão de aparelhos',
    objective: 'Preparar balança e leitor RFID para as rotinas pecuárias.',
    status: 'hardware',
    capabilities: ['Bluetooth', 'Localização', 'Balança', 'RFID'],
    primaryAction: 'Buscar dispositivos',
  },
  {
    id: 'lote-animais',
    group: 'Pecuária',
    title: 'Lote de animais',
    objective: 'Criar um lote em fluxo de múltiplas etapas.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'especie', label: 'Espécie', type: 'select', required: true, options: ['Bovino', 'Bubalino', 'Ovino'] },
      { id: 'descricao', label: 'Descrição', required: true },
      { id: 'categoria', label: 'Categoria', type: 'select', required: true, options: ['Bezerro', 'Novilha', 'Vaca', 'Boi'] },
    ],
    primaryAction: 'Próximo passo',
  },
  {
    id: 'registrar-animal',
    group: 'Pecuária',
    title: 'Registrar animal',
    objective: 'Cadastrar um animal individualmente.',
    status: 'ready',
    fields: [
      { id: 'categoria', label: 'Categoria', required: true },
      { id: 'raca', label: 'Raça', required: true },
      { id: 'nascimento', label: 'Data de nascimento', type: 'date', required: true },
      { id: 'peso', label: 'Peso (kg)', type: 'number', required: true },
      { id: 'preco-kg', label: 'Preço do kg vivo', type: 'number' },
    ],
    primaryAction: 'Registrar animal',
  },
  {
    id: 'pesagem',
    group: 'Pecuária',
    title: 'Pesagens',
    objective: 'Consultar e registrar pesagens do rebanho.',
    status: 'ready',
    existingRoute: '/fazendas/campo/pesagem',
  },
  {
    id: 'transferencia-animal',
    group: 'Pecuária',
    title: 'Transferência animal / lote',
    objective: 'Mover um animal para outro lote com identificação por brinco, RFID ou câmera.',
    status: 'hardware',
    fields: [
      { id: 'identificacao', label: 'Identificação animal', required: true, placeholder: 'Brinco ou ID' },
      responsavel,
      { id: 'lote-atual', label: 'Lote atual', required: true },
      { id: 'novo-lote', label: 'Novo lote', required: true },
    ],
    capabilities: ['Balança', 'RFID', 'Scanner SISBOV'],
    primaryAction: 'Salvar transferência',
  },
  {
    id: 'scanner-sisbov',
    group: 'Pecuária',
    title: 'Scanner SISBOV',
    objective: 'Capturar a identificação do animal usando a câmera.',
    status: 'hardware',
    capabilities: ['Câmera', 'Área de enquadramento', 'Reiniciar leitura'],
    primaryAction: 'Abrir câmera',
  },
  {
    id: 'transferencia-lote-area',
    group: 'Pecuária',
    title: 'Transferência lote / área',
    objective: 'Alterar a localização de um lote entre área e módulo.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'lote', label: 'Lote', required: true },
      { id: 'local-atual', label: 'Área / módulo atual', required: true },
      { id: 'area', label: 'Nova área', required: true },
      { id: 'modulo', label: 'Novo módulo', required: true },
    ],
    primaryAction: 'Salvar transferência',
  },
  {
    id: 'nascimentos',
    group: 'Pecuária',
    title: 'Nascimentos',
    objective: 'Registrar nascimento de animais.',
    status: 'ready',
    existingRoute: '/fazendas/campo/ciclo',
  },
  {
    id: 'mortes',
    group: 'Pecuária',
    title: 'Mortes',
    objective: 'Consultar e registrar mortes do rebanho.',
    status: 'ready',
    existingRoute: '/fazendas/campo/ciclo',
  },
  {
    id: 'perdas',
    group: 'Pecuária',
    title: 'Perdas',
    objective: 'Registrar perdas após identificar o animal.',
    status: 'hardware',
    fields: [{ id: 'identificacao', label: 'Identificação animal', required: true, placeholder: 'Brinco ou ID' }],
    capabilities: ['Balança', 'RFID', 'Scanner SISBOV'],
    primaryAction: 'Buscar animal',
  },
  {
    id: 'compras-animais',
    group: 'Pecuária',
    title: 'Compra de animais',
    objective: 'Consultar e registrar compras de animais.',
    status: 'mapped',
    primaryAction: 'Nova compra',
    emptyLabel: 'Nenhuma compra de animais registrada.',
    sourceDetail: 'O formulário de compra não foi aberto na gravação.',
  },
  {
    id: 'vendas',
    group: 'Pecuária',
    title: 'Vendas',
    objective: 'Registrar vendas de animais com documentos e frete.',
    status: 'ready',
    existingRoute: '/fazendas/campo/venda',
  },
  {
    id: 'nutricoes',
    group: 'Pecuária',
    title: 'Nutrições',
    objective: 'Registrar produtos, quantidade, área, módulo e cocho.',
    status: 'ready',
    existingRoute: '/fazendas/campo/arracoamento',
  },
  {
    id: 'sanitario',
    group: 'Pecuária',
    title: 'Sanitário',
    objective: 'Criar um manejo sanitário por responsável e lote.',
    status: 'ready',
    fields: [responsavel, { id: 'lote', label: 'Lote', required: true }],
    primaryAction: 'Próximo passo',
  },
  {
    id: 'desmama',
    group: 'Pecuária',
    title: 'Desmama',
    objective: 'Registrar desmama e identificar vacas paridas.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'tipo', label: 'Tipo', required: true },
      { id: 'lote', label: 'Lote', required: true },
      { id: 'identificacao', label: 'Identificação das vacas paridas', required: true },
    ],
    primaryAction: 'Salvar desmama',
  },
  {
    id: 'apartacao',
    group: 'Pecuária',
    title: 'Apartação',
    objective: 'Executar e registrar a apartação do rebanho.',
    status: 'mapped',
    primaryAction: 'Iniciar apartação',
    sourceDetail: 'Os campos internos não foram exibidos.',
  },
  {
    id: 'localizar-animal',
    group: 'Pecuária',
    title: 'Localizar animal',
    objective: 'Localizar um animal por brinco, ID, RFID ou câmera.',
    status: 'hardware',
    fields: [{ id: 'identificacao', label: 'Identificação animal', required: true, placeholder: 'Brinco ou ID' }],
    capabilities: ['RFID', 'Scanner SISBOV'],
    primaryAction: 'Buscar animal',
  },
  {
    id: 'pastagens',
    group: 'Pecuária',
    title: 'Pastagens',
    objective: 'Registrar recursos e serviços aplicados à pastagem.',
    status: 'ready',
    fields: [
      responsavel,
      { id: 'armazem-insumos', label: 'Armazém de insumos', required: true },
      { id: 'armazem-producao', label: 'Armazém de produção', required: true },
    ],
    sections: ['Insumos', 'Abastecimentos', 'Máquinas / Equipamentos'],
    primaryAction: 'Salvar pastagem',
  },
  ...[
    ['estacao-monta', 'Estação de monta', 'Gerenciar períodos e ciclos de reprodução.'],
    ['lotes-reproducao', 'Lotes / reprodução', 'Organizar lotes vinculados ao processo reprodutivo.'],
    ['material-reprodutivo', 'Touros / sêmen / embrião', 'Gerenciar material e recursos reprodutivos.'],
    ['protocolos-estacao', 'Protocolos / estação', 'Gerenciar protocolos associados à estação reprodutiva.'],
    ['monta-natural', 'Monta natural', 'Registrar operações de monta natural.'],
    ['diagnostico-gestacao', 'Diagnóstico de gestação', 'Registrar e consultar diagnósticos de gestação.'],
  ].map(([id, title, objective]) => ({
    id,
    group: 'Reprodução',
    title,
    objective,
    status: 'mapped' as const,
    primaryAction: `Abrir ${title.toLocaleLowerCase('pt-BR')}`,
    sourceDetail: 'A fonte mostrou apenas o acesso de menu.',
  })),
  {
    id: 'abastecimentos',
    group: 'Gestão de frota',
    title: 'Abastecimentos',
    objective: 'Consultar e registrar abastecimentos da frota.',
    status: 'mapped',
    primaryAction: 'Novo abastecimento',
    emptyLabel: 'Nenhum abastecimento registrado.',
    sourceDetail: 'O formulário interno não foi exibido.',
  },
  {
    id: 'manutencao-frota',
    group: 'Gestão de frota',
    title: 'Manutenção',
    objective: 'Controlar manutenções da frota.',
    status: 'mapped',
    primaryAction: 'Nova manutenção',
    sourceDetail: 'Os campos internos não foram exibidos.',
  },
  {
    id: 'minhas-os',
    group: 'Ordem de serviço',
    title: 'Minhas OS',
    objective: 'Consultar ordens de serviço vinculadas ao funcionário e à fazenda.',
    status: 'mapped',
    emptyLabel: 'Nenhuma ordem de serviço atribuída.',
    sourceDetail: 'A listagem e o formulário interno não foram percorridos.',
  },
  {
    id: 'sincronizacao',
    group: 'Sincronização',
    title: 'Sincronização de dados',
    objective: 'Enviar a fila local para a nuvem após operação offline.',
    status: 'ready',
    existingRoute: '/fazendas/mais/sync',
    capabilities: ['Rebanho', 'Lotes', 'Pesagem', 'Mortes'],
  },
]

export const FEATURE_BY_ID: Record<string, FeatureDefinition> = Object.fromEntries(
  [...ADMIN_FEATURES, ...OPERATIONAL_FEATURES].map((feature) => [feature.id, feature]),
)

export function groupFeatures(features: FeatureDefinition[]) {
  return features.reduce<Record<string, FeatureDefinition[]>>((groups, feature) => {
    groups[feature.group] = [...(groups[feature.group] ?? []), feature]
    return groups
  }, {})
}
