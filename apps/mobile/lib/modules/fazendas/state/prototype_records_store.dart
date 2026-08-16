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
  PrototypeRecordsState build() => const PrototypeRecordsState();

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
