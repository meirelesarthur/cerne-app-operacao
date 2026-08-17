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
  'carga': [
    PrototypeRecord(
      id: 'carga-1',
      title: 'Ração de engorda 18%',
      description: '1.000 kg · Misturador 01',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Origem': 'Armazém A',
        'Equipamento': 'Misturador 01',
        'Quantidade': '1.000 kg',
      },
    ),
  ],
  'descarga': [
    PrototypeRecord(
      id: 'descarga-1',
      title: 'Curral 7 · Cocho A',
      description: 'Ração de engorda · 980 kg',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'Carlos Dias',
        'Produto': 'Ração de engorda',
        'Destino': 'Curral 7 · Cocho A',
        'Quantidade': '980 kg',
      },
    ),
  ],
  'nota-cocho': [
    PrototypeRecord(
      id: 'cocho-1',
      title: 'Lote 42 · Curral 7',
      description: '2 — Adequado · 16/08/2026',
      status: PrototypeRecordStatus.completed,
      details: {
        'Responsável': 'João Oliveira',
        'Data': '16/08/2026',
        'Nota': '2 — Adequado',
        'Observação': 'Consumo dentro do esperado',
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
