import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrototypeRecordStatus { active, completed, scheduled }

class PrototypeRecord {
  const PrototypeRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.details = const {},
  });

  final String id;
  final String title;
  final String description;
  final PrototypeRecordStatus status;
  final Map<String, String> details;
}

const initialPrototypeRecords = <String, List<PrototypeRecord>>{
  'saldo-estoque': [
    PrototypeRecord(
      id: 'saldo-1',
      title: 'Ração Engorda',
      description: 'Armazém A · 12.400 kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Armazém A',
        'Saldo': '12.400 kg',
        'Reserva': '1.000 kg',
        'Atualização': 'Hoje, 08:42',
      },
    ),
    PrototypeRecord(
      id: 'saldo-2',
      title: 'Sal Mineral',
      description: 'Armazém A · 3.200 kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Armazém A',
        'Saldo': '3.200 kg',
        'Reserva': '240 kg',
        'Atualização': 'Ontem, 17:18',
      },
    ),
    PrototypeRecord(
      id: 'saldo-3',
      title: 'Vacina Aftosa',
      description: 'Farmácia · 540 doses',
      status: PrototypeRecordStatus.active,
      details: {
        'Local': 'Farmácia',
        'Saldo': '540 doses',
        'Lote': 'VA-2026-08',
        'Validade': '30/11/2026',
      },
    ),
  ],
  'processamentos': [
    PrototypeRecord(
      id: 'processo-1',
      title: 'Transferência do Lote 42',
      description: 'Pendente · aguardando sincronização',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Tipo': 'Transferência',
        'Lote': 'Lote 42',
        'Responsável': 'João Oliveira',
        'Estado': 'Aguardando sincronização',
      },
    ),
    PrototypeRecord(
      id: 'processo-2',
      title: 'Pesagem do Lote 19',
      description: 'Concluída · hoje às 08:03',
      status: PrototypeRecordStatus.completed,
      details: {
        'Tipo': 'Pesagem',
        'Lote': 'Lote 19',
        'Responsável': 'Maria Souza',
        'Estado': 'Concluída',
      },
    ),
  ],
  'configuracoes-misturador': [
    PrototypeRecord(
      id: 'config-mist-1',
      title: 'Configuração Fazenda São Pedro',
      description: 'kg · tolerância 2% · alertas ativados',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Unidade': 'kg',
        'Tolerância': '2%',
        'Alertas': 'Ativados',
      },
    ),
  ],
  'marcacao': [
    PrototypeRecord(
      id: 'marcacao-1',
      title: 'Erosão na curva de nível',
      description: 'Ponto de atenção · Talhão 02',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Área': 'Talhão 02',
        'Tipo': 'Ponto de atenção',
        'Referência': 'Próximo à porteira leste',
      },
    ),
  ],
  'compras-animais': [
    PrototypeRecord(
      id: 'compra-animal-1',
      title: 'Fazenda Boa Vista',
      description: '36 novilhas · 12/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Espécie': 'Bovino',
        'Categoria': 'Novilha',
        'Quantidade': '36',
        'Documento': 'NF 008421',
        // fidelidade-campos (onda 5): o bloco financeiro required de
        // `/movement-purchases`, que a consulta passou a documentar.
        'Forma de pagamento': 'Parcelado',
        'Total de produtos (R\$)': '198.400,00',
        'Frete (R\$)': '4.200,00',
        'Outros valores (R\$)': '0,00',
        'Desconto (R\$)': '2.600,00',
        'Valor unitário por animal (R\$)': '5.511,11',
        'Vendedor': 'Corretora Campo Alto',
        'Itens da compra': '2 item(ns)',
        'Parcelas': '3 item(ns)',
      },
    ),
  ],
  'apartacao': [
    PrototypeRecord(
      id: 'apartacao-1',
      title: 'Lote Recria 02',
      description: 'Peso · Lote Engorda 05 · 28 animais',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Critério': 'Peso',
        'Destino': 'Lote Engorda 05',
        'Quantidade': '28',
        'Data': '15/08/2026',
      },
    ),
  ],
  // banco-real (onda 2): dado sintético inspirado nas categorias e na ordem de
  // grandeza reais de `products` (543.983 linhas no dump gbcerne) — nenhum
  // registro copiado do banco de produção. Ver
  // docs/ajustes-banco-real/02-oportunidades-banco-real.md, seção 2.6.
  'consulta-produtos': [
    PrototypeRecord(
      id: 'produto-1',
      title: 'Ração Engorda 18%',
      description: 'Nutrição · kg · custo médio R\$ 2,38/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Nutrição',
        'Unidade': 'kg',
        'Custo médio': 'R\$ 2,38',
        'Preço de mercado': 'R\$ 2,55',
        'Estoque mínimo': '2.000 kg',
      },
    ),
    PrototypeRecord(
      id: 'produto-2',
      title: 'Sal Mineral Proteinado',
      description: 'Nutrição · kg · custo médio R\$ 4,90/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Nutrição',
        'Unidade': 'kg',
        'Custo médio': 'R\$ 4,90',
        'Preço de mercado': 'R\$ 5,20',
        'Estoque mínimo': '500 kg',
      },
    ),
    PrototypeRecord(
      id: 'produto-3',
      title: 'Vacina Aftosa',
      description: 'Sanitário · dose · custo médio R\$ 3,10/dose',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Sanitário',
        'Unidade': 'dose',
        'Custo médio': 'R\$ 3,10',
        'Preço de mercado': 'R\$ 3,40',
        'Estoque mínimo': '200 doses',
      },
    ),
    PrototypeRecord(
      id: 'produto-4',
      title: 'Vermífugo Injetável',
      description: 'Sanitário · frasco 500ml · custo médio R\$ 68,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Sanitário',
        'Unidade': 'frasco',
        'Custo médio': 'R\$ 68,00',
        'Preço de mercado': 'R\$ 74,90',
        'Estoque mínimo': '20 frascos',
      },
    ),
    PrototypeRecord(
      id: 'produto-5',
      title: 'Diesel S10',
      description: 'Combustível · L · custo médio R\$ 6,12/L',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Combustível',
        'Unidade': 'L',
        'Custo médio': 'R\$ 6,12',
        'Preço de mercado': 'R\$ 6,35',
        'Estoque mínimo': '1.000 L',
      },
    ),
    PrototypeRecord(
      id: 'produto-6',
      title: 'Semente de Braquiária',
      description: 'Agrícola · kg · custo médio R\$ 18,50/kg',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Agrícola',
        'Unidade': 'kg',
        'Custo médio': 'R\$ 18,50',
        'Preço de mercado': 'R\$ 21,00',
        'Estoque mínimo': '300 kg',
      },
    ),
    PrototypeRecord(
      id: 'produto-7',
      title: 'Fertilizante NPK 20-05-20',
      description: 'Agrícola · saca 50 kg · custo médio R\$ 189,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Agrícola',
        'Unidade': 'saca',
        'Custo médio': 'R\$ 189,00',
        'Preço de mercado': 'R\$ 205,00',
        'Estoque mínimo': '100 sacas',
      },
    ),
    PrototypeRecord(
      id: 'produto-8',
      title: 'Filtro de óleo — trator',
      description: 'Peça de equipamento · unidade · custo médio R\$ 42,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Categoria': 'Peça de equipamento',
        'Unidade': 'unidade',
        'Custo médio': 'R\$ 42,00',
        'Preço de mercado': 'R\$ 49,90',
        'Estoque mínimo': '10 unidades',
      },
    ),
  ],
  // banco-real (correção de demonstrabilidade): estas 8 features viraram
  // `readOnly: true` nas Ondas 1/2 (ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md)
  // mas não tinham amostra semeada — como o app não cria mais registros para
  // elas, a lista ficava vazia para sempre. Dados sintéticos, coerentes com
  // os campos do catálogo e com os mocks já usados no módulo (nenhum copiado
  // de banco de produção).
  'cadastrar-area': [
    PrototypeRecord(
      id: 'area-1',
      title: 'Talhão 03',
      description: 'Agricultura · 42 ha',
      status: PrototypeRecordStatus.active,
      details: {
        'Tipo de uso': 'Agricultura',
        'Área total': '42 ha',
        'Área produtiva': '38 ha',
        'Área não produtiva': '4 ha',
        'Unidade': 'ha',
        'Localização': 'Setor Norte',
        'Cultura / cobertura': 'Braquiária',
        // fidelidade-campos (onda 3): campos de `/areas` que a consulta
        // passou a documentar — a amostra mostra o que a tela agora conhece.
        'Cor no mapa': 'Verde',
        'Matrícula': '18.472',
        'Atividade': 'Agricultura',
        'Proprietário': 'Fazenda Cerne S/A',
        'Ativa': 'Sim',
        'Infraestrutura': '3 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'area-2',
      title: 'Piquete 07',
      description: 'Pecuária · 18 ha',
      status: PrototypeRecordStatus.active,
      details: {
        'Tipo de uso': 'Pecuária',
        'Área total': '18 ha',
        'Carga animal (UA/ha)': '1,8',
        'Unidade': 'ha',
        'Localização': 'Setor Leste',
        'Cor no mapa': 'Amarelo',
        'Atividade': 'Pecuária',
        'Área de recreio': 'Não',
        'Ativa': 'Sim',
      },
    ),
  ],
  'formulacoes': [
    PrototypeRecord(
      id: 'formulacao-1',
      title: 'Ração Engorda 18%',
      description: '1.000 kg · R\$ 2.380,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Ativo': 'Sim',
        'Quantidade de referência': '1.000',
        'Unidade de medida': 'kg',
        'Tipo': 'Formulação',
        'Custo por kg (R\$)': '2,38',
        'Custo estimado (R\$)': '2.380,00',
        'Data da formulação': '2026-08-11',
        'Unidade da matéria-prima': 'kg',
        'Objetivo': 'Ganho de peso na terminação',
      },
    ),
    PrototypeRecord(
      id: 'formulacao-2',
      title: 'Sal Mineral Proteinado',
      description: '500 kg · R\$ 2.450,00',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Ativo': 'Sim',
        'Quantidade de referência': '500',
        'Unidade de medida': 'kg',
        'Tipo': 'Estoque',
        'Custo por kg (R\$)': '4,90',
        'Custo estimado (R\$)': '2.450,00',
      },
    ),
  ],
  'batidas': [
    PrototypeRecord(
      id: 'batida-1',
      title: 'Ração Engorda 18%',
      description: '1.000 kg previsto · 985 kg realizado',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Tipo': 'Formulação',
        'Armazém de destino': 'Armazém A',
        'Quantidade prevista': '1.000',
        'Quantidade realizada': '985',
        'Unidade de medida': 'kg',
        // fidelidade-campos (onda 5): os três required de `/diet-beats`.
        'Dieta': 'Dieta Terminação',
        'Vagão / equipamento': 'Vagão Misturador 01',
        'Data da batida': '2026-08-30',
        'Itens da batida': '5 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'batida-2',
      title: 'Sal Mineral Proteinado',
      description: '500 kg previsto · 500 kg realizado',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Tipo': 'Estoque',
        'Armazém de destino': 'Depósito B',
        'Quantidade prevista': '500',
        'Quantidade realizada': '500',
        'Unidade de medida': 'kg',
      },
    ),
  ],
  'lote-animais': [
    PrototypeRecord(
      id: 'lote-animais-1',
      title: 'Lote Recria 02',
      description: 'Bovino · Novilha',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Espécie': 'Bovino',
        'Categoria': 'Novilha',
        'Data de formação': '2026-07-14',
        'Parâmetro de peso': 'Médio',
        'Animais do lote': '84 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'lote-animais-2',
      title: 'Lote Engorda 05',
      description: 'Bovino · Boi',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Espécie': 'Bovino',
        'Categoria': 'Boi',
        'Data de formação': '2026-08-02',
        'Curral de confinamento': 'Curral 02',
        'Parâmetro de peso': 'Pesado',
        'Animais do lote': '126 item(ns)',
      },
    ),
  ],
  'estacao-monta': [
    PrototypeRecord(
      id: 'estacao-monta-1',
      title: 'Estação Primavera 2026',
      description: 'IATF · 01/09/2026 a 30/11/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Código': 'EM-2026-01',
        'Data do lançamento': '2026-08-20',
        'Data de início': '01/09/2026',
        'Data de término': '30/11/2026',
        'Método principal': 'IATF',
      },
    ),
  ],
  // fidelidade-campos (onda 4): `lotes-reproducao` volta como consulta
  // somente leitura e, como as demais `readOnly`, precisa de amostra semeada
  // — o app não cria registro para ela, então sem isto a lista ficaria vazia
  // para sempre. Dado sintético, coerente com os mocks do módulo.
  'lotes-reproducao': [
    PrototypeRecord(
      id: 'lotes-reproducao-1',
      title: 'Lote Matrizes 01',
      description: 'Matrizes · Estação Primavera 2026 · 2026-08-22',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Código': 'LR-2026-014',
        'Data do vínculo': '2026-08-22',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote': 'Lote Matrizes 01',
        'Finalidade': 'Matrizes',
        'Quantidade de animais': '212',
      },
    ),
    PrototypeRecord(
      id: 'lotes-reproducao-2',
      title: 'Lote Receptoras 03',
      description: 'Receptoras · Estação Primavera 2026 · 2026-08-25',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Carlos Dias',
        'Código': 'LR-2026-015',
        'Data do vínculo': '2026-08-25',
        'Estação de monta': 'Estação Primavera 2026',
        'Lote': 'Lote Receptoras 03',
        'Finalidade': 'Receptoras',
        'Quantidade de animais': '64',
      },
    ),
  ],
  'material-reprodutivo': [
    PrototypeRecord(
      id: 'material-reprodutivo-1',
      title: 'SEM-4471',
      description: 'Sêmen · Nelore · 120 doses',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Tipo de recurso': 'Sêmen',
        'Raça': 'Nelore',
        'Fornecedor / origem': 'Central de Genética Boa Vista',
        'Quantidade disponível': '120',
        'Código': 'BSS-2026-007',
        'Data do lançamento': '2026-08-18',
        'Descrição': 'Partida de sêmen Nelore para a estação de primavera',
        'Estação de monta': 'Estação Primavera 2026',
        'Produtos (armazém e sêmen)': '2 item(ns)',
      },
    ),
    PrototypeRecord(
      id: 'material-reprodutivo-2',
      title: 'TOU-018',
      description: 'Touro · Angus · 1 unidade',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Tipo de recurso': 'Touro',
        'Raça': 'Angus',
        'Fornecedor / origem': 'Fazenda São Pedro',
        'Quantidade disponível': '1',
      },
    ),
  ],
  'protocolos-estacao': [
    PrototypeRecord(
      id: 'protocolo-estacao-1',
      title: 'Protocolo IATF Primavera',
      description: 'IATF · Estação Primavera 2026 · 01/09/2026',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'Maria Souza',
        'Estação de monta': 'Estação Primavera 2026',
        'Tipo': 'IATF',
        'Data de início': '01/09/2026',
        'Código': 'PS-2026-003',
        'Descrição': 'Protocolo de 11 dias com implante e IATF no D11',
        'Etapas do protocolo': '6 item(ns)',
      },
    ),
  ],
  // banco-real (Onda 1): "Vendas" subiu para decisão ADM — cliente, valor e
  // condição de pagamento são decisão comercial (ver
  // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1). A tela não declara
  // `fields` (mesmo padrão de `minhas-os`), então a amostra usa apenas
  // `details` livres.
  'vendas': [
    PrototypeRecord(
      id: 'venda-1',
      title: 'Frigorífico Vale Verde',
      description: '42 bois · R\$ 210.000,00 · 10/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Cliente': 'Frigorífico Vale Verde',
        'Quantidade': '42 bois',
        'Valor total': 'R\$ 210.000,00',
        'Condição de pagamento': '28 dias',
        'Data': '10/08/2026',
      },
    ),
    PrototypeRecord(
      id: 'venda-2',
      title: 'Pecuária Santa Fé',
      description: '15 novilhas · R\$ 67.500,00 · 22/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Cliente': 'Pecuária Santa Fé',
        'Quantidade': '15 novilhas',
        'Valor total': 'R\$ 67.500,00',
        'Condição de pagamento': 'À vista',
        'Data': '22/08/2026',
      },
    ),
  ],
  'minhas-os': [
    PrototypeRecord(
      id: 'os-1',
      title: 'OS #1048 · Cerca do Talhão 02',
      description: 'Em andamento · prioridade alta',
      status: PrototypeRecordStatus.active,
      details: {
        'Responsável': 'João Oliveira',
        'Fazenda': 'Fazenda São Pedro',
        'Prioridade': 'Alta',
        'Prazo': '18/08/2026',
      },
    ),
    PrototypeRecord(
      id: 'os-2',
      title: 'OS #1039 · Inspeção do bebedouro',
      description: 'Programada · prioridade média',
      status: PrototypeRecordStatus.scheduled,
      details: {
        'Responsável': 'João Oliveira',
        'Fazenda': 'Fazenda São Pedro',
        'Prioridade': 'Média',
        'Prazo': '20/08/2026',
      },
    ),
  ],
};

class PrototypeRecordsState {
  const PrototypeRecordsState({
    this.recordsByFeature = const {},
    this.nextId = 100,
  });

  final Map<String, List<PrototypeRecord>> recordsByFeature;
  final int nextId;

  List<PrototypeRecord> recordsFor(String featureId) =>
      recordsByFeature[featureId] ?? const [];

  PrototypeRecordsState copyWith({
    Map<String, List<PrototypeRecord>>? recordsByFeature,
    int? nextId,
  }) {
    return PrototypeRecordsState(
      recordsByFeature: recordsByFeature ?? this.recordsByFeature,
      nextId: nextId ?? this.nextId,
    );
  }
}

final prototypeRecordsProvider =
    NotifierProvider<PrototypeRecordsNotifier, PrototypeRecordsState>(
      PrototypeRecordsNotifier.new,
    );

class PrototypeRecordsNotifier extends Notifier<PrototypeRecordsState> {
  @override
  PrototypeRecordsState build() =>
      const PrototypeRecordsState(recordsByFeature: initialPrototypeRecords);

  PrototypeRecord addRecord({
    required String featureId,
    required String title,
    required String description,
    required PrototypeRecordStatus status,
    Map<String, String> details = const {},
  }) {
    final created = PrototypeRecord(
      id: '$featureId-${state.nextId}',
      title: title,
      description: description,
      status: status,
      details: Map.unmodifiable(details),
    );
    final current = state.recordsFor(featureId);
    state = state.copyWith(
      nextId: state.nextId + 1,
      recordsByFeature: {
        ...state.recordsByFeature,
        featureId: [created, ...current],
      },
    );
    return created;
  }

  void seed(Map<String, List<PrototypeRecord>> recordsByFeature) {
    state = state.copyWith(
      recordsByFeature: {
        for (final entry in recordsByFeature.entries)
          entry.key: List.unmodifiable(entry.value),
      },
    );
  }

  void clear() => state = const PrototypeRecordsState();
}
